import 'package:flutter/material.dart';

Widget eventAndGiftList(BuildContext context, List<dynamic> list,
    Function onTap, bool trailing, dynamic onDelete, dynamic onEdit) {
  return ListView.separated(
    itemCount: list.length,
    separatorBuilder: (context, index) => defaultDivider(context),
    itemBuilder: (context, index) {
      return ListTile(
        title: Text(list[index]['name'].toString()),
        leading: list[index].containsKey('image')
            ? CircleAvatar(
                backgroundImage: NetworkImage(list[index]['image'].toString()),
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
