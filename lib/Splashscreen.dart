import 'package:flutter/material.dart';
import 'package:medicineapp/main.dart';

class splashscreen extends StatefulWidget {
  const splashscreen({super.key});

  @override
  State<splashscreen> createState() => _splashscreenState();
}

class _splashscreenState extends State<splashscreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(
      Duration(seconds: 3),
       
      () => Navigator.pushReplacement(context,MaterialPageRoute(builder: (context) => MyHomePage())),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Image.asset('assets/images/medicineicon1.png',height: 300,width: 300,)),
    );
  }
}
