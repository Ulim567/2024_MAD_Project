import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shrine/productprovider.dart';

class WishlistPage extends StatefulWidget {
  const WishlistPage({Key? key}) : super(key: key);

  @override
  _WishlistPageState createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  @override
  void initState() {
    super.initState();
    // Fetch wishlist items when the page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductProvider>(context, listen: false).fetchWishlistItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wishlist'),
      ),
      body: Consumer<ProductProvider>(
        builder: (context, productProvider, child) {
          final wishlistItems = productProvider.wishlistItems;

          if (wishlistItems.isEmpty) {
            return const Center(child: Text('Your wishlist is empty'));
          }

          return ListView.builder(
            itemCount: wishlistItems.length,
            itemBuilder: (context, index) {
              final item = wishlistItems[index];

              return ListTile(
                leading: Image.network(
                  item['imageURL'] ?? '',
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
                title: Text(item['name']),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    await productProvider.toggleCart(item['id'], context);
                    await productProvider.fetchWishlistItems();
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
