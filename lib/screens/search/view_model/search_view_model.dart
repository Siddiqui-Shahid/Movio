import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../constants.dart';
import '../../description.dart';

class MovieSearchViewModel {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _movies = [];

  TextEditingController get searchController => _searchController;
  List<dynamic> get movies => _movies;

  Future<void> searchMovies(String query) async {
    final url =
        'https://api.themoviedb.org/3/search/movie?api_key=$apiKey&query=$query&include_adult=false';
    final response = await http.get(Uri.parse(url));
    final data = jsonDecode(response.body);
    _movies = data['results'];
  }

  Description getMovieAtIndex(int index) {
    final movie = _movies[index];
    log("movie.toString()");
    log(movie.toString());
    return Description(
      id: movie['id'],
      name: movie['title'],
      bannerurl: "$preImageUrl${movie['backdrop_path']}",
      posterurl: "$preImageUrl${movie['poster_path']}",
      description: movie['overview'],
      vote: movie['vote_average'].toString(),
      launch_on: movie['release_date'],
      gerneIdData: [],
    );
  }

  void onMovieTapped(BuildContext context, int index) {
    final movie = _movies[index];
    print(movie['backdrop_path'].toString());
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => getMovieAtIndex(index)),
    );
  }
}
