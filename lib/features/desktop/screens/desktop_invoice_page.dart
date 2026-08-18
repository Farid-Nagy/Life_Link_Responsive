import 'package:flutter/material.dart';
import 'package:lifelink/core/theme/app_colors.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class DesktopInvoicePage extends StatelessWidget {
  final double amount;
  final String method;
  final String orderType;
  final String bloodType;
  final String hospital;
  final int quantity;
  final DateTime receiveDate;
  final String? deliveryAddress;
  final String? deliveryName;
  final String? deliveryPhone;
  final String? notes;
  final String invoiceNumber;
  final String transactionNumber;

  const DesktopInvoicePage({
    super.key,
    required this.amount,
    required this.method,
    required this.orderType,
    required this.bloodType,
    required this.hospital,
    required this.quantity,
    required this.receiveDate,
    required this.invoiceNumber,
    required this.transactionNumber,
    this.deliveryAddress,
    this.deliveryName,
    this.deliveryPhone,
    this.notes,
  });

  String get _date => '${receiveDate.day}/${receiveDate.month}/${receiveDate.year}';
  String get _time => '${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}';

  Future<void> _generatePdf() async {
    final pdf = pw.Document();
    final rows = <MapEntry<String, String>>[
      MapEntry('Invoice Number', invoiceNumber),
      MapEntry('Transaction Number', transactionNumber),
      MapEntry('Date', _date),
      MapEntry('Time', _time),
      MapEntry('Order Type', orderType),
      MapEntry('Payment Method', method),
      MapEntry('Blood Type', bloodType),
      MapEntry('Hospital', hospital),
      MapEntry('Quantity', '$quantity bag(s)'),
      if (deliveryAddress?.trim().isNotEmpty == true)
        MapEntry('Delivery Address', deliveryAddress!),
      if (deliveryName?.trim().isNotEmpty == true)
        MapEntry('Delivery Name', deliveryName!),
      if (deliveryPhone?.trim().isNotEmpty == true)
        MapEntry('Delivery Phone', deliveryPhone!),
      if (notes?.trim().isNotEmpty == true) MapEntry('Notes', notes!),
      MapEntry('Amount Paid', '${amount.toStringAsFixed(2)} EGP'),
      const MapEntry('Status', 'Successful'),
    ];

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (_) => pw.Padding(
          padding: const pw.EdgeInsets.all(26),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'LIFELINK INVOICE',
                style: pw.TextStyle(
                  fontSize: 26,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.teal800,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text('Payment Successful', style: const pw.TextStyle(fontSize: 15)),
              pw.SizedBox(height: 18),
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300),
                columnWidths: {
                  0: const pw.FlexColumnWidth(2),
                  1: const pw.FlexColumnWidth(3),
                },
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.teal100),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Field', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Value', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                    ],
                  ),
                  ...rows.map(
                    (row) => pw.TableRow(
                      children: [
                        pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(row.key)),
                        pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(row.value)),
                      ],
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 24),
              pw.Center(
                child: pw.Text('Thank you for using LifeLink'),
              ),
            ],
          ),
        ),
      ),
    );

    await Printing.layoutPdf(onLayout: (_) async => pdf.save());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 0,
        title: const Text(
          'Invoice',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 22),
            child: OutlinedButton.icon(
              onPressed: _generatePdf,
              icon: const Icon(Icons.picture_as_pdf_rounded, size: 18),
              label: const Text('PDF'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.white,
                side: const BorderSide(color: AppColors.white70),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(28, 28, 28, 36),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1040),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(26),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.border),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.shadow,
                        blurRadius: 18,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 68,
                        height: 68,
                        decoration: BoxDecoration(
                          color: AppColors.primarySoft,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.receipt_long_rounded,
                          color: AppColors.primary,
                          size: 34,
                        ),
                      ),
                      const SizedBox(width: 18),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Payment Successful',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                color: AppColors.text,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              'Thank you for using LifeLink',
                              style: TextStyle(color: AppColors.muted, fontSize: 15),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEAF8F0),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.check_circle_rounded, color: AppColors.success, size: 19),
                            SizedBox(width: 7),
                            Text(
                              'Successful',
                              style: TextStyle(
                                color: AppColors.success,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final wide = constraints.maxWidth >= 860;
                    final children = [
                      _sectionCard('Transaction', [
                        _row('Invoice Number', invoiceNumber),
                        _row('Transaction Number', transactionNumber),
                        _row('Date', _date),
                        _row('Time', _time),
                      ]),
                      _sectionCard('Order Details', [
                        _row('Order Type', orderType),
                        _row('Blood Type', bloodType),
                        _row('Hospital', hospital),
                        _row('Quantity', '$quantity bag(s)'),
                        _row('Payment Method', method),
                      ]),
                    ];
                    return wide
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: children[0]),
                              const SizedBox(width: 18),
                              Expanded(child: children[1]),
                            ],
                          )
                        : Column(children: [children[0], const SizedBox(height: 18), children[1]]);
                  },
                ),
                const SizedBox(height: 18),
                _sectionCard(
                  'Payment Summary',
                  [
                    _row('Amount Paid', '${amount.toStringAsFixed(2)} EGP', emphasized: true),
                    if (deliveryAddress?.trim().isNotEmpty == true)
                      _row('Delivery Address', deliveryAddress!),
                    if (deliveryName?.trim().isNotEmpty == true)
                      _row('Delivery Name', deliveryName!),
                    if (deliveryPhone?.trim().isNotEmpty == true)
                      _row('Delivery Phone', deliveryPhone!),
                    if (notes?.trim().isNotEmpty == true) _row('Notes', notes!),
                  ],
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_rounded),
                        label: const Text('Back'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary),
                          minimumSize: const Size.fromHeight(54),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _generatePdf,
                        icon: const Icon(Icons.picture_as_pdf_rounded),
                        label: const Text('Download PDF'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.white,
                          minimumSize: const Size.fromHeight(54),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionCard(String title, List<Widget> rows) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowSoft,
            blurRadius: 12,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 12),
          ...rows,
        ],
      ),
    );
  }

  Widget _row(String label, String value, {bool emphasized = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.muted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                color: emphasized ? AppColors.primary : AppColors.text,
                fontWeight: emphasized ? FontWeight.w900 : FontWeight.w700,
                fontSize: emphasized ? 18 : 15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
