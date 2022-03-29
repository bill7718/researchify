import 'dart:io';

import 'package:flutter/material.dart';
import 'package:waterloo/beta/text.dart';

class ListFiles extends StatelessWidget {
  final Directory base;

  const ListFiles({Key? key, required this.base}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var files = base.listSync(recursive: true);
    var prefixLength = base.path.length;

    var widgets = <Widget>[];
    for (var f in files) {
      widgets.add(
          Draggable<FileSystemEntity>(feedback: Card(child: Headline6(f.path.substring(prefixLength))),
              child: ListTile(title: Headline6(f.path.substring(prefixLength))),
          data: f,
          ));
    }

    return Column(
      children: widgets,
    );
  }
}
