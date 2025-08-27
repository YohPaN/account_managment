import 'package:account_managment/helpers/text_w_or_dark_helper.dart';
import 'package:account_managment/models/item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ListItem extends StatelessWidget {
  final Item item;
  final int accountId;
  final Function(String, Item) callbackFunc;
  bool canManage = false;

  ListItem({
    super.key,
    required this.item,
    required this.accountId,
    required this.callbackFunc,
    required this.canManage,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: DefaultTextStyle(
              style: TextStyle(color: textColor(item.category?.color)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title),
                  if (item.description != "") Text(item.description!),
                ],
              ),
            ),
          ),
        ),
        if (item.transfertItem)
          const Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.input),
          ),
        if (item.toAccount!["id"] != null &&
            item.toAccount!["id"] != accountId.toString())
          const Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.output),
          ),
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Text(
            AppLocalizations.of(context)!.amount_of_money(
                item.transfertItem ? item.valuation * -1 : item.valuation),
            style: TextStyle(color: textColor(item.category?.color)),
          ),
        ),
        if (canManage && !item.transfertItem)
          IconButton(
            style: ButtonStyle(
              iconColor:
                  WidgetStatePropertyAll(textColor(item.category?.color)),
            ),
            onPressed: () {
              callbackFunc("update", item);
            },
            icon: const Icon(Icons.mode),
          ),
      ],
    );
  }
}
