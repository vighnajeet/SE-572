import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:http/http.dart' as http;
import 'package:jeet_final_proj/models/Movie.dart';
import 'package:jeet_final_proj/utils/header_util.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'dart:async';
import 'dart:convert';

import 'constants/constants.dart';

class MoviesListPage extends StatefulWidget {
  MoviesListPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MoviesListState createState() => _MoviesListState();
}

class _MoviesListState extends State<MoviesListPage> {
  bool _loading = true;
  List<Movie> moviesList = [];

  ProgressDialog dialog;

  @override
  Widget build(BuildContext context) {
    dialog = ProgressDialog(
      context,
      type: ProgressDialogType.Normal,
      textDirection: TextDirection.rtl,
      isDismissible: true,
    );

    dialog.style(message: 'Loading...');

    return Material(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Movies'),
        ),
        body: Center(
            child: _loading
                ? Container()
                : Column(
                    children: <Widget>[
                      Expanded(
                        child: ListView.separated(
                          itemCount: moviesList.length,
                          itemBuilder: (BuildContext context, int index) {
                            return InkWell(
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                    flex: 3,
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Text(
                                        moviesList[index].name,
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.normal),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Column(
                                      children: <Widget>[
                                        Text(
                                          moviesList[index].rating.toString(),
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.normal),
                                        ),
                                        Icon(
                                          Icons.star,
                                          color: Colors.amber,
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              onTap: () {
                                if (Globals.sessionToken != null) {
                                  _tapDetailModalBottomSheet(
                                      context, moviesList[index]);
                                } else {
                                  showAlertDialog(context);
                                }
                              },
                            );
                          },
                          separatorBuilder: (BuildContext context, int index) {
                            return Divider();
                          },
                        ),
                      ),
                    ],
                  )),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _loading = true;
    fetchMovies().then((movieList) => _renderResults(movieList));
    // WidgetsBinding.instance.addPostFrameCallback((_) => dialog.hide());
  }

  Future<List<Movie>> fetchMovies() async {
    List<Movie> moviesList = [];

    final uri = Uri.http(BASE_URL, filmsApi);

    print('uri $uri');

    final response = await http
        .get(uri, headers: NetworkHelper.getHeader(Globals.sessionToken))
        .timeout(Duration(seconds: requestTimeOut));

    var decodedResponse = json.decode(response.body.toString());
    print('response $decodedResponse');

    if (decodedResponse != null) {
      decodedResponse.forEach((result) {
        moviesList.add(Movie.fromJson(result));
      });
    }
    print('movies');
    print(moviesList);
    return moviesList;
  }

  Future<dynamic> _updateMovieRating(Movie movie) async {
    final uri = Uri.http(BASE_URL, filmsApi);

    print('uri $uri');

    final response = await http
        .put(uri,
            body: json.encode(movie.toJson()),
            headers: NetworkHelper.getHeader(Globals.sessionToken))
        .timeout(Duration(seconds: requestTimeOut));

    print('update rating : ${json.decode(response.body.toString())}');
  }

  _renderResults(List<Movie> movies) {
    moviesList.addAll(movies);
    setState(() {
      dialog.hide();
      _loading = false;
    });
  }

  _tapDetailModalBottomSheet(context, Movie movie) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Wrap(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                    child: Container(
                        child: Column(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            movie.name,
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                        _getRatingWidget(movie)
                      ],
                    )
                        // decoration: _getBorderDecoration(),
                        ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(16, 16, 16, 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        FlatButton(
                          child: Text('Cancel'),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                        RaisedButton(
                          child: Text('Update rating'),
                          color: Theme.of(context).accentColor,
                          splashColor: Theme.of(context).accentColor,
                          textColor: Colors.white,
                          onPressed: () {
                            //print("print meal");
                            //print(meal);
                            _updateMovieRating(movie);
                            Navigator.pop(context);

                            setState(() {
                              _loading = true;
                            });
                            setState(() {
                              _loading = false;
                            });

                          },
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          );
        });
  }

  _getRatingWidget(Movie movie) {
    return RatingBar(
      initialRating: movie.rating.toDouble(),
      minRating: 1,
      direction: Axis.horizontal,
      allowHalfRating: false,
      itemCount: 10,
      itemSize: 30.0,
      itemPadding: EdgeInsets.symmetric(horizontal: 2.0),
      itemBuilder: (context, _) => Icon(
        Icons.star,
        color: Colors.amber,
      ),
      onRatingUpdate: (rating) {
        movie.rating = rating.toInt();
        print('rating updated : $rating');
      },
    );
  }

  showAlertDialog(BuildContext context) {
    // set up the button
    Widget okButton = FlatButton(
      child: Text("OK"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Session missing"),
      content: Text("Please login to edit the ratings"),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
