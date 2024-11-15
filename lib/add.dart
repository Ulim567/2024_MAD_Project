import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:shrine/productprovider.dart'; // Import your ProductProvider

class AddPage extends StatefulWidget {
  const AddPage({Key? key}) : super(key: key);

  @override
  _AddPageState createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  final ImagePicker _picker = ImagePicker();
  XFile? _imageFile;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _imageFile = pickedFile;
        });
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  Future<void> _saveProduct() async {
    try {
      String downloadURL = "https://handong.edu/site/handong/res/img/logo.png";
      if (_imageFile != null) {
        String fileName = _imageFile!.name; // 파일 이름 가져오기
        Reference ref =
            FirebaseStorage.instance.ref().child('products/$fileName');
        UploadTask uploadTask = ref.putFile(File(_imageFile!.path)); // 파일 업로드
        TaskSnapshot snapshot = await uploadTask; // 업로드 완료 대기

        // 이미지 URL 가져오기
        downloadURL = await snapshot.ref.getDownloadURL();
      }

      // 현재 사용자 UID 가져오기
      String creatorUID = FirebaseAuth.instance.currentUser!.uid;

      // 제품 데이터 준비
      Map<String, dynamic> productData = {
        'name': _nameController.text,
        'price': double.tryParse(_priceController.text) ?? 0.0,
        'description': _descriptionController.text,
        'imageURL': downloadURL,
        'creatorUID': creatorUID,
        'createdAt': FieldValue.serverTimestamp(),
        'modifiedAt': FieldValue.serverTimestamp(),
        'likes': [],
      };

      // Provider를 통해 제품 추가
      await Provider.of<ProductProvider>(context, listen: false)
          .addProduct(productData);

      // 성공 메시지 표시
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('제품이 저장되었습니다!')),
      );

      // 페이지를 HomePage로 이동
      Navigator.pushReplacementNamed(context, '/'); // HomePage로 이동

      // 필드 초기화
      _nameController.clear();
      _priceController.clear();
      _descriptionController.clear();
      setState(() {
        _imageFile = null; // 선택된 이미지 지우기
      });
    } catch (e) {
      print('제품 저장 오류: $e'); // 오류 출력
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('제품 저장 중 오류 발생')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add'),
        leading: FittedBox(
          fit: BoxFit.scaleDown,
          child: TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.black),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: _saveProduct, // Call the save function
            child: const Text(
              'Save',
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                height: 300,
                width: double.infinity,
                decoration: BoxDecoration(
                  image: _imageFile == null
                      ? const DecorationImage(
                          image: NetworkImage(
                              "https://handong.edu/site/handong/res/img/logo.png"),
                        )
                      : DecorationImage(
                          image: FileImage(File(_imageFile!.path)),
                          fit: BoxFit.cover,
                        ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.camera_alt),
                onPressed: _pickImage,
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Product Name',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _priceController,
                  decoration: const InputDecoration(
                    labelText: 'Price',
                    prefixText: '\$ ',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
