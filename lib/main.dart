import 'package:flutter/widgets.dart';
import 'app/app.dart';
import 'bootstrap/bootstrap.dart';

void main() async {
  await Bootstrap.init();
  runApp(const App());
}
