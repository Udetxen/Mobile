import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

enum LoaderType {
  chasingDots,
  doubleBounce,
  wave,
  wanderingCubes,
}

class Loading extends StatelessWidget {
  final LoaderType? loaderType;

  const Loading({super.key, this.loaderType = LoaderType.chasingDots});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.brown[100],
      child: Center(
        child: _getLoader(),
      ),
    );
  }

  Widget _getLoader() {
    switch (loaderType) {
      case LoaderType.chasingDots:
        return const SpinKitChasingDots(
          color: Colors.brown,
          size: 50.0,
        );
      case LoaderType.doubleBounce:
        return const SpinKitDoubleBounce(
          color: Colors.brown,
          size: 50.0,
        );
      case LoaderType.wave:
        return const SpinKitWave(
          color: Colors.brown,
          size: 50.0,
        );
      case LoaderType.wanderingCubes:
        return const SpinKitWanderingCubes(
          color: Colors.brown,
          size: 50.0,
        );
      default:
        return const SpinKitChasingDots(
          color: Colors.brown,
          size: 50.0,
        );
    }
  }
}
