import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_login/screens/single_genre_screen.dart';

import '../screens/all_movies.dart';

class GenreListScreen extends StatefulWidget {
  @override
  _GenreListScreenState createState() => _GenreListScreenState();
}

class _GenreListScreenState extends State<GenreListScreen> {
  @override
  Widget build(BuildContext context) {
    log(allGenresList.toString());
    return Scaffold(
        backgroundColor: Colors.black,
        body: allGenresList.isEmpty
            ? Center(child: CircularProgressIndicator())
            : OrientationBuilder(
                builder: (context, orientation) {
                  return GridView.builder(
                    physics: BouncingScrollPhysics(),
                    itemCount: allGenresList.length,
                    padding: EdgeInsets.all(10),
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SingleGenre(
                                      name: allGenresList[index].name,
                                      id: allGenresList[index].id)),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.blue.shade100,
                                borderRadius: BorderRadius.circular(20)),
                            child: Center(
                              child: Text(
                                allGenresList[index].name,
                                style:
                                    TextStyle(color: Colors.blueGrey.shade900),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount:
                          orientation == Orientation.portrait ? 2 : 4,
                    ),
                  );
                },
              )

        // ListView.builder(
        //         itemCount: _genres.length,
        //         itemBuilder: (context, index) {
        //           return ExpansionTile(
        //             title: Text(
        //               _genres[index]["name"],
        //               style: TextStyle(color: Colors.green),
        //             ),
        //             children: <Widget>[
        //               FutureBuilder(
        //                 future: getMoviesByGenre(_genres[index]["id"]),
        //                 builder: (context, snapshot) {
        //                   if (snapshot.connectionState ==
        //                       ConnectionState.waiting) {
        //                     return const Center(
        //                         child: CircularProgressIndicator());
        //                   }
        //                   final movies = snapshot.data;
        //                   return movies!.isEmpty
        //                       ? const Center(child: Text('No movies found.'))
        //                       : ListView.builder(
        //                           shrinkWrap: true,
        //                           scrollDirection: Axis.horizontal,
        //                           itemCount: movies.length,
        //                           itemBuilder: (context, index) {
        //                             final movie = movies[index];
        //                             return SizedBox(
        //                               width: 140,
        //                               height: 300,
        //                               child: Column(
        //                                 children: [
        //                                   Container(
        //                                     decoration: BoxDecoration(
        //                                       image: movie['poster_path'] !=
        //                                               null
        //                                           ? DecorationImage(
        //                                               image: CachedNetworkImageProvider(
        //                                                   preImageUrl +
        //                                                       movie[
        //                                                           'poster_path']),
        //                                             )
        //                                           : const DecorationImage(
        //                                               image: AssetImage(
        //                                                   "assets/images/MovieIcon.png")),
        //                                     ),
        //                                   ),
        //                                   const SizedBox(height: 5),
        //                                   Container(
        //                                     child: modified_text(
        //                                         size: 15,
        //                                         text: movie['title'] ??
        //                                             'Loading'),
        //                                   )
        //                                 ],
        //                               ),
        //                             );
        //                           },
        //                         );
        //                 },
        //               ),
        //             ],
        //           );
        //         },
        //       ),
        );
  }
}
