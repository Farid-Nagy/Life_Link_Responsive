import 'package:flutter/material.dart';
import 'package:lifelink/core/theme/app_colors.dart';
import 'package:lifelink/core/responsive/responsive_layout.dart';
import 'package:lifelink/features/desktop/screens/desktop_service_pages.dart';
import 'package:lifelink/features/mobile/screens/pay_now.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lifelink/core/services/quantity_parser.dart';

const Color primaryColor = AppColors.primary;

class DeliveryPage extends StatefulWidget {
  const DeliveryPage({super.key});

  @override
  State<DeliveryPage> createState() => _DeliveryPageState();
}

class _DeliveryPageState extends State<DeliveryPage> {
  String? selectedBlood;
  String? selectedHospital;
  int count = 1;
  int availableQty = 0;
  DateTime? receiveDate;

  final TextEditingController hospitalNameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  final double deliveryFee = 50.0;

  // تخزين آخر البيانات المستلمة
  Map<String, Map<String, dynamic>>? lastBloodData;

  Stream<Map<String, Map<String, dynamic>>> getBloodStream() {
    return FirebaseFirestore.instance
        .collection('blood_inventory')
        .snapshots()
        .map((snapshot) {
      Map<String, Map<String, dynamic>> tempData = {};
      for (var doc in snapshot.docs) {
        tempData[doc.id] =
            Map<String, dynamic>.from(doc['hospitals'] ?? {});
      }
      return tempData;
    });
  }

  void pickDate() async {
    final now = DateUtils.dateOnly(DateTime.now());
    final date = await showDatePicker(
      context: context,
      initialDate: receiveDate ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      helpText: 'Select date',
      cancelText: 'Cancel',
      confirmText: 'Select',
    );
    if (date != null) setState(() => receiveDate = date);
  }

  // دالة لتحديث البيانات والمتغيرات المرتبطة
  void updateBloodData(Map<String, Map<String, dynamic>> newData) {
    lastBloodData = newData;
    
    if (selectedBlood != null) {
      final availableHospitals = newData[selectedBlood]!.entries
          .where((entry) {
            final val = parseInventoryQuantity(entry.value);
            return val > 0;
          })
          .toList();

      // إذا المستشفى المختارة لم تعد موجودة أو كميتها صفر
      if (selectedHospital != null &&
          !availableHospitals.any((entry) => entry.key == selectedHospital)) {
        selectedHospital = null;
        count = 1;
        availableQty = 0;
      }

      // تحديث availableQty إذا هناك مستشفى مختارة
      if (selectedHospital != null) {
        availableQty = parseInventoryQuantity(
          newData[selectedBlood]![selectedHospital],
        );
        if (count > availableQty) count = availableQty;
      }
    }
  }

  @override
  void dispose() {
    hospitalNameController.dispose();
    addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final showDeliveryFee = addressController.text.isNotEmpty;
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width >= 800;
    final isDesktop = width >= 1100;

    BoxDecoration boxDecoration({bool selected = false}) => BoxDecoration(
          color: selected ? primaryColor : AppColors.surface,
          borderRadius: BorderRadius.circular(isDesktop ? 18 : 14),
          border: Border.all(
            color: selected ? primaryColor : AppColors.borderStrong,
            width: selected ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: selected
                  ? primaryColor.withOpacity(0.16)
                  : AppColors.shadowSoft,
              blurRadius: isDesktop ? 12 : 4,
              offset: const Offset(0, 4),
            ),
          ],
        );

