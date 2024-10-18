import 'package:flutter/material.dart';

class EventListPage extends StatelessWidget {
  const EventListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Event List Page'),
      ),
      body: const Center(
        child: Text('Welcome to the Event List Page'),
      ),
    );
  }
}