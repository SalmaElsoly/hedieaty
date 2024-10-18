import 'package:flutter/material.dart';


class GiftDetailPage extends StatelessWidget {
  const GiftDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gift Detail Page'),
      ),
      body: const Center(
        child: Text('Welcome to the Gift Detail Page'),
      ),
    );
  }
}