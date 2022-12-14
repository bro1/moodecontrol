import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/standalone.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:url_launcher/url_launcher.dart';


void main() {
  tz.initializeTimeZones();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Moode player control',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Moode player control'),
    );

  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  loadSet() {
    var sp = SharedPreferences.getInstance().then((value)
    {

      var h = value.getString("host");

      setState(() {
        if (h != null) mpdHost = h;
      });

    });

  }

  _MyHomePageState() {
    loadSet();
  }

  late Info timeStamps;
  var displayMsg = true;
  var mpdHost = "localhost";

  @override
  void initState() {
    super.initState();
    timeStamps = getCandidateTimeStamps(context);
  }


  _refreshLocationsFromNetwork() {
    setState(() {
      timeStamps = getCandidateTimeStamps(context);
    });
  }

  FutureOr onBackLoadSettings(dynamic d) {
    loadSet();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(onPressed: () {
            Navigator.push(context,
              MaterialPageRoute(builder: (context) => SettingsPage("Settings")),
            ).then(onBackLoadSettings);
          }, icon: Icon(Icons.settings)),
        ],
    ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
                child: Text('ALT 101'),
                onPressed: () { playRNZNews(context, mpdHost, "ALT 101", "http://stream.revma.ihrhls.com/zc7779");
                }),

            ElevatedButton(
                child: Text('ALT 98.7'),
                onPressed: () { playRNZNews(context, mpdHost, "ALT 98.7", "http://stream.revma.ihrhls.com/zc201");
                }),

            ElevatedButton(
              child: Text('ZM'),
              onPressed: () { playRNZNews(context, mpdHost, "ZM", "http://ais-nzme.streamguys1.com/nz_008/playlist.m3u8") ;
            }),

            ElevatedButton(
                child: Text('Stop playing'),
                onPressed: () { stopPlaying(context, mpdHost) ;
                }),


          ],
        ),
      ),
    );
  }
}

Info getCandidateTimeStamps(BuildContext context) {
  Info r = new Info();

  var nz = getLocation('Pacific/Auckland');
  var now = TZDateTime.now(nz);
  var earlier = now.subtract(Duration(hours: 1));
  
  r.currentHour = fullTimeStampFormat.format(now);
  r.pastHour = fullTimeStampFormat.format(earlier);

  return r;
}

class Info {
  late String currentHour;
  late String pastHour;
}

void playURLLocally(String url, BuildContext context) async {
  launch(url);
}


void playURL(String url, String mpdHost, BuildContext context) async {

  var zc = await http.get(Uri.parse("http://${mpdHost}/command?cmd=clear"));
  if (zc.statusCode != 200) {
    snack(context, "Could not clear Moode queue");
  }

  var url1 = "http://${mpdHost}/command?cmd=add%20${url}";
  var z = await http.get(Uri.parse(url1));
  if (z.statusCode == 200) {
    var pl = await http.get(Uri.parse("http://${mpdHost}/command?cmd=play"));
    if (pl.statusCode != 200) {
      snack(context, "Could not initiate play on Moode");
    }
  } else {
    snack(context, "Could not add news to Moode");
  }

}


void snack(BuildContext context, String msg) {
  final snackbarController = ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(msg)),
  );

}

void playRNZNews(BuildContext context, String host, String name, String radiourl) async {

    playURL(radiourl, host, context);
    snack(context, "Playing: ${name}");
}


void stopPlaying(BuildContext context, String mpdHost) async {

      var zc = await http.get(Uri.parse("http://${mpdHost}/command?cmd=stop"));
      if (zc.statusCode != 200) {
        snack(context, "Could not clear Moode queue");
      }

}




var fullTimeStampFormat = DateFormat("yyyyMMdd-HH");

class SettingsPage extends StatefulWidget {
  final String _appBarTitle;

  SettingsPage(this._appBarTitle, { Key? key }) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState(_appBarTitle);
}


class _SettingsPageState extends State<SettingsPage> {
  final String _appBarTitle;

  TextEditingController nameController = TextEditingController();
  bool displayMsg = false;

  @override
  void initState() {
    super.initState();
  }

  _SettingsPageState(this._appBarTitle) {

    var spf = SharedPreferences.getInstance();
    spf.then(
            (prefs)  {
              var n = prefs.getString("host");

              setState(() {
                if (n != null) nameController.text = n;

              });

            }
    );

  }


  void save() async {
    var spf = await SharedPreferences.getInstance();
    spf.setString("host", nameController.text);
  }

  void _removeSettings() async {

    var sp = await SharedPreferences.getInstance();
    sp.clear();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text(this._appBarTitle)
        ),
        body: Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children:<Widget>[
                Text("SETTINGS"),
                Container(
                  padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                  child: TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Moode Hostname',
                    ),
                    onChanged: (String s) {
                      save();
                    },
                  ),
                ),

                Text("""
                                
                                
                                
                                
                                
ABOUT:

Moode is a smart music player system that you can run on a Raspberry Pi computers."""),

                ElevatedButton(
                    child: Text('https://moodeaudio.org/'),
                    onPressed: () {
                      launch('https://moodeaudio.org/');
                    }),

              ]
          ),
        ),
        // this is for debugging purposes only
        floatingActionButton: false ? FloatingActionButton(
            onPressed: _removeSettings,
            tooltip: 'Increment',
            child: Icon(Icons.add)
        ) : null

    );
  }
}
