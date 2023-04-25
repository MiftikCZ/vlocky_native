import 'dart:convert';

import 'package:flutter/material.dart';
import "package:http/http.dart" as http;

void main() {
  runApp(TheApp());
}

// Every component in Flutter is a widget, even the whole app itself
class TheApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(useMaterial3: true),
      home: const MainApp(),
    );
  }
}

class Recipe {
  final String? name;
  final String? description;
  final String? cas;
  final String? zpusob;
  final List<String>? postup;

  Recipe({this.name, this.description, this.cas, this.zpusob, this.postup});
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  createState() => MainAppState();
}

class MainAppState extends State<MainApp> {
  //MainApp({super.key});
  static const double _receptTextSize = 18;

  Recipe? _selectedRecipe;

  Future<String> getJSONData() async {
    var response = await http.get(
      // Encode the url
      Uri.parse(Uri.encodeFull(
          "https://raw.githubusercontent.com/MiftikCZ/vlocky/main/recepty.js")),

      // Only accept JSON response
      //headers: {"Accept": "application/json"}
    );

    setState(() {
      // Get the JSON data
      List<String> mineResponse = response.body.split("\n");
      mineResponse.removeAt(0);
      var newResponse = json.decode("[" + mineResponse.join(""));
      vlockyRecepty = List<Recipe>.from(newResponse
              .map((el) => Recipe(
                  name: el["title"],
                  description: el["description"],
                  cas: el["time"],
                  zpusob: el["type"],
                  postup: List<String>.from(el["recept"].toList()).toList()))
              .toList())
          .toList();
    });

    return "Successfull";
  }

  List<Recipe> vlockyRecepty = [];

  Widget _receptItem({required int index}) {
    return ListTile(
      title: Text(vlockyRecepty[index].name ?? "bez názvu"),
      onTap: () {
        setState(() {
          _selectedRecipe = vlockyRecepty[index];
        });
      },
      //subtitle: Text(description ?? "bez popisku")
    );
  }

  Widget _drawer() {
    return Drawer(
      child: SizedBox.expand(
        child: ListView(
          shrinkWrap: true,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.black38,
              ),
              child: Center(child: Text('Objevuj recepty')),
            ),
            vlockyRecepty.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Center(child: CircularProgressIndicator()))
                : LimitedBox(
                    maxHeight: 500,

                    //constraints: BoxConstraints.expand(),
                    //height: 700,
                    child: SingleChildScrollView(
                      child: ListView.builder(
                        shrinkWrap: true,
                        //separatorBuilder: (context, index) => const Divider(),
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: vlockyRecepty.length,
                        padding: EdgeInsets.zero,
                        itemBuilder: (context, index) {
                          return _receptItem(index: index);
                        },
                      ),
                    ),
                  )
          ],
        ),
      ),
    );
  }

  Widget _receptInfoWidget({required String top, required Widget bottom}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(top, style: const TextStyle(fontSize: 15, color: Colors.white54)),
        // Expanded(flex: 0, child: bottom)
        bottom
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _drawer(),
      appBar: AppBar(
        title: _selectedRecipe == null
            ? const Text("Recepty na vločky")
            : Text(_selectedRecipe?.name ?? "bez názvu"),
        centerTitle: true,
      ),
      body: Container(
          child: _selectedRecipe == null
              ? const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text("Vyber si jakýkoliv recept z nabídky vlevo!"),
                )
              : ListView(children: [
                  _receptInfoWidget(
                      top: "Popisek",
                      bottom: Text(
                        _selectedRecipe?.description ?? "bez popisku",
                        style: const TextStyle(fontSize: _receptTextSize),
                        textAlign: TextAlign.start,
                      )),
                  const Divider(),
                  _receptInfoWidget(
                      top: "Čas",
                      bottom: Text(
                        _selectedRecipe?.cas ?? "?",
                        style: const TextStyle(fontSize: _receptTextSize),
                        textAlign: TextAlign.start,
                      )),
                  const Divider(),
                  _receptInfoWidget(
                      top: "Způsob",
                      bottom: Text(
                        _selectedRecipe?.zpusob ?? "dobré vločky",
                        style: const TextStyle(fontSize: _receptTextSize),
                        textAlign: TextAlign.start,
                      )),
                  const Divider(),
                  _receptInfoWidget(
                      top: "Postup",
                      bottom: Column(
                          children: _selectedRecipe!.postup != null
                              ? _selectedRecipe!.postup!.map((String name) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "\u2022 ",
                                          style: TextStyle(
                                              fontSize: 18,
                                              color: Colors.white38),
                                        ),
                                        Expanded(
                                            child: Text(
                                          name,
                                          style: TextStyle(
                                              color: name.startsWith("*")
                                                  ? Colors.white70
                                                  : null,
                                              fontSize: _receptTextSize),
                                          textAlign: TextAlign.start,
                                        ))
                                      ],
                                    ),
                                  );
                                }).toList()
                              : [
                                  const Text(
                                    "?",
                                    style: TextStyle(fontSize: _receptTextSize),
                                    textAlign: TextAlign.start,
                                  )
                                ])),
                  //const Divider(),
                ])),
    );
  }

  @override
  void initState() {
    super.initState();
    // Call the getJSONData() method when the app initializes
    getJSONData();
  }
}
