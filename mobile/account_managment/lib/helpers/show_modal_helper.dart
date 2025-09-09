import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

typedef ModalBuilder = Widget Function(BuildContext context);

showModalHelper<T>({
  required BuildContext context,
  required ModalBuilder childBuilder,
  bool isScrollControlled = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    isScrollControlled: isScrollControlled,
    builder: (BuildContext modalContext) {
      return MultiProvider(
        providers: [
          InheritedProvider<T>(
            update: (context, value) {
              return Provider.of<T>(context, listen: false);
            },
          ),
        ],
        child: childBuilder(modalContext),
      );
    },
  );
}
