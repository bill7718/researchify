
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:researchify/services/hugo_service.dart';
import 'package:serializable_data/serializable_data.dart';

void main() {
  const String home = 'G:\\My Drive\\research_app\\futures\\';

  late HugoService hugo;

  setUp(() async {
    hugo = HugoService(Directory(home), Crypto());
  });

  group('Hugo Service', ()
  {
    group('Get Static Path', () {
      testWidgets(
          'When I have a normal path I get the expected response ',
              (WidgetTester tester) async {
            var path = hugo.getStaticPath(
                '$home\\content\\en\\docs\\companies\\vw.md');
            expect(path,
                'G:\\My Drive\\research_app\\futures\\static\\companies\\vw\\');
          });
    });

    https://s7g10.scene7.com/is/image/volkswagenag/homepage-transporter-16x9-2500x1406?Zml0PWNyb3AsMSZmbXQ9anBnJnFsdD03OSZ3aWQ9MTg3NSZoZWk9MTQwNiZhbGlnbj0wLjAwLDAuMDAmYmZjPW9mZiZmN2Zi

    group('addImageComment', () {
      testWidgets(
          'When I have a normal parameters I expect a file to be written to a directory ',
              (WidgetTester tester) async {
            await hugo.addImageComment('$home\\content\\en\\docs\\companies\\vw.md',
                'https://www.volkswagen.co.uk/files/live/sites/vwuk/files/Technology/Electrification/Electric%20Innovation/I.D.%20Range/new%20electric%20platform-C023-770X320-Tablet.png', '');

          });
    });
  });
}