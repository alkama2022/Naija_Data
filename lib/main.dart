import 'package:data_naija_app/presentation/widgets/app_bootstrap.dart';
import 'package:flutter/material.dart';

void main() {
  // Show the loading state immediately; AppBootstrap loads storage, restores
  // the session and checks connectivity before the first route is shown.
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AppBootstrap());
}
