import 'package:flutter/material.dart';
import 'package:quick_store/shared/decorations.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({Key key}) : super(key: key);

  @override
  _InventoryPageState createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  TextEditingController controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.all(8),
      child: Column(
        children: [
          Expanded(
            flex: 1,
            child: Text(
                'INVENTORY',
                textAlign: TextAlign.left,
                style: theme.textTheme.headline4
            )
          ),
          Expanded(
            flex: 1,
            child: TextFormField(
              controller: controller,
              decoration: searchFieldDecoration.copyWith(
                  suffixIcon: IconButton(onPressed: () {
                    // controller.text = "";
                    // widget.searchHandler("");
                  }, icon: Icon(Icons.highlight_off_rounded))
              ),
              // onChanged: widget.searchHandler,
            )
          ),
          Expanded(
            flex: 10,
            child: Text('Grid here'),
          ),
        ],
      ),
    );
  }
}
