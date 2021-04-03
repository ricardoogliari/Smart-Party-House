import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pubnub/pubnub.dart';

typedef void OnError(Exception exception);

void main() {
  runApp(new MaterialApp(home: new ExampleApp()));
}

class ExampleApp extends StatelessWidget {
  AudioPlayer advancedPlayer;
  AudioCache audioCache;

  final myKeyset = Keyset(
      subscribeKey: 'sub-c-70f7e4f2-14be-11eb-9b79-2636081330fc',
      publishKey: 'pub-c-44b19894-6841-4993-a042-c1a12ae18a62',
      uuid: UUID('demo'));

  Channel myChannel;
  PubNub pubnub;

  void initPlayer(){
    advancedPlayer = new AudioPlayer();
    audioCache = new AudioCache(fixedPlayer: advancedPlayer);

    advancedPlayer.onPlayerCompletion.every((element) {
      myChannel.publish({ 'action': 0 });
      return true;
    });
  }

  String localFilePath;

  Widget _body() => Center(
      child: Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            _btn('Play', () {
              audioCache.play('one_horse_town.mp3');
              myChannel.publish({ 'action': 1 });
            }),
            _btn('Stop', () {
              advancedPlayer.stop();
              myChannel.publish({ 'action': 0 });
            }),
          ]
        ),
      ),
    );

  Widget _btn(String txt, VoidCallback onPressed) {
    return ButtonTheme(
        minWidth: 48.0,
        child: RaisedButton(child: Text(txt), onPressed: onPressed));
  }

  @override
  Widget build(BuildContext context) {
    initPlayer();
    pubnub = PubNub(defaultKeyset: myKeyset);
    myChannel = pubnub.channel('node-red');

    return DefaultTabController(
      length: 1,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Smart Party House'),
        ),
        body: _body()
      ),
    );
  }
}