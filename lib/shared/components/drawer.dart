import 'package:flutter/material.dart';
import 'package:hedieaty/controllers/user.dart';
import 'package:hedieaty/models/user.dart';
import 'package:hedieaty/shared/components/error_component.dart';
import 'package:hedieaty/shared/components/list.dart';
import 'package:provider/provider.dart';

import '../../views/event_list_page.dart';
import '../theme.dart';

Widget defaultDrawer(UserModel user, UserController userController, BuildContext parentContext) => Builder(builder: (parentContext) {
      final TextEditingController usernameController = TextEditingController();
      final TextEditingController emailController = TextEditingController();

      return Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
                decoration: BoxDecoration(
                  color: Theme.of(parentContext).colorScheme.secondary,
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: Provider.of<ThemeColorData>(parentContext).isDark
                              ? const Icon(Icons.wb_sunny_rounded)
                              : const Icon(Icons.nightlight_round_rounded),
                          onPressed: () {
                            Provider.of<ThemeColorData>(parentContext, listen: false)
                                .toggleTheme();
                          },
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 42,
                          backgroundImage: user.profileImage != null
                              ? NetworkImage(user.profileImage!)
                              : const AssetImage('assets/images/avater.png')
                                  as ImageProvider,
                        ),
                        const SizedBox(width: 16),
                        Text(
                          user.username,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                          ),
                        ),
                      ],
                    ),
                  ],
                )),
            ListTile(
              title: const Text('Profile'),
              onTap: () {
                Navigator.pushNamed(parentContext, '/profile');
              },
              leading: const Icon(Icons.person),
            ),
            ListTile(
              title: const Text('My Event List'),
              onTap: () {
                Navigator.of(parentContext).push(
                  MaterialPageRoute(
                    builder: (context) => EventListPage(
                      user: user,
                    ),
                  ),
                );
              },
              leading: const Icon(Icons.event),
            ),
            ListTile(
              title: const Text('My Pledged Gifts'),
              onTap: () {
                Navigator.pushNamed(parentContext, '/my_pledged_gifts');
              },
              leading: const Icon(Icons.card_giftcard),
            ),
            ListTile(
              title: const Text('Add Friend'),
              onTap: () {
                showDialog(
                    barrierDismissible: false,
                    context: parentContext,
                    builder: (BuildContext context) => AlertDialog(
                          title: Text('Add Friend'),
                          content: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  showGeneralDialog(
                                      context: context,
                                      pageBuilder: (context, animation,
                                              secondaryAnimation) =>
                                          SimpleDialog(
                                            title: Text('Add Friend'),
                                            children: [
                                              SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.8,
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                      12.0),
                                                  child: TextFormField(
                                                    controller: usernameController,
                                                    decoration: InputDecoration(
                                                      labelText: 'Username',
                                                      hintText:
                                                          'Enter username',
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              ElevatedButton(
                                                onPressed: () async {
                                                  Navigator.of(context).pop();
                                                  try {
                                                    await userController.addFriendByUsername(usernameController.text, context);
                                                  } catch(e) {
                                                    showError("Error", e.toString(), context);
                                                  }
                                                },
                                                style: ElevatedButton.styleFrom(
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(8.0),
                                                    ),
                                                    elevation: 0.0),
                                                child: Text('Add'),
                                              ),
                                            ],
                                          ));
                                },
                                icon: Icon(Icons.person_add),
                                label: Text('Username'),
                                style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    elevation: 0.0),
                              ),
                              ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  showGeneralDialog(
                                      context: context,
                                      pageBuilder: (context, animation,
                                              secondaryAnimation) =>
                                          SimpleDialog(
                                            title: Text('Add Friend'),
                                            children: [
                                              SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.8,
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                      12.0),
                                                  child: TextFormField(
                                                    controller: emailController,
                                                    decoration: InputDecoration(
                                                      labelText: 'Email',
                                                      hintText:
                                                          'Enter email address',
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              ElevatedButton(
                                                onPressed: () async {
                                                  Navigator.of(context).pop();
                                                  try {
                                                    await userController.addFriendByEmail(emailController.text, context);
                                                  } catch(e) {
                                                    showError("Error", e.toString(), context);
                                                  }
                                                },
                                                style: ElevatedButton.styleFrom(
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(8.0),
                                                    ),
                                                    elevation: 0.0),
                                                child: Text('Add'),
                                              ),
                                            ],
                                          ));
                                },
                                icon: Icon(Icons.email),
                                label: Text('Email'),
                                style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    elevation: 0.0),
                              )
                            ],
                          ),
                        ));
              },
              leading: const Icon(Icons.person_add),
            ),
            defaultDivider(parentContext),
            ListTile(
              title: const Text('Sign Out'),
              onTap: ()async {
                await userController.signOut(parentContext);
                Navigator.pushReplacementNamed(parentContext, '/');
              },
              leading: const Icon(Icons.logout),
            ),
          ],
        ),
      );
    });