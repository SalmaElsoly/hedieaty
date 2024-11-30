import 'package:flutter/material.dart';
import 'package:hedieaty/shared/components/list.dart';
import 'package:provider/provider.dart';

import '../theme.dart';

Widget defaultDrawer(String image, String name) => Builder(builder: (context) {
      return Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: Provider.of<ThemeColorData>(context).isDark
                              ? const Icon(Icons.wb_sunny_rounded)
                              : const Icon(Icons.nightlight_round_rounded),
                          onPressed: () {
                            Provider.of<ThemeColorData>(context, listen: false)
                                .toggleTheme();
                          },
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 42,
                          backgroundImage: AssetImage(image),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          name,
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
                Navigator.pushNamed(context, '/profile');
              },
              leading: const Icon(Icons.person),
            ),
            ListTile(
              title: const Text('My Event List'),
              onTap: () {
                Navigator.pushNamed(context, '/my_event_list');
              },
              leading: const Icon(Icons.event),
            ),
            ListTile(
              title: const Text('My Pledged Gifts'),
              onTap: () {
                Navigator.pushNamed(context, '/my_pledged_gifts');
              },
              leading: const Icon(Icons.card_giftcard),
            ),
            ListTile(
              title: const Text('Add Friend'),
              onTap: () {
                showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                          title: Text('Add Friend'),
                          content: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () {},
                                icon: Icon(Icons.person_add),
                                label: Text('Contact'),
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
                                              Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.8, // Adjust the width as needed
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                      12.0),
                                                  child: TextFormField(
                                                    decoration: InputDecoration(
                                                      labelText: 'Phone Number',
                                                      hintText:
                                                          'Enter phone number',
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              ElevatedButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                child: Text('Add'),
                                                style: ElevatedButton.styleFrom(
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.0),
                                                    ),
                                                    elevation: 0.0),
                                              ),
                                            ],
                                          ));
                                },
                                icon: Icon(Icons.phone_android),
                                label: Text('Number'),
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
            defaultDivider(context),
            ListTile(
              title: const Text('Sign Out'),
              onTap: () {
                Navigator.pushNamed(context, '/sign_in');
              },
              leading: const Icon(Icons.logout),
            ),
          ],
        ),
      );
    });
