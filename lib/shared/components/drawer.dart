import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme.dart';

Widget defaultDrawer(String image, String name)=> Builder(
  builder: (context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary,
            ),
            child: Column(
              children: [ Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: Provider.of<ThemeColorData>(context).isDark ? const Icon(Icons.wb_sunny_rounded) : const Icon(Icons.nightlight_round_rounded),
                    onPressed: () {
                      Provider.of<ThemeColorData>(context, listen: false).toggleTheme();
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
            )
          ),
          ListTile(
            title: const Text('Home'),
            onTap: () {
              Navigator.pushNamed(context, '/home');
            },
          ),
          ListTile(
            title: const Text('Profile'),
            onTap: () {
              Navigator.pushNamed(context, '/profile');
            },
          ),
          ListTile(
            title: const Text('Sign Out'),
            onTap: () {
              Navigator.pushNamed(context, '/sign_in');
            },
          ),
        ],
      ),
    );
  }
);
