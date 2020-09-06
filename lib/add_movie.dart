import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jeet_final_proj/constants/constants.dart';
import 'package:jeet_final_proj/movies_list.dart';

import 'package:http/http.dart' as http;
import 'package:jeet_final_proj/utils/header_util.dart';
import 'package:progress_dialog/progress_dialog.dart';

class AddMoviePage extends StatefulWidget {
  AddMoviePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _AddMovieState createState() => _AddMovieState();
}

class _AddMovieState extends State<AddMoviePage> {

  ProgressDialog dialog;

  final movieController = TextEditingController();
  final ratingController = TextEditingController();
  //final snackBar = SnackBar(content: Text('Movie has been added.'));

  _addMovie(BuildContext context) async {

    //dialog.show();
    if (movieController.text.isEmpty || ratingController.text.isEmpty) {
      showAlertDialogEmptyMovieRating(context);
    }
    else {
      var rating = int.parse(ratingController.text);
      if(rating>0 && rating<11) {
        final uri = Uri.http(BASE_URL, filmsApi);

        print('uri $uri');

        var movieBody = {
          'name': movieController.text,
          'rating': ratingController.text
        };

        final response = await http
            .post(uri, body: json.encode(movieBody),
            headers: NetworkHelper.getHeader(Globals.sessionToken))
            .timeout(Duration(seconds: requestTimeOut));

        var decodedResponse = json.decode(response.body.toString());
        print('response $decodedResponse');

        if (decodedResponse != null) {
          // Scaffold.of(context).showSnackBar(snackBar);
          //dialog.hide();

          movieController.clear();
          ratingController.clear();
          showAlertDialog(context);
          print('context $context');
        }
      }
      else{
        showAlertDialogInvalidRating(context);
      }
    }
  }

  _fvtMoviesBtnClick() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MoviesListPage()),
    );
  }

  @override
  Widget build(BuildContext context) {

    dialog = ProgressDialog(
      context,
      type: ProgressDialogType.Normal,
      textDirection: TextDirection.rtl,
      isDismissible: true,
    );

    dialog.style(message: 'Please wait...');

    return Material(
      child: Scaffold(
        appBar: AppBar(title: Text('Add movie')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TextField(
                  controller: movieController,
                  decoration: new InputDecoration(
                      border: new OutlineInputBorder(
                        borderRadius: const BorderRadius.all(
                          const Radius.circular(50.0),
                        ),
                      ),
                      filled: true,
                      hintText: "Movie name",
                      fillColor: Colors.white70),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: ratingController,
                  decoration: new InputDecoration(
                      border: new OutlineInputBorder(
                        borderRadius: const BorderRadius.all(
                          const Radius.circular(50.0),
                        ),
                      ),
                      filled: true,
                      hintText: "Movie rating",
                      fillColor: Colors.white70),
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    WhitelistingTextInputFormatter.digitsOnly
                  ],
                ),
                SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: RaisedButton(
                    child: Text(
                      'Add movie',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(35.0),
                        side: BorderSide(color: Colors.blue)),
                    color: Colors.blue,
                    onPressed: () {
                      _addMovie(context);
                    },
                    elevation: 5.0,
                  ),
                ),
              ],
            ),
          ),
        ),
          floatingActionButton: FloatingActionButton.extended(
            elevation: 4.0,
            icon: const Icon(Icons.movie),
            label: const Text('Favourite movies'),
            onPressed: _fvtMoviesBtnClick,
          ), // T
          floatingActionButtonLocation: FloatingActionButtonLocation
              .centerFloat // his trailing comma makes auto-formatting nicer for build methods.
      ),
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
      title: Text("Movie added successfully"),
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

  showAlertDialogEmptyMovieRating(BuildContext context) {
    // set up the button
    Widget okButton = FlatButton(
      child: Text("OK"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Please enter movie name and rating."),
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

  showAlertDialogInvalidRating(BuildContext context) {
    // set up the button
    Widget okButton = FlatButton(
      child: Text("OK"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Please enter rating between 1 and 10."),
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
