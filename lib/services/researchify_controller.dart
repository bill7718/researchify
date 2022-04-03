import 'dart:async';

import 'package:caitlin/caitlin.dart';
import 'package:flutter/material.dart';
import 'package:injector/injector.dart';
import 'package:researchify/pages/landing_page.dart';
import 'package:researchify/pages/poc_page.dart';
import 'package:researchify/pages/show_image_page.dart';
import 'package:researchify/pages/show_useful_urls_page.dart';
import 'package:researchify/pages/show_web_page.dart';
import 'package:researchify/services/hugo_service.dart';
import 'package:serializable_data/serializable_data.dart';

import 'researchify_data.dart';

class ResearchifyController extends MappedJourneyController {
  static const String poc = 'poc';
  static const String showUrls = 'showUrls';

  @override
  String currentRoute = LandingPage.route;

  final HugoService hugo;

  ResearchifyController(UserJourneyNavigator navigator, this.state, this.hugo)
      : super(navigator);

  @override
  Map<String, dynamic> get globalEvents =>
      {poc: POCPage.route, showUrls: gotoShowUrls};

  @override
  Map<String, Map<String, dynamic>> get functionMap => {
        ShowUsefulUrlsPage.route: {
          ShowUsefulUrlsPage.selectUrlEvent: gotoShowWebPage
        },
        ShowWebPage.route: {ShowWebPage.viewImagesEvent: handleViewImages}
      };

  @override
  ResearchifyState state;

  Future<void> gotoShowUrls(context, output) async {
    var c = Completer<void>();
    state.urlContexts = await hugo.getUrls();
    currentRoute = ShowUsefulUrlsPage.route;
    navigator.goTo(context, currentRoute, this, state);
    c.complete();
    return c.future;
  }

  Future<void> gotoShowWebPage(context, output) async {
    var c = Completer<void>();
    currentRoute = ShowWebPage.route;
    state.currentUrlContext = output as HugoUrlContext;
    navigator.goTo(context, currentRoute, this,
        ShowWebPageState(state.currentUrlContext!.url));

    c.complete();
    return c.future;
  }

  Future<void> handleViewImages(context, output) async {
    var c = Completer<void>();
    state.imageUrls = output as List<String>;

    if (state.imageUrls?.isNotEmpty ?? false) {
      currentRoute = ShowImagePage.route;
      navigator.goTo(context, currentRoute, this, state);
    } else {
      currentRoute = ShowWebPage.route;
      navigator.goTo(context, currentRoute, this,  ShowWebPageState(state.currentUrlContext!.url, error: 'This page has no images'));
    }
    c.complete();
    return c.future;
  }

  Future<void> handleSkipImage(context, output) async {
    var c = Completer<void>();
    state.imageUrls?.removeAt(0);

    if (state.imageUrls?.isNotEmpty ?? false) {
      navigator.goTo(context, currentRoute, this, state);
    } else {
      currentRoute = ShowWebPage.route;
      navigator.goTo(context, currentRoute, this,
          ShowWebPageState(state.currentUrlContext!.url));
    }

    c.complete();
    return c.future;
  }

  Future<void> handleImageComment(context, output) async {
    var c = Completer<void>();
    var url = state.imageUrls?.removeAt(0);

    await hugo.addImageComment(state.currentUrlContext!.context, url!, output);


    if (state.imageUrls?.isNotEmpty ?? false) {
      navigator.goTo(context, currentRoute, this, state);
    } else {
      currentRoute = ShowWebPage.route;
      navigator.goTo(context, currentRoute, this,
          ShowWebPageState(state.currentUrlContext!.url));
    }

    c.complete();
    return c.future;
  }

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
    Injector.appInstance.registerDependency<Widget>(
        () => const ShowUsefulUrlsPage(),
        dependencyName: ShowUsefulUrlsPage.route);
    Injector.appInstance.registerDependency<Widget>(() => const ShowWebPage(),
        dependencyName: ShowWebPage.route);
  }
}

class ResearchifyState extends DataStateManager
    implements StepInput, ShowUsefulUrlsState, ShowImagePageState {
  @override
  late List<HugoUrlContext> urlContexts;

  HugoUrlContext? currentUrlContext;

  List<String>? imageUrls;

  ResearchifyState(Map<String, RelationshipSpecification> specifications,
      DatabaseReader reader, DatabaseUpdater updater)
      : super(specifications, reader, updater);

  @override
  String get imageUrl => imageUrls?.first ?? '';
}
