library rc_router;

import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

typedef PageRoute NotFoundRouteFactory(RouteSettings routeSettings);

class RcRoutes {
  final NotFoundRouteFactory notFoundRoute;
  final List<RcRoute> routes;

  RcRoutes({this.notFoundRoute, @required List<RcRoute> routes})
      : this.routes = routes ?? [];

  /// Generate the route based on [routeSettings]
  /// If a valid route is found in [routes] it will return it
  /// Else if [notFoundRoute] exist it will show it
  /// Else return null
  Route onGeneratedRoute(RouteSettings routeSettings) {
    for (final route in routes) {
      if (route.routeNameMatchPath(routeSettings.name)) {
        return route.routeBuilder(routeSettings);
      }
    }
    if (notFoundRoute != null) {
      return notFoundRoute(routeSettings);
    }
    return null;
  }
}

class RcRouteParameters {
  final Uri path;
  final Map<String, String> pathParameters;
  final Map<String, String> queryParameters;

  RcRouteParameters({
    @required this.path,
    @required this.pathParameters,
    @required this.queryParameters,
  });

  void clear() {
    pathParameters.clear();
    queryParameters.clear();
  }
}

typedef Route RcRouteBuilder(RouteSettings routeSettings);

abstract class RcRoute extends StatelessWidget {
  /// helper to generate Url from the [path] combined with [pathParams] and [queryParams]
  static String generateRoute(String path,
      {Map<String, String> pathParams, Map<String, String> queryParams}) {
    pathParams ??= {};
    queryParams ??= {};
    String _path = path;
    for (final key in pathParams.keys) {
      _path = _path.replaceFirst(':$key', pathParams[key]);
    }
    final sb = StringBuffer();
    for (final key in queryParams?.keys) {
      sb.write('$key=${queryParams[key]}');
      if (key != queryParams.keys.last) {
        sb.write('&');
      }
    }
    if (sb.isNotEmpty) {
      return '$_path?${sb.toString()}';
    }
    return _path;
  }

  final String _path;

  RcRoute({@required String path}) : this._path = path;

  String get path => _path;

  Widget build(BuildContext context);

  Widget handle(
      {@required BuildContext context, @required RouteSettings routeSettings}) {
    final routeParameters = getRouteParameters(routeSettings.name);
    return Provider<RcRouteParameters>.value(
      value: routeParameters,
      child: Builder(builder: (c) => build(c)),
    );
  }

  Route routeBuilder(RouteSettings routeSettings) {
    return PageRouteBuilder(
      pageBuilder: (c, _, __) {
        return handle(
          context: c,
          routeSettings: routeSettings,
        );
      },
      settings: routeSettings,
    );
  }

  @visibleForTesting
  RcRouteParameters getRouteParameters(String routeName) {
    final pathParameters = <String, String>{};
    final pathUri = Uri.parse(routeName);
    final uri = Uri.parse(path);
    for (int i = 0; i < pathUri.pathSegments.length; i++) {
      if (uri.pathSegments.length <= i) {
        break;
      }
      if (uri.pathSegments[i].startsWith(':')) {
        final key = uri.pathSegments[i].substring(1);
        pathParameters[key] = pathUri.pathSegments[i];
      }
    }
    return RcRouteParameters(
      path: pathUri,
      pathParameters: pathParameters,
      queryParameters: pathUri.queryParameters,
    );
  }

  @visibleForTesting
  bool routeNameMatchPath(String routeName) {
    final pathUri = Uri.parse(routeName);
    final uri = Uri.parse(path);
    bool isValid = pathUri.pathSegments.length == uri.pathSegments.length;
    for (int i = 0; i < pathUri.pathSegments.length; i++) {
      if (uri.pathSegments.length <= i) {
        isValid = false;
        break;
      }
      if (uri.pathSegments[i].startsWith(':')) {
        continue;
      } else if (pathUri.pathSegments[i] != uri.pathSegments[i]) {
        isValid = false;
        break;
      }
    }
    if (isValid) {
      return true;
    }
    return false;
  }
}
