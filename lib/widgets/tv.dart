import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_login/constants.dart';
import 'package:google_login/screens/description.dart';
import 'package:google_login/utils/text.dart';

class TV extends StatelessWidget {
  final List tv;

  const TV({Key? key, required this.tv}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          modified_text(
            text: 'Popular TV Shows',
            size: 26,
          ),
          const SizedBox(height: 10),
          Container(
              // color: Colors.red,
              height: 200,
              child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: tv.length,
                  physics: BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    final curr_tv = tv[index];
                    return InkWell(
                      onTap: () {
/*
{backdrop_path: /zdFhqQvDhMqVElwRJigwIiU39vQ.jpg, first_air_date: 2023-03-23, genre_ids: [18], id: 220964, name: The Rebel, origin_country: [IQ], original_language: ar, original_name: المتمرد, overview: After the deaths of his parents dealt him a terrible blow, an aspiring boxer decides to channel his frustration toward achieving his dream., popularity: 1368.758, poster_path: /fRGuDO6IIsheu0EIMH5vtTUSGRa.jpg, vote_average: 9.5, vote_count: 2}
*/
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Description(
                                    //Todo: add ID
                                    type: "tv",
                                    gerneIdData: curr_tv['genre_ids'],
                                    id: curr_tv['id'],
                                    name: curr_tv['name'],
                                    bannerurl:
                                        "$preImageUrl${curr_tv['backdrop_path']}",
                                    posterurl:
                                        "$preImageUrl${curr_tv['poster_path']}",
                                    description: curr_tv['overview'],
                                    vote: curr_tv['vote_average'].toString(),
                                    launch_on: curr_tv['first_air_date'],
                                  )),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        // color: Colors.green,
                        width: 250,
                        child: Column(
                          children: [
                            //"$preImageUrl${curr_tv['backdrop_path']}"
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: CachedNetworkImage(
                                height: 140,
                                imageUrl:
                                    "$preImageUrl${curr_tv['backdrop_path']}",
                                placeholder: (context, url) =>
                                    Image.asset("assets/images/MovieIcon.png"),
                                errorWidget: (context, url, error) =>
                                    Image.asset("assets/images/MovieIcon.png"),
                                fit: BoxFit.fill,
                              ),
                            ),
                            const SizedBox(height: 5),
                            SizedBox(
                              width: 250,
                              child: modified_text(
                                  size: 15,
                                  text: curr_tv['name'].toString() == "null"
                                      ? 'Loading'
                                      : curr_tv['name'].toString()),
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
