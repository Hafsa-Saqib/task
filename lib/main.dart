// @dart=2.9

import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

void main() {
  runApp(MaterialApp(home: MyApp()));
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Color contColor = Colors.black;
  String pubMes = '';

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        height: double.infinity,
        width: double.infinity,

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () async{
                await connect().then((MqttServerClient client) async{
                  await client.connect('Hafsa','123');
                  if(client.connectionStatus.state == MqttConnectionState.connected) {
                    var text2 = publish('ON', client, "control/thingA");
                    client.subscribe("control/thingA", MqttQos.atLeastOnce);
                    client.updates.listen((List<MqttReceivedMessage<MqttMessage>> c) {
                      final MqttPublishMessage message = c[0].payload;
                      return MqttPublishPayload.bytesToStringAsString(message.payload.message);
                    });
                    print(client.connectionStatus.state);
                    print('Text of btnA $text2');
                    if(text2 != 0){
                      setState(() {
                        contColor = Colors.green;
                      });
                    }
                    print(text2);

                  }
                  else{
                    print(client.connectionStatus.state);
                  }

                });

              },
              child: Container(
                height: 40,
                width: 70,
                color: Colors.green,
                alignment: Alignment.center,
                child: Text(
                  'ON',
                  style: TextStyle(
                      fontSize: 20,
                      color: Colors.black
                  ),
                ),
              ),
            ),
            TextButton(
              onPressed: () async{
                await connect().then((MqttServerClient client) async{
                  // client.disconnect();
                  await client.connect('Hafsa','123');
                  print(client.connectionStatus.state);
                  var text2 =publish('OFF', client, "control/thingA");
                  client.subscribe("control/thingA", MqttQos.atLeastOnce);
                  if(text2!= 0){
                    setState(() {
                      contColor = Colors.red;
                    });
                  }
                  print(text2);
                  client.disconnect();
                  print(client.connectionStatus.state);
                  print('Text of btnA $text2');
                });
              },
              child: Container(
                height: 40,
                width: 70,
                color: Colors.red,
                alignment: Alignment.center,
                child: Text(
                  'OFF',
                  style: TextStyle(
                      fontSize: 20,
                      color: Colors.black
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 40,right: 40),
              child: Container(
                height: 40,
                color: contColor,
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<MqttServerClient> connect() async {
    MqttServerClient client =
    MqttServerClient.withPort('broker.hivemq.com', 'flutter_client', 1883);
    client.logging(on: true);
    final connMessage = MqttConnectMessage()
        .withWillTopic('willtopic')
        .withWillMessage('Will message')
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);
    client.connectionMessage = connMessage;
    try {
      await client.connect();
    } catch (e) {
      print('Exception: $e');
      client.disconnect();
    }

    return client;
  }
  publish(String message,MqttServerClient client,String topic) {
    final MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
    builder.addString(message);
    return client.publishMessage(topic, MqttQos.atLeastOnce, builder.payload);
  }

}