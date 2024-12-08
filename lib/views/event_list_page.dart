import 'package:flutter/material.dart';
import 'package:hedieaty/controllers/event.dart';
import 'package:hedieaty/models/user.dart';
import 'package:hedieaty/shared/components/buttons.dart';
import '../models/event.dart';
import '../shared/components/list.dart';
import '../shared/components/tabs.dart';
import 'event_creation_page.dart';
class EventListPage extends StatefulWidget {
  UserModel? user;
  EventListPage({super.key, this.user});

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
  EventController _eventController = EventController.instance;
  late TabController _tabController;
  late Future<List<EventModel>> _eventsFuture;
  

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: myTabs.length);
    _eventsFuture = _eventController.getMyEvents(context);
  }

  void deleteEvent(int index, List<EventModel> events) {
    setState(() {
      events.removeAt(index);
    });
  }

  void editEvent(int index, List<EventModel> eventList) async {
  Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EventCreatePage(event: eventList[index]),
      ),
    );
  }

  void onTab(int index, List<EventModel> eventList) {
    Navigator.of(context).pushNamed('/my_gift_list',
        arguments: {'event': eventList[index]});
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
                    _eventsFuture.then((events) {
                      events.sort((a, b) => a.name.compareTo(b.name));
                    });
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
                      backgroundImage: widget.user?.profileImage!=null?
                      NetworkImage(
                        widget.user?.profileImage as String,
                        ):
                      AssetImage(
                          'assets/images/avatar.png',
                        ),
                    ),
                  ),
                  Text(
                    widget.user!.username,
                    style: TextStyle(
                      fontSize: 24,
                      color: Theme.of(context).highlightColor,
                    ),
                  ),
                  defaultTabBar(context, myTabs, _tabController),
                ],
              ))),
      body: FutureBuilder<List<EventModel>>(
        future: _eventsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No events found'));
          }

          final events = snapshot.data!;
          final pastEvents = events.where((event) => event.isPast).toList();
          final currentEvents = events.where((event) => event.isCurrent).toList();
          final upcomingEvents = events.where((event) => event.isUpcoming).toList();

          return TabBarView(
            controller: _tabController,
            children: [
              eventAndGiftList(
                  context, pastEvents, onTab, true, deleteEvent, editEvent),
              eventAndGiftList(
                  context, currentEvents, onTab, true, deleteEvent, editEvent),
              eventAndGiftList(
                  context, upcomingEvents, onTab, true, deleteEvent, editEvent),
            ],
          );
        },
      ),
      floatingActionButton: addEventButton(context),
    );
  }
}