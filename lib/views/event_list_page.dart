import 'package:flutter/material.dart';
import 'package:hedieaty/shared/components/buttons.dart';

import '../shared/components/list.dart';
import '../shared/components/tabs.dart';
import 'event_creation_page.dart';

class EventListPage extends StatefulWidget {
  const EventListPage({super.key});

  @override
  State<EventListPage> createState() => _EventListPageState();
}

class _EventListPageState extends State<EventListPage>
    with SingleTickerProviderStateMixin {
  static const List<Tab> myTabs = <Tab>[
    Tab(text: 'Past'),
    Tab(text: 'Current'),
    Tab(text: 'Upcoming'),
  ];

  late TabController _tabController;

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

  void deleteEvent(int index, List events) {
    setState(() {
      events.removeAt(index);
    });
  }

  void editEvent(int index, List<Map<String, dynamic>> eventList) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EventCreatePage(event: eventList[index]),
      ),
    );

    if (result != null) {
      setState(() {
        eventList[index] = result;
      });
    }
  }

  void onTab(int index, List eventList) {
    Navigator.of(context).pushNamed('/my_gift_list',
        arguments: {'eventId': eventList[index]['id']});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('My Events List'),
          actions: [
            PopupMenuButton<String>(
              icon: Icon(Icons.sort),
              onSelected: (String result) {
                setState(() {
                  if (result == 'name') {
                    pastEvents.sort((a, b) =>
                        (a['name'] as String).compareTo(b['name'] as String));
                    currentEvents.sort((a, b) =>
                        (a['name'] as String).compareTo(b['name'] as String));
                    upcomingEvents.sort((a, b) =>
                        (a['name'] as String).compareTo(b['name'] as String));
                  } else if (result == 'time') {
                    // Assuming you have a 'time' field in your events
                    pastEvents.sort((a, b) =>
                        (a['time'] as String).compareTo(b['time'] as String));
                    currentEvents.sort((a, b) =>
                        (a['time'] as String).compareTo(b['time'] as String));
                    upcomingEvents.sort((a, b) =>
                        (a['time'] as String).compareTo(b['time'] as String));
                  }
                });
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'name',
                  child: Text('Sort by Name'),
                ),
              ],
            ),
          ],
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
                    child: CircleAvatar(
                      radius: 35,
                      backgroundImage:
                          const AssetImage('assets/images/avater.png'),
                    ),
                  ),
                  Text(
                    'User Name',
                    style: TextStyle(
                      fontSize: 24, // Increase the font size as needed
                      color: Theme.of(context).highlightColor,
                    ),
                  ),
                  defaultTabBar(context, myTabs, _tabController),
                ],
              ))),
      body: TabBarView(
        controller: _tabController,
        children: [
          eventAndGiftList(
              context, pastEvents, onTab, true, deleteEvent, editEvent),
          eventAndGiftList(
              context, currentEvents, onTab, true, deleteEvent, editEvent),
          eventAndGiftList(
              context, upcomingEvents, onTab, true, deleteEvent, editEvent),
        ],
      ),
      floatingActionButton: addEventButton(context),
    );
  }
}
