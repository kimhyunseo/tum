import 'dart:async';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:flutter/material.dart';
import 'parsers/product_parser.dart';
import 'models/product_parse_result.dart';

class ReceiveShareService {
  StreamSubscription? _sub;

  void startListening(BuildContext context) {
    // For text/links
    _sub = ReceiveSharingIntent.getTextStream().listen((String value) async {
      final url = _extractUrl(value);
      if (url != null) {
        final res = await ProductParser.parseFromUrl(url);
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => ImportFromLinkPage(parseResult: res)));
      }
    }, onError: (err) {});

    // For initial shared content when app was closed
    ReceiveSharingIntent.getInitialText().then((value) async {
      if (value != null) {
        final url = _extractUrl(value);
        if (url != null) {
          final res = await ProductParser.parseFromUrl(url);
          Navigator.of(context).push(MaterialPageRoute(builder: (_) => ImportFromLinkPage(parseResult: res)));
        }
      }
    });
  }

  void dispose(){
    _sub?.cancel();
  }

  String? _extractUrl(String text){
    final regex = RegExp(r'(https?:\/\/[^\s]+)');
    final match = regex.firstMatch(text);
    return match?.group(1);
  }
}

// Import UI depends on product parse result; define here to avoid import cycles.
class ImportFromLinkPage extends StatefulWidget {
  final ProductParseResult parseResult;
  ImportFromLinkPage({required this.parseResult});
  @override
  _ImportFromLinkPageState createState()=>_ImportFromLinkPageState();
}

class _ImportFromLinkPageState extends State<ImportFromLinkPage>{
  late TextEditingController _titleCtrl;
  late TextEditingController _priceCtrl;
  late TextEditingController _categoryCtrl;

  @override
  void initState(){
    super.initState();
    _titleCtrl = TextEditingController(text: widget.parseResult.title ?? '');
    _priceCtrl = TextEditingController(text: widget.parseResult.price?.toString() ?? '');
    _categoryCtrl = TextEditingController(text: widget.parseResult.category ?? '');
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: Text('Import')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if(widget.parseResult.imageUrl!=null) Image.network(widget.parseResult.imageUrl!, height:150),
            TextField(controller: _titleCtrl, decoration: InputDecoration(labelText: 'Title')),
            TextField(controller: _priceCtrl, decoration: InputDecoration(labelText: 'Price'), keyboardType: TextInputType.number),
            TextField(controller: _categoryCtrl, decoration: InputDecoration(labelText: 'Category')),
            SizedBox(height:16),
            ElevatedButton(onPressed: _save, child: Text('Save'))
          ],
        ),
      ),
    );
  }

  void _save(){
    // Create Item and push to provider
    // To avoid direct dependency here, we pop with result and let caller handle saving
    Navigator.pop(context, {
      'title': _titleCtrl.text.trim(),
      'price': double.tryParse(_priceCtrl.text.trim()),
      'category': _categoryCtrl.text.trim(),
      'image': widget.parseResult.imageUrl,
      'source': widget.parseResult.sourceUrl,
    });
  }
}
