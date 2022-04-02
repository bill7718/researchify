

import 'dart:async';

import 'package:waterloo/waterloo.dart';


class HarnessEventHandler extends WaterlooEventHandler {
  @override
  Future<void> handleEvent(context, {String event = '', output}) {
    var c = Completer<void>();
    print('$event : ${output.toString()}');

    c.complete();
    return c.future;
  }

  @override
  void handleException(context, ex, StackTrace? st) {
    print('${ex.toString()} : ${st.toString()}');
  }


}