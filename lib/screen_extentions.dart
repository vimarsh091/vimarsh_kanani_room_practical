import 'package:flutter/material.dart';

extension Space on int {
  Widget get verticleSpace => SizedBox(
        height: toDouble(),
      );

  Widget get horizontalSpace => SizedBox(
        width: toDouble(),
      );
}
