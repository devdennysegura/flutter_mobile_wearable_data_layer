import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:mobile_wearable_data_layer/mobile_wearable_data_layer.dart';

final MethodChannel channel = MethodChannel("mobile_wear_data_layer");

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<String> _message = Future<String>.value('');
  @override
  void initState() {
    super.initState();
  }

  void assignFuture(Function func) {
    setState(() {
      _message = func();
    });
  }

  Future<String> sendMessage() async {
    final bool response = await MobileWearableDataLayer.sendDefaultPath(
      'Saludos desde mobile',
    );
    return '''path:
    /flutter_wearable_datalayer: 
    response: $response''';
  }

  Future<String> sendCustomPathMessage() async {
    final bool response = await MobileWearableDataLayer.sendCustomPath(
      'test',
      'Saludos desde mobile custom',
    );
    return '''path:
    /test: 
    response: $response''';
  }

  void receivedMessage(dynamic data) {
    print('data received on mobile: $data');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          leading: Image.network(
            'https://apprecs.org/ios/images/app-icons/256/1c/986496028.jpg',
            height: 40,
          ),
          backgroundColor: Colors.white,
          title: const Text('Mobile-Wearable Data-Layer Sample',
              style: TextStyle(
                color: Colors.black,
              )),
        ),
        body: Center(
          child: MobileWearReceiverWidget(
            builder: (context, data) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Mensaje: ${data != null ? data.toString() : ''}',
                  ),
                  MaterialButton(
                    color: Colors.black,
                    textColor: Colors.white,
                    child: Text('Send Default'),
                    onPressed: () => assignFuture(this.sendMessage),
                  ),
                  MaterialButton(
                    color: Colors.indigo,
                    textColor: Colors.white,
                    child: Text('Send Custom'),
                    onPressed: () => assignFuture(this.sendCustomPathMessage),
                  ),
                  FutureBuilder<String>(
                      future: _message,
                      builder: (_, AsyncSnapshot<String> snapshot) {
                        return Text(
                          snapshot.data ?? '',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        );
                      }),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
