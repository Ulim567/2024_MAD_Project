import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shrine/edit.dart';
import 'package:shrine/productprovider.dart';

class DetailPage extends StatelessWidget {
  final String productId;

  const DetailPage({Key? key, required this.productId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        final productData = productProvider.products.firstWhere(
          (product) => product['id'] == productId,
          orElse: () => {},
        );

        if (productData.isEmpty) {
          return const Center(child: Text('Product not found'));
        }

        final currentUserUid = FirebaseAuth.instance.currentUser?.uid;
        final isCreator = productData['creatorUID'] == currentUserUid;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Product Details'),
            actions: isCreator
                ? [
                    IconButton(
                      icon: const Icon(Icons.create),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                EditPage(productId: productId),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
                        await productProvider.deleteProduct(productId);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Product deleted successfully!')),
                        );
                        Navigator.pop(context);
                      },
                    ),
                  ]
                : null,
          ),
          body: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 300,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(productData['imageURL'] ?? ''),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                productData['name'],
                                style: const TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.thumb_up),
                              onPressed: () async {
                                await productProvider.toggleLike(
                                    productId, context);
                                await productProvider.fetchProducts();
                              },
                            ),
                            Text(
                              '${productData['likes']?.length ?? 0} Likes',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '\$ ${productData['price'].toString()}',
                          style:
                              const TextStyle(fontSize: 20, color: Colors.grey),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          productData['description'] ?? '',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
              Positioned(
                bottom: 10,
                left: 10,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Creator UID: ${productData['creatorUID']}',
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                    Text(
                      'Created: ${productData['createdAt']?.toDate().toString()}',
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                    Text(
                      'Modified: ${productData['modifiedAt']?.toDate().toString()}',
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
          floatingActionButton: FutureBuilder<bool>(
            future: productProvider.isInCart(productId),
            builder: (context, snapshot) {
              final isInCart = snapshot.data ?? false;
              return FloatingActionButton(
                onPressed: () async {
                  await productProvider.toggleCart(productId, context);
                },
                child: Icon(isInCart ? Icons.check : Icons.shopping_cart),
              );
            },
          ),
        );
      },
    );
  }
}
