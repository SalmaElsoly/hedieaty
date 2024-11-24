import 'package:flutter/material.dart';
import 'package:hedieaty/shared/components/list.dart';

class PledgedGiftPage extends StatefulWidget {
  const PledgedGiftPage({super.key});

  @override
  _PledgedGiftPageState createState() => _PledgedGiftPageState();
}

class _PledgedGiftPageState extends State<PledgedGiftPage> {
  final List<Map<String, dynamic>> gifts = [
    {
      'id': 1,
      'name': 'Smart Watch',
      'image': 'https://via.placeholder.com/150',
      'pledger': 'John Doe',
      'pledger_image': 'https://via.placeholder.com/50',
    },
    {
      'id': 2,
      'name': 'Wireless Earbuds',
      'image': 'https://via.placeholder.com/150',
      'pledger': 'Jane Smith',
      'pledger_image': 'https://via.placeholder.com/50',
    },
    {
      'id': 3,
      'name': 'Fitness Tracker',
      'image': 'https://via.placeholder.com/150',
      'pledger': 'Alice Johnson',
      'pledger_image': 'https://via.placeholder.com/50',
    }
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pledged Gift'),
      ),
      body: Center(
        child: ListView.separated(
            itemBuilder: (context, index) {
              return ListTile(
                leading: Container(
                  width: 60,
                  height: 80,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/app_icon.png'),
                      fit: BoxFit.fitHeight,
                    ),
                  ),
                ),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Gift ${index + 1}',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Event: Birthday Party',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color:
                              Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                    Text(
                      'Friend: John Doe',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color:
                              Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                    Text(
                      'Deadline: 2022-12-31',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color:
                              Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
                trailing: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Theme.of(context).highlightColor.withOpacity(0.6),
                    foregroundColor: Theme.of(context).colorScheme.onError,
                  ),
                  child: Text('Cancel'),
                ),
              );
            },
            separatorBuilder: (context, index) {
              return defaultDivider(context);
            },
            itemCount: 5),
      ),
    );
  }
}
