import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_login/constants.dart';
import 'package:google_login/screens/description.dart';
import 'package:google_login/utils/text.dart';

class TopRatedMovies extends StatelessWidget {
  final List toprated;

  const TopRatedMovies({Key? key, required this.toprated}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          modified_text(
            text: 'Top Rated Movies',
            size: 26,
          ),
          const SizedBox(height: 10),
          SizedBox(
              height: 270,
              child: ListView.builder(
                  physics: BouncingScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  itemCount: toprated.length,
                  itemBuilder: (context, index) {
                    final top = toprated[index];
                    return InkWell(
                      onTap: () {
                        log(top.toString());
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Description(
                                    //Todo: add ID
                                    type: "movie",
                                    data: top['genre_ids'],
                                    id: top['id'],
                                    name: top['title'],
                                    bannerurl:
                                        "$preImageUrl${top['backdrop_path']}",
                                    posterurl:
                                        "$preImageUrl${top['poster_path']}",
                                    description: top['overview'],
                                    vote: top['vote_average'].toString(),
                                    launch_on: top['release_date'],
                                  )),
                        );
                        /*

{adult: false, backdrop_path: /tmU7GeKVybMWFButWEGl2M4GeiP.jpg, genre_ids: [18, 80], id: 238, original_language: en, original_title: The Godfather, overview: Spanning the years 1945 to 1955, a chronicle of the fictional Italian-American Corleone crime family. When organized crime family patriarch, Vito Corleone barely survives an attempt on his life, his youngest son, Michael steps in to take care of the would-be killers, launching a campaign of bloody revenge., popularity: 130.349, poster_path: /3bhkrj58Vtu7enYsRolD1fZdja1.jpg, release_date: 1972-03-14, title: The Godfather, video: false, vote_average: 8.7, vote_count: 17745}

 */
                      },
                      //preImageUrl + top['poster_path']
                      child: SizedBox(
                        width: 140,
                        child: Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: CachedNetworkImage(
                                height: 200,
                                imageUrl: "$preImageUrl${top['poster_path']}",
                                placeholder: (context, url) =>
                                    Image.asset("assets/images/MovieIcon.png"),
                                errorWidget: (context, url, error) =>
                                    Image.asset("assets/images/MovieIcon.png"),
                                fit: BoxFit.fill,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Container(
                              child: modified_text(
                                  size: 15, text: top['title'] ?? 'Loading'),
                            )
                          ],
                        ),
                      ),
                    );
                  }))
        ],
      ),
    );
  }
}
