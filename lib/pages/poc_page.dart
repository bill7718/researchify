import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image/image.dart';
import 'package:researchify/widgets/researchify_scaffold.dart';
import 'package:serializable_data/serializable_data.dart';
import 'package:webview_windows/webview_windows.dart';
import 'package:screenshot/screenshot.dart';
import 'package:http/http.dart' as http;

class POCPage extends StatelessWidget {
  static const String route = 'POCPage';

  const POCPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var site = 'https://www.volkswagen-newsroom.com/en/press-releases';
    ScreenshotController screenshotController = ScreenshotController();
    ScreenshotController screenshotController2 = ScreenshotController();
    return Screenshot (
      controller: screenshotController,
        child: ResearchifyScaffold(
        subtitle: 'Proof of Concept',
        body: FutureBuilder<WebviewController>(
            future: getController(site),
            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container();
              }
              if (snapshot.connectionState == ConnectionState.done) {
                return Stack(
                  children: [
                    Screenshot(
                    controller: screenshotController2,
                    child: Webview(snapshot.data)),
                    Positioned(
                        right: 50,
                        bottom: 50,
                        child: IconButton(
                          icon: const Icon(Icons.camera_alt, color: Colors.blue,),
                          onPressed: () async {
                            /* var data = await screenshotController.captureAndSave(
                               'screenShots'
                             );*/
                            WebviewController controller = snapshot.data;
                            /*
                            controller.executeScript('''
                            var header = document.head.innerHTML
                            var body = document.body.innerHTML
                            window.chrome.webview.postMessage({"header": header, "body" : body });
                                                         ''');

                             */
                            controller.executeScript('''
                            var images = document.getElementsByTagName('img'); 
                            var srcList = [];
                            for(var i = 0; i < images.length; i++) {
                                  srcList.push(images[i].src);
                             }
                             window.chrome.webview.postMessage({"images": srcList });
                                                                                     ''');

                          },

                        ))
                  ],
                );
              }
              return Container();
            })));
  }

  Future<WebviewController> getController(String url) async {
    var c = Completer<WebviewController>();
    final _controller = WebviewController();
    await _controller.initialize();

    await _controller.setBackgroundColor(Colors.transparent);
    await _controller.setPopupWindowPolicy(WebviewPopupWindowPolicy.deny);
    await _controller.loadUrl(url);

    _controller.webMessage.listen((map) async {
      /*
      var content = '<html><head> ${event['header']} </head><body>${event['body']}</body>';
      var crypto = Crypto();
      var hash = crypto.generateHash(content);
      var file = File('${Directory.current.path}/grabs/z${hash.substring(0, 8)}.html');
      file.writeAsStringSync(content);

       */

      if (map['images'] != null) {
        var crypto = Crypto();
        var images = map['images'];
        for (String url in images) {
          var response = await http.get(Uri.parse(url));
          var bytes = response.bodyBytes;
          if (url.contains('jpg')) {
            var decoder = JpegDecoder();
            var image = decoder.decodeImage(bytes);
            var encoder = PngEncoder();
            var bytes2 = encoder.encodeImage(image!);
            var hash = crypto.hash(Uint8List.fromList(bytes2));
            var file = File('${Directory.current.path}/grabs/z${hash.substring(0, 8)}.png');
            file.writeAsBytesSync(bytes2);
          } else {
            var hash = crypto.hash(Uint8List.fromList(bytes));
            var file = File('${Directory.current.path}/grabs/z${hash.substring(0, 8)}.png');
            file.writeAsBytesSync(bytes);
          }
        }
      }

      print(map);
    });

    c.complete(_controller);

    return c.future;
  }
}
