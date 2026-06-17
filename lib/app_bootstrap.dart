import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'firebase_options.dart';

class AppBootstrap {
  const AppBootstrap._();

  static Future<void> initialize() async {
    WidgetsFlutterBinding.ensureInitialized();

    await Future.wait([
      JustAudioBackground.init(
        androidNotificationChannelId: 'com.waveon.music.channel.audio',
        androidNotificationChannelName: 'Music Playback',
        androidNotificationOngoing: true,
        androidNotificationIcon: 'drawable/ic_notification',
      ),
      Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform),
    ]);

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }
}
