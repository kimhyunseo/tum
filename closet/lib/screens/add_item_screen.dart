import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../models/wardrobe_item.dart';

class AddItemScreen extends StatefulWidget {
  final void Function(WardrobeItem) onAdd;
  final WardrobeItem? existing;
  const AddItemScreen({Key? key, required this.onAdd, this.existing}) : super(key: key);

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  String _category = 'top';
  int _minTemp = 0;
  int _maxTemp = 30;
  bool _waterproof = false;
  String? _imagePath;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      final e = widget.existing!;
      _nameCtrl.text = e.name;
      _category = e.category;
      _minTemp = e.minTemp;
      _maxTemp = e.maxTemp;
      _waterproof = e.waterproof;
      _imagePath = e.imagePath;
    }
  }

  Future<void> _pickImage(ImageSource src) async {
    try {
      final XFile? picked = await _picker.pickImage(source: src, maxWidth: 1200, maxHeight: 1200, imageQuality: 80);
      if (picked == null) return;
      final appDir = await getApplicationDocumentsDirectory();
      final ext = picked.path.split('.').last;
      final filename = '${const Uuid().v4()}.$ext';
      final saved = File('${appDir.path}/$filename');
      await File(picked.path).copy(saved.path);
      setState(() {
        _imagePath = saved.path;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('이미지 선택 오류: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('옷장 아이템 추가')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Image picker
              Center(
                child: Column(
                  children: [
                    _imagePath != null
                        ? ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.file(File(_imagePath!), width: 120, height: 120, fit: BoxFit.cover))
                        : Container(width: 120, height: 120, decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: Colors.grey[200]), child: const Icon(Icons.photo, size: 48, color: Colors.grey)),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton.icon(onPressed: () => _pickImage(ImageSource.camera), icon: const Icon(Icons.photo_camera), label: const Text('카메라')),
                        const SizedBox(width: 8),
                        TextButton.icon(onPressed: () => _pickImage(ImageSource.gallery), icon: const Icon(Icons.photo_library), label: const Text('갤러리')),
                        if (_imagePath != null)
                          IconButton(onPressed: () => setState(() => _imagePath = null), icon: const Icon(Icons.delete_forever, color: Colors.red)),
                      ],
                    )
                  ],
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: '이름'),
                validator: (v) => (v == null || v.isEmpty) ? '필수 입력' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _category,
                items: const [
                  DropdownMenuItem(value: 'top', child: Text('상의')),
                  DropdownMenuItem(value: 'bottom', child: Text('하의')),
                  DropdownMenuItem(value: 'outer', child: Text('아우터')),
                  DropdownMenuItem(value: 'shoes', child: Text('신발')),
                ],
                onChanged: (v) => setState(() => _category = v ?? 'top'),
                decoration: const InputDecoration(labelText: '카테고리'),
              ),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                    child: TextFormField(
                  initialValue: '$_minTemp',
                  decoration: const InputDecoration(labelText: '최소 온도 (°C)'),
                  keyboardType: TextInputType.number,
                  onChanged: (v) => _minTemp = int.tryParse(v) ?? 0,
                )),
                const SizedBox(width: 12),
                Expanded(
                    child: TextFormField(
                  initialValue: '$_maxTemp',
                  decoration: const InputDecoration(labelText: '최대 온도 (°C)'),
                  keyboardType: TextInputType.number,
                  onChanged: (v) => _maxTemp = int.tryParse(v) ?? 30,
                )),
              ]),
              const SizedBox(height: 12),
              SwitchListTile(
                title: const Text('방수 여부'),
                value: _waterproof,
                onChanged: (v) => setState(() => _waterproof = v),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState?.validate() ?? false) {
                    final id = widget.existing?.id ?? const Uuid().v4();
                    final item = WardrobeItem(
                        id: id,
                        name: _nameCtrl.text.trim(),
                        category: _category,
                        minTemp: _minTemp,
                        maxTemp: _maxTemp,
                        waterproof: _waterproof,
                        imagePath: _imagePath ?? widget.existing?.imagePath);
                    widget.onAdd(item);
                    Navigator.of(context).pop(item);
                  }
                },
                child: const Text('추가'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
