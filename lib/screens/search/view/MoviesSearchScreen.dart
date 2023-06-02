import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../utils/text.dart';
import '../../../widgets/geren_list.dart';
import '../model/search_view_model.dart';

class MovieSearchView extends StatefulWidget {
  @override
  _MovieSearchViewState createState() => _MovieSearchViewState();
}

class _MovieSearchViewState extends State<MovieSearchView> {
  final MovieSearchViewModel _viewModel = MovieSearchViewModel();

  @override
  void dispose() {
    _viewModel.searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              height: 50,
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Theme(
                data: ThemeData(
                  textSelectionTheme: const TextSelectionThemeData(
                    cursorColor: Colors.black,
                  ),
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: TextField(
                    controller: _viewModel.searchController,
                    style: TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      hintText: 'Search for a movie',
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Colors.black,
                      ),
                      border: InputBorder.none,
                      hintStyle: TextStyle(color: Colors.black26),
                    ),
                    onSubmitted: (query) async {
                      await _viewModel.searchMovies(query);
                      setState(() {});
                    },
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: _viewModel.movies.length == 0
                ? GenreListScreen()
                : Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    child: OrientationBuilder(builder: (context, orientation) {
                      return GridView.builder(
                        physics: const BouncingScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount:
                              orientation == Orientation.portrait ? 2 : 4,
                          childAspectRatio: 0.65,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        itemCount: _viewModel.movies.length,
                        itemBuilder: (context, index) {
                          final movie = _viewModel.getMovieAtIndex(index);
                          return InkWell(
                            onTap: () {
                              _viewModel.onMovieTapped(context, index);
                            },
                            child: SizedBox(
                              child: Column(
                                children: [
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        image: _viewModel.movies[index]
                                                    ['poster_path'] !=
                                                null
                                            ? DecorationImage(
                                                image:
                                                    CachedNetworkImageProvider(
                                                  _viewModel.movies[index]
                                                      ['poster_path'],
                                                ),
                                                fit: BoxFit.fill)
                                            : const DecorationImage(
                                                image: AssetImage(
                                                    "assets/images/MovieIcon.png"),
                                                fit: BoxFit.fill),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Container(
                                    child: modified_text(
                                        size: 15,
                                        text: _viewModel.movies[index]
                                                ['title'] ??
                                            'Loading'),
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    }),
                  ),
          ),
        ],
      ),
    );
  }
}
