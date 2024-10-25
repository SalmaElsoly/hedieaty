import 'package:flutter/material.dart';

Widget addEventButton(BuildContext context) {
  return FloatingActionButton.extended(
    onPressed: () {
      Navigator.pushNamed(context, '/event_create');
    },
    label: const Text('Add Event'),
    icon: const Icon(Icons.add),
  );
}
