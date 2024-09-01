import 'package:flutter/material.dart';

class CardComponent extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final Widget? child;
  final int? flex;

  const CardComponent(
      {super.key, this.title, this.subtitle, this.child, this.flex});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex ?? 1,
      child: Container(
        margin: const EdgeInsets.all(15),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null || subtitle != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (title != null)
                    Text(
                      title!,
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                ],
              ),
            if (child != null)
              Expanded(
                child: Center(
                  child: child,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
