import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_echarts/flutter_echarts.dart';
import 'package:intl/intl.dart';
import 'package:number_display/number_display.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import 'dark_theme_script.dart';

final display = createDisplay(decimal: 2);

var _dir;

const api_death =
    'https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_19-covid-Deaths.csv';

const api_confirmed =
    'https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_19-covid-Confirmed.csv';

const api_recovered =
    'https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_19-covid-Recovered.csv';



class GraphView extends StatefulWidget {
  @override
  _GraphViewState createState() => _GraphViewState();
}

class _GraphViewState extends State<GraphView> with AutomaticKeepAliveClientMixin<GraphView> {
  @override
  bool get wantKeepAlive => true;

  var dataDate = [];
  var dataDeathNumber = [];
  var dataConfirmedNumber = [];
  var dataRecoveredNumber = [];

  var lengthOfDate = 0;

  int dataRecoveredNumberOneDate = 0;
  int dataConfirmedNumberOneDate = 0;
  int dataDeathNumberOneDate = 0;


  loadAsset() async {
    dataDeathNumber.clear();
    dataDate.clear();
    dataConfirmedNumber.clear();
    dataRecoveredNumber.clear();


    dataRecoveredNumberOneDate = 0;
    dataConfirmedNumberOneDate = 0;
    dataDeathNumberOneDate = 0;

    await _downloadAssets(api_death, 1);
    await _downloadAssets(api_confirmed, 2);
    await _downloadAssets(api_recovered, 3);

    File myData1 = await _getLocalFile("t1", _dir);
    File myData2 = await _getLocalFile("t2", _dir);
    File myData3 = await _getLocalFile("t3", _dir);
    String contents1 = await myData1.readAsString();
    String contents2 = await myData2.readAsString();
    String contents3 = await myData3.readAsString();

    List<List<dynamic>> csvTable1 = CsvToListConverter(eol: '\n',shouldParseNumbers: false).convert(contents1);
    List<List<dynamic>> csvTable2 = CsvToListConverter(eol: '\n',shouldParseNumbers: false).convert(contents2);
    List<List<dynamic>> csvTable3 = CsvToListConverter(eol: '\n',shouldParseNumbers: false).convert(contents3);


//    print(csvTable1);
//    print("--------");
//    print(csvTable2);
//    print("--------");
//    print(csvTable3);
//    print("--------");


    final lengthOne = csvTable1.length;
    dataDate = csvTable1[0].sublist(4);
    lengthOfDate = dataDate.length;



    for(int j=0; j < dataDate.length; j++){
      dataDeathNumberOneDate = 0;
      for(int i=1; i < lengthOne.toInt(); i++){
        int curr_nu = int.tryParse(csvTable1[i][j+4]);
        if(curr_nu != null){
          dataDeathNumberOneDate += curr_nu;
        }
      }
      dataDeathNumber.add(dataDeathNumberOneDate);
    }
    dataDeathNumberOneDate = dataDeathNumber.elementAt(dataDeathNumber.length - 1);
    if(dataDeathNumberOneDate == 0){
      dataDeathNumberOneDate = dataDeathNumber.elementAt(dataDeathNumber.length - 2);
    }

    final lengthTwo = csvTable2.length;

    for(int j=0; j < dataDate.length; j++){
      dataConfirmedNumberOneDate = 0;
      for(int i=1; i < lengthTwo.toInt(); i++){
        int curr_nu = int.tryParse(csvTable2[i][j+4]);
        if(curr_nu != null){
          dataConfirmedNumberOneDate += curr_nu;
        }
      }
      dataConfirmedNumber.add(dataConfirmedNumberOneDate);
    }
    dataConfirmedNumberOneDate = dataConfirmedNumber.elementAt(dataConfirmedNumber.length - 1);
    if(dataConfirmedNumberOneDate == 0){
      dataConfirmedNumberOneDate = dataConfirmedNumber.elementAt(dataConfirmedNumber.length - 2);
    }


    final lengthThree = csvTable3.length;

    for(int j=0; j < dataDate.length; j++){
      dataRecoveredNumberOneDate = 0;
      for(int i=1; i < lengthThree.toInt(); i++){
        int curr_nu = int.tryParse(csvTable3[i][j+4]);
        if(curr_nu != null){
          dataRecoveredNumberOneDate += curr_nu;
        }
      }
      dataRecoveredNumber.add(dataRecoveredNumberOneDate);
    }
    dataRecoveredNumberOneDate = dataRecoveredNumber.elementAt(dataRecoveredNumber.length - 1);
    if(dataRecoveredNumberOneDate == 0){
      dataRecoveredNumberOneDate = dataRecoveredNumber.elementAt(dataRecoveredNumber.length - 2);
    }

    setState(() {
    });
  }

