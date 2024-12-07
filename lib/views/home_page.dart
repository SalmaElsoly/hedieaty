import 'package:flutter/material.dart';
import 'package:hedieaty/models/user.dart';
import 'package:hedieaty/shared/components/buttons.dart';
import 'package:hedieaty/controllers/user.dart';

import '../shared/components/drawer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late List<UserModel> _friends;
  bool _isSearching = false;
  late TextEditingController _searchController;
  final UserController _userController = UserController();

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
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
                          .where((element) => element.username.contains(value))
                          .toList();
                    });
                    if (value.isEmpty) {
                      _userController.getFriends(context).then((value) {
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
        drawer: FutureBuilder<UserModel>(
          future: _userController.getCurrentUser(context) as Future<UserModel>,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (!snapshot.hasData) {
              return const Center(child: Text('No user data found'));
            }
            return defaultDrawer(
              snapshot.data!,
            );
          },
        ),
        body: FutureBuilder<List<UserModel>>(
          future: _userController.getFriends(context),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No friends found'));
            }

            _friends = snapshot.data!;
            return ListView.separated(
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    leading: CircleAvatar(
                      radius: 24,
                      backgroundImage: _friends[index].profileImage != null
                          ? NetworkImage(_friends[index].profileImage!)
                          : const AssetImage('assets/images/avater.png')
                              as ImageProvider,
                    ),
                    title: Text(_friends[index].username),
                    onTap: () {
                      Navigator.pushNamed(context, '/friend_event_list',
                          arguments: {'userId': _friends[index].id});
                    },
                    hoverColor: Theme.of(context).hoverColor,
                    enabled: true,
                    trailing: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        child: Text('${_friends[index].eventsCount}',
                            style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSecondary))),
                  );
                },
                separatorBuilder: (BuildContext context, int index) => Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
                      child: Divider(
                        height: 3,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                itemCount: _friends.length);
          },
        ),
        floatingActionButton: addEventButton(context));
  }
}
