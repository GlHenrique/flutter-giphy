import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_giphy/ui/gif_page.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';
import 'package:transparent_image/transparent_image.dart';

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
        '$baseUrl/search?api_key=$apiKey&q=$search&limit=19&offset=$offset&rating=g&lang=pt');
    http.Response response;

    if (search == null || search!.isEmpty) {
      response = await http.get(urlTrending);
      return json.decode(response.body);
    }

    response = await http.get(urlSearch);
    return json.decode(response.body);
  }

  int getCount(List data) {
    if (search == null || search!.isEmpty) return data.length;
    return data.length + 1;
  }

  @override
  void initState() {
    super.initState();
    _getGifs();
  }

  Widget _createGifTable(BuildContext context, AsyncSnapshot snapshot) {
    return GridView.builder(
        padding: const EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: getCount(snapshot.data['data']),
        itemBuilder: (context, index) {
          if (search == null || index < snapshot.data['data'].length) {
            return GestureDetector(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: FadeInImage.memoryNetwork(
                  placeholder: kTransparentImage,
                  image: snapshot.data['data'][index]['images']['fixed_height']
                      ['url'],
                  height: 300,
                  fit: BoxFit.cover,
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Gif(snapshot.data['data'][index]),
                  ),
                );
              },
              onLongPress: () {
                Share.share(snapshot.data['data'][index]['images']
                    ['fixed_height']['url']);
              },
            );
          }
          return GestureDetector(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 70,
                ),
                Text(
                  'Carregar mais',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                  ),
                ),
              ],
            ),
            onTap: () {
              setState(() {
                offset += 19;
              });
            },
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Image.network(
            'https://developers.giphy.com/static/img/dev-logo-lg.gif'),
        centerTitle: true,
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              textInputAction: TextInputAction.search,
              onSubmitted: (value) {
                setState(() {
                  search = value;
                  offset = 0;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Pesquise...',
                labelStyle: TextStyle(
                  color: Colors.white,
                ),
                border: OutlineInputBorder(),
              ),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
              child: FutureBuilder(
            future: _getGifs(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                case ConnectionState.none:
                  return Container(
                    width: 200,
                    height: 200,
                    alignment: Alignment.center,
                    child: const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                      strokeWidth: 5,
                    ),
                  );
                default:
                  if (snapshot.hasError) return Container();
                  return _createGifTable(context, snapshot);
              }
            },
          ))
        ],
      ),
    );
  }
}
