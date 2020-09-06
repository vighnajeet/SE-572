import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jeet_final_proj/add_movie.dart';
import 'package:jeet_final_proj/constants/constants.dart';
import 'package:jeet_final_proj/movies_list.dart';
import 'package:jeet_final_proj/utils/header_util.dart';
import 'package:progress_dialog/progress_dialog.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Jeets term project',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Final Term project'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Controller to handle the input textfield
  final loginController = TextEditingController();

  // To show progress dialog
  ProgressDialog dialog;

  /// Handle the login button click
  _loginBtnClick() async {
    if (loginController.text.isEmpty) {
      showAlertDialog(context);
    } else {
      await dialog.show();
      _login();
    }
  }

  _fvtMoviesBtnClick() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MoviesListPage()),
    );
  }

  _login() async {
      final uri = Uri.http(BASE_URL, loginApi);

      print('uri $uri');
      var loginBody = {'username': loginController.text};

      final response = await http
          .post(uri, body: json.encode(loginBody), headers: NetworkHelper.getHeader(Globals.sessionToken))
          .timeout(Duration(seconds: requestTimeOut));

      var decodedResponse = json.decode(response.body.toString());
      print('response $decodedResponse');

      await dialog.hide();

      if (decodedResponse != null) {
        if (decodedResponse['token'] != null) {
          Globals.session = decodedResponse['token'];
              _moveToAddMoviePage();
        }
      }

  }

  _moveToAddMoviePage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddMoviePage()),
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
      title: Text("username missing"),
      content: Text("Please enter a username to login"),
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

  @override
  Widget build(BuildContext context) {

    dialog = ProgressDialog(
      context,
      type: ProgressDialogType.Normal,
      textDirection: TextDirection.rtl,
      isDismissible: true,
    );

    dialog.style(message: 'Please wait...');

    return Scaffold(
        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text(widget.title),
        ),
        body: Center(
          // Center is a layout widget. It takes a single child and positions it
          // in the middle of the parent.
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              // Column is also a layout widget. It takes a list of children and
              // arranges them vertically. By default, it sizes itself to fit its
              // children horizontally, and tries to be as tall as its parent.
              //
              // Invoke "debug painting" (press "p" in the console, choose the
              // "Toggle Debug Paint" action from the Flutter Inspector in Android
              // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
              // to see the wireframe for each widget.
              //
              // Column has various properties to control how it sizes itself and
              // how it positions its children. Here we use mainAxisAlignment to
              // center the children vertically; the main axis here is the vertical
              // axis because Columns are vertical (the cross axis would be
              // horizontal).
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TextField(
                  controller: loginController,
                  decoration: new InputDecoration(
                      border: new OutlineInputBorder(
                        borderRadius: const BorderRadius.all(
                          const Radius.circular(50.0),
                        ),
                      ),
                      filled: true,
                      hintText: "User name",
                      fillColor: Colors.white70),
                ),
                SizedBox(
                  height: 16,
                ),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: RaisedButton(
                    child: Text(
                      'Login',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(35.0),
                        side: BorderSide(color: Colors.blue)),
                    color: Colors.blue,
                    onPressed: _loginBtnClick,
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
        );
  }
}
