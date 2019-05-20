import 'package:flutter/material.dart';
import 'package:rc_router_example/src/routes/routes.dart';
import 'package:rc_router/rc_router.dart';

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  RcRoutes rcRoutes;

  @override
  void initState() {
    super.initState();
    rcRoutes = RcRoutes(
      notFoundRoute: generateNotFound,
      routes: [
        HomeRoute(),
        GrettingsRoute(),
      ],
    );
  }

  PageRoute generateNotFound(RouteSettings routeSettings) {
    return MaterialPageRoute(
      builder: (c) {
        return Scaffold(
          body: Center(
            child: Text('Uri "${routeSettings.name}" not found'),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      onGenerateRoute: rcRoutes.onGeneratedRoute,
    );
  }
}
