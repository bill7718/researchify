import 'dart:io';

import 'package:caitlin/caitlin.dart';
import 'package:flutter/material.dart';
import 'package:injector/injector.dart';
import 'package:provider/provider.dart';
import 'package:researchify/pages/poc_page.dart';
import 'package:researchify/services/hugo_service.dart';
import 'package:researchify/services/researchify_data.dart';
import 'package:researchify/services/researchify_navigator.dart';
import 'package:researchify/services/researchify_controller.dart';
import 'package:serializable_data/serializable_data.dart';
import 'package:waterloo/waterloo.dart';

import 'pages/landing_page.dart';
import 'services/researchify_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final i = Injector.appInstance;
  registerDependencies(i);

  runApp(MyApp(
      providers: [
        Provider<WaterlooTextProvider>.value(
            value: i.get<WaterlooTextProvider>()),
        Provider<WaterlooTheme>.value(value: i.get<WaterlooTheme>()),
        Provider<WaterlooEventHandler>.value(value: i.get<WaterlooEventHandler>()),
        Provider<ResearchifyTheme>.value(value: i.get<ResearchifyTheme>()),
      ],
      theme: researchifyTheme(),
      child:
          // Injector.appInstance.get<Widget>(dependencyName: LandingPage.route)
          const POCPage()
  ));
}

void registerDependencies(Injector i) {
  var file = File(Directory.current.path + '/data.json');
  var fb = LocalData(file);
  var reader = DatabaseReader(fb);
  var updater = DatabaseUpdater(fb);
  var state = ResearchifyState(relationshipSpecification, reader, updater);
  var text = InitialisedTextProvider([dataText]);
  var hugo = HugoService(Directory('G:\\My Drive\\research_app\\futures'),  Crypto());

  i.registerSingleton<WaterlooTextProvider>(() => text);
  i.registerSingleton<UserJourneyNavigator>(() => ResearchifyNavigator());
  i.registerSingleton<ResearchifyTheme>(() => ResearchifyTheme());
  i.registerSingleton<WaterlooTheme>(() => i.get<ResearchifyTheme>());
  i.registerSingleton<WaterlooEventHandler>(
      () => ResearchifyController(i.get<UserJourneyNavigator>(), state, hugo));

  ResearchifyController.registerDependencies();
  registerDataDependencies();
}
