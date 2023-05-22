import 'dart:convert';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_login/constants.dart';
import 'package:google_login/screens/single_genre_screen.dart';
import 'package:google_login/utils/text.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../utils/star.dart';
import 'Cast_info.dart';
import 'all_movies.dart';

class Description extends StatefulWidget {
  final String name, description, bannerurl, posterurl, vote, launch_on, type;
  final int id;
  double previousOffset = 0;
  final List<dynamic> gerneIdData;

  Description({
    Key? key,
    required this.name,
    required this.description,
    required this.bannerurl,
    required this.posterurl,
    required this.vote,
    required this.launch_on,
    required this.id,
    this.type = "movie",
    required this.gerneIdData,
  }) : super(key: key);

  @override
  State<Description> createState() => _DescriptionState();
}

class _DescriptionState extends State<Description> {
  bool isLoading = true;
  List<Star> stars = [];
  final GlobalKey castExpansionTileKey = GlobalKey();
  final GlobalKey similarExpansionTileKey = GlobalKey();
  final GlobalKey reviewExpansionTileKey = GlobalKey();
  bool isCastExpanded = true;
  bool isSimilarExpanded = true;
  bool isReviewExpanded = true;
  List<dynamic> similarMovies = [];
  List<dynamic> movieReviews = [];
  bool isBookmark = false;
  bool isFavorite = false;

  Future<void> getSimilarMovies(int movieId) async {
    final response = await http.get(Uri.parse(
        'https://api.themoviedb.org/3/movie/$movieId/similar?api_key=$apiKey'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      // log(data['results'].toString());
      similarMovies = data['results'];
    } else {
      throw Exception('Failed to load similar movies');
    }
  }

  Future<void> getMovieReviews() async {
    final url =
        'https://api.themoviedb.org/3/movie/${widget.id}/reviews?api_key=$apiKey&language=en-US&page=1';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      movieReviews = json['results'];
      log("movieReviews.toString()");
      log(movieReviews.toString());
    } else {
      throw Exception('Failed to load movie reviews');
    }
  }

