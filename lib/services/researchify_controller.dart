import 'dart:async';

import 'package:caitlin/caitlin.dart';
import 'package:flutter/material.dart';
import 'package:injector/injector.dart';
import 'package:researchify/pages/landing_page.dart';
import 'package:researchify/pages/poc_page.dart';
import 'package:serializable_data/serializable_data.dart';

import 'researchify_data.dart';

class ResearchifyController extends MappedJourneyController {
  static const String poc = 'poc';

  @override
  String currentRoute = LandingPage.route;

  ResearchifyController(UserJourneyNavigator navigator, this.state)
      : super(navigator);

  @override
  Map<String, dynamic> get globalEvents => {
        poc: POCPage.route

      };

  @override
  Map<String, Map<String, dynamic>> get functionMap => {

      };

  @override
  ResearchifyState state;


  Future<void> saveUrlNote(context, output) async {
    var c = Completer<void>();

    var urlNote = await state.queryOrCreate<UrlNotes>(
        field: UrlNotes.urlLabel, value: output.first);
    urlNote.set(UrlNotes.commentLabel, output[1]);

    c.complete();
    return c.future;
  }

  Future<void> saveUrlHash(context, output) async {
    var c = Completer<void>();

    var urlNote = await state.queryOrCreate<UrlNotes>(
        field: UrlNotes.urlLabel, value: output.first);
    urlNote.set(UrlNotes.hashLabel, output[1]);

    c.complete();
    return c.future;
  }

  static void registerDependencies() {
    Injector.appInstance.registerDependency<Widget>(() => const LandingPage(),
        dependencyName: LandingPage.route);
    Injector.appInstance.registerDependency<Widget>(() => const POCPage(),
        dependencyName: POCPage.route);
  }
}

class ResearchifyState extends DataStateManager implements StepInput {
  ResearchifyState(Map<String, RelationshipSpecification> specifications,
      DatabaseReader reader, DatabaseUpdater updater)
      : super(specifications, reader, updater);
}
