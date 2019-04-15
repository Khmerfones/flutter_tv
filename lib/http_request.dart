import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'key_code.dart';

class HttpDemo extends StatefulWidget {
  HttpDemo({Key key}) : super(key: key);

  @override
  _HttpDemoState createState() => new _HttpDemoState();
}

class _HttpDemoState extends State<HttpDemo> {
  var _ipAddress = 'Unknown';
  FocusNode focusNode;
  bool _active = false;

  _getIPAddress() async {
    print("_active = $_active");
    var url = 'https://httpbin.org/ip';
    var httpClient = new HttpClient();

    String result;
    try {
      var request = await httpClient.getUrl(Uri.parse(url));
      var response = await request.close();
      if (response.statusCode == HttpStatus.ok) {
        var jsonStr = await response.transform(utf8.decoder).join();
        var data = json.decode(jsonStr);
        result = data['origin'];
      } else {
        result =
            'Error getting IP address:\nHttp status ${response.statusCode}';
      }
    } catch (exception) {
      result = 'Failed getting IP address';
    }

    // If the widget was removed from the tree while the message was in flight,
    // we want to discard the reply rather than calling setState to update our
    // non-existent appearance.
    if (!mounted) return;

    setState(() {
      _ipAddress = result;
      _active = !_active;
    });
  }

  @override
  void initState() {
    print('initState called.');
    super.initState();
    focusNode = new FocusNode();
  }

  @override
  void dispose() {
    print('dispose called.');
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var spacer = new SizedBox(height: 32.0);
    FocusScope.of(context).requestFocus(focusNode);
    return new Scaffold(
      appBar: new AppBar(title: new Text('Http Demo')),
      body: new Center(
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Text('Your current IP address is:'),
            new Text('$_ipAddress.'),
            spacer,
            new RawKeyboardListener(
              focusNode: focusNode,
              onKey: (RawKeyEvent event) {
                if (event is RawKeyDownEvent &&
                    event.data is RawKeyEventDataAndroid) {
                  RawKeyDownEvent rawKeyDownEvent = event;
                  RawKeyEventDataAndroid rawKeyEventDataAndroid =
                      rawKeyDownEvent.data;
                  print("keyCode = ${rawKeyEventDataAndroid.keyCode}");
                  switch (rawKeyEventDataAndroid.keyCode) {
                    case KEY_CENTER:
                      _getIPAddress();
                      break;
                    default:
                      break;
                  }
                }
              },
              child: new RaisedButton(
                onPressed: _getIPAddress,
                color: _active ? Colors.lightGreen[700] : Colors.grey[600],
                child: new Text('Get IP address'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
