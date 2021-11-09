import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/widgets.dart';
import 'package:rc_router/rc_router.dart';

class ExampleRoute extends RcRoute {
  final Widget child;

  const ExampleRoute({
    Key? key,
    required String path,
    this.child = const SizedBox.shrink(),
  }) : super(path: path, key: key);

  @override
  Widget build(BuildContext context) {
    return child;
  }
}
