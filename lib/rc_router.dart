library rc_router;

import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import 'package:provider/provider.dart';

typedef PageRoute NotFoundRouteFactory(RouteSettings routeSettings);

class RcRoutes {
  final NotFoundRouteFactory notFoundRoute;
  final List<RcRoute> routes;

  RcRoutes({this.notFoundRoute, @required List<RcRoute> routes})
      : this.routes = routes ?? [];

  Route onGeneratedRoute(RouteSettings routeSettings) {
    for (final r in routes) {
      if (r.routeNameMatchPath(routeSettings.name)) {
        return r.routeBuilder(routeSettings);
      }
    }
    return notFoundRoute(routeSettings);
  }
}

class RcRouteParams {
  Uri path;
  final Map<String, String> pathParams = {};
  final Map<String, String> queryParams = {};

  void clear() {
    pathParams.clear();
    queryParams.clear();
  }
}

typedef Route RcRouteBuilder(RouteSettings routeSettings);

abstract class RcRoute extends StatelessWidget {
  final String _path;
  final RcRouteParams routeParams;

  RcRoute({@required String path})
      : this.routeParams = RcRouteParams(),
        this._path = path;

  String get path => _path;

  Widget build(BuildContext context);

  Widget handle(BuildContext context) {
    return Provider<RcRouteParams>.value(
      value: routeParams,
      child: Builder(
        builder: (c) {
          return build(c);
        },
      ),
    );
  }

  Route routeBuilder(RouteSettings routeSettings) {
    return PageRouteBuilder(
      pageBuilder: (c, _, __) => handle(c),
      settings: routeSettings,
    );
  }

  bool routeNameMatchPath(String routeName) {
    final pathUri = Uri.parse(routeName);
    final uri = Uri.parse(path);
    bool isValid = pathUri.pathSegments.isNotEmpty ||
        (pathUri.pathSegments.length == uri.pathSegments.length);
    if (pathUri.pathSegments.isEmpty &&
        uri.pathSegments.isNotEmpty &&
        uri.pathSegments.first.startsWith(':')) {
      routeParams.path = pathUri;
      routeParams.queryParams
        ..clear()
        ..addAll(pathUri.queryParameters);
      return true;
    }
    for (int i = 0; i < pathUri.pathSegments.length; i++) {
      if (uri.pathSegments.length <= i) {
        isValid = false;
        break;
      }
      if (uri.pathSegments[i].startsWith(':')) {
        final key = uri.pathSegments[i].substring(1);
        routeParams.pathParams[key] = pathUri.pathSegments[i];
      } else if (pathUri.pathSegments[i] != uri.pathSegments[i]) {
        isValid = false;
        break;
      }
    }
    if (isValid) {
      routeParams.path = pathUri;
      routeParams.queryParams
        ..clear()
        ..addAll(pathUri.queryParameters);
      return true;
    }
    routeParams.clear();
    return false;
  }
}
