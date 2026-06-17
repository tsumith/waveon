import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:waveon/app_providers.dart';
import 'package:waveon/app_root.dart';
import 'package:waveon/app_bootstrap.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kReleaseMode) {
    debugPrint = (String? message, {int? wrapWidth}) {};
  }
  await AppBootstrap.initialize();

  FlutterError.onError = (FlutterErrorDetails details) {
    if (kReleaseMode) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(details);
    } else {
      FlutterError.presentError(details);
    }
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    if (kReleaseMode) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    }
    return true;
  };
  runApp(AppProviders(child: AppRoot()));
}
