import 'dart:convert';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_login/constants.dart';
import 'package:http/http.dart' as http;

import '../utils/text.dart';
import 'description.dart';

class CastedPersonDetailsScreen extends StatefulWidget {
  final int personId;

  const CastedPersonDetailsScreen({required this.personId});

  @override
  _CastedPersonDetailsScreenState createState() =>
      _CastedPersonDetailsScreenState();
}

class _CastedPersonDetailsScreenState extends State<CastedPersonDetailsScreen> {
  late Map<String, dynamic> _personDetails = {};
  bool isLoading = true;
  List<dynamic> starAllMoviesList = [];
  @override
  void initState() {
    super.initState();
    getStarMovies();
    _fetchPersonDetails();
  }

  Future<void> getStarMovies() async {
    final response = await http.get(
      Uri.parse(
          'https://api.themoviedb.org/3/person/${widget.personId}/movie_credits?api_key=$apiKey'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      // log("data");
      // log(data.toString());
      // log("data['cast']");
      // log(data['cast'].toString());
      starAllMoviesList = data['cast'];
      setState(() {});
      // log("data['cast'].runtimeType.toString()");
      // log(data['cast'].runtimeType.toString());
    } else {
      throw Exception('Failed to loadindivisualStarmovie credits');
    }
  }

  Future<void> _fetchPersonDetails() async {
    final response = await http.get(Uri.parse(
        'https://api.themoviedb.org/3/person/${widget.personId}?api_key=$apiKey'));

    if (response.statusCode == 200) {
      final jsonBody = json.decode(response.body);
      setState(() {
        _personDetails = jsonBody;
        isLoading = false;
      });
    } else {
      throw Exception('Failed to load person details');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          :
          // _personDetails == null
          //         ? const Center(
          //             child: CircularProgressIndicator(),
          //           )
          //         :
          ListView(
              physics: BouncingScrollPhysics(),
              children: [
                CachedNetworkImage(
                  imageUrl: preImageUrl + _personDetails['profile_path'],
                  placeholder: (context, url) =>
                      Image.asset("assets/images/MovieIcon.png"),
                  errorWidget: (context, url, error) =>
                      Image.asset("assets/images/MovieIcon.png"),
                  fit: BoxFit.cover,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: modified_text(
                    text: _personDetails['name'],
                    size: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: modified_text(
                    text: _personDetails['biography'],
                    size: 18,
                    isDiscreption: true,
                  ),
                ),
                SizedBox(
                  height: starAllMoviesList.length != 0 ? 250 : 0,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: starAllMoviesList.length,
                    itemBuilder: (context, index) {
                      final indivisualStarMovie = starAllMoviesList[index];
                      return Padding(
                        padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                        child: InkWell(
                          onTap: () {
                            log(preImageUrl +
                                indivisualStarMovie['poster_path']);
                            log(indivisualStarMovie['title']);

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Description(
                                        data: indivisualStarMovie['genre_ids'],
                                        type: "movie",
                                        id: indivisualStarMovie['id'] ?? "",
                                        name:
                                            indivisualStarMovie['title'] ?? "",
                                        bannerurl: (preImageUrl +
                                                indivisualStarMovie[
                                                        'backdrop_path']
                                                    .toString()) ??
                                            "",
                                        posterurl: (preImageUrl +
                                                indivisualStarMovie[
                                                        'poster_path']
                                                    .toString()) ??
                                            "",
                                        description:
                                            indivisualStarMovie['overview'] ??
                                                "",
                                        vote:
                                            indivisualStarMovie['vote_average']
                                                    .toString() ??
                                                "",
                                        launch_on: indivisualStarMovie[
                                                'release_date'] ??
                                            "",
                                      )),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                SizedBox(
                                  width: 100,
                                  height: 150,
                                  child: CachedNetworkImage(
                                    imageUrl:
                                        "$preImageUrl${indivisualStarMovie["poster_path"]}",
                                    imageBuilder: (context, imageProvider) =>
                                        Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        image: DecorationImage(
                                          fit: BoxFit.fill,
                                          image: imageProvider,
                                        ),
                                      ),
                                    ),
                                    placeholder: (context, url) => Image.asset(
                                        "assets/images/MovieIcon.png"),
                                    errorWidget: (context, url, error) =>
                                        Image.asset(
                                            "assets/images/MovieIcon.png"),
                                  ),
                                ),
                                const SizedBox(height: 5),
                                modified_text(
                                    size: 15,
                                    text: indivisualStarMovie["title"])
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
