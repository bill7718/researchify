import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:researchify/services/researchify_controller.dart';
import 'package:waterloo/waterloo.dart';

class ResearchifyLeftMenu extends StatelessWidget {
  const ResearchifyLeftMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Container (
      margin: const EdgeInsets.all(25),
        child: Column(
      children: const [
         WaterlooEventButton(
          text: 'Review Known Web Pages',
          event: ResearchifyController.showUrls,
        ),
        WaterlooEventButton(
          text: 'Show POC Page',
          event: ResearchifyController.poc,
        ),

      ],
    ));
  }



}

