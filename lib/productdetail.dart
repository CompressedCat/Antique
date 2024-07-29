import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter_stripe/flutter_stripe.dart';

class ProductDetailPage extends StatelessWidget {
  final String itemId;

  const ProductDetailPage({super.key, required this.itemId});

  Future<void> _handlePayment(BuildContext context, int amount) async {
    try {
      // final response = await http.post(
      //   Uri.parse('http://localhost:3000/create-payment-intent'), // Replace with your server URL
      //   headers: {'Content-Type': 'application/json'},
      //   body: json.encode({'amount': amount}),
      // );
      //
      // final jsonResponse = json.decode(response.body);
      // final clientSecret = jsonResponse['clientSecret'];
      //
      // await Stripe.instance.initPaymentSheet(
      //   paymentSheetParameters: SetupPaymentSheetParameters(
      //     paymentIntentClientSecret: clientSecret,
      //     merchantDisplayName: 'Antique Community',
      //   ),
      // );
      //
      // await Stripe.instance.presentPaymentSheet();
      //
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(content: Text('Payment successful')),
      // );
    } catch (e) {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text('Payment failed: ${e.toString()}')),
      // );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Detail'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('items').doc(itemId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Item not found'));
          }

          var itemData = snapshot.data!.data() as Map<String, dynamic>;
          int itemPrice = itemData['itemPrice'];

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.network(
                  itemData['itemImage'],
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                const SizedBox(height: 16),
                Text(
                  itemData['itemName'],
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  itemData['itemDescription'],
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  'Price: RM $itemPrice',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _handlePayment(context, itemPrice * 100), // Convert to smallest currency unit
                    child: const Text('Buy'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
