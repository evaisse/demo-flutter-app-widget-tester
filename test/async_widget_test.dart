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

class DemoAsyncStatefulWidget extends StatefulWidget {
  AsyncStringFunction waitFor;

  DemoAsyncStatefulWidget(this.waitFor);

  @override
  _DemoAsyncStatefulWidgetState createState() => _DemoAsyncStatefulWidgetState();
}

class _DemoAsyncStatefulWidgetState extends State<DemoAsyncStatefulWidget> {
  bool _isLoaded = false;

  onPressed() async {
    String response = await widget.waitFor();
    debugPrint('Async response : $response');
    setState(() {
      _isLoaded = !_isLoaded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo Async Widget tester',
      home: Scaffold(
        appBar: AppBar(
          title: Text("Demo async widget"),
        ),
        body: Row(
          children: [
            Text(_isLoaded ? 'done' : 'loading', key: Key('testText')),
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
        DemoAsyncStatefulWidget(() {
          return Future.value('foo');
        }),
      );

      await tester.pumpAndSettle();

      expect(find.text('loading'), findsOneWidget);

      await tester.tap(find.byKey(Key('pressMe')));
      await tester.pumpAndSettle();

      expect(find.text('done'), findsOneWidget);
    });
  });

  testWidgets('callback with real async http call', (WidgetTester tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(
        DemoAsyncStatefulWidget(() async {
          return fetchUrl('https://httpbin.org/get?message=Hello+world');
        }),
      );

      await tester.pumpAndSettle();

      expect(find.text('loading'), findsOneWidget);

      await tester.tap(find.byKey(Key('pressMe')));
      await tester.pumpAndSettle();

      expect(find.text('done'), findsOneWidget);
    });
  });

  testWidgets('callback with IO process', (WidgetTester tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(
        DemoAsyncStatefulWidget(() async {
          await Process.run('echo', ['hello']);
          return 'done.';
        }),
      );

      await tester.pumpAndSettle();

      expect(find.text('loading'), findsOneWidget);

      await tester.tap(find.byKey(Key('pressMe')));
      await tester.pumpAndSettle();

      expect(find.text('done'), findsOneWidget);
    });
  });

  testWidgets('callback with IO synced', (WidgetTester tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(
        DemoAsyncStatefulWidget(() async {
          File('pubspec.yaml').readAsStringSync();
          return 'done.';
        }),
      );

      await tester.pumpAndSettle();

      expect(find.text('loading'), findsOneWidget);

      await tester.tap(find.byKey(Key('pressMe')));
      await tester.pumpAndSettle();

      expect(find.text('done'), findsOneWidget);
    });
  });

  testWidgets('callback with File io as future', (WidgetTester tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(
        DemoAsyncStatefulWidget(() async {
          await File('pubspec.yaml').readAsString();
          return 'done.';
        }),
      );

      await tester.pumpAndSettle();

      expect(find.text('loading'), findsOneWidget);

      await tester.tap(find.byKey(Key('pressMe')));
      await tester.pumpAndSettle();

      expect(find.text('done'), findsOneWidget);
    });
  });

  testWidgets('callback with IO process', (WidgetTester tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(
        DemoAsyncStatefulWidget(() async {
          await Process.run('echo', ['hello']);
          return 'done.';
        }),
      );

      await tester.pumpAndSettle();

      expect(find.text('loading'), findsOneWidget);

      await tester.tap(find.byKey(Key('pressMe')));
      await tester.pumpAndSettle();

      expect(find.text('done'), findsOneWidget);
    });
  });
}
