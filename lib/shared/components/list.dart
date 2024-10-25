import 'package:flutter/material.dart';

Widget eventAndGiftList(BuildContext context, List<Map<String, dynamic>> list,
    Function onTap, bool trailing, dynamic onDelete, dynamic onEdit) {
  return ListView.builder(
    itemCount: list.length,
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
