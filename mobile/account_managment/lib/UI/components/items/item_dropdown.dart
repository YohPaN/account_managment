import 'package:flutter/material.dart';

abstract class ItemDropdown extends StatelessWidget {
  const ItemDropdown({
    super.key,
    required this.onSelect,
    required this.initialValue,
    this.values = const [],
  });

  final List<dynamic> values;
  final ValueChanged<dynamic> onSelect;
  final dynamic initialValue;

  List<DropdownMenuEntry<String>> buildList(BuildContext context);

  @override
  Widget build(BuildContext context, {String label = ""}) {
    return DropdownMenu(
      expandedInsets: const EdgeInsets.all(50),
      label: Text(label),
      initialSelection: initialValue,
      onSelected: (value) => onSelect(value),
      dropdownMenuEntries: buildList(context),
    );
  }
}
