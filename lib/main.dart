/* This program is an example of a stream in dart
   There are two types of streams, single subscription and broadcast stream
   This example is built upon the broadcast method
   useful for retrieving large sums of photos for example.
 */

//packages needed for the app
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

void main(){
  runApp(MaterialApp(
    home: StreamPhotos(),
  ));
}

//this cass will handle json mapping
class Photo{
  var title;
  var url;

  //mapping the json to the vars
  Photo.fromJsonMap(Map map):
      title = map['title'],
      url = map['url'];
}

class StreamPhotos extends StatefulWidget {
  @override
  _StreamPhotosState createState() => _StreamPhotosState();
}

class _StreamPhotosState extends State<StreamPhotos> {

  //need a StreamController of type Photo class
  StreamController <Photo> streamController;
  //and an empty list of type Photo elements
  List <Photo> list = [];

  //initiating the controller and setting state on init
  @override
  void initState() {
    super.initState();
    //loading streamController for operation using load function
    load(streamController);
    //broadcasting our controller
    streamController = StreamController.broadcast();

    //listening for stream, when found add to list using setState
    streamController.stream.listen((onData){
      setState(() {
        list.add(onData);
      });
    });

  }

  //this function provides the core of the stream operation
  //takes StreamController variable as a parameter
  //and is an async method
  load(StreamController sc) async{
    //the origin url
    String url ="https://jsonplaceholder.typicode.com/photos";
    //creating variables for client, request and response
    var client = http.Client();
    var request = http.Request('get', Uri.parse(url));
    var streamedRes = await client.send(request);

    //using the response variable we are
    streamedRes.stream
    .transform(Utf8Decoder())//decoding Utf8 format
    .transform(json.decoder)//decoding json
    .expand((e)=> e)//transforms each element into a sequence of elements
    .map((map) => Photo.fromJsonMap(map))//mapping into their proper variable names
    .pipe(streamController);//handing the events to StreamConsumer
  }

  //gotta make sure to dispose the stream
  @override
  void dispose(){
    super.dispose();
    streamController?.close();//closing streamController
    streamController = null;//and setting it to null
  }


  @override
  Widget build(BuildContext context) {
    return Material(
      child: Theme(
        data: ThemeData(
          primarySwatch: Colors.deepPurple,
        ),
        child: Scaffold(
          appBar: AppBar(
            title: Text("Stream images from json"),
          ),
          body: Center(
            //will build widgets using listview.builder
            child: ListView.builder(
              //itemBuilder takes parameters and calls widget maker makeElement
                itemBuilder: (BuildContext context, int index) => makeElement(index)
            ),

          ),
        ),
      ),
    );
  }

  //This renders the widgets on the listView
  Widget makeElement(int index){
    //checking to see if stream is empty
    if(index >= list.length){
      return null;
    }
    //if not..
    else{
      return Container(
          child: Card(
            child: Column(
              children: <Widget>[
                Image.network(list[index].url, scale: 0.3,),
                Text(list[index].title)
              ],
            ),
          )
      );
    }
  }
}
