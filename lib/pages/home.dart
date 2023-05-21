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
  double _temperatureValue = 0.2;
  double _fabValue = 1;
  double _heaterValue = 1;
  late AnimationController _controller;
  double rangeMin = 0;
  double rangeMax = 0;
  static const _SLIDER_MAX_STEP = 40;

  @override
  void initState() {
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.on('outputs-fuzzed', handleGetOutputs);
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: false);
    super.initState();
  }

  void handleGetOutputs(dynamic payload) {
    setState(() {
      _fabValue = payload['fab'] as double;
      _heaterValue = payload['heater'] as double;
      _temperatureValue = getTemperature(payload['temperature'] as int);
      changeSpeed(_fabValue);
    });
  }

  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context);

    var ventiladorAsset = 'assets/images/ventilador_2.png';
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
      body: ListView(
        children: [
          Padding(
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
                    value: _temperatureValue,
                    barWidth: 5,
                    barSpace: 0.5,
                    gradientColors: _colors,
                    onChanged: (double value) {
                      setState(() {
                        _temperatureValue = value;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                    '${_rangedSelectedValue(_SLIDER_MAX_STEP, _temperatureValue)} °C',
                    style: const TextStyle(fontSize: 32)),
                const SizedBox(height: 32),
                const Divider(
                  height: 20,
                  color: Colors.black54,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  child: Center(child: Text('VENTILADOR')),
                ),
                RotationTransition(
                  turns: Tween(begin: 0.0, end: 1.0).animate(_controller),
                  child: Image.asset(
                    ventiladorAsset,
                    height: 170,
                    width: 170,
                  ),
                ),
                const Divider(
                  height: 20,
                  color: Colors.black54,
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Center(child: Text('CALENTADOR')),
                ),
                LedBulbIndicator(
                  margin: 30,
                  initialState: getLedBulbColor(_heaterValue),
                  glow: (_heaterValue > 13) ? true : false,
                  size: (_heaterValue > 13) ? 150 : 50,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  void changeSpeed(double value) {
    if (value >= 13) {
      if ((value >= rangeMin && value <= rangeMax)) {
        return;
      } else {
        _controller.duration = Duration(milliseconds: getValueSpeedFab(value));
        _controller.repeat();
        rangeMin = double.parse(value.toStringAsFixed(1));
        rangeMax = double.parse(value.toStringAsFixed(1)) + 0.1;
      }
    } else if (value <= 13) {
      _controller.stop();
    }
  }

  int getValueSpeedFab(double value) {
    return (1 * 15000 / (value)).round();
  }

  LedBulbColors getLedBulbColor(double value) {
    if (value > 50) {
      return LedBulbColors.red;
    } else if (value >= 13 && value <= 50) {
      return LedBulbColors.yellow;
    }
    return LedBulbColors.off;
  }

  final List<Color> _colors = [
    Colors.blue.shade900,
    Colors.blue.shade400,
    Colors.yellow,
    Colors.orange,
    Colors.red.shade800
  ];

  int _rangedSelectedValue(int maxSteps, double value) {
    double stepRange = 1.0 / maxSteps;
    return (value / stepRange + 1).clamp(1, maxSteps).toInt();
  }

  double getTemperature(int temperature) {
    return (temperature <= 40) ? temperature / 40 : 1;
  }
}
