import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'dart:convert';

import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Variacao Ativos',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.green,
      ),
      home: const MyHomePage(title: 'Variacao ativo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<SalesDetails> sales = [];

  Future<String> getJsonFromAPI() async {
    String url =
        "https://chart-data-binding-c4a34-default-rtdb.firebaseio.com/data.json";
    http.Response response = await http.get(Uri.parse(url));

    return response.body;
  }

  Future loadSalesData() async {
    final String jsonString = await getJsonFromAPI();
    final dynamic jsonResponse = json.decode(jsonString);
    for (Map<String, dynamic> i in jsonResponse) {
      sales.add(SalesDetails.fromJson(i));
    }
  }

  @override
  void initState() {
    loadSalesData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            appBar: AppBar(
              title: const Text("Variação Ativos"),
            ),
            body: FutureBuilder(
              future: getJsonFromAPI(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return (SfCartesianChart(
                      primaryXAxis: CategoryAxis(interval: 1),
                      enableMultiSelection: true,
                      enableAxisAnimation: true,
                      series: <ChartSeries>[
                        LineSeries<SalesDetails, String>(
                            dataSource: sales,
                            xValueMapper: (SalesDetails details, _) =>
                                details.day,
                            yValueMapper: (SalesDetails details, _) =>
                                details.salesCount)
                      ]));
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            )));
  }
}

class SalesDetails {
  SalesDetails(this.day, this.salesCount);
  final String day;
  final double salesCount;

  factory SalesDetails.fromJson(Map<String, dynamic> parsedJson) {
    return SalesDetails(parsedJson['day'].toString(),
        double.parse(parsedJson['salesCount'].toString()));
  }
}
