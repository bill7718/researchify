import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image/image.dart';
import 'package:researchify/dependencies.dart';
import 'package:webview_windows/webview_windows.dart';
import 'package:http/http.dart' as http;

///
/// Displays a web page in a way that supports research.
///
/// It provides the following capabilities
/// - on build the widgets checks the content against an (optional) hash key.
/// If the hashes match then a callback is called. This enables an external function to determine
/// if this page has been seen before.
///
/// - an option to save the web page in a system folder for later evaluation. The ability to
/// record a comment against the page is also provided.
///
/// - an option to download and save all the images in the page. Any images that have not been seen before are
/// saved for later evaluation.
///

class WebPageEvaluation extends StatelessWidget {

  static const String saveUrlNoteEvent = 'saveUrlNote';

  /// The url of the web page to display
  final String url;

  /// If provided, the widget compares the hash of the page content to this hash
  /// if the 2 hashes match then the [callback] functions is called.
  final String? hash;

  /// If provided, the widget compares the hash of the page content to [hash]
  /// if the 2 hashes match then this function is called.
  final Function? callback;

  final Crypto? crypto;

  const WebPageEvaluation(
      {Key? key, required this.url, this.hash, this.callback, this.crypto})
      : super(
          key: key,
        );

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<WebviewController>(
        future: getController(url),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            Timer t = Timer(const Duration(milliseconds: 1000), () {
              snapshot.data.executeScript('''
                    var header = document.head.innerHTML
                    var body = document.body.innerHTML
                    window.chrome.webview.postMessage({"check": true,  "header": header, "body" : body });
                    ''');
            });

            return Stack(children: [
              Webview(snapshot.data),
              Positioned(
                  right: 50,
                  bottom: 50,
                  child: IconButton(
                      icon: const Icon(
                        Icons.camera_alt,
                      ),
                      onPressed: () async {
                        snapshot.data.executeScript('''
                            var images = document.getElementsByTagName('img'); 
                            var srcList = [];
                            for(var i = 0; i < images.length; i++) {
                                  srcList.push(images[i].src);
                             }
                             window.chrome.webview.postMessage({"images": srcList });
                                                                                     ''');
                      })),
              Positioned(
                  right: 100,
                  bottom: 50,
                  child: IconButton(
                      icon: const Icon(
                        Icons.save_alt,
                      ),
                      onPressed: () async {
                        snapshot.data.executeScript('''
                    var header = document.head.innerHTML
                    var body = document.body.innerHTML
                    window.chrome.webview.postMessage({"check": false, "header": header, "body" : body });
                    ''');
                      })),
              Positioned(
                right: 150,
                bottom: 50,
                child: IconButton(
                    icon: const Icon(
                      Icons.note_add,
                    ),
                    onPressed: () async {
                      var note = await showDialog<String>(
                          context: context,
                          builder: (context) {
                            var comment = '';
                            return Dialog(
                                child: Column(
                              children: [
                                WaterlooTextField(
                                  label: 'Notes',
                                  maxLines: 5,
                                  valueBinder: (v) => comment = v,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    WaterlooTextButton(
                                      text: 'Back',
                                      exceptionHandler: () {},
                                      onPressed: () {
                                          Navigator.pop(context);
                                      },
                                    ),
                                    WaterlooTextButton(
                                      text: 'Next',
                                      exceptionHandler: () {},
                                      onPressed: () {
                                        Navigator.pop(context, comment);
                                      },

                                    )
                                  ],
                                )
                              ],
                            ));
                          });

                      if (note != null) {
                        snapshot.data.executeScript('''
                    var header = document.head.innerHTML
                    var body = document.body.innerHTML
                    window.chrome.webview.postMessage({"check": false, "header": header, "body" : body });
                    ''');
                        //TODO Save the note against the web page and then call the callback function to allow the parent page to update
                      }
                    }),
              )
            ]);
          }

          return Container();
        });
  }

  Future<WebviewController> getController(String url) async {
    var c = Completer<WebviewController>();
    final _controller = WebviewController();
    await _controller.initialize();

    await _controller.setBackgroundColor(Colors.transparent);
    await _controller.setPopupWindowPolicy(WebviewPopupWindowPolicy.deny);
    await _controller.loadUrl(url);

    _controller.webMessage.listen((map) async {
      if (map['images'] != null) {
        var images = map['images'];
        for (String url in images) {
          var response = await http.get(Uri.parse(url));
          var bytes = response.bodyBytes;
          if (url.contains('jpg')) {
            var decoder = JpegDecoder();
            var image = decoder.decodeImage(bytes);
            var encoder = PngEncoder();
            var bytes2 = encoder.encodeImage(image!);
            var hash = crypto?.hash(Uint8List.fromList(bytes2)) ?? '';
            var file = File('${Directory.current.path}/grabs/z$hash.png');
            file.writeAsBytesSync(bytes2);
          } else {
            var hash = crypto?.hash(Uint8List.fromList(bytes)) ?? '';
            var file = File('${Directory.current.path}/grabs/z$hash.png');
            file.writeAsBytesSync(bytes);
          }
        }
      } else {
        if (map['check'] != null) {
          var content =
              '<html><head> ${map['header']} </head><body>${map['body']}</body></html>';
          var contentHash = crypto?.generateHash(content);
          if (contentHash != hash && map['check'] == false) {
            var file =
                File('${Directory.current.path}/grabs/z$contentHash.html');
            file.writeAsStringSync(content);
          }
          if (contentHash == hash && map['check'] == true) {
            callback != null ? callback!(hash) : () {};
          }
        }
      }
    });

    c.complete(_controller);

    return c.future;
  }
}
