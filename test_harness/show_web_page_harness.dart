import 'package:caitlin/caitlin.dart';
import 'package:flutter/material.dart';
import 'package:injector/injector.dart';
import 'package:provider/provider.dart';
import 'package:researchify/main.dart';
import 'package:researchify/pages/show_useful_urls_page.dart';
import 'package:researchify/pages/show_web_page.dart';
import 'package:researchify/researchify.dart';
import 'package:researchify/services/hugo_service.dart';
import 'package:researchify/services/researchify_theme.dart';
import 'package:waterloo/waterloo.dart';

import 'harness_event_handler.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final i = Injector.appInstance;
  registerDependencies(i);
  var handler = HarnessEventHandler();
  runApp(MyApp(
      providers: [
        Provider<WaterlooTextProvider>.value(
            value: i.get<WaterlooTextProvider>()),
        Provider<WaterlooTheme>.value(value: i.get<WaterlooTheme>()),
        Provider<WaterlooEventHandler>.value(value: handler),
        Provider<StepInput>.value(value: ShowWebPageState('https://www.volkswagen-newsroom.com/en/press-releases', error: 'This is an error')),
      ],
      theme: researchifyTheme(),
      child: const ShowWebPage()));
}

