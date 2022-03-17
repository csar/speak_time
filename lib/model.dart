import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:random_string/random_string.dart';
import 'package:speak_time/main.dart';
import 'package:speak_time/web.dart';

class Clock extends ChangeNotifier {
 Clock(){
    Zone.current.createPeriodicTimer(Duration(milliseconds: 200), onTick);
  }

  int? since;
  onTick(Timer timer) {
    var millis = DateTime.now().millisecondsSinceEpoch;
    elapsed(millis);
  }
  String time = "-";
  elapsed(int? now) {
    if (since==null) {
      time = "-";
    } else if (now!=null){
      var millis = now-since!;
      int? hours;
      time = "";
      if(millis>Duration.millisecondsPerHour) {
        hours = millis ~/ Duration.millisecondsPerHour;
        millis -= hours*Duration.millisecondsPerHour;
        time = '$hours:';
      }


      int? minutes;

      if (millis>Duration.millisecondsPerMinute) {
        minutes = millis ~/ Duration.millisecondsPerMinute;
        millis -= minutes*Duration.millisecondsPerMinute;
        time += minutes.toString().padLeft(2,'0')+":";
      } else time +="00:";

      int sec = (millis/Duration.millisecondsPerSecond).round();
      time += sec.toString().padLeft(2,'0');


    }
    notifyListeners();

  }
  toggleTime() {
    if (since==null) {
      since = DateTime.now().millisecondsSinceEpoch;
      elapsed(since);
    } else {
      since=null;
      elapsed(null);
    }
    notifyListeners();
  }
}
class Model extends ChangeNotifier {
  String initial = "" ;
  int version;
  int counter = 1;
  List<Speaker> icons;
  TapDownDetails? details;
  Offset? dragstart;
  Model(this.version) : icons = List.empty(growable: true);


  add() {
    var nw = Speaker(details!.localPosition.dx-bubbleSize/2,details!.localPosition.dy-bubbleSize/2);
    icons.add(nw);
    notifyListeners();
  }

  Speaker? selected() {
    try{
      return icons.firstWhere((element) => element.started!=null);
    } catch(_) {
      return null;
    }
  }
  start(Speaker s) {
    if (s.started!=null) { // mute
      print("muting");
      s.start();
      notifyListeners();
      return false;
    } else {
      try {
        icons
            .firstWhere((element) => element.started != null)
            .start();
        s.start();
        notifyListeners();
        print("switched");
        return true;
      } catch (e){
        s.start();
        notifyListeners();
        print("start");

        return false;
      }
    }
  }
  move(DragTargetDetails dtd) {
    Speaker sp = dtd.data;
    final sx = sp.x-dragstart!.dx;
    final sy = sp.y-dragstart!.dy;
    print(sx);
    print(sy);
    print(dtd.offset);
    sp.x = dtd.offset.dx;//-sx;
    sp.y = dtd.offset.dy;//-sy;
    notifyListeners();

  }
  moveTo(Speaker s,DraggableDetails details) {
    s.x = details.offset.dx;
    s.y = details.offset.dy;
    notifyListeners();
  }

  negate() {
    counter *= -1;
    notifyListeners();
  }
  increment() {
    counter +=1;
    notifyListeners();
  }

  save()  async {
    var data = "Speaker,Name,Info,Start,Duration,Round\n";

    for (var s in icons) {
      for ( var p in s.parts) {
        data += '${s.id},${s.name},${s.info},${DateTime.fromMillisecondsSinceEpoch( p.from).toIso8601String()},${p.duration},${s.round}\n';
      }
    }


    var now = DateTime.now().toIso8601String();
    final name=  'Session_${now.substring(0,19)}.csv';
    print("save");
    if (kIsWeb) {
     Writer(name).save(data);
    } else {
      final file = await _localFile(name);
      print(file.absolute);
      file.writeAsString(data);
    }

  }
}


class Speaker {
  var id = randomAlpha(3).toUpperCase();
double x;
double y;
Speaker(this.x,this.y);
int? started;

  Color  color = Colors.blue;
  String name="";
  String info="";
  bool round=true;

start() {
  if (started!=null) {
    parts.add(Participation(started!, DateTime.now().millisecondsSinceEpoch-started!));
    started=null;
  } else {
    started = DateTime.now().millisecondsSinceEpoch;
  }
}
List<Participation> parts = List.empty(growable: true);
}

class Participation {
  int from;
  int duration;
  Participation(this.from, this.duration);


}

Future<String> get _localPath async {
  final directory = await getApplicationDocumentsDirectory();

  return directory.path;
}

Future<File> _localFile(String name) async {
  final path = await _localPath;

  return File('$path/$name');
}