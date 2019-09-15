import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

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
        final rcRoutes = RcRoutes(routes: null);

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
  });
}
