import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shrine/card_builder.dart';
import 'package:shrine/productprovider.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _sortOrder = 'ASC'; // 초기 정렬 기준

  @override
  void initState() {
    super.initState();
    // 페이지가 처음 생성될 때만 제품 데이터를 불러옵니다.
    Provider.of<ProductProvider>(context, listen: false).fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.person),
          onPressed: () {
            Navigator.pushNamed(context, '/profile');
          },
        ),
        title: const Text('Main'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.pushNamed(context, '/wishlist');
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(context, '/add');
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(40.0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: DropdownButton<String>(
              value: _sortOrder,
              items: const [
                DropdownMenuItem(
                  value: 'ASC',
                  child: Text('ASC'),
                ),
                DropdownMenuItem(
                  value: 'DSC',
                  child: Text('DESC'),
                ),
              ],
              onChanged: (String? newValue) {
                setState(() {
                  _sortOrder = newValue!;
                  // 선택된 정렬 기준에 따라 제품을 정렬합니다.
                  Provider.of<ProductProvider>(context, listen: false)
                      .sortProducts(_sortOrder);
                });
              },
            ),
          ),
        ),
      ),
      body: Consumer<ProductProvider>(
        builder: (context, productProvider, child) {
          if (productProvider.products.isEmpty) {
            return const Center(child: Text('제품이 없습니다.'));
          }

          return GridView.count(
            crossAxisCount: 2,
            padding: const EdgeInsets.all(16.0),
            childAspectRatio: 8.0 / 9.0,
            children: buildGridCards(context),
          );
        },
      ),
      resizeToAvoidBottomInset: false,
    );
  }
}
