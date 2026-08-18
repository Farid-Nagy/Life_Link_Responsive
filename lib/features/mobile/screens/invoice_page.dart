import 'package:flutter/material.dart';
import 'package:lifelink/core/theme/app_colors.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

class InvoicePage extends StatelessWidget {
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

  const InvoicePage({
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    final date = "${receiveDate.day}/${receiveDate.month}/${receiveDate.year}";
    final time = "${DateTime.now().hour}:${DateTime.now().minute}";

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text("Invoice", style: TextStyle(color: Colors.black)),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // الصفحة زي ما هي بالضبط
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.darkShadow,
                    blurRadius: 12,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(Icons.receipt_long, size: 50, color: primary),
                  const SizedBox(height: 12),
                  Text(
                    "Payment Successful",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: primary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "Thank you for using Lifelink",
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // تفاصيل الفاتورة
            _invoiceItem("Invoice Number", invoiceNumber),
            _invoiceItem("Transaction Number", transactionNumber),
            _invoiceItem("Date", date),
            _invoiceItem("Time", time),
            _invoiceItem("Order Type", orderType),
            _invoiceItem("Payment Method", method),
            _invoiceItem("Blood Type", bloodType),
            _invoiceItem("Hospital", hospital),
            _invoiceItem("Quantity", quantity.toString()),
            if (deliveryAddress != null)
              _invoiceItem("Delivery Address", deliveryAddress!),
            _invoiceItem("Amount Paid", "${amount.toStringAsFixed(2)} EGP"),
            _invoiceItem("Status", "Successful", highlight: true),
            const SizedBox(height: 20),
            if (deliveryName != null)
              _invoiceItem("Delivery Name", deliveryName!),
            if (deliveryPhone != null)
              _invoiceItem("Delivery Phone", deliveryPhone!),
            if (notes != null) _invoiceItem("Notes", notes!),

            const SizedBox(height: 30),

            // زر العودة
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  side: BorderSide(color: primary, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 5,
                  shadowColor: AppColors.darkShadow,
                ),
                child: Text(
                  "Back",
                  style: TextStyle(
                    color: primary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // زر تحميل PDF بدون أي تغيير في الصفحة
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await _generatePdf(); // هنا نعمل PDF
                },
                icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
                label: const Text(
                  "Download PDF",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _invoiceItem(String title, String value, {bool highlight = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowSoft,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 16)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: highlight ? AppColors.success : AppColors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _generatePdf() async {
    final pdf = pw.Document();

    final date = "${receiveDate.day}/${receiveDate.month}/${receiveDate.year}";
    final time = "${DateTime.now().hour}:${DateTime.now().minute}";

    final data = {
      "Invoice Number": invoiceNumber,
      "Transaction Number": transactionNumber,
      "Date": date,
      "Time": time,
      "Order Type": orderType,
      "Payment Method": method,
      "Blood Type": bloodType,
      "Hospital": hospital,
      "Quantity": quantity.toString(),
      if (deliveryAddress != null) "Delivery Address": deliveryAddress!,
      "Amount Paid": "${amount.toStringAsFixed(2)} EGP",
      "Status": "Successful",
      if (deliveryName != null) "Delivery Name": deliveryName!,
      if (deliveryPhone != null) "Delivery Phone": deliveryPhone!,
      if (notes != null) "Notes": notes!,
    };

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(24),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  "INVOICE",
                  style: pw.TextStyle(
                    fontSize: 28,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.teal800,
                  ),
                ),
                pw.Divider(height: 20, thickness: 2, color: PdfColors.grey300),
                pw.SizedBox(height: 8),
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
                          child: pw.Text("Field", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text("Value", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                      ],
                    ),
                    ...data.entries.map(
                      (e) => pw.TableRow(
                        children: [
                          pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(e.key)),
                          pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(e.value)),
                        ],
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 30),
                pw.Text(
                  "Thank you for using Lifelink ❤️",
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(fontSize: 14, color: PdfColors.grey800),
                ),
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }
}
