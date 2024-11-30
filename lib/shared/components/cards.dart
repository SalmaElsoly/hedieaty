import 'package:flutter/material.dart';

Widget eventDetailCard(
    BuildContext context, Map<String, dynamic> event, bool isOwner) {
  return Card(
    margin: const EdgeInsets.all(10.0),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15.0),
    ),
    elevation: 5,
    child: Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            event['name'],
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                'Date: ${event['date']}',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(width: 10),
              Text(
                'Time: ${event['time']}',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Location: ${event['location']}',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 10),
          Text(
            'Description: ${event['description']}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 10),
          if (isOwner)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FloatingActionButton.extended(
                  onPressed: () {
                    Navigator.of(context).pushNamed('/gift_create',
                        arguments: {'eventId': event['id']});
                  },
                  icon: Icon(Icons.add),
                  label: const Text('Add Gift'),
                ),
              ],
            ),
        ],
      ),
    ),
  );
}
