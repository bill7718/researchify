import 'dart:async';

import 'package:caitlin/caitlin.dart';
import 'package:flutter/material.dart';
import 'package:injector/injector.dart';
import 'package:researchify/pages/create_tag_page.dart';
import 'package:researchify/pages/landing_page.dart';
import 'package:researchify/pages/poc_page.dart';
import 'package:researchify/pages/tag_file.dart';
import 'package:serializable_data/serializable_data.dart';

import 'researchify_data.dart';

class ResearchifyController extends MappedJourneyController {
  static const String createTag = 'createTag';
  static const String tagFile = 'tagFile';
  static const String poc = 'poc';

  @override
  String currentRoute = LandingPage.route;

  ResearchifyController(UserJourneyNavigator navigator, this.state)
      : super(navigator);

  @override
  Map<String, dynamic> get globalEvents => {
        createTag: gotoCreateTagPage,
        tagFile: gotoTagFilePage,
        poc: POCPage.route

      };

  @override
  Map<String, Map<String, dynamic>> get functionMap => {
        CreateTagPage.route: {
          UserJourneyController.saveEvent: handleCreateTag,
          UserJourneyController.backEvent: LandingPage.route
        },
        TagFilePage.route: {TagFilePage.addTagEvent: handleAddTag}
      };

  @override
  ResearchifyState state;

  Future<void> handleCreateTag(context, output) async {
    var tags = await state.reader
        .query<Tag>(field: Tag.nameLabel, value: output.get(Tag.nameLabel));

    if (tags.isNotEmpty) {
      navigator.goTo(
          context,
          currentRoute,
          this,
          DataObjectJourneyFormInputState(output,
              specifications: dataSpecification(),
              initialError: Tag.duplicateTagError));
    } else {
      state.setState(output);
      state.save();
      navigator.goTo(context, LandingPage.route, this, const EmptyStepInput());
    }
  }

  Future<void> gotoCreateTagPage(context, output) async {
    var c = Completer<void>();
    Tag tag = await state.getOrCreate<Tag>();
    currentRoute = CreateTagPage.route;
    navigator.goTo(
        context,
        currentRoute,
        this,
        DataObjectJourneyFormInputState(tag,
            specifications: dataSpecification()));

    c.complete();
    return c.future;
  }

  Future<void> gotoTagFilePage(context, output) async {
    var c = Completer<void>();

    var tags = await state.reader.query<Tag>();

    currentRoute = TagFilePage.route;
    navigator.goTo(
        context,
        currentRoute,
        this,
        DataObjectJourneyFormInputState(tags,
            specifications: dataSpecification()));

    c.complete();
    return c.future;
  }

  Future<void> handleAddTag(context, output) async {
    var c = Completer<void>();

    var artefact = await state.queryOrCreate<Artefact>(
        field: Artefact.nameLabel, value: output.first);
    artefact.addTag(output.last);
    artefact.set(Artefact.nameLabel, output.first);
    await state.setState(artefact);
    var tags = await state.reader.query<Tag>();
    state.save();

    currentRoute = TagFilePage.route;
    navigator.goTo(
        context,
        currentRoute,
        this,
        DataObjectJourneyFormInputState(tags,
            specifications: dataSpecification()));

    c.complete();
    return c.future;
  }

  static void registerDependencies() {
    Injector.appInstance.registerDependency<Widget>(() => const LandingPage(),
        dependencyName: LandingPage.route);
    Injector.appInstance.registerDependency<Widget>(() => const CreateTagPage(),
        dependencyName: CreateTagPage.route);
    Injector.appInstance.registerDependency<Widget>(() => const TagFilePage(),
        dependencyName: TagFilePage.route);
    Injector.appInstance.registerDependency<Widget>(() => const POCPage(),
        dependencyName: POCPage.route);
  }
}

class ResearchifyState extends DataStateManager implements StepInput {
  ResearchifyState(Map<String, RelationshipSpecification> specifications,
      DatabaseReader reader, DatabaseUpdater updater)
      : super(specifications, reader, updater);
}
