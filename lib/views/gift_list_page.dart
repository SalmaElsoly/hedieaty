import 'package:flutter/material.dart';


class GiftListPage extends StatelessWidget {
  const GiftListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gift List Page'),
      ),
      body: const Center(
        child: Text('Welcome to the Gift List Page'),
      ),
    );
  }
}