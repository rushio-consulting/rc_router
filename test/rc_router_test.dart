import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pedantic/pedantic.dart';
import 'package:provider/provider.dart';

import 'package:rc_router/rc_router.dart';

import 'src/route_example.dart';

void main() {
  group('RcRoute', () {
    test('generateRoute', () {
      final url = RcRoute.generateRoute(
        '/test',
      );
      expect(url, '/test');
    });
    test('generateRoute with path params and qeury params', () {
      final url = RcRoute.generateRoute(
        '/test/:id',
        pathParams: {
          'id': '1',
        },
        queryParams: {
          'a': 'a',
          'b': 'b',
        },
      );
      expect(url, '/test/1?a=a&b=b');
    });

    group('valid', () {
      test('simple', () {
        final path = '/example';
        final route = ExampleRoute(
          path: path,
        );
        final match = route.routeNameMatchPath(path);
        expect(match, isTrue);
      });

      test('with path params', () {
        final route = ExampleRoute(
          path: '/example/:withPathParams',
        );
        final match = route.routeNameMatchPath('/example/12');
        expect(match, isTrue);
      });

      test('with query params', () {
        final route = ExampleRoute(
          path: '/example',
        );
        final match = route.routeNameMatchPath('/example?a=a');
        expect(match, isTrue);
      });

      test('all', () {
        final route = ExampleRoute(
          path: '/example/:withPathParams',
        );
        final match = route.routeNameMatchPath('/example/12?a=a');
        expect(match, isTrue);
      });
    });

    group('invalid', () {
      test('simple', () {
        final path = '/example';
        final route = ExampleRoute(
          path: path,
        );
        final match = route.routeNameMatchPath('/toto');
        expect(match, isFalse);
      });
    });
  });

  group('RcRoutes', () {
    group('valid', () {
      test('empty', () {
        final rcRoutes = RcRoutes(routes: const <RcRoute>[]);

        final route =
            rcRoutes.onGeneratedRoute(RouteSettings(name: '/example'));
        expect(route, isNull);
      });
      test('simple', () {
        final rcRoutes = RcRoutes(
          routes: [
            ExampleRoute(
              path: '/example',
            ),
          ],
        );

        final route =
            rcRoutes.onGeneratedRoute(RouteSettings(name: '/example'));
        expect(route, isNotNull);
      });
    });

    group('invalid', () {
      test('simple', () {
        final rcRoutes = RcRoutes(
          routes: [
            ExampleRoute(
              path: '/example',
            ),
          ],
        );

        final route = rcRoutes.onGeneratedRoute(RouteSettings(name: '/toto'));
        expect(route, isNull);
      });

      test('fallback to not found', () {
        final rcRoutes = RcRoutes(
          routes: [
            ExampleRoute(
              path: '/example',
            ),
          ],
          notFoundRoute: (routeSettings) {
            return PageRouteBuilder(
              pageBuilder: (context, _, __) => Container(),
            );
          },
        );
        final route = rcRoutes.onGeneratedRoute(RouteSettings(name: '/toto'));
        expect(route, isNotNull);
      });
    });
  });

  group('widgets', () {
    testWidgets('show good widget', (widgetTester) async {
      final rcRoutes = RcRoutes(
        routes: [
          ExampleRoute(
            path: '/',
            child: Scaffold(
              body: Text('/'),
            ),
          )
        ],
      );

      await widgetTester.pumpWidget(
        MaterialApp(
          onGenerateRoute: rcRoutes.onGeneratedRoute,
        ),
      );
      await widgetTester.pumpAndSettle();

      expect(find.text('/'), findsOneWidget);
    });

    testWidgets('get parameters', (widgetTester) async {
      final rcRoutes = RcRoutes(
        routes: [
          ExampleRoute(
            path: '/',
            child: Scaffold(
              body: Text('/'),
            ),
          ),
          ExampleRoute(
            path: '/:id',
            child: Home(),
          ),
        ],
      );
      final navigator = GlobalKey<NavigatorState>();

      await widgetTester.pumpWidget(
        MaterialApp(
          navigatorKey: navigator,
          onGenerateRoute: rcRoutes.onGeneratedRoute,
        ),
      );
      unawaited(navigator.currentState!.pushNamed('/test?key=value'));
      await widgetTester.pumpAndSettle();

      expect(find.text('test'), findsOneWidget);
      expect(find.text('value'), findsOneWidget);
    });
  });
}

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final routeParams = Provider.of<RcRouteParameters>(context, listen: false);
    return Center(
      child: Column(
        children: <Widget>[
          Text('${routeParams.pathParameters['id']}'),
          Text('${routeParams.queryParameters['key']}'),
        ],
      ),
    );
  }
}
