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
            style: TextStyle(fontSize: 18, color: Colors.grey),
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

      return ListTile(
        title: Text(name),
        leading: imageUrl != null
            ? CircleAvatar(
                backgroundImage: NetworkImage(imageUrl),
                radius: 24,
              )
            : null,
        trailing: trailing
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
                        icon: Icon(Icons.edit)),
                    IconButton(
                        onPressed: () {
                          onDelete(index, list);
                        },
                        style:
                            ButtonStyle(iconSize: WidgetStatePropertyAll(20.0)),
                        icon: Icon(Icons.delete)),
                  ],
                ),
              )
            : null,
        onTap: () {
          onTap(index, list);
        },
      );
    },
  );
}

Widget defaultDivider(BuildContext context) {
  return Padding(
    padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * 0.1),
    child: Divider(
      height: 3,
      color: Theme.of(context).colorScheme.secondary,
    ),
  );
}