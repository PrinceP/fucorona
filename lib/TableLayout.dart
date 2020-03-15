import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'dart:async' show Future;
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/widgets.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import 'package:intl/intl.dart';

var now = new DateTime.now();
final yesterday = DateTime(now.year, now.month, now.day - 1);
final day_before_yesterday = DateTime(now.year, now.month, now.day - 2);

var formatter = new DateFormat('MM-dd-yyyy');
String yest = formatter.format(yesterday) ;
String dayby = formatter.format(day_before_yesterday);

const api =
    'https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_daily_reports/';

const api_death =
    'https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_19-covid-Deaths.csv';

const api_confirmed =
    'https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_19-covid-Confirmed.csv';

const api_recovered =
    'https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_19-covid-Recovered.csv';



String _dir;
class TableLayout extends StatefulWidget  {
  @override
  _TableLayoutState createState() => _TableLayoutState();
}

class _TableLayoutState extends State<TableLayout> with AutomaticKeepAliveClientMixin<TableLayout>{

  List<List<dynamic>> data = [];
  @override
  bool get wantKeepAlive => true;

  loadAsset() async {
    File myData;
    await _downloadAssets(yest);
    await _downloadAssets(dayby);



    myData = await _getLocalFile(yest, _dir);

    var isExist = await myData.exists();
    if (isExist) {
      print('File exists------------------>_getLocalFile()');
    } else {
      print('file does not exist---------->_getLocalFile()');
    }

    String contents = await myData.readAsString();

    print(contents.toString());
    if(contents.toString().substring(0,3) == "404"){
      myData = await _getLocalFile(dayby, _dir);
      contents = await myData.readAsString();
    }


//    print(contents);
    List<List<dynamic>> csvTable = CsvToListConverter(eol: '\n').convert(contents);
//    print(csvTable);
    final length1_ = csvTable.length;
    for(int i=0; i < length1_.toInt(); i++){
      csvTable[i].removeAt(7);
      csvTable[i].removeAt(6);
      csvTable[i].removeAt(2);
    }
//    print(csvTable);
    data = csvTable;
    setState(() {
    });
  }

  String _getLocalFileName(String name, String dir) => '$dir/$name.csv';
  File _getLocalFile(String name, String dir) => File('$dir/$name.csv');

  Future<String> loadCsvInFuture(String name, String dir) async {
    print('$dir/$name.csv');
    return await rootBundle.loadString('$dir/$name.csv');
  }

  Future<void> _downloadAssets(String name) async {
    if (_dir == null) {
      _dir = (await getApplicationDocumentsDirectory()).path;
    }

    if (!await _hasToDownloadAssets(name, _dir)) {
      print("Exists");
      return;
    }
    var zippedFile = await _downloadFile(
        '$api/$name.csv',
        '$name.csv',
        _dir);

    var bytes = zippedFile.readAsBytesSync();
    print('$api/$name.csv');
    var filename = '$_dir/$name.csv';
    var outFile = File(filename);
    outFile = await outFile.create(recursive: true);
    await outFile.writeAsBytes(bytes);
  }

  Future<bool> _hasToDownloadAssets(String name, String dir) async {
    var file = File('$dir/$name.csv');
    print('$api/$name.csv');
    return !(await file.exists());
  }

  Future<File> _downloadFile(String url, String filename, String dir) async {
    var req = await http.Client().get(Uri.parse(url));
    var file = File('$dir/$filename');
    return file.writeAsBytes(req.bodyBytes);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.refresh),
          onPressed: () async {
            await loadAsset();
            //print(data);
          }),
      body: SingleChildScrollView(
        child: Table(
          columnWidths: {
            0: FixedColumnWidth(70.0),
            1: FixedColumnWidth(90.0),
            2: FixedColumnWidth(90.0),
            3: FixedColumnWidth(70.0),
            4: FixedColumnWidth(90.0),

          },
          border: TableBorder.all(width: 1.0, style: BorderStyle.solid),
          children: data.map((item) {
            return TableRow(
                children: item.map((row) {
                  return Container(
//                    color:
//                    row.toString().contains("") ? Colors.red : Colors.green,
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Text(
                        row.toString(),
                        style: TextStyle(fontSize: 15.0, fontStyle: FontStyle.normal, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }).toList());
          }).toList(),
        ),
      ),
    );
  }
}
