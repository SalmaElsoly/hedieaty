import 'package:flutter/material.dart';

import '../dummy_data.dart';
import '../shared/components/list.dart';
import '../shared/components/tabs.dart';

class FriendEventListPage extends StatefulWidget {
  const FriendEventListPage({super.key});

  @override
  State<FriendEventListPage> createState() => _FriendEventListPageState();
}

class _FriendEventListPageState extends State<FriendEventListPage>
    with SingleTickerProviderStateMixin {
  static const List<Tab> myTabs = <Tab>[
    Tab(text: 'Past'),
    Tab(text: 'Current'),
    Tab(text: 'Upcoming'),
  ];

  late TabController _tabController;
  int userId = 0;

  final pastEvents = [
    {"id": 1, "name": "Alice's Birthday"},
    {"id": 2, "name": "Tech Conference"},
  ];

  final currentEvents = [
    {"id": 3, "name": "Cooking Workshop"},
  ];

  final upcomingEvents = [
    {"id": 4, "name": "Football Match"},
    {"id": 5, "name": "Music Festival"},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: myTabs.length);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    userId = args['userId'];
  }

  void onTab(int index, List eventList) {
    Navigator.of(context).pushNamed('/friend_gift_list',
        arguments: {'eventId': eventList[index]['id']});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event List'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(160.0),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).colorScheme.secondary,
                    width: 3,
                  ),
                ),
                child: const CircleAvatar(
                  radius: 35,
                  backgroundImage: AssetImage('assets/images/avater.png'),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '${users[userId - 1]['username']}',
                style: TextStyle(
                  fontSize: 24,
                  color: Theme.of(context).highlightColor,
                ),
              ),
              defaultTabBar(context, myTabs, _tabController),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          eventAndGiftList(context, pastEvents, onTab, false, null, null),
          eventAndGiftList(context, currentEvents, onTab, false, null, null),
          eventAndGiftList(context, upcomingEvents, onTab, false, null, null),
        ],
      ),
    );
  }
}
