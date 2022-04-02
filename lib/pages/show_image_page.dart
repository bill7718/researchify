
import 'package:caitlin/caitlin.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:researchify/widgets/researchify_scaffold.dart';
import 'package:waterloo/waterloo.dart';

class ShowImagePage extends StatelessWidget {

  static const String route = 'ShowImagePage';

  static const String skipEvent = 'skip';
  static const String commentEvent = 'comment';

  const ShowImagePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    ShowImagePageState state =
    Provider.of<StepInput>(context) as ShowImagePageState;
    var comment = '';
    var formKey = GlobalKey();

    return ResearchifyScaffold(
      subtitle: 'Show Image',
        body: Container (
          margin: const EdgeInsets.all(25),
            child: Form (
              key: formKey,
            child: ListView (
          children: [
            Image.network(state.imageUrl),
            WaterlooTextField(
              help: 'Comment on this image for the web site using Markdown format for the text',
              label: 'Comment',
              maxLines: 10,
              valueBinder: (v)=>comment = v,
              validator: (v) {
                if (v?.isEmpty ?? true) {
                  return 'Please provide a comment or skip this image';
                }
                return null;
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                const WaterlooEventButton(text: 'Skip', event: skipEvent),
                WaterlooEventButton(text: 'Add to Web Site, ', event: commentEvent, payload: ()=>comment, formKey: formKey,)
              ],
            )
          ],
        ))));
  }
}

abstract class ShowImagePageState extends StepInput {
  
  String get imageUrl;
  
}



