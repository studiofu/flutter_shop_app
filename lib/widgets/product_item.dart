import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/screens/product_detail_screen.dart';

import '../providers/auth.dart';
import '../providers/cart.dart';
import '../providers/product.dart';

class ProductItem extends StatelessWidget {
  const ProductItem({super.key});

  // final String id;
  // final String title;
  // final String imageUrl;

  @override
  Widget build(BuildContext context) {
    //final product = Provider.of<Product>(context);

    final cart = Provider.of<Cart>(context, listen: false);
    final auth = Provider.of<Auth>(context, listen: false);

    // if using consumer, you can only wrap the sub-part of the
    // widget so that not everything are rebuilt in this screen

    return Consumer<Product>(
      builder: (context, product, child) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: GridTile(
            // navigate to detail screen
            footer: GridTileBar(
              backgroundColor: Colors.black54,
              title: Text(product.title, textAlign: TextAlign.center),
              leading: IconButton(
                icon: Icon(product.isFavorite
                    ? Icons.favorite
                    : Icons.favorite_border),
                onPressed: () {
                  product.toggleFavoriteStatus(auth.token, auth.userId);
                },
                color: Theme.of(context).colorScheme.secondary,
              ),
              trailing: IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () {
                  cart.addItem(product.id, product.price, product.title);
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Add Item to cart!'),
                    duration: Duration(seconds: 2),
                    action: SnackBarAction(
                      label: 'Undo',
                      onPressed: () {
                        cart.removeSingleItem(product.id);
                      },
                    ),
                  ));
                },
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
            // navigate to detail screen
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pushNamed(ProductDetailScreen.routeName,
                    arguments: product.id);
              },
              child: Image.network(
                product.imageUrl,
                fit: BoxFit.cover,
              ),
            ),
          ),
        );
      },
    );
  }
}
