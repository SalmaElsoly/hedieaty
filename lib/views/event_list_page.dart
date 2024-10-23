import 'package:flutter/material.dart';
import 'package:hedieaty/shared/components/buttons.dart';

import '../shared/components/list.dart';

class EventListPage extends StatefulWidget {
  const EventListPage({super.key});

  @override
  State<EventListPage> createState() => _EventListPageState();
}

class _EventListPageState extends State<EventListPage> with SingleTickerProviderStateMixin {
  static const List<Tab> myTabs = <Tab>[
    Tab(text: 'Past'),
    Tab(text: 'Current'),
    Tab(text: 'Upcoming'),
  ];

  late TabController _tabController;

  List<String> pastEvents = ['Event 1', 'Event 2', 'Event 3'];
  List<String> currentEvents = ['Event 4', 'Event 5', 'Event 6'];
  List<String> upcomingEvents = ['Event 7', 'Event 8', 'Event 9'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: myTabs.length);
  }

  void deleteEvent(List<String> events, int index) {
    setState(() {
      events.removeAt(index);
    });
  }

  void editEvent(List<String> events, int index) {
    setState(() {
      events[index] = 'Edited Event';
    });
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event List'),

        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(140.0),
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
                    backgroundImage: const AssetImage('assets/images/avater.png'),
                  ),
                ),
                Text('User Name'),
                TabBar(
                  controller: _tabController,
                  tabs: myTabs,
                  unselectedLabelColor: Theme.of(context).colorScheme.onPrimary,
                  labelColor: Theme.of(context).colorScheme.secondary,
                  indicatorColor: Theme.of(context).highlightColor,
                ),
              ],
            ))
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          userEventAndGiftList(context, deleteEvent, editEvent, pastEvents, []),
          userEventAndGiftList(context, deleteEvent, editEvent, currentEvents, []),
          userEventAndGiftList(context, deleteEvent, editEvent, upcomingEvents, []),
        ],
      ),
      floatingActionButton: addEventButton(context),
    );
  }
}