  Future<void> hasMovieInBookmark() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .collection('movies')
        .get();
    // log("snapshot.toString()");
    // log(snapshot.toString());
    // log("snapshot.size.toString()");
    // log(snapshot.size.toString());
    isBookmark = snapshot.size == 1;
    setState(() {
      isLoading = false;
    });
  }

  Future<void> getMovieStars(int movieId) async {
    final response = await http.get(
      Uri.parse(
          'https://api.themoviedb.org/3/movie/$movieId/credits?api_key=$apiKey'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> starData = data['cast'];
      // log("data.toString()");
      // log(data.toString());
      // log("starData.toString()");
      // log(starData.toString());
      stars = starData
          .map((star) => Star(
                name: star['name'],
                profileImageUrl:
                    'https://image.tmdb.org/t/p/w500${star['profile_path']}',
                castId: star['id'],
              ))
          .toList();
      // log("stars.toString()");
      // log(stars.toString());
      setState(() {});
    } else {
      throw Exception('Failed to load movie stars');
    }
  }

  void _scrollToSelectedContent({required GlobalKey expansionTileKey}) {
    final keyContext = expansionTileKey.currentContext;
    if (keyContext != null) {
      Future.delayed(const Duration(milliseconds: 200)).then((value) {
        Scrollable.ensureVisible(keyContext,
            duration: const Duration(milliseconds: 200));
      });
    }
  }

  void add(
      {required String title,
      required String discription,
      required String imageUrl,
      required String movieId,
      required BuildContext context}) async {
    CollectionReference ref = FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .collection("movies");
    var data = {
      'title': title,
      'description': discription,
      'imageUrl': imageUrl,
      'id': movieId.toString().toLowerCase(),
      'created': DateTime.now(),
    };

    ref.add(data);
  }

  void showToast(String message) {
    Widget toast = Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 7,
            offset: Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: Container(
          color: Colors.black,
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Text(
            message,
            style: TextStyle(color: Colors.green),
          ),
        ),
      ),
    );

    FToast fToast = FToast();
    fToast.init(context);
    fToast.showToast(
      child: toast,
      gravity: ToastGravity.BOTTOM,
      toastDuration: Duration(seconds: 2),
    );
  }

  void deleteMovie() async {
    CollectionReference ref = FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .collection('movies');
    ref
        .where('id', isEqualTo: widget.id.toString().toLowerCase())
        .get()
        .then((QuerySnapshot snapshot) {
      snapshot.docs.forEach((DocumentSnapshot doc) {
        doc.reference.delete().then((value) {
          log('Document deleted successfully');
        }).catchError((error) {
          log('Failed to delete document: $error');
        });
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getSimilarMovies(widget.id);
    getMovieReviews();
    getMovieStars(widget.id);
    hasMovieInBookmark();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SizedBox(
              height: MediaQuery.of(context).size.height,
              child: ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  SizedBox(
                    height: 250,
                    child: Stack(
                      children: [
                        Positioned(
                          child: SizedBox(
                            height: 250,
                            width: MediaQuery.of(context).size.width,
                            child: CachedNetworkImage(
                              imageUrl: widget.bannerurl,
                              placeholder: (context, url) =>
                                  Image.asset("assets/images/MovieIcon.png"),
                              errorWidget: (context, url, error) =>
                                  Image.asset("assets/images/MovieIcon.png"),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 10,
                          child: modified_text(
                            text: '⭐ Average Rating - ${widget.vote}',
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.all(10),
                          child: modified_text(text: widget.name, size: 24),
                        ),
                      ),
                      const Divider(
                        color: Colors.black,
                      ),
                      widget.type == "tv"
                          ? const SizedBox(
                              width: 0,
                            )
                          : Padding(
                              padding: const EdgeInsets.only(right: 15.0),
                              child: GestureDetector(
                                child: Icon(
                                  Icons.bookmark,
                                  color:
                                      isBookmark ? Colors.green : Colors.grey,
                                  size: 30,
                                ),
                                onTap: () {
                                  log("widget.id");
                                  log(widget.id.toString());
                                  if (!isBookmark) {
                                    add(
                                        title: widget.name,
                                        discription: widget.description,
                                        imageUrl: widget.posterurl,
                                        movieId: widget.id.toString(),
                                        context: context);
                                  } else {
                                    deleteMovie();
                                  }
                                  setState(() {
                                    isBookmark = !isBookmark;
                                  });
                                },
                              ),
                            ),
                    ],
                  ),
                  // todo : put gerene clickable
                  if (widget.type != 'tv')
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: [
                          for (dynamic genre in widget.gerneIdData)
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SingleGenre(
                                          name: allGenresMap[genre] ?? "",
                                          id: genre)),
                                );
                              },
                              child: Container(
                                padding: EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(25),
                                    border: Border.all(
                                        color: Colors.green, width: 3)),
                                child: modified_text(
                                    text: allGenresMap[genre] ?? 'Loading',
                                    size: 12),
                              ),
                            )
                          // Chip(label: genre['name'],backgroundColor: Colors.black,),
                        ],
                      ),
                    )
                  else
                    const SizedBox(
                      height: 0,
                      width: 0,
                    ),

                  Container(
                    padding: const EdgeInsets.only(left: 10),
                    child: modified_text(
                        text: 'Releasing On - ${widget.launch_on}', size: 14),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(width: 10),
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: CachedNetworkImage(
                            height: 150,
                            width: 100,
                            fit: BoxFit.fill,
                            imageUrl: widget.posterurl,
                            placeholder: (context, url) =>
                                Image.asset("assets/images/MovieIcon.png"),
                            errorWidget: (context, url, error) =>
                                Image.asset("assets/images/MovieIcon.png"),
                          ),
                        ),
                      ),
                      Flexible(
                        child: Container(
                            padding: const EdgeInsets.all(10),
                            child: modified_text(
                              text: widget.description ?? "",
                              size: 18,
                              maxLines: 18,
                            )),
                      ),
                    ],
                  ),
                  widget.type != "tv"
                      ? const SizedBox(height: 20)
                      : SizedBox(height: 0),
                  if (widget.type != "tv")
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.black,
                          border: Border.all(color: Colors.green),
                        ),
                        child: ExpansionTile(
                          trailing: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 500),
                            transitionBuilder:
                                (Widget child, Animation<double> animation) {
                              return ScaleTransition(
                                  child: child, scale: animation);
                            },
                            child: Icon(
                                isCastExpanded
                                    ? Icons.keyboard_arrow_down_rounded
                                    : Icons.expand_less_rounded,
                                color: Colors.green),
                          ),
                          key: castExpansionTileKey,
                          iconColor: Colors.red,
                          onExpansionChanged: (value) {
                            if (value) {
                              _scrollToSelectedContent(
                                  expansionTileKey: castExpansionTileKey);
                            }
                            setState(() {
                              isCastExpanded = !isCastExpanded;
                            });
                          },
                          title: modified_text(
                            text: "Cast",
                            size: 24,
                          ),
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8.0),
                              height: 210,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: stars.length,
                                physics: const BouncingScrollPhysics(),
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                itemBuilder: (context, index) {
                                  return InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                CastedPersonDetailsScreen(
                                                  personId: stars[index].castId,
                                                )),
                                      );
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        children: [
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: CachedNetworkImage(
                                              width: 100,
                                              height: 150,
                                              imageUrl: preImageUrl +
                                                  stars[index].profileImageUrl,
                                              placeholder: (context, url) =>
                                                  Image.asset(
                                                      "assets/images/MovieIcon.png"),
                                              errorWidget: (context, url,
                                                      error) =>
                                                  Image.asset(
                                                      "assets/images/MovieIcon.png"),
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                          Container(
                                            child: modified_text(
                                                size: 15,
                                                text: stars[index].name),
                                          )
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    SizedBox(height: 0),
                  widget.type != "tv"
                      ? const SizedBox(height: 20)
                      : SizedBox(height: 0),
                  if (widget.type != "tv")
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.black,
                          border: Border.all(color: Colors.green),
                        ),
                        child: ExpansionTile(
                          trailing: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 500),
                            transitionBuilder:
                                (Widget child, Animation<double> animation) {
                              return ScaleTransition(
                                  child: child, scale: animation);
                            },
                            child: Icon(
                                isCastExpanded
                                    ? Icons.keyboard_arrow_down_rounded
                                    : Icons.expand_less_rounded,
                                color: Colors.green),
                          ),
                          key: similarExpansionTileKey,
                          iconColor: Colors.red,
                          onExpansionChanged: (value) {
                            if (value) {
                              _scrollToSelectedContent(
                                  expansionTileKey: similarExpansionTileKey);
                            }
                            setState(() {
                              isSimilarExpanded = !isSimilarExpanded;
                            });
                          },
                          title: modified_text(
                            text: "Similar",
                            size: 24,
                          ),
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8.0),
                              height: 225,
                              child: ListView.builder(
                                physics: BouncingScrollPhysics(),
                                scrollDirection: Axis.horizontal,
                                itemCount: similarMovies.length,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                itemBuilder: (context, index) {
                                  final similarMovie = similarMovies[index];
                                  return InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => Description(
                                            //Todo: add ID
                                            type: "movie",
                                            gerneIdData:
                                                similarMovie['genre_ids'],
                                            id: similarMovie['id'],
                                            name: similarMovie['title'],
                                            bannerurl: preImageUrl +
                                                similarMovie['backdrop_path']
                                                    .toString(),
                                            posterurl: preImageUrl +
                                                similarMovie['poster_path']
                                                    .toString(),
                                            description:
                                                similarMovie['overview'],
                                            vote: similarMovie['vote_average']
                                                .toString(),
                                            launch_on:
                                                similarMovie['release_date'],
                                          ),
                                        ),
                                      );
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        children: [
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: CachedNetworkImage(
                                              width: 100,
                                              height: 150,
                                              imageUrl:
                                                  "$preImageUrl${similarMovie["poster_path"]}",
                                              placeholder: (context, url) =>
                                                  Image.asset(
                                                      "assets/images/MovieIcon.png"),
                                              errorWidget: (context, url,
                                                      error) =>
                                                  Image.asset(
                                                      "assets/images/MovieIcon.png"),
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                          SizedBox(
                                            width: 100,
                                            child: modified_text(
                                                size: 15,
                                                text: similarMovie['title'] ??
                                                    "Loading"),
                                          )
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    SizedBox(height: 0),
                  widget.type != "tv"
                      ? const SizedBox(height: 20)
                      : SizedBox(height: 0),
                  if (widget.type != "tv")
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.black,
                          border: Border.all(color: Colors.green),
                        ),
                        child: SizedBox(
                          child: ExpansionTile(
                            trailing: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 500),
                              transitionBuilder:
                                  (Widget child, Animation<double> animation) {
                                return ScaleTransition(
                                    child: child, scale: animation);
                              },
                              child: Icon(
                                  isReviewExpanded
                                      ? Icons.keyboard_arrow_down_rounded
                                      : Icons.expand_less_rounded,
                                  color: Colors.green),
                            ),
                            key: reviewExpansionTileKey,
                            iconColor: Colors.red,
                            onExpansionChanged: (value) {
                              if (value) {
                                _scrollToSelectedContent(
                                    expansionTileKey: reviewExpansionTileKey);
                              }
                              setState(() {
                                isReviewExpanded = !isReviewExpanded;
                              });
                            },
                            title: modified_text(
                              text: "Review",
                              size: 24,
                            ),
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8.0),
                                height: 225,
                                child: Expanded(
                                  child: ListView.builder(
                                    physics: BouncingScrollPhysics(),
                                    itemCount: movieReviews.length,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    itemBuilder: (context, index) {
                                      final movieReview = movieReviews[index];
                                      return InkWell(
                                        onTap: () async {
                                          String url = movieReview['url'];
                                          try {
                                            await launchUrl(Uri.parse(url),
                                                mode: LaunchMode
                                                    .externalApplication);
                                          } catch (e) {
                                            log(e.toString());
                                            showToast(
                                                "There was a problem loading the website");
                                          }
                                        },
                                        child: ListTile(
                                          leading: CircleAvatar(
                                            child: CachedNetworkImage(
                                              height: 200,
                                              imageUrl:
                                                  "$preImageUrl${movieReview['author_details']['avatar_path']}",
                                              placeholder: (context, url) =>
                                                  Image.asset(
                                                      "assets/images/MovieIcon.png"),
                                              errorWidget: (context, url,
                                                      error) =>
                                                  Image.asset(
                                                      "assets/images/MovieIcon.png"),
                                              fit: BoxFit.fill,
                                            ),
                                          ),
                                          title: modified_text(
                                            text: movieReview['author'],
                                            size: 24,
                                          ),
                                          subtitle: modified_text(
                                            text: movieReview['content'],
                                            size: 18,
                                            maxLines: 6,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  else
                    SizedBox(height: 0),
                ],
              ),
            ),
    );
  }
}
