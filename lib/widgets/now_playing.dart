import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:google_login/screens/description.dart';

import '../constants.dart';
import '../utils/text.dart';
/*
Single
{adult: false, backdrop_path: /9n2tJBplPbgR2ca05hS5CKXwP2c.jpg, genre_ids: [16, 12, 10751, 14, 35], id: 502356, original_language: en, original_title: The Super Mario Bros. Movie, overview: While working underground to fix a water main, Brooklyn plumbers—and brothers—Mario and Luigi are transported down a mysterious pipe and wander into a magical new world. But when the brothers are separated, Mario embarks on an epic quest to find Luigi., popularity: 6510.501, poster_path: /qNBAXBIQlnOThrVvA6mA2B5ggV6.jpg, release_date: 2023-04-05, title: The Super Mario Bros. Movie, video: false, vote_average: 7.5, vote_count: 1495}
*/

class NowPlaying extends StatelessWidget {
  final List nowplaying;
  List<Widget> imageSliders = [];

  NowPlaying({super.key, required this.nowplaying});
  @override
  Widget build(BuildContext context) {
    for (int i = 0; i < nowplaying.length; i++) {
      final nowPlayingMovie = nowplaying[i];
      imageSliders.add(ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Description(
                  //Todo: add ID
                  type: "movie",
                  gerneIdData: nowPlayingMovie['genre_ids'],
                  id: nowPlayingMovie['id'],
                  name: nowPlayingMovie['title'],
                  bannerurl: preImageUrl.toString() +
                      nowPlayingMovie['backdrop_path'].toString(),
                  posterurl: preImageUrl.toString() +
                      nowPlayingMovie['poster_path'].toString(),
                  description: nowPlayingMovie['overview'],
                  vote: nowPlayingMovie['vote_average'].toString(),
                  launch_on: nowPlayingMovie['release_date'],
                ),
              ),
            );
          },
          child: Container(
            color: Colors.blue.shade100,
            child: Row(
              children: [
                CachedNetworkImage(
                  height: 200,
                  imageUrl: "$preImageUrl${nowPlayingMovie['poster_path']}",
                  placeholder: (context, url) =>
                      Image.asset("assets/images/MovieIcon.png"),
                  errorWidget: (context, url, error) =>
                      Image.asset("assets/images/MovieIcon.png"),
                  fit: BoxFit.fill,
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      modified_text(
                        size: 20,
                        text: "${nowPlayingMovie['title'] ?? 'Loading'}",
                        color: Colors.black,
                        maxLines: 3,
                      ),
                      modified_text(
                        size: 20,
                        text: "⭐- ${nowPlayingMovie['vote_average'] ?? '--'}",
                        color: Colors.black,
                        maxLines: 1,
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ));
    }
    return SizedBox(
      height: 200,
      child: CarouselSlider(
        options: CarouselOptions(
          aspectRatio: 2.0,
          enlargeCenterPage: true,
          enableInfiniteScroll: false,
          initialPage: 2,
          autoPlay: true,
        ),
        items: imageSliders,
      ),
    );
  }
}
