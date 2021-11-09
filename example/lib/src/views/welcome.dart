import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rc_router/rc_router.dart';
import 'package:rc_router_example/src/routes/routes.dart';

class WelcomePage extends StatefulWidget {
  WelcomePage({Key? key}) : super(key: key);

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  @override
  Widget build(BuildContext context) {
    final name = Provider.of<String>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.open_in_new),
            onPressed: () {
              Navigator.of(context).pushNamed('/route/inconnue');
            },
          )
        ],
      ),
      body: Center(
        child: Text('Hello, $name'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          print(RcRoute.generateRoute(
            GrettingsRoute.routePath,
            pathParams: {'name': 'kevin'},
          ));
          Navigator.of(context).pushNamed(
            GrettingsRoute.generateRoute('kevin'),
          );
        },
        child: Icon(Icons.new_releases),
      ),
    );
  }
}
