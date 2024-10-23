import 'package:flutter/material.dart';

import '../shared/components/drawer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hedieaty'),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () { Scaffold.of(context).openDrawer(); },
              tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
            );
          },
        ),
        elevation: 6.0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      drawer: defaultDrawer('assets/images/avater.png', 'User Name', ),
      body: ListView.separated(
          itemBuilder: (BuildContext context, int index) {
            return ListTile(
              leading: const CircleAvatar(
                radius: 24,
                backgroundImage: AssetImage('assets/images/avater.png'),
              ),
              title: Text('Event $index'),
              onTap: () {
                Navigator.pushNamed(context, '/event_list');
              },
              hoverColor: Theme.of(context).hoverColor,
              enabled: true,
              trailing: Text('1', style: TextStyle(
                background: Paint()
                  ..color = Theme.of(context).primaryColor
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = 10
                  ..strokeJoin = StrokeJoin.round,
                color: Theme.of(context).colorScheme.onPrimary,
              )
              ),
            );
          },
          separatorBuilder: (BuildContext context, int index) => const Divider(
            height: 3,
            color: Colors.grey,
          ),
          itemCount:20

      ),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: () {},
        label: const Text('Add Event'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}