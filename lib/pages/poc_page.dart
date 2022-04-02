import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:researchify/dependencies.dart';
import 'package:researchify/services/hugo_service.dart';

import 'package:researchify/widgets/researchify_scaffold.dart';
import 'package:researchify/widgets/web_page_evaluation.dart';

class POCPage extends StatelessWidget {
  static const String route = 'POCPage';

  const POCPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var hugo = HugoService(Directory('G:\\My Drive\\research_app\\futures'));
    var currentContext = NotifiableUrlContext();

    return FutureBuilder<List<HugoUrlContext>>(
        future: hugo.getUrls(),
        builder: (BuildContext context,
            AsyncSnapshot<List<HugoUrlContext>> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            var widgets = <Widget>[];
            for (HugoUrlContext urlContext in snapshot.data ?? []) {
              widgets.add(ListTile(
                title: Text(urlContext.url.split('//').last),
                subtitle: Text(urlContext.context.split('\\').last),
                onTap: () {
                  currentContext.context = urlContext;
                },
              ));
            }
            return ChangeNotifierProvider<NotifiableUrlContext>.value(
              value: currentContext,
              child: Consumer<NotifiableUrlContext>(
                builder: (context, urlContext, _) {
                  if (urlContext.context == null) {
                    return ResearchifyScaffold(
                        subtitle: 'POC',
                        body: ListView(
                          children: widgets,
                        ));
                  } else {
                    return ResearchifyScaffold(
                        subtitle: 'POC',
                        body: WebPageEvaluation(url: urlContext.context!.url, crypto: Crypto(),),
                        rhPanel: ListView(
                        children: widgets,
                    ),
                        );

                  }

                }
              ),
            );



          } else {
            return Container();
          }
        });
  }
}

class NotifiableUrlContext with ChangeNotifier {

  HugoUrlContext? _context;


  HugoUrlContext? get context =>_context;
  set context(HugoUrlContext? urlContext) {
    _context = urlContext;
    notifyListeners();
  }
}
