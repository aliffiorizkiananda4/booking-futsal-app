import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {
  final Color? color;

  const LoadingWidget({super.key, this.color});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(color: color ?? const Color(0xFF22C55E)),
    );
  }
}
