import 'dart:async';

import 'package:caitlin/caitlin.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:researchify/widgets/researchify_scaffold.dart';
import 'package:waterloo/waterloo.dart';
import 'package:webview_windows/webview_windows.dart';

class ShowWebPage extends StatelessWidget {
  static const String route = 'ShowWebPage';

  static const String viewImagesEvent = 'viewImages';

  const ShowWebPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ShowWebPageState state =
        Provider.of<StepInput>(context) as ShowWebPageState;
    var handler = Provider.of<WaterlooEventHandler>(context);

    return ResearchifyScaffold(
        subtitle: 'Show web Page',
        body: FutureBuilder<WebviewController>(
            future: getController(state.url, context, handler),
            builder: (BuildContext context,
                AsyncSnapshot<WebviewController> snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return Stack(children: [
                  Webview(snapshot.data!),
                   if (state.error != null) Positioned(
                      left: 50, top: 50,
                      child: Card (
                          child: Container (
                            margin: EdgeInsets.all(5),
                        child : Text(
                        state.error!,
                        style: Theme.of(context).textTheme.headline5?.copyWith(color: Colors.red),
                      )))),
                  Positioned(
                      right: 50,
                      bottom: 50,
                      child: IconButton(
                          icon: const Icon(
                            Icons.camera_alt,
                          ),
                          onPressed: () async {
                            snapshot.data?.executeScript('''
                            var images = document.getElementsByTagName('img'); 
                            var srcList = [];
                            for(var i = 0; i < images.length; i++) {
                                  srcList.push(images[i].src);
                             }
                             window.chrome.webview.postMessage({"images": srcList });
                                                                                     ''');
                          }))
                ]);
              }

              return Container();
            }));
  }

  Future<WebviewController> getController(String url, BuildContext context, WaterlooEventHandler handler) async {
    var c = Completer<WebviewController>();
    final _controller = WebviewController();
    await _controller.initialize();

    await _controller.setBackgroundColor(Colors.transparent);
    await _controller.setPopupWindowPolicy(WebviewPopupWindowPolicy.deny);
    await _controller.loadUrl(url);


    _controller.webMessage.listen((map) async {
      if (map['images'] != null) {
        handler.handleEvent(context, event: viewImagesEvent, output: map['images'] );
      }
    });


      c.complete(_controller);

    return c.future;
  }
}

class ShowWebPageState extends StepInput {

  ShowWebPageState(this.url, { this.error});
  final String url;
  final String? error;
}
