import 'package:flutter/material.dart';
import 'package:hedieaty/controllers/gifts.dart';
import 'package:hedieaty/shared/components/cards.dart';
import 'package:hedieaty/shared/components/list.dart';
import 'package:hedieaty/shared/components/tabs.dart';
import 'package:hedieaty/views/gift_create_page.dart';
import 'package:hedieaty/views/gift_detail_page.dart';
import 'package:page_transition/page_transition.dart';

import '../models/event.dart';
import '../models/gift.dart';

class GiftListPage extends StatefulWidget {
  final EventModel? event;
  const GiftListPage({super.key, this.event});

  @override
  State<GiftListPage> createState() => _GiftListPageState();
}

class _GiftListPageState extends State<GiftListPage>
    with SingleTickerProviderStateMixin {
  static const List<Tab> tabs = <Tab>[
    Tab(icon: Icon(Icons.card_giftcard), text: 'Unpledged'),
    Tab(icon: Icon(Icons.check_circle), text: 'Pledged'),
  ];
  late Future<List<GiftModel>> _giftsFuture;
  final GiftsController _giftsController = GiftsController.instance;
  GiftCategory? selectedCategory;

  late TabController tabController;

  void onTap(int index, List<GiftModel> list) async {
    await Navigator.push(
        context,
        PageTransition(
            child: GiftDetailPage(
              gift: list[index],
              isOwner: true,
            ),
            type: PageTransitionType.rightToLeftWithFade));
    refreshGifts();
  }

  void onDelete(int index, List<GiftModel> list) async {
    await _giftsController.deleteGift(list[index], widget.event!, context);
    refreshGifts();
  }

  void onEdit(int index, List<GiftModel> list) async {
    final result = await Navigator.push(
      context,
      PageTransition(
          child: GiftCreatePage(
            event: widget.event,
            gift: list[index],
          ),
          type: PageTransitionType.topToBottom),
    );
    if (result != null) {
      refreshGifts();
    }
  }

  void refreshGifts() {
    setState(() {
      _giftsFuture = _giftsController.getGifts(widget.event!.id!, context);
    });
  }

  @override
  void initState() {
    super.initState();
    tabController = TabController(vsync: this, length: tabs.length);
    _giftsFuture = _giftsController.getGifts(widget.event!.id!, context);
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Gift List'),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.filter_list),
            onSelected: (String result) {
              if (result == 'name') {
                setState(() {
                  _giftsFuture.then((gifts) {
                    gifts.sort((a, b) => a.name.compareTo(b.name));
                  });
                });
              } else if (result == 'filter') {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return FutureBuilder<List<GiftModel>>(
                      future: _giftsFuture,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return Center(child: CircularProgressIndicator());
                        }

                        final categories = GiftCategory.values.toList();

                        return AlertDialog(
                          title: Text('Filter by Category'),
                          content: DropdownButton<GiftCategory>(
                            value: selectedCategory,
                            hint: Text('Select Category'),
                            isExpanded: true,
                            items: [
                              DropdownMenuItem<GiftCategory>(
                                value: null,
                                child: Text('All Categories'),
                              ),
                              ...categories.map((category) {
                                return DropdownMenuItem<GiftCategory>(
                                  value: category,
                                  child: Text(category.name),
                                );
                              }).toList(),
                            ],
                            onChanged: (GiftCategory? value) {
                              setState(() {
                                selectedCategory = value;
                                Navigator.pop(context);
                              });
                            },
                          ),
                        );
                      },
                    );
                  },
                );
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'name',
                child: Text('Sort by Name'),
              ),
              const PopupMenuItem<String>(
                value: 'filter',
                child: Text('Filter by Category'),
              ),
            ],
          ),
        ],
        bottom: PreferredSize(
            preferredSize: Size.fromHeight(300.0),
            child: Column(
              children: [
                eventDetailCard(context, widget.event),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 4.0),
                  child: InkWell(
                    key: Key('addGiftButton'),
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        PageTransition(
                            child: GiftCreatePage(
                              event: widget.event,
                            ),
                            type: PageTransitionType.bottomToTop),
                      );
                      if (result != null) {
                        refreshGifts();
                      }
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: double.infinity,
                      height: 48,
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Theme.of(context).cardColor,
                              Theme.of(context).primaryColor,
                              Theme.of(context).colorScheme.secondary,
                              Theme.of(context).cardColor
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Theme.of(context).cardColor,
                            width: 1,
                          )),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Add Gift',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                defaultTabBar(context, tabs, tabController)
              ],
            )),
      ),
      body: FutureBuilder<List<GiftModel>>(
        future: _giftsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No gifts found'));
          }

          var gifts = snapshot.data!;

          if (selectedCategory != null) {
            gifts = gifts
                .where((gift) => gift.category == selectedCategory)
                .toList();
          }

          final pledgedGifts = gifts
              .where((gift) =>
                  gift.status == GiftStatus.pledged ||
                  gift.status == GiftStatus.purchased)
              .toList();
          final unpledgedGifts = gifts
              .where((gift) => gift.status == GiftStatus.unpledged)
              .toList();

          return TabBarView(
            controller: tabController,
            children: [
              unpledgedGifts.isEmpty
                  ? const Center(child: Text('No unpledged gifts'))
                  : eventAndGiftList(
                      context, unpledgedGifts, onTap, true, onDelete, onEdit),
              pledgedGifts.isEmpty
                  ? const Center(child: Text('No pledged gifts'))
                  : ListView.separated(
                      itemBuilder: (BuildContext context, int index) {
                        return ListTile(
                          leading: CircleAvatar(
                            radius: 24,
                            backgroundColor: Colors.transparent,
                            child: FadeInImage.assetNetwork(
                              placeholder: 'assets/images/app_icon.png',
                              image: pledgedGifts[index].giftImageUrl!,
                              fit: BoxFit.cover,
                              imageErrorBuilder: (context, error, stackTrace) {
                                return Image.asset('assets/images/app_icon.png',
                                    fit: BoxFit.cover);
                              },
                            ),
                          ),
                          title: Text(pledgedGifts[index].name),
                          onTap: () {
                            onTap(index, pledgedGifts);
                          },
                          trailing:
                              pledgedGifts[index].status == GiftStatus.pledged
                                  ? Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .highlightColor
                                            .withOpacity(0.8),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: const Text(
                                        'Pledged',
                                        style: TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    )
                                  : Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: Colors.greenAccent,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        'Purchased',
                                        style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSecondary,
                                        ),
                                      ),
                                    ),
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) {
                        return defaultDivider(context);
                      },
                      itemCount: pledgedGifts.length)
            ],
          );
        },
      ),
    );
  }
}
