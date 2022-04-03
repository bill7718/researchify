
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:image/image.dart';
import 'package:serializable_data/serializable_data.dart';

///
/// Provides services for interacting with Hugo Web site written in Markdown
///
class HugoService {


  final Directory home;
  final Crypto crypto;

  HugoService(this.home, this.crypto);


  Future<List<HugoUrlContext>> getUrls() async {

    var c = Completer<List<HugoUrlContext>>();
    var response = <HugoUrlContext>[];

    var base = Directory(home.path + '/content/en/docs/');

   if (!base.existsSync()) {
     throw Exception('docs not found: ${base.path}');
   }

   var files = base.listSync(recursive: true);

   for (FileSystemEntity item in files) {
     if (item is File) {
       if (item.path.endsWith('.md') && !item.path.contains('_index')) {
         var lines = item.readAsLinesSync();
         var urls = extractUrls(lines);
         for (var url in urls) {
           response.add(HugoUrlContext(item.path, url));
         }
       }
     }
   }

    c.complete(response);
    return c.future;
  }

  List<String> extractUrls(List<String> lines) {
    var response = <String>[];

    var start = false;

    for (var line in lines) {
      if (line.contains('Web Sites') && line.contains('#####')) {
        start = true;
      } else {
        if (line.contains('#####')) {
          start = false;
        } else {
          var urlStart = line.indexOf('(') + 1;
          var urlEnd = line.indexOf(')', urlStart);
          if (start && urlStart > 0 && urlEnd > urlStart) {
            response.add(line.substring(urlStart, urlEnd));
          }
        }
      }
    }


    return response;
  }

  Future<void> addImageComment(String path, String imageUrl, String comment ) async {
    var c = Completer<void>();

    // first get the image and put it in the static folder
    var imageResponse = await http.get(Uri.parse(imageUrl));
    var bytes = imageResponse.bodyBytes;
    var staticPath = getStaticPath(path);
    var staticDirectory = Directory(staticPath);
    if (!staticDirectory.existsSync()) {
      staticDirectory.createSync();
    }

    if (!imageUrl.contains('png')) {
      var hash = crypto.hash(Uint8List.fromList(bytes));
      var file = File('${staticDirectory.path}${hash.substring(0, 12)}.jpg');
      file.writeAsBytesSync(bytes);
    } else {
      var hash = crypto.hash(Uint8List.fromList(bytes));
      var file = File('${staticDirectory.path}${hash.substring(0, 12)}.png');
      file.writeAsBytesSync(bytes);
    }

    var contentFile = File(path);
    var contents = contentFile.readAsLinesSync();
    var index = 0;
    var notesStartIndex = -1;
    while (index < contents.length) {
      if (contents[index] == '##### Notes') {
        notesStartIndex = index;
      }
      index++;
    }

    var text = comment;
    if (notesStartIndex == -1) {
      text = '##### Notes\n\n$text';
      var c = contentFile.readAsStringSync();
      c = c + text;
      contentFile.writeAsStringSync(c);
    } else {
      text = '\n$text';
      contents.insert(notesStartIndex, text);
      var c = '';
      for (var line in contents) {
        c = c + line + '\n';
      }
      contentFile.writeAsStringSync(c);
    }


    c.complete();
    return c.future;
  }

  String getStaticPath(String path) {

    var temp = path.substring(home.path.length);
    temp = temp.substring('\\content\\en\\docs\\'.length);
    var parts = temp.split('\\');
    var response = '${home.path}static\\${parts.first}\\${parts.last.split('.').first}\\';

    return response;

  }

}


class HugoUrlContext {

  final String context;
  final String url;

  HugoUrlContext(this.context, this.url);
}