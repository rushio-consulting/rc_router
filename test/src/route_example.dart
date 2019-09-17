import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/widgets.dart';
import 'package:rc_router/rc_router.dart';

class ExampleRoute extends RcRoute {
  final Widget child;

  ExampleRoute({@required String path, this.child}) : super(path: path);

  @override
  Widget build(BuildContext context) {
    return child;
  }
}
