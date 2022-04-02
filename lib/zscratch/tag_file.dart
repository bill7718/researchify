import 'dart:io';

import 'package:caitlin/caitlin.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:researchify/services/researchify_data.dart';
import 'package:researchify/widgets/list_files.dart';
import 'package:researchify/widgets/researchify_scaffold.dart';
import 'package:waterloo/waterloo.dart';

class TagFilePage extends StatelessWidget {
  static const String route = 'TagFilePage';

  static const String addTagEvent = 'addTag';

  const TagFilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    DataObjectJourneyFormInputState i =
        Provider.of<StepInput>(context) as DataObjectJourneyFormInputState;
    var textProvider = Provider.of<WaterlooTextProvider>(context);
    var handler = Provider.of<WaterlooEventHandler>(context);

    final GlobalKey formKey = GlobalKey();

    final error = FormError();
    //error.error = textProvider.get(i.initialError) ?? '';

    var folder = Directory(Directory.current.path + '\\notes\\');

    var tagWidgets = <Widget>[];
    for (Tag tag in i.data) {
      tagWidgets.add(
        DragTarget<FileSystemEntity>(
          builder: (_, __, ___) {
            return ListTile(title: Headline6(tag.get(Tag.nameLabel) ?? ''));
          },
          onAccept: (f) {
            handler.handleEvent(context, event: addTagEvent, output: [f.path, tag.get(Tag.nameLabel)]);
          },
          onWillAccept: (data) => true,
        ),
      );
    }

    return ResearchifyScaffold(
      subtitle: 'Tag a File',
      body: Row(children: [
        Container(
          margin: const EdgeInsets.all(25),
          constraints: const BoxConstraints.tightFor(width: 400),
          child: ListFiles(
            base: folder,
          ),
        ),
        Container(
            margin: const EdgeInsets.all(25),
            constraints: const BoxConstraints.tightFor(width: 400),
            child: Column(
              children: tagWidgets,
            ))
      ]),
    );
  }
}
