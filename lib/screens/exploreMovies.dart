import 'dart:convert';
import 'dart:developer';

import 'package:appinio_swiper/appinio_swiper.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:expandable_text/expandable_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_login/screens/description.dart';
import 'package:google_login/utils/text.dart';
import 'package:http/http.dart' as http;

import '../constants.dart';

class ExploreMovies extends StatefulWidget {
  const ExploreMovies({Key? key}) : super(key: key);

  @override
  State<ExploreMovies> createState() => _ExploreMoviesState();
}

class _ExploreMoviesState extends State<ExploreMovies> {
  List<dynamic> randomMovies = [];
  bool isLoading = true;
  int apiIndex = 2;
  Future<void> getRandomMovies() async {
    var url =
        'https://api.themoviedb.org/3/discover/movie?api_key=$apiKey&sort_by=popularity.desc&page=$apiIndex&include_adult=false';
    if (cache.containsKey(url)) {
      cache[url];
    } else {
      var response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        cache[url] = response;
      }
    }

    if (cache[url].statusCode == 200) {
      var data = json.decode(cache[url].body);
      randomMovies.addAll(data['results']);

      // log("data['result'].toString()");
      // log(data['result'].toString());
      // log(randomMovies.toString());
      setState(() {
        isLoading = false;
        apiIndex++;
      });
    } else {
      throw Exception('Failed to load movies');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getRandomMovies();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey.shade900,
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SizedBox(
              height: MediaQuery.of(context).size.height * 0.8,
              child: AppinioSwiper(
                cardsCount: randomMovies.length,
                cardsBuilder: (BuildContext context, int index) {
                  final randomMovie = randomMovies[index];
                  return InkWell(
                    onTap: () {
                      log(randomMovie['backdrop_path'].toString());
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Description(
                                  //Todo: add ID
                                  type: "movie",
                                  gerneIdData: randomMovie['genre_ids'],
                                  id: randomMovie['id'],
                                  name: randomMovie['title'],
                                  bannerurl:
                                      "$preImageUrl${randomMovie['backdrop_path'].toString()}",
                                  posterurl:
                                      "$preImageUrl${randomMovie['poster_path'].toString()}",
                                  description: randomMovie['overview'],
                                  vote: randomMovie['vote_average'].toString(),
                                  launch_on: randomMovie['release_date'],
                                )),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        border:
                            Border.all(color: Colors.blue.shade100, width: 3),
                        borderRadius: BorderRadius.circular(10),
                        // border: BorderSide(color: Colors.green, width: 2),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: CachedNetworkImage(
                                height:
                                    MediaQuery.of(context).size.height * 0.75,
                                imageUrl:
                                    "$preImageUrl${randomMovie['poster_path']}",
                                placeholder: (context, url) =>
                                    Image.asset("assets/images/MovieIcon.png"),
                                errorWidget: (context, url, error) =>
                                    Image.asset("assets/images/MovieIcon.png"),
                                fit: BoxFit.fill,
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              left: 10,
                              child: Container(
                                // color: Colors.red,
                                height: 100,
                                width: MediaQuery.of(context).size.width * 0.8,
                                child: ListView(
                                  padding: EdgeInsets.symmetric(vertical: 4),
                                  children: [
                                    modified_text(
                                      text: "${randomMovie['title']}",
                                      size: 26,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    ExpandableText(
                                      "${randomMovie['overview']}",
                                      expandText: '...show more',
                                      collapseText: '...show less',
                                      maxLines: 2,
                                      linkStyle: GoogleFonts.robotoCondensed(
                                          color: Colors.blue.shade100,
                                          fontWeight: FontWeight.bold),
                                      style: GoogleFonts.robotoCondensed(
                                        color: Colors.blue.shade100,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                },
                onSwipe:
                    (index, AppinioSwiperDirection appinioSwiperDirection) {
                  if (index >= (randomMovies.length - 4)) {
                    getRandomMovies();
                  }
                },
              ),
            ),
    );
  }
}
