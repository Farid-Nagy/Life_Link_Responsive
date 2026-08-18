import 'package:flutter/material.dart';
import 'package:lifelink/core/theme/app_colors.dart';
import 'package:lifelink/internet_service.dart';
import 'package:lifelink/core/responsive/responsive_layout.dart';
import 'package:lifelink/features/desktop/screens/desktop_invoice_page.dart';
import 'invoice_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

const Color primaryColor = AppColors.primary;

/// ==========================
/// PayNow Page
/// ==========================
class PayNow extends StatelessWidget {
  final String bloodType;
  final String hospital;
  final int quantity;
  final DateTime receiveDate;
  final String orderType;
  final String? deliveryAddress;
  final double? deliveryFee;

  const PayNow({
    super.key,
    required this.bloodType,
    required this.hospital,
    required this.quantity,
    required this.receiveDate,
    required this.orderType,
    this.deliveryAddress,
    this.deliveryFee,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: PaymentScreen(
        bloodType: bloodType,
        hospital: hospital,
        quantity: quantity,
        receiveDate: receiveDate,
        orderType: orderType,
        deliveryAddress: deliveryAddress,
        deliveryFee: deliveryFee,
      ),
    );
  }
}

enum PaymentMethod { telda, visa, mastercard }

class PaymentScreen extends StatefulWidget {
  final String bloodType;
  final String hospital;
  final int quantity;
  final DateTime receiveDate;
  final String orderType;
  final String? deliveryAddress;
  final double? deliveryFee;

