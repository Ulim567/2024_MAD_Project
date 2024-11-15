import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:shrine/productprovider.dart';

class EditPage extends StatefulWidget {
  final String productId;

  const EditPage({Key? key, required this.productId}) : super(key: key);

  @override
  _EditPageState createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  final ImagePicker _picker = ImagePicker();
  XFile? _imageFile;
  String? _imageUrl; // 이미지 URL을 저장하는 변수
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProductData();
  }

  Future<void> _loadProductData() async {
    try {
      DocumentSnapshot productDoc = await FirebaseFirestore.instance
          .collection('products')
          .doc(widget.productId)
          .get();
      if (productDoc.exists) {
        Map<String, dynamic> productData =
            productDoc.data() as Map<String, dynamic>;
        _nameController.text = productData['name'];
        _priceController.text = productData['price'].toString();
        _descriptionController.text = productData['description'];
        _imageUrl = productData['imageURL']; // 이미지 URL 저장
        setState(() {}); // UI 업데이트
      }
    } catch (e) {
      print('Error loading product data: $e');
    }
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _imageFile = pickedFile;
          _imageUrl = null; // 사용자가 새 이미지를 선택하면 기존 URL 지우기
        });
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  Future<void> _saveProduct() async {
    if (_imageFile == null && (_imageUrl == null || _imageUrl!.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이미지를 선택하세요')),
      );
      return;
    }

    try {
      String? downloadURL;
      // Firebase Storage에 이미지 업로드
      if (_imageFile != null) {
        String fileName = _imageFile!.name; // 파일 이름 가져오기
        Reference ref =
            FirebaseStorage.instance.ref().child('products/$fileName');
        UploadTask uploadTask = ref.putFile(File(_imageFile!.path)); // 파일 업로드
        TaskSnapshot snapshot = await uploadTask; // 업로드 완료 대기

        // 이미지 URL 가져오기
        downloadURL = await snapshot.ref.getDownloadURL();
      } else {
        downloadURL = _imageUrl;
      }

      // 제품 데이터 준비
      Map<String, dynamic> productData = {
        'name': _nameController.text,
        'price': double.tryParse(_priceController.text) ?? 0.0,
        'description': _descriptionController.text,
        'imageURL': downloadURL,
        'creatorUID': FirebaseAuth.instance.currentUser!.uid,
        'modifiedAt': FieldValue.serverTimestamp(),
      };

      // Provider를 통해 제품 수정
      await Provider.of<ProductProvider>(context, listen: false)
          .updateProduct(widget.productId, productData);

      // 성공 메시지 표시
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('제품이 수정되었습니다!')),
      );

      // 필드 초기화
      _nameController.clear();
      _priceController.clear();
      _descriptionController.clear();
      setState(() {
        _imageFile = null; // 선택된 이미지 지우기
        _imageUrl = null; // 이미지 URL도 초기화
      });

      // 이전 페이지로 돌아가기
      Navigator.pop(context);
    } catch (e) {
      print('제품 수정 오류: $e'); // 오류 출력
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('제품 수정 중 오류 발생')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Product'),
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
                      ? (_imageUrl != null
                          ? DecorationImage(
                              image: NetworkImage(_imageUrl!), // 이미지 URL 사용
                              fit: BoxFit.cover,
                            )
                          : const DecorationImage(
                              image: NetworkImage(
                                  "https://handong.edu/site/handong/res/img/logo.png"),
                            ))
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
