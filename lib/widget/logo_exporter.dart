import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'app_logo.dart';

class LogoExporter extends StatelessWidget {
  const LogoExporter({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1024,
      height: 1024,
      color: Colors.white,
      child: const Center(
        child: AppLogo(size: 200, showText: false),
      ),
    );
  }
}