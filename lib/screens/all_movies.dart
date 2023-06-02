import 'dart:convert';
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_login/constants.dart';
import 'package:google_login/main.dart';
import 'package:google_login/screens/bookmark.dart';
import 'package:google_login/screens/exploreMovies.dart';
import 'package:google_login/screens/searchScreen.dart';
import 'package:google_login/utils/text.dart';
import 'package:google_login/widgets/now_playing.dart';
import 'package:google_login/widgets/toprated.dart';
import 'package:google_login/widgets/trending.dart';
import 'package:google_login/widgets/tv.dart';
import 'package:http/http.dart' as http;
import 'package:tmdb_api/tmdb_api.dart';

import '../Auth_Functions/googleSignIn.dart';
import '../utils/genre.dart';

List<Genre> allGenresList = [];
Map<dynamic, String> allGenresMap = {};

class LandingPage extends StatefulWidget {
  final User? userCredential;
  final String providerId;
  const LandingPage({Key? key, this.userCredential, required this.providerId})
      : super(key: key);
  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  int _selectedIndex = 0;
  bool isLoading = true;
  List<dynamic> movies = [];

  Future<void> getGenres() async {
    String str =
        'https://api.themoviedb.org/3/genre/movie/list?api_key=$apiKey';
    var response;
    if (cache.containsKey(str)) {
      cache[str];
    } else {
      response = await http.get(Uri.parse(str));
      cache[str] = response;
    }
    if (response.statusCode == 200) {
      final jsonResult = jsonDecode(response.body);
      final List<dynamic> genresJson = jsonResult['genres'];

      final genresList = genresJson.map((genreJson) {
        return Genre(
          id: genreJson['id'],
          name: genreJson['name'],
        );
      }).toList();
      final genresMap = Map<int, String>.fromIterable(
        genresJson,
        key: (genre) => genre['id'],
        value: (genre) => genre['name'],
      );
      allGenresMap = genresMap;
      allGenresList = genresList;
    } else {
      throw Exception('Failed to load genres');
    }
  }

  final List<Widget> _widgetOptions = <Widget>[
    const AllMovies(),
    MovieSearchScreen(),
    Bookmark(),
    const ExploreMovies(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    getGenres();

    setState(() {
      isLoading = false;
      allGenresMap = allGenresMap;
      allGenresList = allGenresList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey.shade900,
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.blue.shade100,
        ),
        title: modified_text(text: 'Movio', size: 24),
        backgroundColor: Colors.blueGrey.shade900,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: blueGreyBackgroundColor,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue.shade100,
        unselectedItemColor: Colors.grey[600],
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark),
            label: 'Bookmark',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: 'Explore',
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: Colors.black,
        child: Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  right: 8.0,
                  top: 20,
                  bottom: 8.0,
                ),
                child: CircleAvatar(
                  radius: (MediaQuery.of(context).size.width * 0.2) + 3,
                  backgroundColor: Colors.blue.shade100,
                  child: CircleAvatar(
                    radius: MediaQuery.of(context).size.width * 0.2,
                    backgroundImage: NetworkImage(
                      widget.userCredential?.photoURL ??
                          "https://i.stack.imgur.com/l60Hf.png",
                    ),
                  ),
                ),
              ),
              const Divider(color: Colors.transparent),
              Container(
                alignment: Alignment.centerLeft,
                width: MediaQuery.of(context).size.width * 0.7,
                height: 50.0,
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 2),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Text(
                  "LogIn : ${widget.providerId}",
                  style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.w900,
                      color: Colors.blue.shade100),
                ),
              ),
              const Divider(color: Colors.transparent),
              Container(
                alignment: Alignment.topLeft,
                width: MediaQuery.of(context).size.width * 0.7,
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 2),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Row(
                  children: [
                    Text(
                      "Name : ",
                      style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.w900,
                          color: Colors.blue.shade100,
                          overflow: TextOverflow.ellipsis),
                    ),
                    Expanded(
                      child: Text(
                        "${widget.userCredential?.displayName}",
                        maxLines: 3,
                        style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.w900,
                            color: Colors.blue.shade100,
                            overflow: TextOverflow.ellipsis),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(color: Colors.transparent),
              GestureDetector(
                onTap: () {
                  if (widget.providerId == "google.com") {
                    signOutGoogle();
                  } else if (widget.providerId == "facebook.com") {
                    signOutFacebook();
                  }
                  Navigator.popUntil(context, ModalRoute.withName('NULL'));
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const MyApp()));
                },
                child: Container(
                  alignment: Alignment.topLeft,
                  width: MediaQuery.of(context).size.width * 0.7,
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 2),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.logout, color: Colors.blue.shade100),
                      Text(
                        "\t Logout",
                        style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.w900,
                            color: Colors.blue.shade100,
                            overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> signOutFacebook() async {
    await FacebookAuth.instance.logOut();
    await FirebaseAuth.instance.signOut();
  }
}

class AllMovies extends StatefulWidget {
  const AllMovies({
    super.key,
  });

  @override
  State<AllMovies> createState() => _AllMoviesState();
}

class _AllMoviesState extends State<AllMovies> {
  List<dynamic> trendingmovies = [];
  List topratedmovies = [];
  List tv = [];
  List nowPlaying = [];

  @override
  void initState() {
    super.initState();
    loadmovies();
  }

  loadmovies() async {
    TMDB tmdbWithCustomLogs = TMDB(
      ApiKeys(apiKey, readaccesstoken),
    );

    Map trendingresult = await tmdbWithCustomLogs.v3.trending.getTrending();
    Map topratedresult = await tmdbWithCustomLogs.v3.movies.getTopRated();
    Map nowPlayingResult = await tmdbWithCustomLogs.v3.movies.getNowPlaying();
    Map tvresult = await tmdbWithCustomLogs.v3.tv.getPopular();
    //TODO : Get Random
    Map random = await tmdbWithCustomLogs.v3.discover.getMovies();
    log('............................................');
    // log("${nowPlayingResult.toString()}");
    log('............................................');
    setState(() {
      trendingmovies = trendingresult['results'];
      topratedmovies = topratedresult['results'];
      tv = tvresult['results'];
      nowPlaying = nowPlayingResult['results'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        NowPlaying(nowplaying: nowPlaying),
        TrendingMovies(
          trending: trendingmovies,
        ),
        TopRatedMovies(
          toprated: topratedmovies,
        ),
        TV(tv: tv),
      ],
    );
  }
}
