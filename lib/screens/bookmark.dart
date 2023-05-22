import 'dart:convert';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_login/utils/text.dart';
import 'package:http/http.dart' as http;

import '../constants.dart';
import 'description.dart';

class Bookmark extends StatefulWidget {
  const Bookmark({
    Key? key,
  }) : super(key: key);
  @override
  State<Bookmark> createState() => _BookmarkState();
}

class _BookmarkState extends State<Bookmark> {
  List<dynamic> bookmarkMovies = [];
  bool isLoading = true;
  Future getDocs() async {
    CollectionReference usersRef = FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .collection('movies');

    usersRef.get().then((QuerySnapshot snapshot) {
      snapshot.docs.forEach((DocumentSnapshot doc) {
        bookmarkMovies.add(doc.data());
        // log(doc.data().toString());
        // log("bookmarkMovies.toString()");
        // log(bookmarkMovies.toString());
      });
      setState(() {
        isLoading = false;
      });
    });
/*
Sample:-
[{created: Timestamp(seconds=1682951909, nanoseconds=894000000), imageUrl: https://image.tmdb.org/t/p/w500/wDWwtvkRRlgTiUr6TyLSMX8FCuZ.jpg, description: Following the latest Ghostface killings, the four survivors leave Woodsboro behind and start a fresh chapter., id: 934433, title: Scream VI}, {created: Timestamp(seconds=1682951917, nanoseconds=896000000), imageUrl: https://image.tmdb.org/t/p/w500/bkPpmNSdbRIgtscqH86BQFLJXcz.jpg, description: On the eve of her 38th birthday, a woman desperately attempts to fix her broken biological clock., id: 1085103, title: Clock}, {created: Timestamp(seconds=1682951907, nanoseconds=144000000), imageUrl: https://image.tmdb.org/t/p/w500/9NXAlFEE7WDssbXSMgdacsUD58Y.jpg, description: Wendy Darling, a young girl afraid to leave her childhood home behind, meets Peter Pan, a boy who refuses to grow up. Alongside her brothers and a tiny fairy, Tinker Bell, she travels with Peter to the magical world of Neverland. There, she encounters an evil pirate captain, Captain Hook, and embarks on a thrilling adventure that will change her life forever., id: 420808, title: Peter Pan & Wendy}, {created: Timestamp(seconds=1682951912, nanoseconds=182000000), imageUrl: https://image.tmdb.org/t/p/w500/c0Zv7gNTH8LoRnHANhAHGWhGvJC.jpg, description: A steely special ops agent finds his morality put to the test when he infiltrates a crime syndicate and unexpectedly bonds with the boss' young son., id: 1102776, title: AKA}, {created: Timestamp(seconds=1682951922, nanoseconds=898000000), imageUrl: https://image.tmdb.org/t/p/w500/qNBAXBIQlnOThrVvA6mA2B5ggV6.jpg, description: While working underground to fix a water main, Brooklyn plumbers—and brothers—Mario and Luigi are transported down a mysterious pipe and wander into a magical new world. But when the brothers are separated, Mario embarks on an epic quest to find Luigi., id: 502356, title: The Super Mario Bros. Movie}]
 */
    // log("bookmarkMovies.toString()");
    // log(bookmarkMovies.toString());
  }

  Future<Map<String, dynamic>> fetchMovieData(String movieId) async {
    final String url =
        "https://api.themoviedb.org/3/movie/$movieId?api_key=$apiKey";
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load movie data');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // log("getDocs()");
    getDocs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : bookmarkMovies.length == 0
                ? modified_text(
                    text: "There Are no movies",
                    size: 30,
                  )
                : ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: bookmarkMovies.length,
                    itemBuilder: (context, index) {
                      final bookmarkMovie = bookmarkMovies[index];
                      return InkWell(
                        onTap: () {
                          // setState(() {
                          //   isLoading = true;
                          // });
                          fetchMovieData(bookmarkMovie['id']).then((value) {
                            try {
                              log(value.toString());
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Description(
                                    //Todo: add ID
                                    type: "movie",
                                    id: value['id'],
                                    name: value['title'],
                                    bannerurl: preImageUrl +
                                        value['backdrop_path'].toString(),
                                    posterurl: preImageUrl +
                                        value['poster_path'].toString(),
                                    description: value['overview'],
                                    vote: value['vote_average'].toString(),
                                    launch_on: value['release_date'],
                                    gerneIdData: [],
                                  ),
                                ),
                              );
                            } catch (ex) {
                              log(ex.toString());
                            }
                          });

                          // fetchMovieData(bookmarkMovie['id']).then((data) {
                          //   try {
                          //     setState(() {
                          //       isLoading = false;
                          //     });

                          //   } catch (e) {
                          //     log('Error navigating to new screen: $e');
                          //   }
                          // });
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: CachedNetworkImage(
                                    height: 200,
                                    imageUrl:
                                        "$preImageUrl${bookmarkMovie['imageUrl']}",
                                    placeholder: (context, url) => Image.asset(
                                        "assets/images/MovieIcon.png"),
                                    errorWidget: (context, url, error) =>
                                        Image.asset(
                                            "assets/images/MovieIcon.png"),
                                    fit: BoxFit.fill,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                flex: 5,
                                child: Container(
                                  height: 200,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      modified_text(
                                        text: bookmarkMovie['title'],
                                        size: 26,
                                      ),
                                      modified_text(
                                        text: bookmarkMovie['description'],
                                        size: 18,
                                        maxLines: 5,
                                      )
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