  String _getLocalFileName(String name, String dir) => '$dir/$name.csv';
  File _getLocalFile(String name, String dir) => File('$dir/$name.csv');

  Future<String> loadCsvInFuture(String name, String dir) async {
    print('$dir/$name.csv');
    return await rootBundle.loadString('$dir/$name.csv');
  }

  Future<void> _downloadAssets(String name, int t_number) async {
    if (_dir == null) {
      _dir = (await getApplicationDocumentsDirectory()).path;
    }

//
//    if ( t_number == 1 && !await _hasToDownloadAssets("t1", _dir)) {
//      print("Exists 1.csv");
//      return;
//    }
//    if (t_number == 2 && !await _hasToDownloadAssets("t2", _dir)) {
//      print("Exists 2.csv");
//      return;
//    }
//    if (t_number == 3 && !await _hasToDownloadAssets("t3", _dir)) {
//      print("Exists 3.csv");
//      return;
//    }

    await _hasToDownloadAssets("t1", _dir);
    await _hasToDownloadAssets("t2", _dir);
    await _hasToDownloadAssets("t3", _dir);

    if(t_number == 1) {
      var zippedFile = await _downloadFile(
          '$name',
          't1.csv',
          _dir);

      var bytes = zippedFile.readAsBytesSync();
      var filename = '$_dir/t1.csv';
      var outFile = File(filename);
      outFile = await outFile.create(recursive: true);
      await outFile.writeAsBytes(bytes);
    }
    else if(t_number == 2){
      var zippedFile = await _downloadFile(
          '$name',
          't2.csv',
          _dir);

      var bytes = zippedFile.readAsBytesSync();
      var filename = '$_dir/t2.csv';
      var outFile = File(filename);
      outFile = await outFile.create(recursive: true);
      await outFile.writeAsBytes(bytes);

    }
    else{
      var zippedFile = await _downloadFile(
          '$name',
          't3.csv',
          _dir);

      var bytes = zippedFile.readAsBytesSync();
      var filename = '$_dir/t3.csv';
      var outFile = File(filename);
      outFile = await outFile.create(recursive: true);
      await outFile.writeAsBytes(bytes);
    }

  }

  Future<bool> _hasToDownloadAssets(String name, String dir) async {
    var file = File('$dir/$name.csv');
    return !(await file.exists());
  }

  Future<File> _downloadFile(String url, String filename, String dir) async {
    var req = await http.Client().get(Uri.parse(url));
    var file = File('$dir/$filename');
    return file.writeAsBytes(req.bodyBytes);
  }


