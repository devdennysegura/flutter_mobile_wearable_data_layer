import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

const MethodChannel channel = const MethodChannel('mobile_wear_data_layer');

class MobileWearableDataLayer {
  static Future<bool> sendDefaultPath(String data) async {
    final bool sended = (await channel.invokeMethod(
          'sendDefaultPath',
          {'message': data},
        ))
            .toString()
            .toLowerCase() ==
        'true';
    return sended;
  }

  static Future<bool> sendCustomPath(String path, String data) async {
    final bool sended = (await channel.invokeMethod(
          'sendCustomPath',
          {
            'path': path,
            'message': data,
          },
        ))
            .toString()
            .toLowerCase() ==
        'true';
    return sended;
  }
}

typedef Widget MobileWearReceiverBuilder(
  BuildContext context,
  dynamic receivedData,
);

class MobileWearReceiverWidget extends StatefulWidget {
  final MobileWearReceiverBuilder builder;
  final Function onReceived;

  MobileWearReceiverWidget({Key key, @required this.builder, this.onReceived})
      : assert(builder != null),
        super(key: key);

  @override
  createState() => _MobileWearReceiverWidgetState();
}

class _MobileWearReceiverWidgetState extends State<MobileWearReceiverWidget> {
  var receivedMessage;

  @override
  initState() {
    super.initState();
    channel.setMethodCallHandler((call) {
      if (call.method == 'receivedMessage') {
        setState(() => receivedMessage = call.arguments);
        if (widget.onReceived != null) widget.onReceived(call.arguments);
      }
    });
  }

  @override
  Widget build(BuildContext context) => widget.builder(
        context,
        receivedMessage,
      );
}
