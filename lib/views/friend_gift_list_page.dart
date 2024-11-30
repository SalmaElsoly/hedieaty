import 'package:flutter/material.dart';

import '../dummy_data.dart';
import '../shared/components/cards.dart';

class FriendGiftListPage extends StatefulWidget {
  const FriendGiftListPage({super.key});

  @override
  State<FriendGiftListPage> createState() => _FriendGiftListPageState();
}

class _FriendGiftListPageState extends State<FriendGiftListPage> {
  List Gifts = [
    {
      "id": 1,
      "name": "Smart Watch",
      "image": "https://example.com/images/smart_watch.png",
      "status": "Unpledged"
    },
    {
      "id": 2,
      "name": "Bluetooth Speaker",
      "image": "https://example.com/images/bluetooth_speaker.png",
      "status": "Pledged"
    },
    {"id": 4, "name": "Fitness Tracker", "image": "", "status": "Purchased"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gift List'),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.sort),
            onSelected: (String result) {
              setState(() {
                if (result == 'name') {
                  gifts.sort((a, b) =>
                      (a['name'] as String).compareTo(b['name'] as String));
                } else if (result == 'category') {
                  gifts.sort((a, b) => (a['category'] as String)
                      .compareTo(b['category'] as String));
                }
              });
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'name',
                child: Text('Sort by Name'),
              ),
              const PopupMenuItem<String>(
                value: 'category',
                child: Text('Sort by Category'),
              ),
            ],
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(180.0),
          child: eventDetailCard(context, events[0], false),
        ),
      ),
      body: ListView.separated(
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            leading: CircleAvatar(
              radius: 24,
            ),
            title: Text(Gifts[index]['name']),
            onTap: () {
              Navigator.of(context).pushNamed('/gift_detail',
                  arguments: {'giftId': Gifts[index]['id']});
            },
            trailing: Gifts[index]['status'] == 'Unpledged'
                ? Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Unpledged',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSecondary,
                      ),
                    ),
                  )
                : (Gifts[index]['status'] == 'Pledged'
                    ? Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).highlightColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Pledged',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      )
                    : Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.greenAccent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Purchased',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      )),
          );
        },
        separatorBuilder: (BuildContext context, int index) {
          return const Divider();
        },
        itemCount: Gifts.length,
      ),
    );
  }
}
