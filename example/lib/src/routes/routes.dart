import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:rc_router_example/src/views/welcome.dart';
import 'package:rc_router/rc_router.dart';

class HomeRoute extends RcRoute {
  static String routePath = '/';

  HomeRoute() : super(path: HomeRoute.routePath);

  @override
  Widget build(BuildContext context) {
    final name = 'anonymous';
    return Provider<String>.value(
      value: name,
      child: WelcomePage(),
    );
  }
}

class GrettingsRoute extends RcRoute {
  static String routePath = '/greetings/:name';

  static String generateRoute(String name) {
    return RcRoute.generateRoute(routePath, pathParams: {'name': name});
  }

  GrettingsRoute() : super(path: GrettingsRoute.routePath);

  @override
  Widget build(BuildContext context) {
    final routeParams = Provider.of<RcRouteParams>(context);
    final name = routeParams.pathParams['name'] ?? 'anonymous';
    return Provider<String>.value(
      value: name,
      child: WelcomePage(),
    );
  }

  @override
  Route routeBuilder(RouteSettings routeSettings) {
    return MaterialPageRoute(
      builder: (c) => handle(c),
      settings: routeSettings,
    );
  }
}
