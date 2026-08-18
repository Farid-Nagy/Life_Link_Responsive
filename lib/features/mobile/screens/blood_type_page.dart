import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lifelink/core/responsive/responsive_layout.dart';
import 'package:lifelink/core/theme/app_colors.dart';
import 'package:lifelink/features/desktop/screens/desktop_service_pages.dart';
import 'package:lifelink/features/mobile/screens/pay_now.dart';
import 'package:lifelink/core/services/quantity_parser.dart';

class BloodTypePage extends StatefulWidget {
  const BloodTypePage({super.key});

  @override
  State<BloodTypePage> createState() => _BloodTypePageState();
}

class _BloodTypePageState extends State<BloodTypePage> {
  String? selectedBlood;
  String? selectedHospital;
  int count = 1;
  int availableQty = 0;
  DateTime? receiveDate;

  Map<String, Map<String, dynamic>> bloodData = {};
  Map<String, Map<String, dynamic>>? lastBloodData;

  Future<void> pickDate() async {
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
    if (date != null && mounted) {
      setState(() => receiveDate = date);
    }
  }

  void updateBloodData(Map<String, Map<String, dynamic>> newData) {
    lastBloodData = newData;

    if (selectedBlood == null || selectedHospital == null) return;

    final hospitals = newData[selectedBlood];
    final quantity = parseInventoryQuantity(hospitals?[selectedHospital]);

    if (hospitals == null || !hospitals.containsKey(selectedHospital) || quantity <= 0) {
      setState(() {
        selectedHospital = null;
        count = 1;
        availableQty = 0;
      });
      return;
    }

    if (availableQty != quantity || count > quantity) {
      setState(() {
        availableQty = quantity;
        if (count > availableQty) count = availableQty;
      });
    }
  }

