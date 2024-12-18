import 'package:flutter/material.dart';
import 'package:hedieaty/models/user.dart';
import 'package:hedieaty/shared/components/buttons.dart';
import 'package:hedieaty/controllers/user.dart';
import 'package:hedieaty/views/friend_event_list_page.dart';
import 'package:hedieaty/views/notification_page.dart';
import 'package:provider/provider.dart';

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
  late Stream<List<UserModel>> _userStream;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _userStream = _userController.getFriends(context);
    //loadCurrentUser();
  }

  // Future<void> loadCurrentUser()async{
  //   final user = await _userController.getCurrentUser(context);
  //   setState(() {
  //     _user = user!;
  //   });
  // }

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
                      _userStream = _userController.getFriends(context).map((users) =>
                        users.where((element) =>
                          element.username.toLowerCase().contains(value.toLowerCase())
                        ).toList()
                      );
                    });
                  },
                )              : const Text('Hedieaty'),
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
                onPressed: () async{
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => NotificationPage()));
                  setState(() {});
                },
                icon: const Icon(Icons.notifications_active)),
          ],
        ),
        // drawer: defaultDrawer(_user),
        //use Future builder ti load drawer
        drawer:Consumer<UserModel?>(
          builder: (context, user, child) {
            if (user == null) {
              return const Center(child: CircularProgressIndicator());
            }
            return defaultDrawer(user, _userController, context);
          },
        ),
        body: StreamBuilder<List<UserModel>>(
          stream: _userStream,
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
                      child: FadeInImage.assetNetwork(
                        placeholder: 'assets/images/avater.png',
                        image: _friends[index].profileImage ?? '',
                        fit: BoxFit.cover,
                        imageErrorBuilder: (context, error, stackTrace) {
                          return Image.asset('assets/images/avater.png',
                              fit: BoxFit.cover);
                        },
                      ),
                    ),
                    title: Text(_friends[index].username),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => FriendEventListPage(
                                  friend: _friends[index])));
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
        floatingActionButton: addEventButton(() {
          Navigator.pushNamed(context, '/event_create');
        }, context));
  }
}