  const PaymentScreen({
    super.key,
    required this.bloodType,
    required this.hospital,
    required this.quantity,
    required this.receiveDate,
    required this.orderType,
    this.deliveryAddress,
    this.deliveryFee,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  // 🔥🔥🔥 الإضافات الجديدة فقط هنا 🔥🔥🔥

  Future<void> _deductFromInventory() async {
    DocumentReference docRef = FirebaseFirestore.instance
        .collection('blood_inventory')
        .doc(widget.bloodType);

    await docRef.update({
      'hospitals.${widget.hospital.toLowerCase()}': FieldValue.increment(
        -widget.quantity,
      ),
    });
  }

  Future<void> _saveOrder(String paymentMethod) async {
    final user = FirebaseAuth.instance.currentUser;

    await FirebaseFirestore.instance.collection('orders').add({
      'userId': user?.uid,
      'userEmail': user?.email,
      'invoiceNumber': _invoiceNumber,
      'transactionNumber': _transactionNumber,
      'orderType': widget.orderType,
      'bloodType': widget.bloodType,
      'hospital': widget.hospital,
      'quantity': widget.quantity,
      'receiveDate': widget.receiveDate,
      'deliveryAddress': widget.deliveryAddress,
      'deliveryFee': widget.deliveryFee,
      'totalAmount': totalAmount,
      'paymentMethod': paymentMethod,
      'status': 'completed',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  PaymentMethod _selected = PaymentMethod.telda;
  final double _amountPerBag = 200.0;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _cardNumber = TextEditingController();
  final TextEditingController _expiry = TextEditingController();
  final TextEditingController _cvv = TextEditingController();

  // إضافة متغيرات للأرقام التسلسلية
  late String _invoiceNumber;
  late String _transactionNumber;

  // قائمة البطاقات المسموح بها مع بياناتها الكاملة
  final List<Map<String, String>> _allowedCards = [
    // بطاقات VISA
    {
      'number': '1234567812345678',
      'expiry': '12/25',
      'cvv': '123',
      'type': 'VISA',
    },
    {
      'number': '1111222233334444',
      'expiry': '03/26',
      'cvv': '789',
      'type': 'VISA',
    },

    // بطاقات Mastercard
    {
      'number': '8765432187654321',
      'expiry': '08/24',
      'cvv': '456',
      'type': 'Mastercard',
    },
    {
      'number': '5555666677778888',
      'expiry': '11/25',
      'cvv': '321',
      'type': 'Mastercard',
    },

    // بطاقات Telda
    {
      'number': '9876987698769876',
      'expiry': '09/26',
      'cvv': '987',
      'type': 'Telda',
    },
    {
      'number': '5432543254325432',
      'expiry': '05/25',
      'cvv': '654',
      'type': 'Telda',
    },
    {
      'number': '9999888877776666',
      'expiry': '12/27',
      'cvv': '147',
      'type': 'Telda',
    },
  ];

  double get totalAmount {
    double total = _amountPerBag * widget.quantity;
    if (widget.deliveryFee != null) {
      total += widget.deliveryFee!;
    }
    return total;
  }

  @override
  void initState() {
    super.initState();
    // إنشاء الأرقام التسلسلية عند فتح الصفحة
    _generateInvoiceNumbers();

    // إضافة مستمعين للتنسيق التلقائي
    _cardNumber.addListener(_formatCardNumber);
    _expiry.addListener(_formatExpiryDate);
  }

  // دالة إنشاء الأرقام التسلسلية
  void _generateInvoiceNumbers() {
    _invoiceNumber = "#INV-${DateTime.now().millisecondsSinceEpoch}";
    _transactionNumber =
        "OPR-${DateTime.now().second}${DateTime.now().millisecond}";
  }

  @override
  void dispose() {
    _cardNumber.removeListener(_formatCardNumber);
    _expiry.removeListener(_formatExpiryDate);
    _cardNumber.dispose();
    _expiry.dispose();
    _cvv.dispose();
    super.dispose();
  }

  // دالة تنسيق رقم البطاقة (إضافة مسافة كل 4 أرقام)
  void _formatCardNumber() {
    String text = _cardNumber.text.replaceAll(RegExp(r'\s+\b|\b\s'), '');
    if (text.isEmpty) return;

    String formatted = '';
    for (int i = 0; i < text.length; i++) {
      if (i > 0 && i % 4 == 0) {
        formatted += ' ';
      }
      formatted += text[i];
    }

    if (_cardNumber.text != formatted) {
      _cardNumber.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
  }

  // دالة تنسيق تاريخ الانتهاء (إضافة / بعد الشهر)
  void _formatExpiryDate() {
    String text = _expiry.text.replaceAll(RegExp(r'[^\d]'), '');
    if (text.isEmpty) return;

    if (text.length >= 3) {
      String month = text.substring(0, 2);
      String year = text.substring(2, text.length > 4 ? 4 : text.length);

      // التأكد من أن الشهر بين 01 و 12
      if (month.isNotEmpty) {
        int monthInt = int.parse(month);
        if (monthInt > 12) {
          month = '12';
        } else if (monthInt < 1 && month.length == 2) {
          month = '01';
        }
      }

      String formatted = text.length >= 2 ? '$month/$year' : text;

      if (_expiry.text != formatted) {
        _expiry.value = TextEditingValue(
          text: formatted,
          selection: TextSelection.collapsed(offset: formatted.length),
        );
      }
    }
  }

  // دالة التحقق من رقم البطاقة
  String? _validateCardNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter card number';
    }

    String numbers = value.replaceAll(' ', '');

    if (numbers.length != 16) {
      return 'Card number must be 16 digits';
    }

    // التحقق من وجود رقم البطاقة في القائمة
    bool cardExists = _allowedCards.any((card) => card['number'] == numbers);

    if (!cardExists) {
      return 'This card is not authorized for payment';
    }

    return null;
  }

  // دالة التحقق من تاريخ الانتهاء
  String? _validateExpiryDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Required';
    }

    String numbers = value.replaceAll('/', '');
    if (numbers.length < 4) {
      return 'Invalid date';
    }

    // التحقق من تطابق التاريخ مع البطاقة
    String cardNumber = _cardNumber.text.replaceAll(' ', '');
    if (cardNumber.isNotEmpty) {
      var card = _allowedCards.firstWhere(
        (c) => c['number'] == cardNumber,
        orElse: () => {},
      );

      if (card.isNotEmpty && card['expiry'] != value) {
        return 'Expiry date does not match this card';
      }
    }

    return null;
  }

  // دالة التحقق من الرقم السري CVV
  String? _validateCVV(String? value) {
    if (value == null || value.isEmpty) {
      return 'Required';
    }

    if (value.length < 3) {
      return '3 digits required';
    }

    // التحقق من تطابق الـ CVV مع البطاقة
    String cardNumber = _cardNumber.text.replaceAll(' ', '');
    if (cardNumber.isNotEmpty) {
      var card = _allowedCards.firstWhere(
        (c) => c['number'] == cardNumber,
        orElse: () => {},
      );

      if (card.isNotEmpty && card['cvv'] != value) {
        return 'CVV does not match this card';
      }
    }

    return null;
  }

  Widget _summaryCard(TextTheme text) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Transaction Summary",
            style: text.titleMedium!.copyWith(color: primaryColor),
          ),
          const SizedBox(height: 10),

          // إضافة الرقم التسلسلي للفاتورة في ملخص العمليات
          _row("Invoice Number", _invoiceNumber),
          _row("Transaction Number", _transactionNumber),
          const Divider(height: 20, thickness: 1),
          _row("Order Type", widget.orderType),
          _row("Blood Type", widget.bloodType),
          _row("Hospital", widget.hospital),
          _row("Quantity", "${widget.quantity} bag(s)"),
          if (widget.deliveryAddress != null)
            _row("Delivery Address", widget.deliveryAddress!),
          _row(
            "Receive Date",
            "${widget.receiveDate.day}/${widget.receiveDate.month}/${widget.receiveDate.year}",
          ),
          if (widget.deliveryFee != null)
            _row("Delivery Fee", "${widget.deliveryFee} EGP"),
          const Divider(height: 20, thickness: 1),
          _row("Total Amount", "${totalAmount.toStringAsFixed(0)} EGP"),
        ],
      ),
    );
  }

  Widget _row(String left, String right) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(left, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(
            right,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _paymentTile({
    required String title,
    required String subtitle,
    required Widget icon,
    required PaymentMethod value,
  }) {
    final selected = _selected == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selected = value;
          _cardNumber.clear();
          _expiry.clear();
          _cvv.clear();
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [BoxShadow(color: AppColors.shadow, blurRadius: 6)],
        ),
        child: Row(
          children: [
            icon,
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: selected ? Colors.white : Colors.black,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: selected ? Colors.white70 : AppColors.black54,
                    ),
                  ),
                ],
              ),
            ),
            Radio(
              value: value,
              groupValue: _selected,
              activeColor: Colors.white,
              onChanged: (v) {
                setState(() {
                  _selected = v!;
                  _cardNumber.clear();
                  _expiry.clear();
                  _cvv.clear();
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _cardForm(TextTheme text) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: AppColors.shadowSoft, blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Card Details",
            style: text.titleMedium!.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 15),

          // حقل رقم البطاقة مع التنسيق التلقائي والتحقق من القائمة المسموح بها
          TextFormField(
            controller: _cardNumber,
            keyboardType: TextInputType.number,
            maxLength: 19,
            decoration: _input("Card Number (xxxx xxxx xxxx xxxx)"),
            validator: _validateCardNumber,
            onChanged: (value) {
              // إعادة التحقق من الحقول الأخرى عند تغيير رقم البطاقة
              _expiry.text = '';
              _cvv.text = '';
            },
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              // حقل تاريخ الانتهاء مع التنسيق التلقائي
              Expanded(
                child: TextFormField(
                  controller: _expiry,
                  keyboardType: TextInputType.number,
                  maxLength: 5,
                  decoration: _input("Expiry (MM/YY)"),
                  validator: _validateExpiryDate,
                ),
              ),
              const SizedBox(width: 12),

              // حقل CVV
              Expanded(
                child: TextFormField(
                  controller: _cvv,
                  keyboardType: TextInputType.number,
                  maxLength: 3,
                  obscureText: true,
                  decoration: _input("CVV"),
                  validator: _validateCVV,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  InputDecoration _input(String hint) => InputDecoration(
    hintText: hint,
    counterText: "",
    filled: true,
    fillColor: AppColors.inputFillLight,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    errorStyle: const TextStyle(fontSize: 12),
  );

  Widget _payBtn() {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onPressed: _onPayPressed,
        child: const Text(
          "Pay Now",
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
    );
  }

  /// تحقق من الإنترنت قبل الدفع
  void _onPayPressed() async {
    bool hasInternet = await InternetService.hasInternet();

    if (!hasInternet) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("❌ No Internet Connection"),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      final method = _selected == PaymentMethod.telda
          ? "Telda"
          : _selected == PaymentMethod.visa
          ? "VISA"
          : "Mastercard";

      try {
        // 🔥 خصم من المخزون
        await _deductFromInventory();

        // 🔥 حفظ الطلب مرة واحدة فقط
        await _saveOrder(method);

        // 🔥 فتح صفحة الفاتورة بعد الحفظ
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ResponsiveLayout(
              mobile: InvoicePage(
                amount: totalAmount,
                method: method,
                orderType: widget.orderType,
                bloodType: widget.bloodType,
                hospital: widget.hospital,
                quantity: widget.quantity,
                receiveDate: widget.receiveDate,
                deliveryAddress: widget.deliveryAddress,
                invoiceNumber: _invoiceNumber,
                transactionNumber: _transactionNumber,
              ),
              tablet: DesktopInvoicePage(
                amount: totalAmount,
                method: method,
                orderType: widget.orderType,
                bloodType: widget.bloodType,
                hospital: widget.hospital,
                quantity: widget.quantity,
                receiveDate: widget.receiveDate,
                deliveryAddress: widget.deliveryAddress,
                invoiceNumber: _invoiceNumber,
                transactionNumber: _transactionNumber,
              ),
              desktop: DesktopInvoicePage(
                amount: totalAmount,
                method: method,
                orderType: widget.orderType,
                bloodType: widget.bloodType,
                hospital: widget.hospital,
                quantity: widget.quantity,
                receiveDate: widget.receiveDate,
                deliveryAddress: widget.deliveryAddress,
                invoiceNumber: _invoiceNumber,
                transactionNumber: _transactionNumber,
              ),
            ),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("❌ Error processing order: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryColor,
        automaticallyImplyLeading: true,
        titleSpacing: 18,
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.bloodtype_rounded, color: primaryColor),
            ),
            const SizedBox(width: 10),
            const Text(
              'LifeLink',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final desktop = constraints.maxWidth >= 1050;
          final content = desktop
              ? _desktopPaymentContent(text)
              : _mobilePaymentContent(text);

          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              desktop ? 28 : 16,
              desktop ? 24 : 16,
              desktop ? 28 : 16,
              28,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1180),
                child: content,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _desktopPaymentContent(TextTheme text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Payment',
                    style: text.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Review your order and complete the payment securely.',
                    style: TextStyle(color: AppColors.muted),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.lock_outline_rounded,
                    size: 17,
                    color: AppColors.primary,
                  ),
                  SizedBox(width: 7),
                  Text(
                    'Secure checkout',
                    style: TextStyle(
                      color: AppColors.primaryDark,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 5, child: _summaryCard(text)),
            const SizedBox(width: 20),
            Expanded(
              flex: 6,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Payment method',
                    style: text.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _paymentTile(
                    title: 'Telda',
                    subtitle: 'Fast & secure',
                    icon: Image.asset('images/01.png', width: 48),
                    value: PaymentMethod.telda,
                  ),
                  const SizedBox(height: 10),
                  _paymentTile(
                    title: 'VISA',
                    subtitle: 'Credit / Debit Card',
                    icon: Image.asset('images/03.png', width: 48),
                    value: PaymentMethod.visa,
                  ),
                  const SizedBox(height: 10),
                  _paymentTile(
                    title: 'Mastercard',
                    subtitle: 'Credit / Debit Card',
                    icon: Image.asset('images/02.png', width: 48),
                    value: PaymentMethod.mastercard,
                  ),
                  const SizedBox(height: 16),
                  Form(key: _formKey, child: _cardForm(text)),
                  const SizedBox(height: 14),
                  _payBtn(),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Center(
          child: Text(
            'All rights reserved 2026',
            style: text.bodySmall?.copyWith(color: AppColors.muted),
          ),
        ),
      ],
    );
  }

  Widget _mobilePaymentContent(TextTheme text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Payment',
          style: text.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 15),
        _summaryCard(text),
        const SizedBox(height: 22),
        Text('Payment method', style: text.titleMedium),
        const SizedBox(height: 10),
        _paymentTile(
          title: 'Telda',
          subtitle: 'Fast & secure',
          icon: Image.asset('images/01.png', width: 55),
          value: PaymentMethod.telda,
        ),
        const SizedBox(height: 10),
        _paymentTile(
          title: 'VISA',
          subtitle: 'Credit / Debit Card',
          icon: Image.asset('images/03.png', width: 55),
          value: PaymentMethod.visa,
        ),
        const SizedBox(height: 10),
        _paymentTile(
          title: 'Mastercard',
          subtitle: 'Credit / Debit Card',
          icon: Image.asset('images/02.png', width: 55),
          value: PaymentMethod.mastercard,
        ),
        const SizedBox(height: 22),
        Form(key: _formKey, child: _cardForm(text)),
        const SizedBox(height: 16),
        _payBtn(),
      ],
    );
  }
}