    return Scaffold(
      backgroundColor: isDesktop ? AppColors.background : null,
      appBar: AppBar(
        backgroundColor: primaryColor,
        centerTitle: true,
        title: const Text(
          "Delivery Details",
          style: TextStyle(
            fontFamily: "Cairo",
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: StreamBuilder<Map<String, Map<String, dynamic>>>(
        stream: getBloodStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final bloodData = snapshot.data!;
          
          // تحديث البيانات عند وصول بيانات جديدة
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (lastBloodData != bloodData) {
              updateBloodData(bloodData);
            }
          });

          final content = Column(
            children: [

                /// BLOOD TYPES GRID
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: bloodData.keys.length,
                  gridDelegate:
                      SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: isDesktop ? 285 : (isWide ? 270 : 190),
                    crossAxisSpacing: isDesktop ? 14 : 10,
                    mainAxisSpacing: isDesktop ? 14 : 10,
                    mainAxisExtent: isDesktop ? 108 : 92,
                  ),
                  itemBuilder: (context, index) {
                    final type = bloodData.keys.elementAt(index);

                    int totalQty = 0;
                    bloodData[type]!.forEach((key, value) {
                      totalQty += parseInventoryQuantity(value);
                    });

                    final isSelected = selectedBlood == type;

                    return InkWell(
                      onTap: () {
                        setState(() {
                          selectedBlood = type;
                          selectedHospital = null;
                          availableQty = 0;
                          count = 1;
                        });
                      },
                      child: Container(
                        decoration: boxDecoration(selected: isSelected),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              type,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Qty: $totalQty',
                              style: TextStyle(
                                fontSize: 12,
                                color: isSelected
                                    ? Colors.white70
                                    : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                SizedBox(height: isDesktop ? 26 : 20),

                /// HOSPITAL + COUNTER
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Container(
                        decoration: boxDecoration(),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: SizedBox(
                          height: isDesktop ? 56 : null,
                          child: DropdownButtonFormField<String>(
                          key: ValueKey('${selectedBlood}_${bloodData.hashCode}'), // مفتاح ديناميكي لإجبار إعادة البناء
                          value: selectedHospital,
                          hint: const Text('Hospital'),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                          ),
                          items: selectedBlood == null
                              ? <DropdownMenuItem<String>>[]
                              : bloodData[selectedBlood]!.entries
                                  .where((entry) {
                                    return parseInventoryQuantity(entry.value) > 0;
                                  })
                                  .map((entry) => DropdownMenuItem<String>(
                                        value: entry.key,
                                        child: Text(entry.key),
                                      ))
                                  .toList(),
                          onChanged: selectedBlood == null
                              ? null
                              : (value) {
                                  setState(() {
                                    selectedHospital = value;
                                    availableQty = parseInventoryQuantity(
                                      bloodData[selectedBlood]![selectedHospital],
                                    );
                                    count = availableQty > 0 ? 1 : 0;
                                  });
                                },
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      flex: 2,
                      child: Container(
                        height: isDesktop ? 56 : null,
                        decoration: boxDecoration(),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: Row(
                        children: [
                          Expanded(
                            child: IconButton(
                              tooltip: 'Decrease quantity',
                              onPressed: (count > 1 && selectedHospital != null)
                                  ? () => setState(() => count--)
                                  : null,
                              icon: const Icon(Icons.remove_rounded, color: primaryColor),
                            ),
                          ),
                          Container(
                            constraints: const BoxConstraints(minWidth: 42),
                            alignment: Alignment.center,
                            child: Text(
                              '$count',
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          Expanded(
                            child: IconButton(
                              tooltip: 'Increase quantity',
                              onPressed: selectedHospital != null && availableQty > 0 && count < availableQty
                                  ? () => setState(() => count = (count + 1).clamp(1, availableQty))
                                  : null,
                              icon: const Icon(Icons.add_rounded, color: primaryColor),
                            ),
                          ),
                        ],
                      ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                /// Hospital Name
                Container(
                  height: isDesktop ? 58 : null,
                  decoration: boxDecoration(),
                  child: TextField(
                    controller: hospitalNameController,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                      labelText: 'Hospital Name',
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                /// Address
                Container(
                  height: isDesktop ? 58 : null,
                  decoration: boxDecoration(),
                  child: TextField(
                    controller: addressController,
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                      labelText: 'Delivery Address',
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                /// Date
                InkWell(
                  onTap: pickDate,
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: isDesktop ? 17 : 14),
                    decoration: boxDecoration(),
                    child: Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: AppColors.primarySoft,
                            borderRadius: BorderRadius.circular(11),
                          ),
                          child: const Icon(Icons.event_outlined, color: AppColors.primary, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Receive Date',
                                style: TextStyle(fontSize: 12, color: AppColors.muted, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                receiveDate == null
                                    ? 'Select date'
                                    : '${receiveDate!.day}/${receiveDate!.month}/${receiveDate!.year}',
                                style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                if (showDeliveryFee)
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: isDesktop ? 14 : 12),
                    decoration: boxDecoration(),
                    child: Text(
                      'Delivery Fee: EGP $deliveryFee',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                const SizedBox(height: 20),

                /// NEXT BUTTON
                SizedBox(
                  width: double.infinity,
                  height: isDesktop ? 54 : 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: selectedBlood != null &&
                            selectedHospital != null &&
                            receiveDate != null &&
                            hospitalNameController.text.isNotEmpty &&
                            addressController.text.isNotEmpty
                        ? () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ResponsiveLayout(
                                  mobile: PayNow(
                                    bloodType: selectedBlood!,
                                    hospital: hospitalNameController.text,
                                    quantity: count,
                                    receiveDate: receiveDate!,
                                    orderType: "Delivery",
                                    deliveryAddress: addressController.text,
                                    deliveryFee: deliveryFee,
                                  ),
                                  tablet: DesktopPaymentPage(
                                    bloodType: selectedBlood!,
                                    hospital: hospitalNameController.text,
                                    quantity: count,
                                    receiveDate: receiveDate!,
                                    orderType: "Delivery",
                                    deliveryAddress: addressController.text,
                                    deliveryFee: deliveryFee,
                                  ),
                                  desktop: DesktopPaymentPage(
                                    bloodType: selectedBlood!,
                                    hospital: hospitalNameController.text,
                                    quantity: count,
                                    receiveDate: receiveDate!,
                                    orderType: "Delivery",
                                    deliveryAddress: addressController.text,
                                    deliveryFee: deliveryFee,
                                  ),
                                ),
                              ),
                            );
                          }
                        : null,
                    child: const Text(
                      'Next',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),
              ],
            );

          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              isDesktop ? 30 : 16,
              isDesktop ? 28 : 16,
              isDesktop ? 30 : 16,
              36,
            ),
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isDesktop ? 1180 : 1100,
                ),
                child: content,
              ),
            ),
          );
        },
      ),
    );
  }
}
