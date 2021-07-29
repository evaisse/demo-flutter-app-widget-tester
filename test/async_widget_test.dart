import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

typedef AsyncStringFunction = Future<String> Function();

Future<String> fetchUrl(String url) async {
  final HttpClient client = HttpClient();
  final HttpClientRequest request = await client.getUrl(Uri.parse(url));
  final HttpClientResponse response = await request.close();

  final completer = Completer<String>();
  final contents = StringBuffer();
  response.transform(utf8.decoder).listen((data) {
    contents.write(data);
  }, onDone: () {
    completer.complete(contents.toString());
    print(contents.toString());
  });

  return completer.future;
}

class TestWidget extends StatefulWidget {
  AsyncStringFunction waitFor;

  TestWidget(this.waitFor);

  @override
  _TestWidgetState createState() => _TestWidgetState();
}

class _TestWidgetState extends State<TestWidget> {
  bool _isGood = false;

  onPressed() async {
    String response = await widget.waitFor();
    debugPrint('Async response : $response');
    setState(() {
      _isGood = !_isGood;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: Scaffold(
        appBar: AppBar(
          title: Text("zouzou"),
        ),
        body: Row(
          children: [
            Text(_isGood ? 'goodgood' : 'badbad', key: Key('testText')),
            ElevatedButton(
              key: Key('pressMe'),
              child: Text('press me'),
              onPressed: onPressed,
            ),
          ],
        ),
      ),
    );
  }
}

void main() async {
  setUpAll(() {
    HttpOverrides.global = null;
  });

  testWidgets('fake async', (WidgetTester tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(
        TestWidget(() {
          return Future.value('foo');
        }),
      );

      await tester.pumpAndSettle();

      expect(find.byKey(Key('pressMe')), findsOneWidget);
      expect(find.text('badbad'), findsOneWidget);

      await tester.tap(find.byKey(Key('pressMe')));
      await tester.pumpAndSettle();

      expect(find.text('goodgood'), findsOneWidget);
    });
  });

  testWidgets('callback with real async', (WidgetTester tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(
        TestWidget(() async {
          return fetchUrl('https://httpbin.org/get?message=Hello+world');
        }),
      );

      await tester.pumpAndSettle();

      expect(find.byKey(Key('pressMe')), findsOneWidget);
      expect(find.text('badbad'), findsOneWidget);

      await tester.tap(find.byKey(Key('pressMe')));
      await tester.pumpAndSettle();

      expect(find.text('goodgood'), findsOneWidget);
    });
  });
}
