import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:researchify/dependencies.dart';
import 'package:researchify/services/hugo_service.dart';
import 'package:researchify/widgets/researchify_scaffold.dart';

class ShowUsefulUrlsPage extends StatelessWidget {
  static const String route = 'ShowUsefulUrlsPage';
  static const String selectUrlEvent = 'selectUrl';

  const ShowUsefulUrlsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ShowUsefulUrlsState state =
        Provider.of<StepInput>(context) as ShowUsefulUrlsState;
    var handler = Provider.of<WaterlooEventHandler>(context);

    var widgets = <Widget>[];

    for (HugoUrlContext urlContext in state.urlContexts) {
      widgets.add(ListTile(
        title: Text(urlContext.url.split('//').last),
        subtitle: Text(urlContext.context.split('\\').last),
        onTap: () {
          handler.handleEvent(context,
              event: selectUrlEvent, output: urlContext);
        },
      ));
    }

    return ResearchifyScaffold(subtitle: 'Show Useful Urls', body:
    ListView(
      children: widgets,
    ));
  }
}

abstract class ShowUsefulUrlsState extends StepInput {
  List<HugoUrlContext> get urlContexts;
}