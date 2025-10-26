import 'package:flutter/material.dart';

class MunshiLogo extends StatefulWidget {
  final double size;

  const MunshiLogo({super.key, this.size = 96});

  @override
  State<MunshiLogo> createState() => _MunshiLogoState();
}

class _MunshiLogoState extends State<MunshiLogo> {
  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: widget.size,
      child: Image.asset('assets/images/logo.png'),
    );
  }
}
