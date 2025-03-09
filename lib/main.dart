import 'package:flutter/material.dart';
import 'package:music_tech/core/provider/audio_service_provider.dart';
import 'package:music_tech/wrapper/home_wrapper.dart';
import 'package:provider/provider.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final audioServiceProvider = AudioServiceProvider();
  await audioServiceProvider.init(audioServiceProvider);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: audioServiceProvider),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Music Tech',
      scaffoldMessengerKey: scaffoldMessengerKey,
      theme: ThemeData(
        primarySwatch: Colors.orange,
        brightness: Brightness.dark,
      ),
      debugShowCheckedModeBanner: false,
      home: const HomeWrapper(),
    );
  }
}
