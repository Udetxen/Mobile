import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

enum LoaderType {
  dualRing,
  doubleBounce,
  wave,
  wanderingCubes,
}

class Loading extends StatelessWidget {
  final LoaderType? loaderType;
  final bool isFullScreen;

  const Loading(
      {super.key,
      this.loaderType = LoaderType.dualRing,
      this.isFullScreen = true});

  @override
  Widget build(BuildContext context) {
    return isFullScreen
        ? Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: Center(
              child: _getLoader(context),
            ),
          )
        : _getLoader(context);
  }

  Widget _getLoader(BuildContext context) {
    switch (loaderType) {
      case LoaderType.dualRing:
        return SpinKitDualRing(
          color: Theme.of(context).primaryColor,
          size: 50.0,
        );
      case LoaderType.doubleBounce:
        return SpinKitDoubleBounce(
          color: Theme.of(context).primaryColor,
          size: 50.0,
        );
      case LoaderType.wave:
        return SpinKitWave(
          color: Theme.of(context).primaryColor,
          size: 50.0,
        );
      case LoaderType.wanderingCubes:
        return SpinKitWanderingCubes(
          color: Theme.of(context).primaryColor,
          size: 50.0,
        );
      default:
        return SpinKitDualRing(
          color: Theme.of(context).primaryColor,
          size: 50.0,
        );
    }
  }
}
