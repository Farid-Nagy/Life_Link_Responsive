import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lifelink/core/responsive/app_breakpoints.dart';
import 'package:lifelink/core/theme/app_colors.dart';

class AdminReportsPage extends StatelessWidget {
  const AdminReportsPage({super.key});

  Future<List<int>> _load() async {
    final users = await FirebaseFirestore.instance.collection('users').get();
    final orders = await FirebaseFirestore.instance.collection('orders').get();
    var bags = 0;
    for (final doc in orders.docs) {
      final value = doc.data()['quantity'];
      bags += value is num ? value.toInt() : int.tryParse('$value') ?? 0;
    }
    return [users.docs.length, orders.docs.length, bags];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reports')),
      body: FutureBuilder<List<int>>(
        future: _load(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final data = snapshot.data ?? [0, 0, 0];
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppBreakpoints.maxContentWidth,
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final columns = constraints.maxWidth >= 900 ? 3 : 1;
                    return GridView.count(
                      shrinkWrap: true,
                      crossAxisCount: columns,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: columns == 1 ? 3.4 : 1.8,
                      children: [
                        _ReportCard('Users', data[0], Icons.people_outline),
                        _ReportCard('Orders', data[1], Icons.receipt_long),
                        _ReportCard(
                          'Reserved bags',
                          data[2],
                          Icons.bloodtype_outlined,
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final String title;
  final int value;
  final IconData icon;

  const _ReportCard(this.title, this.value, this.icon);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.primary, size: 34),
          const SizedBox(width: 16),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$value',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(title),
            ],
          ),
        ],
      ),
    );
  }
}
