import 'package:caitlin/caitlin.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:researchify/services/researchify_data.dart';
import 'package:researchify/widgets/researchify_scaffold.dart';
import 'package:waterloo/data_object_widgets.dart';
import 'package:waterloo/waterloo.dart';

class CreateTagPage extends StatelessWidget {
  static const String route = 'CreateTagPage';

  const CreateTagPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    DataObjectJourneyFormInputState i =
        Provider.of<StepInput>(context) as DataObjectJourneyFormInputState;
    var textProvider = Provider.of<WaterlooTextProvider>(context);


    final GlobalKey formKey = GlobalKey();

    final error = FormError();
    error.error = textProvider.get(i.initialError) ?? '';

    return ResearchifyScaffold(
        subtitle: 'Create Tag',
        body: Form(
          key: formKey,
          child: Container(
              margin: const EdgeInsets.all(25),
              constraints: const BoxConstraints.tightFor(width: 300),
              child: Column(
                children: [
                  SizedBox (
                  width: 300,
                  child : WaterlooFormMessage(error: error,text: i.formMessage,)),
                  DataObjectWidget(
                      data: i.data,
                      fieldName: Tag.nameLabel,
                      specifications: i.specifications,
                      relationships: i.relationships),

                  SizedBox (
                    width: 300,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                      const WaterlooEventButton(
                        text: 'Back',
                        event: UserJourneyController.backEvent,
                      ),
                    WaterlooEventButton(
                      text: 'Save',
                      event: UserJourneyController.saveEvent,
                      payload: ()=> i.data,
                      formKey: formKey,
                    ),

                  ])
                  )]),
              )),
        );
  }
}
