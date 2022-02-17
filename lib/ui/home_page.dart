import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String? search;
  int offset = 0;
  String apiKey = 'PNKlaY5ndeu9sTAqw6WkM5xP0pzboncM';
  String baseUrl = 'https://api.giphy.com/v1/gifs';

  Future<Map> _getGifs() async {
    Uri urlTrending =
        Uri.parse('$baseUrl/trending?api_key=$apiKey&limit=20&rating=g');
    Uri urlSearch = Uri.parse(
        '$baseUrl/search?api_key=$apiKey&q=$search&limit=20&offset=$offset&rating=g&lang=pt');
    http.Response response;

    if (search == null) {
      response = await http.get(urlTrending);
      return json.decode(response.body);
    }

    response = await http.get(urlSearch);
    return json.decode(response.body);
  }

  @override
  void initState() {
    super.initState();
    _getGifs().then((value) => print(value));
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
