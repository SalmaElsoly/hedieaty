import 'package:flutter/material.dart';
import 'package:hedieaty/models/event.dart';
import 'package:hedieaty/models/gift.dart';


Widget eventAndGiftList<T>(BuildContext context, List<T> list,
    Function onTap, bool trailing, dynamic onDelete, dynamic onEdit) {
  if (list.isEmpty) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.hourglass_empty, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No items found',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500
            ),
          ),
        ],
      ),
    );
  }

  return ListView.separated(
    itemCount: list.length,
    separatorBuilder: (context, index) => defaultDivider(context),
    itemBuilder: (context, index) {
      final item = list[index];
      String name = '';
      String? imageUrl;

      if (item is EventModel) {
        name = item.name;
      } else if (item is GiftModel) {
        name = item.name;
        imageUrl = item.giftImageUrl;
      }

      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.05),
              Theme.of(context).colorScheme.secondary.withOpacity(0.05),
            ],
          ),
        ),
        child: ListTile(
          title: Text(
            name,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          leading: imageUrl != null
              ? Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
            radius: 24,
            backgroundColor: Colors.transparent,
            child: ClipOval(
              child: FadeInImage.assetNetwork(
                placeholder: 'assets/images/app_icon.png',
                image: imageUrl,
                fit: BoxFit.cover,
                imageErrorBuilder: (context, error, stackTrace) {
                  return Image.asset('assets/images/app_icon.png', fit: BoxFit.cover);
                },
              ),
            ),
          )
                )              : Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: item is GiftModel ? [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ] : null,
                    gradient: item is EventModel ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Theme.of(context).colorScheme.primary.withOpacity(0.2),
                        Theme.of(context).colorScheme.secondary.withOpacity(0.2),
                      ],
                    ) : null,
                  ),
                  child: CircleAvatar(
                    radius: 24,
                    backgroundColor: item is EventModel ? Colors.transparent : null,
                    backgroundImage: item is GiftModel ? AssetImage('assets/images/app_icon.png') : null,
                    child: item is EventModel ? Icon(Icons.event, color: Theme.of(context).colorScheme.primary) : null,
                  ),
                ),          trailing: trailing
              ? SizedBox(
                  width: 100,
                  child: Row(
                    children: [
                      IconButton(
                          onPressed: () {
                            onEdit(index, list);
                          },
                          style:
                              ButtonStyle(iconSize: WidgetStatePropertyAll(20.0)),
                          icon: Icon(Icons.edit, color: Theme.of(context).colorScheme.primary)),
                      IconButton(
                          onPressed: () {
                            onDelete(index, list);
                          },
                          style:
                              ButtonStyle(iconSize: WidgetStatePropertyAll(20.0)),
                          icon: Icon(Icons.delete, color: Theme.of(context).colorScheme.error)),
                    ],
                  ),
                )
              : null,
          onTap: () {
            onTap(index, list);
          },
        ),
      );
    },
  );
}

Widget defaultDivider(BuildContext context) {
  return Padding(
    padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * 0.1),
    child: Container(
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Theme.of(context).colorScheme.onSecondary.withOpacity(0.8),
            Theme.of(context).colorScheme.secondary.withOpacity(0.8),
            Theme.of(context).colorScheme.secondary.withOpacity(0.8),
            Theme.of(context).colorScheme.onSecondary.withOpacity(0.8),
          ],
          stops: const [0.0, 0.2, 0.8, 1.0],
        ),
      ),
    ),
  );
}