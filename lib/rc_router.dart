library rc_router;

import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

typedef NotFoundRouteFactory = PageRoute Function(RouteSettings routeSettings);

class RcRoutes {
  final NotFoundRouteFactory? notFoundRoute;
  final List<RcRoute> routes;

  RcRoutes({this.notFoundRoute, required this.routes});

  /// Generate the route based on [routeSettings]
  /// If a valid route is found in [routes] it will return it
  /// Else if [notFoundRoute] exist it will show it
  /// Else return null
  Route? onGeneratedRoute(RouteSettings routeSettings) {
    for (final route in routes) {
      if (route.routeNameMatchPath(routeSettings.name)) {
        return route.routeBuilder(routeSettings);
      }
    }
    if (notFoundRoute != null) {
      return notFoundRoute!(routeSettings);
    }
    return null;
  }
}

class RcRouteParameters {
  final Uri path;
  final Map<String, String> pathParameters;
  final Map<String, String> queryParameters;
  final Object? arguments;

  RcRouteParameters({
    required this.path,
    required this.pathParameters,
    required this.queryParameters,
    this.arguments,
  });
}

typedef RcRouteBuilder = Route Function(RouteSettings routeSettings);

abstract class RcRoute extends StatelessWidget {
  /// helper to generate Url from the [path] combined with [pathParams] and [queryParams]
  static String generateRoute(String path,
      {Map<String, String>? pathParams, Map<String, String?>? queryParams}) {
    pathParams ??= {};
    queryParams ??= {};
    var _path = path;
    for (final key in pathParams.keys) {
      _path = _path.replaceFirst(':$key', pathParams[key]!);
    }
    final sb = StringBuffer();
    for (final key in queryParams.keys) {
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

  const RcRoute({Key? key, required String path})
      : _path = path,
        super(key: key);

  String get path => _path;

  // ignore: annotate_overrides
  Widget build(BuildContext context); // should we add override annotation ?

  Widget handle(
      {required BuildContext context, required RouteSettings routeSettings}) {
    final _routeName = routeSettings.name;
    if (_routeName == null) {
      throw UnimplementedError('anonymous routes not implemented');
    }
    final routeParameters =
        getRouteParameters(_routeName, routeSettings.arguments);
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
  RcRouteParameters getRouteParameters(String routeName, Object? arguments) {
    final pathParameters = <String, String>{};
    final pathUri = Uri.parse(routeName);
    final uri = Uri.parse(path);
    for (var i = 0; i < pathUri.pathSegments.length; i++) {
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
      arguments: arguments,
    );
  }

  @visibleForTesting
  bool routeNameMatchPath(String? routeName) {
    if (routeName == null) {
      return false;
    }
    final pathUri = Uri.parse(routeName);
    final uri = Uri.parse(path);
    var isValid = pathUri.pathSegments.length == uri.pathSegments.length;
    for (var i = 0; i < pathUri.pathSegments.length; i++) {
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
