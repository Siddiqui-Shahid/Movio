import 'dart:convert';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_login/constants.dart';
import 'package:google_login/screens/description.dart';
import 'package:google_login/utils/text.dart';
import 'package:http/http.dart' as http;

class SingleGenre extends StatefulWidget {
  final String name;
  final int id;

  const SingleGenre({Key? key, required this.name, required this.id})
      : super(key: key);

  @override
  State<SingleGenre> createState() => _SingleGenreState();
}

class _SingleGenreState extends State<SingleGenre> {
  List<dynamic> _movies = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getMoviesByGenre(widget.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.green,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        backgroundColor: Colors.black,
        title: modified_text(text: widget.name, size: 18),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: OrientationBuilder(builder: (context, orientation) {
          return GridView.builder(
              physics: BouncingScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: orientation == Orientation.portrait ? 2 : 4,
                childAspectRatio: 0.65,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: _movies.length,
              padding: EdgeInsets.only(bottom: 20.0),
              itemBuilder: (context, index) {
                final movie = _movies[index];
                return GestureDetector(
                  onTap: () {
                    log('https://image.tmdb.org/t/p/w92${movie['poster_path']}');
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Description(
                                //Todo: add ID
                                type: "movie",
                                gerneIdData: movie['genre_ids'],
                                id: movie['id'],
                                name: movie['title'],
                                bannerurl: preImageUrl + movie['backdrop_path'],
                                posterurl: preImageUrl + movie['poster_path'],
                                description: movie['overview'],
                                vote: movie['vote_average'].toString(),
                                launch_on: movie['release_date'],
                              )),
                    );
                  },
                  child: GridTile(
                    child: Column(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10.0),
                            child: CachedNetworkImage(
                              imageUrl: preImageUrl + movie['poster_path'],
                              placeholder: (context, url) =>
                                  Image.asset("assets/images/MovieIcon.png"),
                              errorWidget: (context, url, error) =>
                                  Image.asset("assets/images/MovieIcon.png"),
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                        SizedBox(height: 5),
                        modified_text(
                          size: 15,
                          text: movie['title'] ?? 'Loading',
                          maxLines: 2,
                        )
                      ],
                    ),
                  ),
                );
              });
        }),
      ),
    );
  }

  Future<void> getMoviesByGenre(int genreId) async {
    final url =
        'https://api.themoviedb.org/3/discover/movie?api_key=$apiKey&with_genres=$genreId';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final results = data['results'] as List<dynamic>;
      // log("----------");
      // log(results.toString());
      setState(() {
        _movies = results;
      });
    } else {
      throw Exception('Failed to load movies by genre');
    }
  }
}
