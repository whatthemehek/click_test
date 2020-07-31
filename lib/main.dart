import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audio_cache.dart';
import 'package:vibration/vibration.dart';

part 'data.dart';

void main() {
  runApp(MyApp());
}



final List<int> boxRhythm = [];
final List<int> vibrateRhythm = [250];

int _howFull = 0;


//final n = 3.0; // Scale factor for scroll blocks

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mehek Box',
      theme: ThemeData(
        primaryColor: Colors.white,
      ),
      initialRoute: '/measurebox',
      routes: {
        '/measurebox': (context) => FirstPage(boxData: measureData),
        '/beatbox': (context) => FirstPage(boxData: beatData),
        '/threefourbox': (context) => FirstPage(boxData: threeFourData),
        '/privacy': (context) => PrivacyPolicy(),
      },
    );
  }
}

class MeasureBoxWidget extends StatefulWidget {
  final Data boxData;
  MeasureBoxWidget({this.boxData});
  @override
  //MeasureBoxWidget({Key key}) : super(key: key);
  _MBWidgetState createState() => _MBWidgetState(boxData: boxData);
  Widget build(BuildContext context) {

  }
}


final AudioCache player = new AudioCache(prefix: 'sounds/');

void _vibrate() async {
  if (await Vibration.hasVibrator() && await Vibration.hasCustomVibrationsSupport()) {
    vibrateRhythm.clear();
    int rest = 250;
    for (int i = 0; i < boxRhythm.length; i++) {
      if (boxRhythm[i] != 0) {
        vibrateRhythm.add(rest + 10);
        vibrateRhythm.add(boxRhythm[i]*250 - 10);
        i += boxRhythm[i] - 1;
        rest = 0;
      } else {
        rest += 250;
      }
    }
    Vibration.vibrate(pattern: vibrateRhythm);
    print(vibrateRhythm);
  }
}




class _MBWidgetState extends State<MeasureBoxWidget> {
  final Data boxData;
  _MBWidgetState({this.boxData});
  @override
  bool isButtonEnabled;
  var successClick = false;
  Function _enableButton() {
    isButtonEnabled = (_howFull == boxData.maxFull);
    if (isButtonEnabled) {
      return () {
        boxRhythm.clear();
        for (var l in _currentList) {
          boxRhythm.addAll(boxData.rhythmArrays[boxData.listOfColors.indexOf(l)]);
        }
        player.clearCache();
        List<String> loadAllArray = [];
        for (int i = 0; i < boxRhythm.length; i++) {
          loadAllArray.add('Index'+ (i + 1).toString() + 'Length' + boxRhythm[i].toString() + '.mp3');
          if (boxRhythm[i] != 0) {
            i = i + boxRhythm[i] - 1;
          }
        }
        player.load('metronome.mp3');
        player.loadAll(loadAllArray);
        player.play('metronome.mp3');
        _vibrate();
        for (String j in loadAllArray) {
          player.play(j);
        }
      };
    } else {
      return null;
    }
  }

  Function _removeRhythm(int indexCurrentList, int indexData) {
    return () {
      setState(() {
        successClick = true;
        _currentList.removeAt(indexCurrentList);
        _howFull -= boxData.listOfDurations[indexData];
        print(_howFull);
        print(_currentList);
      });
    };
  }

  Widget build(BuildContext context) {
    if (successClick) {
      return Container(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Center(
                  //Draws the box, with the right size
                    child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey,
                            width: 1,
                          ),
                        ),
                        child: Container(
                            height: boxData.boxHeight * n,
                            width: boxData.boxWidth * n,
                            decoration: BoxDecoration(
                              color: Color(0xc9c9c9),
                              border: Border.all(
                                color: Colors.white,
                                width: 2 * n,
                              ),
                            ),
                            // Draws the blocks currently in the box
                            child: Center(
                                child: Row(
                                  children: [
                                    for (var i in _currentList)
                                      RawMaterialButton(
                                          constraints: BoxConstraints(),
                                          onPressed: _removeRhythm(_currentList.indexOf(i), boxData.listOfColors.indexOf(i)),
                                          child: boxData.listOfContainers[boxData.listOfColors.indexOf(i)],
                                          padding: EdgeInsets.all(0.0),
                                      )
                                  ],
                                )
                            )
                        )
                    )
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 20.0),
                  child: IconButton(
                    iconSize: 80.0,
                    icon: Icon(Icons.play_circle_filled),
                    color: Colors.blue,
                    disabledColor: Colors.grey,
                    onPressed: _enableButton(),
                    tooltip: "Play Rhythm",
                  ),
                )
              ]
          )
      );
    } else {
      return Container(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Center(
                  //Draws the box, with the right size
                    child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey,
                            width: 1,
                          ),
                        ),
                        child: Container(
                            height: boxData.boxHeight * n,
                            width: boxData.boxWidth * n,
                            decoration: BoxDecoration(
                              color: Color(0xc9c9c9),
                              border: Border.all(
                                color: Colors.white,
                                width: 2 * n,
                              ),
                            ),
                            // Draws the blocks currently in the box
                            child: Center(
                                child: Row(
                                  children: [
                                    for (var i in _currentList)
                                      RawMaterialButton(
                                        constraints: BoxConstraints(),
                                        onPressed: _removeRhythm(_currentList.indexOf(i), boxData.listOfColors.indexOf(i)),
                                        padding: EdgeInsets.all(0),
                                        child: boxData.listOfContainers[boxData.listOfColors.indexOf(i)],
                                      )
                                  ],
                                )
                            )
                        )
                    )
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 20.0),
                  child: IconButton(
                    iconSize: 80.0,
                    icon: Icon(Icons.play_circle_filled),
                    color: Colors.blue,
                    disabledColor: Colors.grey,
                    onPressed: _enableButton(),
                    tooltip: "Play Rhythm",
                  ),
                )
              ]
          )
      );
    }
  }
}

