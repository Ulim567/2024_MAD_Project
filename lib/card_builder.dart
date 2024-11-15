import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shrine/detail.dart';
import 'package:shrine/productprovider.dart';

List<Card> buildGridCards(BuildContext context) {
  final theme = Theme.of(context);
  final formatter = NumberFormat.simpleCurrency(
    locale: Localizations.localeOf(context).toString(),
  );

  // ProductProvider의 제품 데이터를 가져옵니다.
  final productProvider = Provider.of<ProductProvider>(context);
  final products = productProvider.products;

  // 데이터가 없는 경우 빈 리스트를 반환합니다.
  if (products.isEmpty) {
    return const <Card>[];
  }

  // ProductProvider에서 가져온 데이터를 기반으로 카드 목록을 생성합니다.
  return products.map((data) {
    final productId = data['id'];
    final productName = data['name'] ?? 'Unknown';
    final productPrice = data['price'] ?? 0.0;
    final imageUrl = data['imageURL'] ?? '';

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              AspectRatio(
                aspectRatio: 18 / 11,
                child: imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.fitWidth,
                      )
                    : Container(color: Colors.grey), // 이미지가 없을 때 기본 색상 표시
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        productName,
                        style: theme.textTheme.titleLarge,
                        maxLines: 1,
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        formatter.format(productPrice),
                        style: theme.textTheme.titleSmall,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 5,
            right: 5,
            child: TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailPage(productId: data['id']),
                  ),
                );
              },
              child: const Text(
                "more",
                style: TextStyle(
                  color: Colors.blue, // Blue color for the button text
                ),
              ),
            ),
          ),
          FutureBuilder<bool>(
            future: productProvider.isInCart(productId),
            builder: (context, snapshot) {
              final isInCart = snapshot.data ?? false;
              return isInCart
                  ? Positioned(
                      top: 5,
                      right: 5,
                      child: Container(
                        padding: const EdgeInsets.all(
                            4), // Padding inside the circle
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.check, color: Colors.white, size: 20),
                      ),
                    )
                  : SizedBox.shrink(); // Empty widget when not in cart
            },
          ),
        ],
      ),
    );
  }).toList();
}
