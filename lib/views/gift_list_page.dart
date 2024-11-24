import 'package:flutter/material.dart';
import 'package:hedieaty/shared/components/cards.dart';
import 'package:hedieaty/shared/components/list.dart';
import 'package:hedieaty/shared/components/tabs.dart';

import '../dummy_data.dart';

class GiftListPage extends StatefulWidget {
  const GiftListPage({super.key});

  @override
  State<GiftListPage> createState() => _GiftListPageState();
}

class _GiftListPageState extends State<GiftListPage>
    with SingleTickerProviderStateMixin {
  static const List<Tab> tabs = <Tab>[
    Tab(text: 'Unpledged'),
    Tab(text: 'Pledged'),
  ];

  late TabController tabController;
  final List<Map<String, dynamic>> unpledgedGifts = [
    {
      "id": 1,
      "name": "Smart Watch",
      "image": "https://example.com/images/smart_watch.png"
    },
    {
      "id": 2,
      "name": "Bluetooth Speaker",
      "image": "https://example.com/images/bluetooth_speaker.png"
    },
  ];

  final List<Map<String, dynamic>> pledgedGifts = [
    {
      "id": 3,
      "name": "Wireless Earbuds",
      "image": "https://example.com/images/wireless_earbuds.png",
      "status": "Pledged"
    },
    {"id": 4, "name": "Fitness Tracker", "image": "", "status": "Purchased"},
  ];

  void onTap(int index, List<Map<String, dynamic>> list) {
    Navigator.of(context)
        .pushNamed('/gift_detail', arguments: {'giftId': list[index]['id']});
  }

  void onDelete(int index, List<Map<String, dynamic>> list) {
    setState(() {
      list.removeAt(index);
    });
  }

  void onEdit(int index, List<Map<String, dynamic>> list) {
    setState(() {
      list[index]['name'] = 'Edited Gift';
    });
  }

  @override
  void initState() {
    super.initState();
    tabController = TabController(vsync: this, length: tabs.length);
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Gift List'),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.sort),
            onSelected: (String result) {
              setState(() {
                if (result == 'name') {
                  unpledgedGifts.sort((a, b) =>
                      (a['name'] as String).compareTo(b['name'] as String));
                  pledgedGifts.sort((a, b) =>
                      (a['name'] as String).compareTo(b['name'] as String));
                } else if (result == 'category') {
                  unpledgedGifts.sort((a, b) => (a['category'] as String)
                      .compareTo(b['category'] as String));
                  pledgedGifts.sort((a, b) => (a['category'] as String)
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
            preferredSize: Size.fromHeight(280.0),
            child: Column(
              children: [
                eventDetailCard(context, events[0], true),
                defaultTabBar(context, tabs, tabController)
              ],
            )),
      ),
      body: TabBarView(
        controller: tabController,
        children: [
          eventAndGiftList(
              context, unpledgedGifts, onTap, true, onDelete, onEdit),
          ListView.separated(
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  leading: CircleAvatar(
                    radius: 24,
                  ),
                  title: Text(pledgedGifts[index]['name']),
                  onTap: () {
                    onTap(index, pledgedGifts);
                  },
                  trailing: pledgedGifts[index]['status'] == 'Pledged'
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
                          child: Text(
                            'Purchased',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSecondary,
                            ),
                          ),
                        ),
                );
              },
              separatorBuilder: (BuildContext context, int index) {
                return const Divider();
              },
              itemCount: pledgedGifts.length)
        ],
      ),
    );
  }
}
