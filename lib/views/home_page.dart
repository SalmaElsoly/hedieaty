import 'package:flutter/material.dart';
import 'package:hedieaty/dummy_data.dart';
import 'package:hedieaty/shared/components/buttons.dart';

import '../shared/components/drawer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late List _friends;
  bool _isSearching = false;
  late TextEditingController _searchController;

  Future<List> friendList(int userId) async {
    List myFriends = [];
    for (var row in friends) {
      if (row['userId'] == userId) {
        for (var value in users) {
          if (value['id'] == row['friendId']) {
            value['events'] = 0;
            myFriends.add(value);
          }
        }
      }
    }
    for (var row in myFriends) {
      for (var event in events) {
        if (row['id'] == event['userId']) {
          row['events'] += 1;
        }
      }
    }
    return myFriends;
  }

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _friends = [];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    final userId = args['userId'];
    friendList(1).then((value) {
      setState(() {
        _friends = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: AppBar(
          title: _isSearching
              ? TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    fillColor: Theme.of(context)
                        .scaffoldBackgroundColor
                        .withOpacity(0.7),
                    filled: true,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                  ),
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.onSurface),
                  onChanged: (value) {
                    setState(() {
                      _friends = _friends
                          .where(
                              (element) => element['username'].contains(value))
                          .toList();
                    });
                    if (value.isEmpty) {
                      friendList(1).then((value) {
                        setState(() {
                          _friends = value;
                        });
                      });
                    }
                  },
                )
              : const Text('Hedieaty'),
          leading: Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
                tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
              );
            },
          ),
          elevation: 6.0,
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                setState(() {
                  _isSearching = !_isSearching;
                });
              },
            ),
            IconButton(
                onPressed: () {
                  // Navigator.push(context, '/notifications');
                },
                icon: const Icon(Icons.notifications_active)),
          ],
        ),
        drawer: defaultDrawer(
          'assets/images/avater.png',
          '${users[1]['username']}',
        ),
        body: ListView.separated(
            itemBuilder: (BuildContext context, int index) {
              return ListTile(
                leading: const CircleAvatar(
                  radius: 24,
                  backgroundImage: AssetImage('assets/images/avater.png'),
                ),
                title: Text('${_friends[index]['username']}'),
                onTap: () {
                  Navigator.pushNamed(context, '/friend_event_list',
                      arguments: {'userId': _friends[index]['id']});
                },
                hoverColor: Theme.of(context).hoverColor,
                enabled: true,
                trailing: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    child: Text('${_friends[index]['events']}',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onSecondary))),
              );
            },
            separatorBuilder: (BuildContext context, int index) => Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
                  child: Divider(
                    height: 3,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
            itemCount: _friends.length),
        floatingActionButton: addEventButton(context));
  }
}
