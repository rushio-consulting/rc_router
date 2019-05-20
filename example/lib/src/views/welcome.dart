import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class WelcomePage extends StatefulWidget {
  WelcomePage({Key key}) : super(key: key);

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
        child: Icon(Icons.new_releases),
        onPressed: () {
          Navigator.of(context).pushNamed('/greetings/kevin');
        },
      ),
    );
  }
}
