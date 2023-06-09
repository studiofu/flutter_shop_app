import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../providers/orders.dart' as providers;
import 'dart:math';

class OrderItem extends StatefulWidget {
  const OrderItem({super.key, required this.order});

  final providers.OrderItem order;

  @override
  State<OrderItem> createState() => _OrderItemState();
}

class _OrderItemState extends State<OrderItem> {
  var _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10),
      child: Column(children: [
        ListTile(
          title: Text('\$${widget.order.amount}'),
          subtitle:
              Text(DateFormat('dd MM yyyy:mm').format(widget.order.dateTime)),
          trailing: IconButton(
            icon: Icon(this._expanded ? Icons.expand_less : Icons.expand_more),
            onPressed: () {
              setState(() {
                _expanded = !_expanded;
              });
            },
          ),
        ),
        if (_expanded)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 4),
            height: min(widget.order.products.length * 20 + 10, 180),
            child: ListView(children: [
              ...widget.order.products
                  .map((e) => Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            e.title,
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${e.quantity} x \$${e.price}',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          )
                        ],
                      ))
                  .toList(),
            ]),
          )
      ]),
    );
  }
}
