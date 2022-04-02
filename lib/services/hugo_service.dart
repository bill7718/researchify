
import 'dart:async';
import 'dart:io';

///
/// Provides services for interacting with Hugo Web site written in Markdown
///
class HugoService {


  final Directory home;

  HugoService(this.home);


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

}


class HugoUrlContext {

  final String context;
  final String url;

  HugoUrlContext(this.context, this.url);
}