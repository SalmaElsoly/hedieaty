import 'package:flutter/material.dart';
import 'package:hedieaty/models/event.dart';
import 'package:page_transition/page_transition.dart';

import '../controllers/gifts.dart';

import '../models/gift.dart';
import '../shared/components/cards.dart';
import 'gift_detail_page.dart';

class FriendGiftListPage extends StatefulWidget {
  EventModel? event;
  FriendGiftListPage({super.key, this.event});

  @override
  State<FriendGiftListPage> createState() => _FriendGiftListPageState();
}

class _FriendGiftListPageState extends State<FriendGiftListPage> {
  late Future<List<GiftModel>> _giftsFuture;
  final GiftsController _giftsController = GiftsController.instance;
  GiftCategory? selectedCategory;
  GiftStatus? selectedStatus;

  @override
  void initState() {
    super.initState();
    _giftsFuture = _giftsController.getGifts(widget.event!.id!, context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.card_giftcard,
                color: Theme.of(context).colorScheme.secondary),
            SizedBox(width: 8),
            const Text('Friend\'s Gift list'),
          ],
        ),
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
              } else if (result == 'filter_category') {
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
              } else if (result == 'filter_status') {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Filter by Status'),
                      content: DropdownButton<GiftStatus>(
                        value: selectedStatus,
                        hint: Text('Select Status'),
                        isExpanded: true,
                        items: [
                          DropdownMenuItem<GiftStatus>(
                            value: null,
                            child: Text('All Statuses'),
                          ),
                          ...GiftStatus.values.map((status) {
                            return DropdownMenuItem<GiftStatus>(
                              value: status,
                              child: Text(status.name),
                            );
                          }).toList(),
                        ],
                        onChanged: (GiftStatus? value) {
                          setState(() {
                            selectedStatus = value;
                            Navigator.pop(context);
                          });
                        },
                      ),
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
                value: 'filter_category',
                child: Text('Filter by Category'),
              ),
              const PopupMenuItem<String>(
                value: 'filter_status',
                child: Text('Filter by Status'),
              ),
            ],
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(180.0),
          child: eventDetailCard(context, widget.event),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).scaffoldBackgroundColor,
              Theme.of(context).primaryColor.withOpacity(0.2),
              Theme.of(context).colorScheme.surface.withOpacity(0.1),
              Theme.of(context).primaryColor.withOpacity(0.2),
            ],
          ),
        ),
        child: FutureBuilder<List<GiftModel>>(
          future: _giftsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
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

            if (selectedStatus != null) {
              gifts =
                  gifts.where((gift) => gift.status == selectedStatus).toList();
            }

            return ListView.separated(
              padding: EdgeInsets.symmetric(vertical: 16),
              itemBuilder: (BuildContext context, int index) {
                final gift = gifts[index];
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Theme.of(context).cardColor.withOpacity(0.7),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).shadowColor.withOpacity(0.05),
                        blurRadius: 4,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    leading: CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.transparent,
                      child: FadeInImage.assetNetwork(
                        placeholder: 'assets/images/app_icon.png',
                        image: gift.giftImageUrl!,
                        fit: BoxFit.cover,
                        imageErrorBuilder: (context, error, stackTrace) {
                          return Image.asset('assets/images/app_icon.png',
                              fit: BoxFit.cover);
                        },
                      ),
                    ),
                    title: Text(
                      gift.name,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onTap: () {
                      Navigator.push(
                          context,
                          PageTransition(
                              child: GiftDetailPage(gift: gift),
                              type: PageTransitionType.rightToLeftWithFade));
                    },
                    trailing: gift.status == GiftStatus.unpledged
                        ? Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .secondary
                                  .withOpacity(0.8),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Unpledged',
                              style: TextStyle(
                                color:
                                    Theme.of(context).colorScheme.onSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          )
                        : (gift.status == GiftStatus.pledged
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
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              )
                            : Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.greenAccent.withOpacity(0.8),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  'Purchased',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              )),
                  ),
                );
              },
              separatorBuilder: (BuildContext context, int index) {
                return SizedBox(height: 8);
              },
              itemCount: gifts.length,
            );
          },
        ),
      ),
    );
  }
}
