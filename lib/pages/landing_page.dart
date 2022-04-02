
import 'package:flutter/material.dart';
import 'package:researchify/widgets/researchify_scaffold.dart';

class LandingPage extends StatelessWidget {

  static const String route = 'LandingPage';

  const LandingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return ResearchifyScaffold(
      subtitle: 'Welcome',
        body: Container());
  }
}



