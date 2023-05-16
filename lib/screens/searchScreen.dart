import 'dart:convert';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_login/constants.dart';
import 'package:http/http.dart' as http;

import '../utils/text.dart';
import '../widgets/geren_list.dart';
import 'description.dart';

class MovieSearchScreen extends StatefulWidget {
  @override
  _MovieSearchScreenState createState() => _MovieSearchScreenState();
}

class _MovieSearchScreenState extends State<MovieSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _movies = [];
  Future<List<dynamic>> searchMovies(String query) async {
    final url =
        'https://api.themoviedb.org/3/search/movie?api_key=$apiKey&query=$query&include_adult=false';
    final response = await http.get(Uri.parse(url));
    final data = jsonDecode(response.body);
    // log(data.toString());
    return data['results'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      // appBar: AppBar(
      //   leading: IconButton(
      //     icon: const Icon(
      //       Icons.arrow_back,
      //       color: Colors.green,
      //     ),
      //     onPressed: () {
      //       Navigator.of(context).pop();
      //     },
      //   ),
      //   backgroundColor: Colors.black,
      //   title:
      // ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 10),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              height: 50,
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Theme(
                data: ThemeData(
                  textSelectionTheme: TextSelectionThemeData(
                    cursorColor: Colors.black,
                  ),
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: TextField(
                    controller: _searchController,
                    style: GoogleFonts.roboto(color: Colors.black),
                    decoration: InputDecoration(
                      hintText: 'Search for a movie',
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.black,
                      ),
                      border: InputBorder.none,
                      // textSelectionTheme:
                      //     TextSelectionThemeData(cursorColor: Colors.white),
                      hintStyle:
                          GoogleFonts.robotoCondensed(color: Colors.black26),
                    ),
                    onSubmitted: (query) async {
                      final movies = await searchMovies(query);
                      setState(() {
                        _movies = movies;
                      });
                    },
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: _movies.length == 0
                ? GenreListScreen()
                : Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    child: OrientationBuilder(builder: (context, orientation) {
                      return GridView.builder(
                        physics: BouncingScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount:
                              orientation == Orientation.portrait ? 2 : 4,
                          childAspectRatio: 0.65,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        itemCount: _movies.length,
                        itemBuilder: (context, index) {
                          final movie = _movies[index];
                          return InkWell(
                            onTap: () {
                              log(movie['backdrop_path'].toString());
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Description(
                                          //Todo: add ID
                                          type: "movie",
                                          data: movie['genre_ids'],
                                          id: movie['id'],
                                          name: movie['title'],
                                          bannerurl:
                                              "$preImageUrl${movie['backdrop_path'].toString()}",
                                          posterurl:
                                              "$preImageUrl${movie['poster_path'].toString()}",
                                          description: movie['overview'],
                                          vote:
                                              movie['vote_average'].toString(),
                                          launch_on: movie['release_date'],
                                        )),
                              );
                            },
                            child: SizedBox(
                              child: Column(
                                children: [
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        image: movie['poster_path'] != null
                                            ? DecorationImage(
                                                image:
                                                    CachedNetworkImageProvider(
                                                  preImageUrl +
                                                      movie['poster_path']
                                                          .toString(),
                                                ),
                                                fit: BoxFit.fill)
                                            : const DecorationImage(
                                                image: AssetImage(
                                                    "assets/images/MovieIcon.png"),
                                                fit: BoxFit.fill),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Container(
                                    child: modified_text(
                                        size: 15,
                                        text: movie['title'] ?? 'Loading'),
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    }),
                  ),
          )
          // _movies.length == 0
          //     ? GenreListScreen()
          //     : Padding(
          //         padding: const EdgeInsets.only(left: 20, right: 20),
          //         child: GridView.builder(
          //           physics: BouncingScrollPhysics(),
          //           gridDelegate:
          //               const SliverGridDelegateWithFixedCrossAxisCount(
          //             crossAxisCount: 2,
          //             childAspectRatio: 0.65,
          //             crossAxisSpacing: 10,
          //             mainAxisSpacing: 10,
          //           ),
          //           itemCount: _movies.length,
          //           itemBuilder: (context, index) {
          //             final movie = _movies[index];
          //             return InkWell(
          //               onTap: () {
          //                 log(movie['backdrop_path'].toString());
          //                 Navigator.push(
          //                   context,
          //                   MaterialPageRoute(
          //                       builder: (context) => Description(
          //                             //Todo: add ID
          //                             type: "movie",
          //                             id: movie['id'],
          //                             name: movie['title'],
          //                             bannerurl:
          //                                 "$preImageUrl${movie['backdrop_path'].toString()}",
          //                             posterurl:
          //                                 "$preImageUrl${movie['poster_path'].toString()}",
          //                             description: movie['overview'],
          //                             vote: movie['vote_average'].toString(),
          //                             launch_on: movie['release_date'],
          //                           )),
          //                 );
          //               },
          //               child: SizedBox(
          //                 child: Column(
          //                   children: [
          //                     Expanded(
          //                       child: Container(
          //                         decoration: BoxDecoration(
          //                           borderRadius: BorderRadius.circular(10),
          //                           image: movie['poster_path'] != null
          //                               ? DecorationImage(
          //                                   image: CachedNetworkImageProvider(
          //                                     preImageUrl +
          //                                         movie['poster_path']
          //                                             .toString(),
          //                                   ),
          //                                   fit: BoxFit.fill)
          //                               : const DecorationImage(
          //                                   image: AssetImage(
          //                                       "assets/images/MovieIcon.png"),
          //                                   fit: BoxFit.fill),
          //                         ),
          //                       ),
          //                     ),
          //                     const SizedBox(height: 5),
          //                     Container(
          //                       child: modified_text(
          //                           size: 15,
          //                           text: movie['title'] ?? 'Loading'),
          //                     )
          //                   ],
          //                 ),
          //               ),
          //             );
          //           },
          //         ),
          //       ),
        ],
      ),
    );
  }
}
