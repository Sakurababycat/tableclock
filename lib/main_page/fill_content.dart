import 'package:table_clock/utils/config_ext.dart';
import 'package:flutter/material.dart';

class FilledViewBuilder extends StatelessWidget {
  final Widget child;
  const FilledViewBuilder({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      final size = constraints.biggest;
      final vFillSize = getVFillSize(size);
      final hFillSize = getHFillSize(size);
      return Stack(
        children: <Widget>[
          Container(
            color: Colors.black,
          ),
          Positioned(
            left: vFillSize,
            top: hFillSize,
            child: Container(
                color: Colors.black,
                height: size.height - 2 * hFillSize,
                width: size.width - 2 * vFillSize,
                child: child),
          )
        ],
      );
    });
  }
}
