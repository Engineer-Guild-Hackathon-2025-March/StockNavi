import 'package:flutter/material.dart';
import 'package:stocknavi/views/base_view.dart';
import 'package:stocknavi/controllers/controller.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stock Navi',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        dividerColor: Color(0xffdedcfa),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        scaffoldBackgroundColor: Color.fromARGB(255, 243, 243, 248),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  late final Controller _controller;
  final _baseViewKey = GlobalKey<BaseViewState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final baseViewState = _baseViewKey.currentState!;
      _controller = Controller(baseViewState);
      baseViewState.setController(_controller);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BaseView(key: _baseViewKey);
  }
}
