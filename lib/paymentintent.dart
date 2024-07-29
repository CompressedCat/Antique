import 'package:http/http.dart' as http;
import 'dart:convert';

Future<String> createPaymentIntent() async {
  final url = Uri.parse('http://www.AntiqueCommunity.com/create-payment-intent');
  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: json.encode({
      'amount': 1000, // Amount in cents
      'currency': 'myr',
    }),
  );

  final body = json.decode(response.body);
  return body['clientSecret'];
}
