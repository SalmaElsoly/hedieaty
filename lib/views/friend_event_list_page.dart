import 'package:flutter/material.dart';
import 'package:hedieaty/views/friend_gift_list_page.dart';

import '../controllers/event.dart';
import '../dummy_data.dart';
import '../models/event.dart';
import '../models/user.dart';
import '../shared/components/list.dart';
import '../shared/components/tabs.dart';

class FriendEventListPage extends StatefulWidget {
  UserModel? friend;
  FriendEventListPage({super.key, this.friend});

  @override
  State<FriendEventListPage> createState() => _FriendEventListPageState();
}

class _FriendEventListPageState extends State<FriendEventListPage>
    with SingleTickerProviderStateMixin {
  static const List<Tab> myTabs = <Tab>[
    Tab(text: 'Past', icon: Icon(Icons.history)),
    Tab(text: 'Current', icon: Icon(Icons.event)),
    Tab(text: 'Upcoming', icon: Icon(Icons.event_available)),
  ];
  EventController _eventController = EventController.instance;
  late TabController _tabController;
  late Future<List<EventModel>> _eventsFuture;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: myTabs.length);
    _eventsFuture = _eventController.getEvents(widget.friend!.id!, context);
  }


  void onTab(int index, List eventList) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FriendGiftListPage(
          event: eventList[index],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.people, color: Theme.of(context).colorScheme.secondary),
            SizedBox(width: 8),
            const Text('Friend\'s Events'),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.sort),
            onSelected: (String result) {
              setState(() {
                if (result == 'name') {
                  setState(() {
                    _eventsFuture = _eventsFuture.then((events) {
                      events.sort((a, b) => a.name.compareTo(b.name));
                      return events;
                    });
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
          preferredSize: const Size.fromHeight(180.0),
          child: Column(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Theme.of(context).colorScheme.secondary,
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
                          spreadRadius: 2,
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 35,
                      backgroundImage: widget.friend?.profileImage != null
                          ? NetworkImage(
                        widget.friend?.profileImage as String,
                      )
                          : AssetImage(
                        'assets/images/avater.png',
                      ) as ImageProvider,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.person_add_alt_1,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                widget.friend?.username ?? '',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).highlightColor,
                  shadows: [
                    Shadow(
                      offset: Offset(1, 1),
                      blurRadius: 2,
                      color: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
                    ),
                  ],
                ),
              ),
              defaultTabBar(context, myTabs, _tabController),
            ],
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.secondary.withOpacity(0.1),
              Theme.of(context).scaffoldBackgroundColor,
            ],
          ),
        ),
        child: FutureBuilder<List<EventModel>>(
          future: _eventsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('No events found'));
            }

            var events = snapshot.data!;
            final pastEvents = events.where((event) => event.isPast).toList();
            final currentEvents =
            events.where((event) => event.isCurrent).toList();
            final upcomingEvents =
            events.where((event) => event.isUpcoming).toList();

            return TabBarView(
              controller: _tabController,
              children: [
                eventAndGiftList(context, pastEvents, onTab, false, null, null),
                eventAndGiftList(context, currentEvents, onTab, false, null, null),
                eventAndGiftList(context, upcomingEvents, onTab, false, null, null),
              ],
            );
          },
        ),
      ),
    );
  }
}