  BoxDecoration _boxDecoration({required bool isDesktop, bool selected = false}) {
    return BoxDecoration(
      color: selected ? AppColors.primary : AppColors.surface,
      borderRadius: BorderRadius.circular(isDesktop ? 18 : 14),
      border: Border.all(
        color: selected ? AppColors.primary : AppColors.borderStrong,
        width: selected ? 1.5 : 1,
      ),
      boxShadow: [
        BoxShadow(
          color: selected ? AppColors.primary.withOpacity(.15) : AppColors.shadowSoft,
          blurRadius: isDesktop ? 12 : 4,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  void openPayment() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ResponsiveLayout(
          mobile: PayNow(
            bloodType: selectedBlood!,
            hospital: selectedHospital!,
            quantity: count,
            receiveDate: receiveDate!,
            orderType: 'Pickup',
          ),
          tablet: DesktopPaymentPage(
            bloodType: selectedBlood!,
            hospital: selectedHospital!,
            quantity: count,
            receiveDate: receiveDate!,
            orderType: 'Pickup',
          ),
          desktop: DesktopPaymentPage(
            bloodType: selectedBlood!,
            hospital: selectedHospital!,
            quantity: count,
            receiveDate: receiveDate!,
            orderType: 'Pickup',
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width >= 800;
    final isDesktop = width >= 1100;

    return Scaffold(
      backgroundColor: isDesktop ? AppColors.background : Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        centerTitle: true,
        title: const Text(
          'Pick your blood type',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('blood_inventory').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('An error occurred. Please try again.'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          final nextData = <String, Map<String, dynamic>>{};
          for (final doc in snapshot.data!.docs) {
            nextData[doc.id] = Map<String, dynamic>.from(
              (doc.data() as Map<String, dynamic>)['hospitals'] ?? const {},
            );
          }
          bloodData = nextData;

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && !identical(lastBloodData, bloodData)) {
              updateBloodData(bloodData);
            }
          });

          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              isDesktop ? 30 : 16,
              isDesktop ? 28 : 16,
              isDesktop ? 30 : 16,
              28,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: isDesktop ? 1180 : 1100),
                child: Column(
                  children: [
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: bloodData.length,
                      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: isDesktop ? 285 : (isWide ? 270 : 190),
                        crossAxisSpacing: isDesktop ? 14 : 10,
                        mainAxisSpacing: isDesktop ? 14 : 10,
                        mainAxisExtent: isDesktop ? 108 : 92,
                      ),
                      itemBuilder: (context, index) {
                        final type = bloodData.keys.elementAt(index);
                        var totalQty = 0;
                        for (final value in bloodData[type]!.values) {
                          totalQty += value is num ? value.toInt() : 0;
                        }
                        final selected = selectedBlood == type;

                        return Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(isDesktop ? 18 : 14),
                            onTap: () {
                              setState(() {
                                selectedBlood = type;
                                selectedHospital = null;
                                availableQty = 0;
                                count = 1;
                              });
                            },
                            child: Container(
                              decoration: _boxDecoration(
                                isDesktop: isDesktop,
                                selected: selected,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    type,
                                    style: TextStyle(
                                      fontSize: isDesktop ? 21 : 18,
                                      fontWeight: FontWeight.w800,
                                      color: selected ? Colors.white : AppColors.text,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    'Qty: $totalQty',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: selected ? Colors.white70 : AppColors.muted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: isDesktop ? 28 : 24),
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Container(
                            height: isDesktop ? 58 : null,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: _boxDecoration(isDesktop: isDesktop),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                key: ValueKey('${selectedBlood}_${bloodData.hashCode}'),
                                value: selectedHospital,
                                hint: const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 12),
                                  child: Text('Hospital'),
                                ),
                                isExpanded: true,
                                icon: const Icon(Icons.keyboard_arrow_down_rounded),
                                dropdownColor: Colors.white,
                                style: const TextStyle(color: AppColors.text),
                                items: selectedBlood == null
                                    ? const []
                                    : bloodData[selectedBlood]!.entries
                                        .where((entry) => entry.value is num && (entry.value as num) > 0)
                                        .map(
                                          (entry) => DropdownMenuItem<String>(
                                            value: entry.key,
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 12),
                                              child: Text(entry.key),
                                            ),
                                          ),
                                        )
                                        .toList(),
                                onChanged: selectedBlood == null
                                    ? null
                                    : (value) {
                                        final quantity = parseInventoryQuantity(
                                          value == null ? 0 : bloodData[selectedBlood]![value],
                                        );
                                        setState(() {
                                          selectedHospital = value;
                                          availableQty = quantity;
                                          count = quantity > 0 ? 1 : 0;
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
                            height: isDesktop ? 58 : null,
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                            decoration: _boxDecoration(isDesktop: isDesktop),
                            child: Row(
                              children: [
                                IconButton(
                                  tooltip: 'Decrease quantity',
                                  onPressed: count > 1 && selectedHospital != null
                                      ? () => setState(() => count--)
                                      : null,
                                  icon: const Icon(Icons.remove_rounded, color: AppColors.primary),
                                  splashRadius: 22,
                                ),
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '$count',
                                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                                      ),
                                      if (selectedHospital != null)
                                        Text(
                                          'Available: $availableQty',
                                          style: const TextStyle(fontSize: 10, color: AppColors.muted),
                                        ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  tooltip: 'Increase quantity',
                                  onPressed: selectedHospital != null && availableQty > 0 && count < availableQty
                                      ? () => setState(() => count = (count + 1).clamp(1, availableQty))
                                      : null,
                                  icon: const Icon(Icons.add_rounded, color: AppColors.primary),
                                  splashRadius: 22,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      borderRadius: BorderRadius.circular(isDesktop ? 18 : 14),
                      onTap: pickDate,
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: isDesktop ? 17 : 14,
                        ),
                        decoration: _boxDecoration(isDesktop: isDesktop),
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
                                    style: TextStyle(
                                      color: receiveDate == null ? AppColors.textSecondary : AppColors.text,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: isDesktop ? 54 : 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.white,
                          disabledBackgroundColor: AppColors.disabledSurface,
                          disabledForegroundColor: AppColors.muted,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: selectedBlood != null &&
                                selectedHospital != null &&
                                receiveDate != null &&
                                availableQty > 0
                            ? openPayment
                            : null,
                        child: const Text(
                          'Next',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
