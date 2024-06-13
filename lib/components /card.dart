import 'package:flutter/material.dart';

class CardComponent extends StatelessWidget {
  final String title;
  final Widget? customWidget;

  const CardComponent({super.key, required this.title, this.customWidget});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(15),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          if (customWidget != null) customWidget!
        ],
      ),
    );
  }
}
