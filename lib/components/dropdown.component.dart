import 'package:flutter/material.dart';

class DropdownWidget extends StatefulWidget {
  final Map<String, String> items;
  final ValueChanged<String> onValueChanged;
  final String? value;

  const DropdownWidget({
    required this.items,
    required this.onValueChanged,
    this.value,
    super.key,
  });

  @override
  State<DropdownWidget> createState() => _DropdownWidgetState();
}

class _DropdownWidgetState extends State<DropdownWidget> {
  late String dropdownValue;

  @override
  void initState() {
    super.initState();
    dropdownValue = widget.value ?? widget.items.values.first;
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: dropdownValue,
      onChanged: (String? value) {
        setState(() {
          dropdownValue = value!;
          widget.onValueChanged(dropdownValue);
        });
      },
      items: widget.items.entries.map<DropdownMenuItem<String>>((entry) {
        return DropdownMenuItem<String>(
          value: entry.value,
          child: Text(entry.key),
        );
      }).toList(),
    );
  }
}