//Compose Page
var _currentList = [];


class _FirstPageWidgetState extends State<FirstPage> {
  final Data boxData;
  _FirstPageWidgetState({this.boxData});
  @override
  var successClick = false;
  Widget build(BuildContext context) {
      Function _addRhythm(int index, Data boxData) {
        if (boxData.listOfDurations[index] + _howFull <= boxData.maxFull) {
          return () {
            setState(() {
              successClick = true;
              _currentList.add(boxData.listOfColors[index]);
              _howFull += boxData.listOfDurations[index];
            });
          };
        }
      }
      if (successClick) {
        return Scaffold(
          appBar: AppBar(
            title: Text(boxData.boxType+' Box'),
          ),
          body: Column (
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container (
                    margin: EdgeInsets.symmetric(vertical: 20.0),
                    height: (boxData.boxHeight - 4)*n,
                    child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          for (var index in boxData.listOfContainers)
                            RawMaterialButton(
                              constraints: BoxConstraints(),
                              padding: EdgeInsets.all(0),
                              onPressed: _addRhythm(boxData.listOfContainers.indexOf(index), boxData),
                              child: index,
                            ),
                        ]
                    )
                ),
                Expanded(
                    child: Container(
                      color: Color(0xffe4e1),
                      child: MeasureBoxWidget(boxData: boxData),
                    )
                ),
              ]// Children
          ),
          drawer: Drawer (
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                DrawerHeader(
                  child: Text('Menu'),
                  decoration: BoxDecoration(
                    color: Colors.white,
                  ),
                ),
                ListTile(
                  title: Text('Measure Box (4/4)'),
                  onTap: () {
                    boxRhythm.clear();
                    Navigator.pushNamed(context, '/measurebox');
                  },
                ),
                ListTile(
                  title: Text('Beat Box (Single Quarter Length)'),
                  onTap: () {
                    boxRhythm.clear();
                    Navigator.pushNamed(context, '/beatbox');
                  },
                ),
                ListTile(
                  title: Text('3/4 Box'),
                  onTap: () {
                    boxRhythm.clear();
                    Navigator.pushNamed(context, '/threefourbox');
                  },
                ),
                ListTile(
                  title: Text('Privacy Policy'),
                  onTap: () {
                    boxRhythm.clear();
                    Navigator.pushNamed(context, '/privacy');
                  },
                ),
              ],
            ),
          ),
        );
      } else {
        return Scaffold(
          appBar: AppBar(
            title: Text(boxData.boxType+' Box'),
          ),
          body: Column (
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container (
                    margin: EdgeInsets.symmetric(vertical: 20.0),
                    height: (boxData.boxHeight - 4)*n,
                    child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          for (var index in boxData.listOfContainers)
                            RawMaterialButton(
                              constraints: BoxConstraints(),
                              padding: EdgeInsets.all(0),
                              onPressed: _addRhythm(boxData.listOfContainers.indexOf(index), boxData),
                              child: index,
                            ),
                        ]
                    )
                ),
                Expanded(
                    child: Container(
                      color: Color(0xffe4e1),
                      child: MeasureBoxWidget(boxData: boxData),
                    )
                ),
              ]// Children
          ),
          drawer: Drawer (
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                DrawerHeader(
                  child: Text('Menu'),
                  decoration: BoxDecoration(
                    color: Colors.white,
                  ),
                ),
                ListTile(
                  title: Text('Measure Box (4/4)'),
                  onTap: () {
                    boxRhythm.clear();
                    Navigator.pushNamed(context, '/measurebox');
                  },
                ),
                ListTile(
                  title: Text('Beat Box (Single Quarter Length)'),
                  onTap: () {
                    boxRhythm.clear();
                    Navigator.pushNamed(context, '/beatbox');
                  },
                ),
                ListTile(
                  title: Text('3/4 Box'),
                  onTap: () {
                    boxRhythm.clear();
                    Navigator.pushNamed(context, '/threefourbox');
                  },
                ),
                ListTile(
                  title: Text('Privacy Policy'),
                  onTap: () {
                    boxRhythm.clear();
                    Navigator.pushNamed(context, '/privacy');
                  },
                ),
              ],
            ),
          ),
        );
      }
  }
}

class FirstPage extends StatefulWidget{
  final Data boxData;
  FirstPage({this.boxData});
  @override
  _FirstPageWidgetState createState() => _FirstPageWidgetState(boxData: boxData);
  Widget build(BuildContext context) {


  }
}
class PrivacyPolicy extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Privacy Policy'),
      ),
      body: Text(
          'At the present (7/21/20), the Mehek Box app and webapp do not intake any user data, in any form.'
      ),
      drawer: Drawer (
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Text('Menu'),
              decoration: BoxDecoration(
                color: Colors.white,
              ),
            ),
            ListTile(
              title: Text('Measure Box (4/4)'),
              onTap: () {
                boxRhythm.clear();
                Navigator.pushNamed(context, '/measurebox');
              },
            ),
            ListTile(
              title: Text('Beat Box (Single Quarter Length)'),
              onTap: () {
                boxRhythm.clear();
                Navigator.pushNamed(context, '/beatbox');
              },
            ),
            ListTile(
              title: Text('3/4 Box'),
              onTap: () {
                boxRhythm.clear();
                Navigator.pushNamed(context, '/threefourbox');
              },
            ),
            ListTile(
              title: Text('Privacy Policy'),
              onTap: () {
                boxRhythm.clear();
                Navigator.pushNamed(context, '/privacy');
              },
            ),
          ],
        ),
      ),
    );
  }
}
