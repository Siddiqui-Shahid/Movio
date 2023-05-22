import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_login/constants.dart';

import '../screens/description.dart';
import '../utils/text.dart';

class TrendingMovies extends StatefulWidget {
  final List trending;

  const TrendingMovies({Key? key, required this.trending}) : super(key: key);

  @override
  State<TrendingMovies> createState() => _TrendingMoviesState();
}

class _TrendingMoviesState extends State<TrendingMovies> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          modified_text(
            text: 'Trending Movies',
            size: 26,
          ),
          SizedBox(height: 10),
          Container(
              height: 270,
              child: ListView.builder(
                  physics: BouncingScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.trending.length,
                  itemBuilder: (context, index) {
                    final trend = widget.trending[index];
                    if (trend['title'] == null) {
                      return const SizedBox();
                    } else {
                      return InkWell(
                        onTap: () {
                          log(trend.toString());
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Description(
                                //Todo: add ID
                                type: "movie",
                                gerneIdData: trend['genre_ids'],
                                id: trend['id'],
                                name: trend['title'],
                                bannerurl: preImageUrl +
                                    trend['backdrop_path'].toString(),
                                posterurl: preImageUrl +
                                    trend['poster_path'].toString(),
                                description: trend['overview'],
                                vote: trend['vote_average'].toString(),
                                launch_on: trend['release_date'],
                              ),
                            ),
                          );
                        },
                        child: Container(
                          width: 140,
                          child: Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: CachedNetworkImage(
                                  height: 200,
                                  imageUrl:
                                      "$preImageUrl${trend['poster_path']}",
                                  placeholder: (context, url) => Image.asset(
                                      "assets/images/MovieIcon.png"),
                                  errorWidget: (context, url, error) =>
                                      Image.asset(
                                          "assets/images/MovieIcon.png"),
                                  fit: BoxFit.fill,
                                ),
                              ),
                              const SizedBox(height: 5),
                              modified_text(
                                size: 15,
                                text: trend['title'] ?? 'Loading',
                                // isDiscreption: true,
                              )
                            ],
                          ),
                        ),
                      );
                    }
                  }))
        ],
      ),
    );
  }
}
