import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';
import 'package:speak_time/model.dart';

void main() {
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (context) => Model(1)),
    ChangeNotifierProvider(create: (context) => Clock())
  ], child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      // appBar: AppBar(
      //   // Here we take the value from the MyHomePage object that was created by
      //   // the App.build method, and use it to set our appbar title.
      //   title: Text("widget.title"),
      // ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
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
            Expanded(
                child: Consumer2<Model, Clock>(
                    builder: (c, m, clock, x) => GestureDetector(
                          child: DragTarget(
                              builder: (c, a, r) => Container(
                                    decoration:
                                        BoxDecoration(color: Colors.grey),
                                    child: Stack(
                                      children: m.icons
                                          .map((speaker)  {
                                            final icon = Container(
                                                decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(60),
                                                    boxShadow: (speaker.started == null
                                                        ? []
                                                        : [
                                                      const BoxShadow(
                                                        color: Color(0xffff0000),
                                                        blurRadius: 20.0,
                                                        spreadRadius: 0.0,
                                                        // offset: Offset(
                                                        //   0.0,
                                                        //   3.0,
                                                        // ),
                                                      ),
                                                    ])),
                                                child: Container(width: 40,height: 40, child: Center(child:Text(speaker.id,style: TextStyle(fontWeight: FontWeight.bold), )),decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: speaker.color),)
                                            );
                                            return Positioned(
                                              left: speaker.x,
                                              top: speaker.y,
                                              child: InkWell(
                                                                child:
                                                                    Draggable(
                                                                  child: icon,
                                                                  feedback: icon,
                                                                  data: speaker,

                                                                  // onDragEnd: (d) => m.moveTo(e, d)
                                                                ),
                                                                onDoubleTap: () => showDialogWithFields(context,speaker),
                                                                onTap: () {
                                                                  print("TAP");
                                                                  print(speaker
                                                                      .started);
                                                                  clock
                                                                      .toggleTime();
                                                                  if(m.start(speaker)) clock.toggleTime();
                                                                },
                                                              ));})
                                          .toList(),
                                    ),
                                  ),
                              onWillAccept: (_) => true,
                              onAcceptWithDetails: m.move),
                          onTap: m.increment,
                          onDoubleTap: m.add,
                          onLongPressDown: (d) =>
                              m.dragstart = d.globalPosition,
                          onDoubleTapDown: (d) => m.details = d,
                          onTapDown: (d) => m.details = d,
                        ))),
            // const Text(
            //   'You have pushed the button this many times:',
            // ),
            // Consumer<Model>(
            //     builder: (c, m, x) => Text(
            //           '${m.counter}',
            //           style: Theme.of(context).textTheme.headline4,
            //         )),
            Consumer<Clock>(
                builder: (c, m, x) => Text(
                      m.time,
                      style: Theme.of(context).textTheme.headline4,
                    )),
          ],
        ),
      ),
      floatingActionButton: Consumer<Model>(
          builder: (c, m, _) => FloatingActionButton(
                onPressed: m.save,
                tooltip: 'Increment',
                child: const Icon(Icons.save_alt,),
              )), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}


void showDialogWithFields( BuildContext context, Speaker s) async {
  return showDialog(
    context: context,
    builder: (_) {
      var emailController = TextEditingController();
      emailController.text=s.id;
      var color = s.color;
      var messageController = TextEditingController();
      return AlertDialog(
        title: Text('Speaker'),
        content: SizedBox(
          //height: double.maxFinite,
          width: 200,
          child : ListView(
            shrinkWrap: true,
            children: [
              TextFormField(

                controller: emailController,
                maxLength: 2,expands: false,
                decoration: InputDecoration(hintText: 'Initial'),
              ),
              TextFormField(
                controller: messageController,
                decoration: InputDecoration(hintText: 'Name'),
              ),
              SizedBox(height:20,),
              BlockPicker(pickerColor: color, onColorChanged: (c) => color=c, availableColors: const [
                Colors.red,
                Colors.pink,
                Colors.purple,
                Colors.deepPurple,
                Colors.indigo,
                Colors.blue,
                // Colors.lightBlue,
                Colors.cyan,
                Colors.teal,
                Colors.green,
                // Colors.lightGreen,
                Colors.lime,
                Colors.yellow,
                Colors.amber,
                Colors.orange,
                Colors.deepOrange,
                Colors.brown,
                // Colors.grey,
                Colors.blueGrey,
                // Colors.black,
              ],
              )
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Send them to your email maybe?
              s.id= emailController.text;
              s.color=color;
              var message = messageController.text;
              Navigator.pop(context);
            },
            child: Text('OK'),
          ),
        ],
      );
    },
  );
}

