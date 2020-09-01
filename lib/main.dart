import 'package:flutter/material.dart';
import 'music.dart';
import 'package:audioplayer2/audioplayer2.dart';
import 'package:audioplayer/audioplayer.dart';
import 'package:volume/volume.dart';
import 'package:flutter/services.dart';
import 'dart:async';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Application de Music',
      theme: ThemeData(

        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'GosMus'),
      debugShowCheckedModeBanner: false,

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
List<Music> musicList= [
  new Music('Hallelujah · Aleluya · Haendel', 'Rossignols Singers', 'assets/Ross1.png', 'C:\Users\Mbongo\AndroidStudioProjects\gosmus_dan\assets\Songs\Hallelujah · Aleluya · Haendel.mp3'),
  new Music('Heaven', 'Heaven-Singers', 'assets/Ross2.png', 'C:\Users\Mbongo\AndroidStudioProjects\gosmus_dan\assets\Songs\Heaven Singers -  Acapella.mp3'),
  new Music('Take-Away', 'Rossignols Singers', 'assets/Ross3.png', 'C:\Users\Mbongo\AndroidStudioProjects\gosmus_dan\assets\Songs\Take-Away.mp3'),
];
  AudioPlayer audioPlayer;
  StreamSubscription positionSubscription;
  StreamSubscription StateSubscription;
  Music actualMusic;
  Duration position = new Duration(seconds: 0);
  Duration duree = new Duration(seconds: 30);
  playerState Statut =  AudioPlayerState.STOPPED;
  int index = 0;
  bool mute = false;
  int maxVol =0, currentVol = 0;
    @override
    void initState(){
    super.initState();
    actualMusic = musicList[index];
    configAudioPlayer();
    initPlatformeState();
    updateVolume();
    }

  @override
  Widget build(BuildContext context) {
      double largeur = MediaQuery.of(context).size.width;
      int newVol = getVolumePourcent().toInt() ;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.title),
        backgroundColor: Colors.black54 ,
        elevation: 20.0,
      ),
      body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
              new Container(
                width : 200,
                color: Colors.red,
                margin: EdgeInsets.only(top: 20.0),
                 child : new Image.asset(actualMusic.imagePath),
            ),
              new Container(
                 margin: EdgeInsets.only(top: 20.0),
                 child: new Text(
                actualMusic.titre,
                textScaleFactor: 2,
            ),
            ),
              new Container(
                margin: EdgeInsets.only(top:5.0),
                child: new Text(
                  actualMusic.auteur,
                ),
              ),
                  new Container(
                    height: largeur / 5 ,
                    margin:  EdgeInsets.only(left: 10.0, right: 10.0),
                    child:  new Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          new IconButton(icon: new Icon(Icons.fast_rewind), onPressed: rewind),
                          new IconButton(icon: (statut != PlayerState.PLAYING) ? new Icon(Icons.play_arrow) : new Icon(Icons.pause),
                          onPressed: (statut != PlayerState.PLAYING)? play: pause,
                          iconSize: 50),
                          new IconButton(icon: (mute) new Icon(Icons.headset_off): new Icon(Icons.headset) , onPressed: muted),
                          new IconButton(icon: new Icon(Icons.fast_forward) , onPressed: forward),
                        ],
                    ),
                  )
                    new Container(
                    margin: EdgeInsets.only(left:  10.0, right:  10.0),
                    child: new Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        textWithStyle(fromDuration(position)  0.8),
                        textWithStyle(fromDuration(duree), 0.8)
                      ],
                      )
                      ),
                      new Container(
                      margin:  EdgeInsets.only(left: 10.0, right:  10.0),
                        child:  new Slider(
                      value: position.inSeconds.toDouble(),
                      min: 0.0,
                      max: duree.inSeconds.toDouble(),
                      inactiveColor: Colors.grey[500],
                      activeColor: Colors.deepPurpleAccent,
                      onChanged: ( double d){
                        setState((){
                          audioPlayer.seek(d);
                      });
                      })
                      ),

                   new Container(
                  height: largeur / 5 ,
                  margin: EdgeInsets.only(left: 5.0, right: 5.0, top:  0.0),
                      child: new Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                                new IconButton(
                                  icon: new Icon(Icons.remove),
                                    iconSize: 18,
                                    onPressed: (){
                                      if (!mute){
                                        Volume.VolDown();
                                        updateVolume();
              }
              }
              ),
                           new Slider(
                             value: (mute) ? 0.0 : currentVol.toDouble(),
                             min: 0.0,
                             max: maxVol.toDouble(),
                             inactiveColor: (mute) ? Colors.red : Colors.grey[500],
                             activeColor: (mute) ? Colors.red : Colors.blue,
                             onChanged: (double d){
                               setState(() {
                                 if (!mute){
                                Volume.setVol(d.toInt());
                                updateVolume();

                                }
                               });
                               )

                                       new Text((mute) ? 'mute' : '$newVol%'),
                                       new IconButton(
                                         icon: new Icon(Icons.add),
                                    iconSize: 18,
                                    onPressed: (){
                                    if (!mute){
                                    Volume.volUp();
                                    updateVolume();
                                    }
          }
                      )
                      ],
                      ),

          ),
            new Container(
                height: largeur / 5,
               margin: EdgeInsets.only(left:  10.0, right: 10.0),
                child: new Row(
                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                  new IconButton(icon: new Icon(Icons.fast_rewind), onPressed: rewind),
                  new IconButton(icon: (statut != PlayerState.PLAYING) ? new Icon(Icons.play_arrow) : new Icon(Icons.pause),
                    onPressed: (statut != PlayerState.PLAYING) ? play : pause,
                    iconSize: 50),
                  new IconButton(icon: (mute) ? new Icon(Icons.headset): new Icon(Icons.headset), onPressed: muted),
                  new IconButton(icon: new Icon(Icons.fast_forward), onPressed: forward),
           ],
               ),
          ),
    )
        ],
      ),
      ),
          );
        }

  double getVolumePourcent(){
      return (currentVol / maxVol) * 100;
}

