import 'package:flutter/material.dart';
import 'package:hedieaty/controllers/gifts.dart';
import 'package:hedieaty/controllers/user.dart';
import 'package:hedieaty/shared/components/list.dart';

import '../models/gift.dart';
import '../models/user.dart';

class PledgedGiftPage extends StatefulWidget {
  const PledgedGiftPage({super.key});

  @override
  _PledgedGiftPageState createState() => _PledgedGiftPageState();
}

class _PledgedGiftPageState extends State<PledgedGiftPage> {
  GiftsController _giftsController = GiftsController();
  UserController _userController = UserController();
  late Future<List<GiftModel>> _gifts;

  @override
  void initState() {
    super.initState();
    _gifts = _giftsController.getGiftPledgedByMe(context);
  }

  Future<UserModel?> getUser(String userid) {
    return _userController.getUser(userid, context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pledged Gift'),
      ),
      body: Center(
        child: FutureBuilder<List<GiftModel>>(
          future: _gifts,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Text('No pledged gifts found');
            }

            return ListView.separated(
              itemBuilder: (context, index) {
                final gift = snapshot.data![index];
                return FutureBuilder<UserModel?>(
                  future: getUser(gift.ownerId!),
                  builder: (context, userSnapshot) {
                    return Container(
                      margin: EdgeInsets.symmetric(vertical: 8.0),
                      child: Column(
                        children: [
                          ListTile(
                            leading: Container(
                              width: 80,
                              height: 80,
                              child: FadeInImage.assetNetwork(
                                placeholder: 'assets/images/app_icon.png',
                                image: gift.giftImageUrl!,
                                fit: BoxFit.cover,
                                imageErrorBuilder:
                                    (context, error, stackTrace) {
                                  return Image.asset(
                                      'assets/images/app_icon.png',
                                      fit: BoxFit.cover);
                                },
                              ),
                            ),
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Gift: ${gift.name}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Friend: ${userSnapshot.data?.username ?? 'Loading...'}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurfaceVariant),
                                ),
                                Text(
                                  'Deadline: ${gift.deadline}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurfaceVariant),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                SizedBox(
                                  width: 120,
                                  height: 40,
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      await _giftsController.markGiftPurchased(
                                          gift, context);
                                      setState(() {
                                        _gifts = _giftsController
                                            .getGiftPledgedByMe(context);
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          Theme.of(context).colorScheme.primary,
                                      foregroundColor: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                    ),
                                    child: Text('Purchased'),
                                  ),
                                ),
                                SizedBox(width: 8),
                                SizedBox(
                                  width: 120,
                                  height: 40,
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      await _giftsController.cancelGift(
                                          gift, context);
                                      setState(() {
                                        _gifts = _giftsController
                                            .getGiftPledgedByMe(context);
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Theme.of(context)
                                          .highlightColor
                                          .withOpacity(0.6),
                                      foregroundColor:
                                          Theme.of(context).colorScheme.onError,
                                    ),
                                    child: Text('Cancel'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              separatorBuilder: (context, index) {
                return defaultDivider(context);
              },
              itemCount: snapshot.data!.length,
            );
          },
        ),
      ),
    );
  }
}
