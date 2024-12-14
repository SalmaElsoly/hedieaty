import 'package:flutter/material.dart';

Widget addEventButton(VoidCallback onPressed, BuildContext context) {
  return FloatingActionButton.extended(
    onPressed: onPressed,
    label: const Text('Add Event'),
    icon: const Icon(Icons.add),
  );
}