Future<void> initPlatformeState() async {
  await Volume.controlVolume(AudioManager.STREAM_MUSIC);
}
 updateVolume()async {
   maxVol = await Volume.getMaxVol;
   currentVol = await Volume.getVol;
   setState(() {});
 }

 setVol(int i) async {
   await volume.setvol(i);
 }
 Text textWithStyle(String data, double scale) {
       return new Text(data,
         textScaleFactor: scale,
         textAlign: TextAlign.center,
         style: new TextStyle(
         color: Colors.black,
         fontSize:  15.0
       ),
       );
    }

     IconButton bouton(IconData icon, double taille, ActionMusic action) {
        return new IconButton(icon: new Icon(icon),
            iconSize: taille,
            color: colors.white,
            onPressed: ()
          switch(action){
            case ActionMusic.PLAY:
              play();
              break;
            case ActionMusic.PAUSE:
              pause();
              break;
            case ActionMusic.REWIND:
              rewind();
              break;
            case ActionMusic.FORWARD:
              forward();
              break;
            default:break;

          }
        );
     }


  void configAudioPlayer(){
      audioPlayer = new AudioPlayer();
      positionSubscription = audioPlayer.onAudioPositionChanged.listen((pos) {
        setState(() {
          position = pos;
        });
        if (position >= duree) {
          position = new Duration(seconds: 0);
        }
      });
      StateSubscription = audioPlayer.onPlayerStateChanged.listen((state) {
        if (state == AudioPlayerState.PLAYING) {
          setState(() {
            duree = audioPlayer.duration;
          });
        } else if (state == AudioPlayerState.STOPPED) {
          setState(() {
            statut = playerState.STOPPED;
          });
        }
      }, onError: (message){
       print(message);
       setState(() {
         statut = PlayerState.STOPPED;
         duree = new Duration(seconds: 0);
         position = new Duration(seconds: 0);
       });
      });
  }
  }
  Future play() async{
  await audioPlayer.play(actualMusic.musicURL);
  setState((){
    statut = AudioPlayerState.PLAYING;
  });
  }
  Future pause() async{
    await audioPlayer.pause();
    setState((){
      statut = AudioPlayerState.PAUSED;
    });
  }
  Future muted() async{
  await audioPlayer.mute(!mute);
  setState((){
    mute = !mute;
  });
  }
    void forward(){
       if (index == musicList.length - 1) {
         index = 0;
       } else {
         index++;
       }
       actualMusic = musicList[index];
       audioPlayer.stop();
       configAudioPlayer();
       play();
    }

    void rewind() {
      if (position > Duration(seconds: 3)) {
        audioPlayer.seek(0.0);
      } else {
        if (index == 0) {
          index = musicList.length - 1;
        } else{
        index--;
      }
    }
    actualMusic = musicList[index];
    audioPlayer.stop();
    configAudioPlayer();
    play();
      }

    }
    String fromDuration ( Duration duree){

    return duree.toString().split('.').first;
    }

enum ActionMusic {
  PLAY,
  PAUSE,
  REWIND,
  FORWARD,
}
enum playerState {
  PLAYED ,
  STOPPED,
  PAUSED,
}
