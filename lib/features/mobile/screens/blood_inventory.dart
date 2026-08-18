import 'package:flutter/material.dart';
import 'package:lifelink/core/theme/app_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lifelink/internet_service.dart';
import 'package:lifelink/network_wrapper.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BloodInventoryAdminPage extends StatefulWidget {
  const BloodInventoryAdminPage({super.key});

  @override
  State<BloodInventoryAdminPage> createState() =>
      _BloodInventoryAdminPageState();
}

class _BloodInventoryAdminPageState extends State<BloodInventoryAdminPage> {
  final Color mainColor = AppColors.primary;
  String currentPage = "inventory";

  final List<String> bloodTypes = [
    "A+","A-","B+","B-","AB+","AB-","O+","O-",
  ];

  final String collectionName = 'blood_inventory';

  bool _messageVisible = false;

  /// منع تكرار الرسائل
  void showMessage(String text, {Color color = Colors.black}) {
    if (_messageVisible) return;
    _messageVisible = true;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context)
        .showSnackBar(
          SnackBar(
            content: Text(text),
            backgroundColor: color,
            duration: const Duration(seconds: 2),
          ),
        )
        .closed
        .then((_) => _messageVisible = false);
  }

  /// تحديث المخزون
  Future<void> updateStock(String bloodType, String hospital, int qty) async {
    await FirebaseFirestore.instance
        .collection(collectionName)
        .doc(bloodType)
        .set({
      'hospitals': {hospital: qty}
    }, SetOptions(merge: true));
  }

  /// تعديل كمية
  void _showEditDialog(String bloodType, Map<String, dynamic> hospitalsData) {
    String? selectedHospital;
    final TextEditingController quantityController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.edit, color: AppColors.primary),
            SizedBox(width: 8),
            Text("Edit Blood Stock"),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: "Select Hospital",
                border: OutlineInputBorder(),
              ),
              items: hospitalsData.keys.map((hospital) {
                return DropdownMenuItem<String>(
                  value: hospital,
                  child: Text(hospital),
                );
              }).toList(),
              onChanged: (value) => selectedHospital = value,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Number of Bags",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: mainColor,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              if (selectedHospital == null ||
                  quantityController.text.isEmpty) {
                showMessage("Please fill all fields", color: Colors.red);
                return;
              }

              bool hasInternet = await InternetService.hasInternet();
              if (!hasInternet) {
                showMessage("❌ No Internet Connection", color: Colors.red);
                return;
              }

              final int qty = int.tryParse(quantityController.text) ?? 0;
              
              // منع القيم السالبة
              if (qty < 0) {
                showMessage("Quantity cannot be negative!", color: Colors.red);
                return;
              }

              await updateStock(bloodType, selectedHospital!, qty);

              Navigator.pop(context);
              showMessage(
                "$bloodType in $selectedHospital set to $qty bags ✅",
                color: Colors.green,
              );
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  /// إضافة مستشفى
  void _showAddHospitalDialog(String bloodType) {
    final TextEditingController hospitalController = TextEditingController();
    final TextEditingController quantityController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.add, color: AppColors.primary),
            SizedBox(width: 8),
            Text("Add Hospital"),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: hospitalController,
              decoration: const InputDecoration(
                labelText: "Hospital Name",
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.sentences, // Changed to sentences for proper case
              onChanged: (value) {
                // تحويل النص إلى حروف صغيرة أثناء الكتابة
                if (value != value.toLowerCase()) {
                  hospitalController.value = TextEditingValue(
                    text: value.toLowerCase(),
                    selection: TextSelection.collapsed(offset: value.toLowerCase().length),
                  );
                }
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Initial Bags",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: mainColor,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              if (hospitalController.text.isEmpty ||
                  quantityController.text.isEmpty) {
                showMessage("Please fill all fields", color: Colors.red);
                return;
              }

              // تحويل اسم المستشفى إلى حروف صغيرة
              String hospitalName = hospitalController.text.toLowerCase();
              
              final int qty = int.tryParse(quantityController.text) ?? 0;
              
              // منع القيم السالبة
              if (qty < 0) {
                showMessage("Quantity cannot be negative!", color: Colors.red);
                return;
              }

              bool hasInternet = await InternetService.hasInternet();
              if (!hasInternet) {
                showMessage("❌ No Internet Connection", color: Colors.red);
                return;
              }

              final docRef = FirebaseFirestore.instance
                  .collection(collectionName)
                  .doc(bloodType);

              final doc = await docRef.get();

              Map<String, dynamic> hospitalsMap = {};
              if (doc.exists && doc.data() != null) {
                hospitalsMap = Map<String, dynamic>.from(doc['hospitals'] ?? {});
              }

              if (hospitalsMap.containsKey(hospitalName)) {
                showMessage("Hospital already exists", color: Colors.red);
                return;
              }

              hospitalsMap[hospitalName] = qty;

              await docRef.set({'hospitals': hospitalsMap});

              Navigator.pop(context);
              showMessage(
                "$hospitalName added with $qty bags ✅",
                color: Colors.green,
              );
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return NetworkWrapper(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Blood Inventory Management",
            style: TextStyle(
              color: Colors.white,
              fontFamily: "Cairo",
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
          backgroundColor: mainColor,
          iconTheme: const IconThemeData(color: Colors.white),
        ),

        /// Drawer مع زرار Logout مباشر
        drawer: Drawer(
          child: Column(
            children: [
              UserAccountsDrawerHeader(
                decoration: BoxDecoration(color: mainColor),
                accountName: const Text("Admin"),
                accountEmail: const Text("admin@lifelink.com"),
                currentAccountPicture: const CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.admin_panel_settings,
                    color: AppColors.primary,
                    size: 40,
                  ),
                ),
              ),

              ListTile(
                leading: Icon(Icons.admin_panel_settings, color: Colors.grey),
                title: const Text("Admin Home"),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, "admin");
                },
              ),

              ListTile(
                leading: Icon(Icons.list_alt, color: Colors.grey),
                title: const Text("Orders"),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, "adminOrdersScreen");
                },
              ),

              ListTile(
                leading: Icon(Icons.inventory_2, color: mainColor),
                title: Text(
                  "Inventory",
                  style: TextStyle(color: mainColor, fontWeight: FontWeight.bold),
                ),
                onTap: () => Navigator.pop(context),
              ),

              const Spacer(),
              const Divider(),

              /// Logout مباشر بدون تأكيد
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text(
                  "Logout",
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.of(context).pushReplacementNamed("loginScreen");
                },
              ),
            ],
          ),
        ),

        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: bloodTypes.map((type) {
              return StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection(collectionName)
                    .doc(type)
                    .snapshots(),
                builder: (context, snapshot) {
                  Map<String, dynamic> hospitalsData = {};

                  if (snapshot.hasData && snapshot.data!.data() != null) {
                    hospitalsData =
                        Map<String, dynamic>.from(snapshot.data!['hospitals'] ?? {});
                  }

                  int totalBags = hospitalsData.values.fold(
                      0, (sum, val) => sum + (val as int));

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      leading: const Icon(Icons.bloodtype, color: AppColors.primary),
                      title: Text(type, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text("Total bags: $totalBags"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: mainColor,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: hospitalsData.isEmpty
                                ? null
                                : () => _showEditDialog(type, hospitalsData),
                            icon: const Icon(Icons.edit, size: 18),
                            label: const Text("Edit"),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () => _showAddHospitalDialog(type),
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text("Add"),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