  Widget _buildDecoratedImage1(int imageIndex) => Expanded(
    child: Container(
      decoration: BoxDecoration(
        border: Border.all(width: 10, color: Color.fromRGBO(255,51,51,1)),
        borderRadius: const BorderRadius.all(const Radius.circular(20)),
      ),
      margin: const EdgeInsets.all(2),
      child: Container(
        color: Color.fromRGBO(255,51,51,1.0),
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.fromLTRB(0, 2, 0, 2),
            ),
            Text(
              "DEATH",
              style: TextStyle(
                fontSize: 17,
                foreground: Paint()
                  ..color = Colors.white
                  ..strokeWidth = 2
                  ..style = PaintingStyle.stroke,
                letterSpacing: 1,
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
            ),
            Text(
              imageIndex.toString(),
              style: TextStyle(
                fontSize: 17,
                foreground: Paint()
                  ..color = Colors.white
                  ..strokeWidth = 2
                  ..style = PaintingStyle.stroke,
                letterSpacing: 1,
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(0, 2, 0, 2),
            ),
          ],
        ),

      ),
    ),
  );


  Widget _buildDecoratedImage2(int imageIndex) => Expanded(
    child: Container(
      decoration: BoxDecoration(
        border: Border.all(width: 10, color: Color.fromRGBO(255,199,96,1)),
        borderRadius: const BorderRadius.all(const Radius.circular(20)),
      ),
      margin: const EdgeInsets.all(2),
      child: Container(
        color: Color.fromRGBO(255,199,96,1.0),
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.fromLTRB(0, 2, 0, 2),
            ),
            Text(
              "CONFIRMED",
              style: TextStyle(
                fontSize: 17,
                foreground: Paint()
                  ..color = Colors.white
                  ..strokeWidth = 2
                  ..style = PaintingStyle.stroke,
                letterSpacing: 1,
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
            ),
            Text(
              imageIndex.toString(),
              style: TextStyle(
                fontSize: 17,
                foreground: Paint()
                  ..color = Colors.white
                  ..strokeWidth = 2
                  ..style = PaintingStyle.stroke,
                letterSpacing: 1,
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(0, 2, 0, 2),
            ),
          ],
        ),

      ),
    ),
  );

  Widget _buildDecoratedImage3(int imageIndex) => Expanded(
    child: Container(
      decoration: BoxDecoration(
        border: Border.all(width: 10, color: Color.fromRGBO(34,139,34,1)),
        borderRadius: const BorderRadius.all(const Radius.circular(20)),
      ),
      margin: const EdgeInsets.all(2),
      child: Container(
        color: Color.fromRGBO(34,139,34,1.0),
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.fromLTRB(0, 2, 0, 2),
            ),
            Text(
                "RECOVERED",
                style: TextStyle(
                    fontSize: 17,
                    foreground: Paint()
                      ..color = Colors.white
                      ..strokeWidth = 2
                      ..style = PaintingStyle.stroke,
                    letterSpacing: 1,
                ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
            ),
            Text(
                imageIndex.toString(),
                style: TextStyle(
                  fontSize: 17,
                  foreground: Paint()
                  ..color = Colors.white
                  ..strokeWidth = 2
                  ..style = PaintingStyle.stroke,
                  letterSpacing: 1,
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(0, 2, 0, 2),
            ),
          ],
        ),

      ),
    ),
  );

  Widget _buildImageRow(int imageIndex1, int imageIndex2, int imageIndex3) => Row(
    children: [
      _buildDecoratedImage1(imageIndex1),
      _buildDecoratedImage2(imageIndex2),
      _buildDecoratedImage3(imageIndex3),
    ],
  );

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.refresh),
          onPressed: () async {
            await loadAsset();
            //print(data);
          }),
      backgroundColor: Colors.black87,
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                  color: Colors.black87,
                ),
                child: Column(
                  children: [
                    _buildImageRow(dataDeathNumberOneDate, dataConfirmedNumberOneDate, dataRecoveredNumberOneDate),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(0, 10, 0, 15),
              ),
              Container(
                child: Echarts(
                  extensions: [darkThemeScript],
                  theme: 'dark',
                  captureAllGestures: true,
                  extraScript: '''
                    var base = +new Date(2020, 1, 22);
                    var oneDay = 24 * 3600 * 1000;
                    var date = [];
                    var length_of_date = 60;
                    for (var i = 1; i < length_of_date; i++) {
                        var now = new Date(base += oneDay);
                        date.push([now.getFullYear(), now.getMonth(), now.getDate()].join('/'));
                        
                    }
                  ''',
                  option: '''
                    {
                      tooltip: {
                          trigger: 'axis',
                          position: function (pt) {
                              return [pt[0], '10%'];
                          }
                      },
                      toolbox: {
                          feature: {
                              dataZoom: {
                                  yAxisIndex: 'none'
                              }
                          }
                      },
                      grid:{
                          left: '5%'
                          
                      },
                      xAxis: {
                          type: 'category',
                          boundaryGap: false,
                          data: date,
                          name: "Time"
                      },
                      yAxis: {
                          type: 'value',
                          boundaryGap: [0, '10%'],
                          axisLabel: {
                            inside: true,
                          },
                      },
                      dataZoom: [{
                          type: 'inside',
                          start: 0,
                          end: 50
                      }, {
                          start: 0,
                          end: 10,
                          handleIcon: 'M10.7,11.9v-1.3H9.3v1.3c-4.9,0.3-8.8,4.4-8.8,9.4c0,5,3.9,9.1,8.8,9.4v1.3h1.3v-1.3c4.9-0.3,8.8-4.4,8.8-9.4C19.5,16.3,15.6,12.2,10.7,11.9z M13.3,24.4H6.7V23h6.6V24.4z M13.3,19.6H6.7v-1.4h6.6V19.6z',
                          handleSize: '80%',
                          handleStyle: {
                              color: '#fff',
                              shadowBlur: 3,
                              shadowColor: 'rgba(0, 0, 0, 0.6)',
                              shadowOffsetX: 2,
                              shadowOffsetY: 2
                          }
                      }],
                      series: [
                          {
                              name: 'death',
                              type: 'line',
                              smooth: true,
                              symbol: 'none',
                              sampling: 'average',
                              itemStyle: {
                                  color: 'rgb(255, 70, 131)'
                              },
                              areaStyle: {
                                  color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [{
                                      offset: 0,
                                      color: 'rgb(255, 158, 68)'
                                  }, {
                                      offset: 1,
                                      color: 'rgb(255, 70, 131)'
                                  }])
                              },
                              data: ${dataDeathNumber}
                          },
                          {
                              name: 'confirmed',
                              type: 'line',
                              smooth: true,
                              symbol: 'none',
                              sampling: 'average',
                              itemStyle: {
                                  color: 'rgb(254, 165, 66)'
                              },
                              areaStyle: {
                                  color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [{
                                      offset: 0,
                                      color: 'rgb(192, 113, 0)'
                                  }, {
                                      offset: 1,
                                      color: 'rgb(254, 165, 66)'
                                  }])
                              },
                              data: ${dataConfirmedNumber}
                          },
                          {
                              name: 'recovered',
                              type: 'line',
                              smooth: true,
                              symbol: 'none',
                              sampling: 'average',
                              itemStyle: {
                                  color: 'rgb(201, 229, 66)'
                              },
                              areaStyle: {
                                  color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [{
                                      offset: 0,
                                      color: 'rgb(33, 186, 69)'
                                  }, {
                                      offset: 1,
                                      color: 'rgb(201, 229, 66)'
                                  }])
                              },
                              data: ${dataRecoveredNumber}
                          }
                          
                      ]
                    }
                  ''',
                ),
                width: 550,
                height: 400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}



//import 'dart:async';
//import 'dart:convert';
//
//import 'package:flutter/material.dart';
//
//import 'package:flutter_echarts/flutter_echarts.dart';
//import 'package:number_display/number_display.dart';
//
//import './liquid_script.dart' show liquidScript;
//import './gl_script.dart' show glScript;
//
//import 'dart:io';
//import 'dart:async';
//import 'dart:convert';
//
//
//final display = createDisplay(decimal: 2);
//
//void main() => runApp(MyApp());
//
//class MyApp extends StatelessWidget {
//  @override
//  Widget build(BuildContext context) {
//    return MaterialApp(
//      theme: ThemeData(
//        primarySwatch: Colors.blue,
//      ),
//      home: MyHomePage(),
//    );
//  }
//}
//
//class MyHomePage extends StatefulWidget {
//  MyHomePage({Key key}) : super(key: key);
//
//  @override
//  _MyHomePageState createState() => _MyHomePageState();
//}
//
//class _MyHomePageState extends State<MyHomePage> {
//  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
//
//  List<Map<String, Object>> _data1 = [{ 'name': 'Please wait', 'value': 0 }];
//
//  getData1() async {
//    await Future.delayed(Duration(seconds: 4));
//
//    File data= new File("XXXXX03-05-2020.csv");
//    data.readAsLines().then(processLines)
//        .catchError((e) => handleError(e));
//
//
//    const dataObj = [{
//      'name': 'Jan',
//      'value': 8726.2453,
//    }, {
//      'name': 'Feb',
//      'value': 2445.2453,
//    }, {
//      'name': 'Mar',
//      'value': 6636.2400,
//    }, {
//      'name': 'Apr',
//      'value': 4774.2453,
//    }, {
//      'name': 'May',
//      'value': 1066.2453,
//    }, {
//      'name': 'Jun',
//      'value': 4576.9932,
//    }, {
//      'name': 'Jul',
//      'value': 8926.9823,
//    }];
//
//    this.setState(() { this._data1 = dataObj;});
//  }
//
//
//
//
//
//  processLines(List<String> lines) {
//    // process lines:
//    for (var line in lines) {
//      print(line);
//    }
//  }
//
//  handleError(e) {
//    print("An error...:" + e.toString());
//  }
//
//  @override
//  void initState() {
//    super.initState();
//
//    this.getData1();
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    return Scaffold(
//      key: _scaffoldKey,
//      appBar: AppBar(
//        title: Text('Fucorona'),
//      ),
//      backgroundColor: Colors.white,
//      body: SingleChildScrollView(
//        child: Center(
//          child: Column(
//            children: <Widget>[
////              Padding(
////                child: Text('Reactive updating and tap event', style: TextStyle(fontSize: 20)),
////                padding: EdgeInsets.fromLTRB(0, 40, 0, 20),
////              ),
////              Text('- data will be fetched in a few seconds'),
////              Text('- tap the bar and trigger the snack'),
////              Container(
////                child: Echarts(
////                  option: '''
////                    {
////                      dataset: {
////                        dimensions: ['name', 'value'],
////                        source: ${jsonEncode(_data1)},
////                      },
////                      color: ['#3398DB'],
////                      legend: {
////                        data: ['直接访问', '背景'],
////                        show: false,
////                      },
////                      grid: {
////                        left: '0%',
////                        right: '0%',
////                        bottom: '5%',
////                        top: '7%',
////                        height: '85%',
////                        containLabel: true,
////                        z: 22,
////                      },
////                      xAxis: [{
////                        type: 'category',
////                        gridIndex: 0,
////                        axisTick: {
////                          show: false,
////                        },
////                        axisLine: {
////                          lineStyle: {
////                            color: '#0c3b71',
////                          },
////                        },
////                        axisLabel: {
////                          show: true,
////                          color: 'rgb(170,170,170)',
////                          formatter: function xFormatter(value, index) {
////                            if (index === 6) {
////                              return `\${value}\\n*`;
////                            }
////                            return value;
////                          },
////                        },
////                      }],
////                      yAxis: {
////                        type: 'value',
////                        gridIndex: 0,
////                        splitLine: {
////                          show: false,
////                        },
////                        axisTick: {
////                            show: false,
////                        },
////                        axisLine: {
////                          lineStyle: {
////                            color: '#0c3b71',
////                          },
////                        },
////                        axisLabel: {
////                          color: 'rgb(170,170,170)',
////                        },
////                        splitNumber: 12,
////                        splitArea: {
////                          show: true,
////                          areaStyle: {
////                            color: ['rgba(250,250,250,0.0)', 'rgba(250,250,250,0.05)'],
////                          },
////                        },
////                      },
////                      series: [{
////                        name: '合格率',
////                        type: 'bar',
////                        barWidth: '50%',
////                        xAxisIndex: 0,
////                        yAxisIndex: 0,
////                        itemStyle: {
////                          normal: {
////                            barBorderRadius: 5,
////                            color: {
////                              type: 'linear',
////                              x: 0,
////                              y: 0,
////                              x2: 0,
////                              y2: 1,
////                              colorStops: [
////                                {
////                                  offset: 0, color: '#00feff',
////                                },
////                                {
////                                  offset: 1, color: '#027eff',
////                                },
////                                {
////                                  offset: 1, color: '#0286ff',
////                                },
////                              ],
////                            },
////                          },
////                        },
////                        zlevel: 11,
////                      }],
////                    }
////                  ''',
////                  extraScript: '''
////                    chart.on('click', (params) => {
////                      if(params.componentType === 'series') {
////                        Messager.postMessage(JSON.stringify({
////                          type: 'select',
////                          payload: params.dataIndex,
////                        }));
////                      }
////                    });
////                  ''',
////                  onMessage: (String message) {
////                    Map<String, Object> messageAction = jsonDecode(message);
////                    print(messageAction);
////                    if (messageAction['type'] == 'select') {
////                      final item = _data1[messageAction['payload']];
////                      _scaffoldKey.currentState.showSnackBar(
////                          SnackBar(
////                            content: Text(item['name'].toString() + ': ' + display(item['value'])),
////                            duration: Duration(seconds: 2),
////                          ));
////                    }
////                  },
////                ),
////                width: 300,
////                height: 250,
////              ),
////              Padding(
////                child: Text('Using WebGL for 3D charts', style: TextStyle(fontSize: 20)),
////                padding: EdgeInsets.fromLTRB(0, 40, 0, 20),
////              ),
////              Text('- chart capture all gestures'),
////              Container(
////                child: Echarts(
////                  extensions: [glScript],
////                  captureAllGestures: true,
////                  option: '''
////                    {
////                        tooltip: {},
////                        visualMap: {
////                            max: 20,
////                            inRange: {
////                                color: ['#313695', '#4575b4', '#74add1', '#abd9e9', '#e0f3f8', '#ffffbf', '#fee090', '#fdae61', '#f46d43', '#d73027', '#a50026']
////                            }
////                        },
////                        xAxis3D: {
////                            type: 'category',
////                            data: ['12a', '1a', '2a', '3a', '4a', '5a', '6a',
////                              '7a', '8a', '9a','10a','11a',
////                              '12p', '1p', '2p', '3p', '4p', '5p',
////                              '6p', '7p', '8p', '9p', '10p', '11p'],
////                        },
////                        yAxis3D: {
////                            type: 'category',
////                            data: ['Saturday', 'Friday', 'Thursday',
////                             'Wednesday', 'Tuesday', 'Monday', 'Sunday'],
////                        },
////                        zAxis3D: {
////                            type: 'value'
////                        },
////                        grid3D: {
////                            boxWidth: 200,
////                            boxDepth: 80,
////                            viewControl: {
////                                // projection: 'orthographic'
////                            },
////                            light: {
////                                main: {
////                                    intensity: 1.2,
////                                    shadow: true
////                                },
////                                ambient: {
////                                    intensity: 0.3
////                                }
////                            }
////                        },
////                        series: [{
////                            type: 'bar3D',
////                            data: [[0,0,5],[0,1,1],[0,2,0],[0,3,0],[0,4,0],[0,5,0],[0,6,0],
////                              [0,7,0],[0,8,0],[0,9,0],[0,10,0],[0,11,2],[0,12,4],[0,13,1],
////                              [0,14,1],[0,15,3],[0,16,4],[0,17,6],[0,18,4],[0,19,4],[0,20,3],
////                              [0,21,3],[0,22,2],[0,23,5],[1,0,7],[1,1,0],[1,2,0],[1,3,0],
////                              [1,4,0],[1,5,0],[1,6,0],[1,7,0],[1,8,0],[1,9,0],[1,10,5],
////                              [1,11,2],[1,12,2],[1,13,6],[1,14,9],[1,15,11],[1,16,6],[1,17,7],
////                              [1,18,8],[1,19,12],[1,20,5],[1,21,5],[1,22,7],[1,23,2],[2,0,1],
////                              [2,1,1],[2,2,0],[2,3,0],[2,4,0],[2,5,0],[2,6,0],[2,7,0],[2,8,0],
////                              [2,9,0],[2,10,3],[2,11,2],[2,12,1],[2,13,9],[2,14,8],[2,15,10],
////                              [2,16,6],[2,17,5],[2,18,5],[2,19,5],[2,20,7],[2,21,4],[2,22,2],
////                              [2,23,4],[3,0,7],[3,1,3],[3,2,0],[3,3,0],[3,4,0],[3,5,0],[3,6,0],
////                              [3,7,0],[3,8,1],[3,9,0],[3,10,5],[3,11,4],[3,12,7],[3,13,14],[3,14,13],
////                              [3,15,12],[3,16,9],[3,17,5],[3,18,5],[3,19,10],[3,20,6],[3,21,4],[3,22,4],
////                              [3,23,1],[4,0,1],[4,1,3],[4,2,0],[4,3,0],[4,4,0],[4,5,1],[4,6,0],[4,7,0],
////                              [4,8,0],[4,9,2],[4,10,4],[4,11,4],[4,12,2],[4,13,4],[4,14,4],[4,15,14],
////                              [4,16,12],[4,17,1],[4,18,8],[4,19,5],[4,20,3],[4,21,7],[4,22,3],[4,23,0],
////                              [5,0,2],[5,1,1],[5,2,0],[5,3,3],[5,4,0],[5,5,0],[5,6,0],[5,7,0],[5,8,2],
////                              [5,9,0],[5,10,4],[5,11,1],[5,12,5],[5,13,10],[5,14,5],[5,15,7],[5,16,11],
////                              [5,17,6],[5,18,0],[5,19,5],[5,20,3],[5,21,4],[5,22,2],[5,23,0],[6,0,1],
////                              [6,1,0],[6,2,0],[6,3,0],[6,4,0],[6,5,0],[6,6,0],[6,7,0],[6,8,0],[6,9,0],
////                              [6,10,1],[6,11,0],[6,12,2],[6,13,1],[6,14,3],[6,15,4],[6,16,0],[6,17,0],
////                              [6,18,0],[6,19,0],[6,20,1],[6,21,2],[6,22,2],[6,23,6]]
////                                .map(function (item) {
////                                return {
////                                    value: [item[1], item[0], item[2]],
////                                }
////                            }),
////                            shading: 'lambert',
////
////                            label: {
////                                textStyle: {
////                                    fontSize: 16,
////                                    borderWidth: 1
////                                }
////                            },
////
////                            emphasis: {
////                                label: {
////                                    textStyle: {
////                                        fontSize: 20,
////                                        color: '#900'
////                                    }
////                                },
////                                itemStyle: {
////                                    color: '#900'
////                                }
////                            }
////                        }]
////                    }
////                  ''',
////                ),
////                width: 300,
////                height: 250,
////              ),
////              Padding(
////                child: Text('Data zoom', style: TextStyle(fontSize: 20)),
////                padding: EdgeInsets.fromLTRB(0, 40, 0, 20),
////              ),
////              Text('- chart capture all gestures'),
////              Container(
////                child: Echarts(
////                  captureAllGestures: true,
////                  extraScript: '''
////                    var base = +new Date(1968, 9, 3);
////                    var oneDay = 24 * 3600 * 1000;
////                    var date = [];
////
////                    var data = [Math.random() * 300];
////
////                    for (var i = 1; i < 20000; i++) {
////                        var now = new Date(base += oneDay);
////                        date.push([now.getFullYear(), now.getMonth() + 1, now.getDate()].join('/'));
////                        data.push(Math.round((Math.random() - 0.5) * 20 + data[i - 1]));
////                    }
////                  ''',
////                  option: '''
////                    {
////                      tooltip: {
////                          trigger: 'axis',
////                          position: function (pt) {
////                              return [pt[0], '10%'];
////                          }
////                      },
////                      toolbox: {
////                          feature: {
////                              dataZoom: {
////                                  yAxisIndex: 'none'
////                              },
////                              restore: {},
////                              saveAsImage: {}
////                          }
////                      },
////                      xAxis: {
////                          type: 'category',
////                          boundaryGap: false,
////                          data: date
////                      },
////                      yAxis: {
////                          type: 'value',
////                          boundaryGap: [0, '100%']
////                      },
////                      dataZoom: [{
////                          type: 'inside',
////                          start: 0,
////                          end: 10
////                      }, {
////                          start: 0,
////                          end: 10,
////                          handleIcon: 'M10.7,11.9v-1.3H9.3v1.3c-4.9,0.3-8.8,4.4-8.8,9.4c0,5,3.9,9.1,8.8,9.4v1.3h1.3v-1.3c4.9-0.3,8.8-4.4,8.8-9.4C19.5,16.3,15.6,12.2,10.7,11.9z M13.3,24.4H6.7V23h6.6V24.4z M13.3,19.6H6.7v-1.4h6.6V19.6z',
////                          handleSize: '80%',
////                          handleStyle: {
////                              color: '#fff',
////                              shadowBlur: 3,
////                              shadowColor: 'rgba(0, 0, 0, 0.6)',
////                              shadowOffsetX: 2,
////                              shadowOffsetY: 2
////                          }
////                      }],
////                      series: [
////                          {
////                              name: 'data',
////                              type: 'line',
////                              smooth: true,
////                              symbol: 'none',
////                              sampling: 'average',
////                              itemStyle: {
////                                  color: 'rgb(255, 70, 131)'
////                              },
////                              areaStyle: {
////                                  color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [{
////                                      offset: 0,
////                                      color: 'rgb(255, 158, 68)'
////                                  }, {
////                                      offset: 1,
////                                      color: 'rgb(255, 70, 131)'
////                                  }])
////                              },
////                              data: data
////                          }
////                      ]
////                    }
////                  ''',
////                ),
////                width: 300,
////                height: 250,
////              ),
////              Padding(
////                child: Text('Using extension', style: TextStyle(fontSize: 20)),
////                padding: EdgeInsets.fromLTRB(0, 40, 0, 0),
////              ),
////              Container(
////                child: Echarts(
////                  extensions: [liquidScript],
////                  option: '''
////                    {
////                      grid: {
////                        left: '0%',
////                        right: '0%',
////                        bottom: '0%',
////                        top: '0%',
////                      },
////                      series: [{
////                        type: 'liquidFill',
////                        data: [0.1]
////                      }]
////                    }
////                  ''',
////                ),
////                width: 300,
////                height: 250,
////              ),
//            ],
//          ),
//        ),
//      ),
//    );
//  }
//}
