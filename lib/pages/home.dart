import 'dart:io';

import 'package:gradient_colored_slider/gradient_colored_slider.dart';
import 'package:led_bulb_indicator/led_bulb_indicator.dart';
import 'package:logica_difusa/services/socket_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  String data = "";
  double _bottomSliderValue = 0.10;
  late AnimationController _controller;
  double rangeMin = 0;
  double rangeMax = 0;

  @override
  void initState() {
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.on('active-bands', handleActiveBands);
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500000),
      vsync: this,
    )..repeat(reverse: false);
    super.initState();
  }

  @override
  void dispose() {
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.off('active-bands');
    super.dispose();
  }

  void handleActiveBands(dynamic payload) {
    //bands = (payload as List).map((band) => Band.fromMap(band)).toList();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        centerTitle: true,
        title: const Text(
          'Lógica Difusa',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 10),
            child: (socketService.serverStatus == ServerStatus.Online)
                ? const Icon(
                    Icons.check_circle,
                    color: Colors.blue,
                  )
                : const Icon(
                    Icons.check_circle,
                    color: Colors.red,
                  ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(
          bottom: 24.0,
          top: 20.0,
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Center(
                      child: Text(
                    'TEMPERATURA DEL AGUA',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  )),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              height: 55,
              child: GradientColoredSlider(
                value: _bottomSliderValue,
                barWidth: 5,
                barSpace: 1,
                gradientColors: _colors,
                onChanged: (double value) {
                  changeSpeed(value);
                  setState(() {
                    _bottomSliderValue = value;
                  });
                },
              ),
            ),
            const SizedBox(height: 15),
            Text(_bottomSliderValue.toStringAsFixed(2),
                style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 32),
            const Divider(
              height: 20,
              color: Colors.black54,
            ),
            const Padding(
              padding:  EdgeInsets.symmetric(vertical: 15),
              child: Center(child: Text('VENTILADOR')),
            ),
            /*  StepProgressIndicator(
              direction: Axis.horizontal,
              totalSteps: 100,
              currentStep: _bottomSliderValue.toInt(),
              size: 29,
              unselectedSize: 10,
              padding: 0,
              selectedColor: Colors.yellow,
              unselectedColor: Colors.cyan,
              roundedEdges: Radius.circular(10),
              selectedGradientColor: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.yellowAccent, Colors.deepOrange],
              ),
              unselectedGradientColor: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.black, Colors.blue],
              ),
            ), */
            RotationTransition(
              turns: Tween(begin: 0.0, end: 1.0).animate(_controller),
              child: Image.asset(
                'assets/images/ventilador.png',
                height: 170,
                width: 170,
              ),
            ),
            const Divider(
              height: 20,
              color: Colors.black54,
            ),
            const Padding(
              padding:  EdgeInsets.only(top: 20),
              child: Center(child: Text('TERMOSTATO')),
            ),
            LedBulbIndicator(
              margin: 30,
              initialState: LedBulbColors.yellow,
              glow: (_bottomSliderValue < 0.30) ? true : false,
              size: (_bottomSliderValue < 0.30) ? 150 : 50,
            )
          ],
        ),
      ),
    );
  }

  void changeSpeed(double value) {
    if (value >= 0.31) {
      if ((value >= rangeMin && value <= rangeMax)) {
        return;
      } else {
        _controller.duration = Duration(milliseconds: getValueSpeedFab(value));
        _controller.repeat();
        rangeMin = double.parse(value.toStringAsFixed(1));
        rangeMax = double.parse(value.toStringAsFixed(1)) + 0.1;
      }
    } else if (value <= 0.30) {
      _controller.stop();
    }
  }

  int getValueSpeedFab(double value) {
    double outputMin = 1000; // El valor mínimo del rango de salida
    double outputMax = 10; // El valor máximo del rango de salida

    int speedFan = (((value) * (outputMax - outputMin)) + outputMin).round();
    print(speedFan);
    return speedFan;
  }

  final List<Color> _colors = [
    Colors.blue.shade900,
    Colors.blue.shade400,
    Colors.yellow,
    Colors.orange,
    Colors.red.shade800
  ];
}
