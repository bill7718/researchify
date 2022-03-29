

import 'package:flutter/material.dart';
import 'package:waterloo/waterloo.dart';

import 'researchify_left_menu.dart';

class ResearchifyScaffold extends StatelessWidget {

  final String? subtitle;
  final Widget body;
  final Widget? rhPanel;


  const ResearchifyScaffold({Key? key, required this.body, this.subtitle, this.rhPanel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return LayoutBuilder(builder: (context, constraints) {
      var availableWidth = constraints.maxWidth;

      return Scaffold(appBar: WaterlooAppBar.get(title: 'Researchify', context: context,
          subtitle: subtitle
      ),body: Row(
        children: [
          if (availableWidth > 600) const ResearchifyLeftMenu(),
          Expanded(child: body),
          if (availableWidth > 800 && rhPanel != null) Container(width: 200,),
        ],
      ),);
    });


  }




}