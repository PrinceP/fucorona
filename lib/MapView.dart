import 'dart:async';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

//class MapView extends StatelessWidget {
//  @override
//  Widget build(BuildContext context) {
//    return Container(
//      child: Center(
//        child: Text('Tab 1 Layout'),
//      ),
//    );
//  }
//}

class MapView extends StatefulWidget {
  @override
  _MapViewState createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {

  final Completer<WebViewController> _controller =
  Completer<WebViewController>();

  num _stackToView = 1;

  void _handleLoad(String value) {
    setState(() {
      _stackToView = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

        body: IndexedStack(
          index: _stackToView,
          children: [
            Column(
              children: <Widget>[
                Expanded(
                    child: WebView(
                      initialUrl: "https://qrip-262cc.web.app/",
                      javascriptMode: JavascriptMode.unrestricted,
                      onPageFinished: _handleLoad,
                      onWebViewCreated: (WebViewController webViewController) {
                        _controller.complete(webViewController);
                      },
                    )),
              ],
            ),
            Container(
                child: Center(child: CircularProgressIndicator(),)
            ),
          ],
        ));
  }
}