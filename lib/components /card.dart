import 'package:flutter/material.dart';

class CardComponent extends StatelessWidget {
  final String? title;
  final Widget? child;
  final int? flex;

  const CardComponent({super.key, this.title, this.child, this.flex});

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
            if (title != null)
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title!,
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.black87,
                        fontWeight: FontWeight.w400,
                      ),
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
