[![codecov](https://codecov.io/gh/rushio-consulting/rc_router/branch/master/graph/badge.svg)](https://codecov.io/gh/rushio-consulting/rc_router)

# rc_router

A simple but powerful router for Flutter

## Usage

### Create a custom RcRoute

The code below is based on what you have in the example app
```dart
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
```

### Create RcRoutes

```dart
...
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
...
```

### Use RcRoutes

```dart
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
```
