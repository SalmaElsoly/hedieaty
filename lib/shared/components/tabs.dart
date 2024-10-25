import 'package:flutter/material.dart';

Widget defaultTabBar(
    BuildContext context, List<Tab> tabs, TabController tabController) {
  return TabBar(
    controller: tabController,
    tabs: tabs,
    unselectedLabelColor: Theme.of(context).colorScheme.onPrimary,
    labelColor: Theme.of(context).colorScheme.secondary,
    indicatorColor: Theme.of(context).highlightColor,
  );
}
