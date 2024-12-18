import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:auto_size_text/auto_size_text.dart';

final airtableApiToken = 'patTjJNwpD104BTKG.9352a6a8b38ce585bc3b55de8667ef8e81800fc5cde77e95a95398447a4ca604';
final airtableApiBaseUrl = 'https://api.airtable.com';
final airtableBaseId = 'appHba5WGxI7G7VDA';
final airtableTableName = 'Proyectos';

void main() => runApp(MaterialApp(home: GraficasProyectosPage(proyecto: 'Nombre del Proyecto')));


class GraficasProyectosPage extends StatefulWidget {
  final String proyecto;
  GraficasProyectosPage({required this.proyecto});

  @override
  _GraficasProyectosPageState createState() => _GraficasProyectosPageState();
}

class _GraficasProyectosPageState extends State<GraficasProyectosPage> {
  late int AvanceProyecto1, RestanteProyecto1;
  late DateTime fechaInicio, fechaEntrega;
  late String nombre;
  bool showAllGraphs = false;

  @override
  void initState() {
    super.initState();
    print('Valor de proyecto: ${widget.proyecto}');
    fetchAirtableData().then((data) {
      if (data.isNotEmpty) {
        setState(() {
          AvanceProyecto1 = data[0]['AvanceProyecto1'];
          RestanteProyecto1 = data[0]['RestanteProyecto1'];
          fechaInicio = data[0]['fechaInicio'];
          fechaEntrega = data[0]['fechaEntrega'];
          nombre = data[0]['nombre'];
        });
      } else {
        print('No se encontraron proyectos que coincidan.');
      }
    }).catchError((error) {
      print('Error al obtener los datos: $error');
    });
  }

Future<List<Map<String, dynamic>>> fetchAirtableData() async {
 final response = await http.get(
   Uri.parse(
     '$airtableApiBaseUrl/v0/$airtableBaseId/$airtableTableName',
   ),
   headers: {
     'Authorization': 'Bearer $airtableApiToken',
   },
 );

 if (response.statusCode == 200) {
   Map<String, dynamic> data = jsonDecode(response.body);
   List<dynamic> records = data['records'];

   List<Map<String, dynamic>> result = [];
  for (var record in records) {
  Map<String, dynamic> fields = record['fields'];

  // GRAFICA DE SOLDADURA 
  if (fields['Nombre del Proyecto'] == widget.proyecto &&fields['En Linea'] == 'Verdadero'&&fields['Linea 4'] == 'Falso') {
    int AvanceProyecto1 = fields['Soldadura'];
    int RestanteProyecto1 = fields['Restante Soldadura'];
    DateTime fechaInicio = fields['Fecha de inicio'] == null || fields['Fecha de inicio'].isEmpty
      ? DateTime.now() // O cualquier otro valor predeterminado que desees
      : DateTime.parse(fields['Fecha de inicio']);
    DateTime fechaEntrega = fields['Fecha de fin'] == null || fields['Fecha de fin'].isEmpty
      ? DateTime.now() // O cualquier otro valor predeterminado que desees
      : DateTime.parse(fields['Fecha de fin']);
    String nombre =  'Soldadura ${fields['Nombre del Proyecto']}';


    result.add({
      'id': record['id'], // Agrega el ID del registro
      'AvanceProyecto1': AvanceProyecto1,
      'RestanteProyecto1': RestanteProyecto1,
      'fechaInicio': fechaInicio,
      'fechaEntrega': fechaEntrega,
      'nombre': nombre,
    });
  }
  //GRAFICA DE PINTURA
    if (fields['Nombre del Proyecto'] == widget.proyecto &&fields['En Linea'] == 'Verdadero'&&fields['Linea 4'] == 'Falso') {
    int AvanceProyecto1 = fields['Pintura'];
    int RestanteProyecto1 = fields['Restante Pintura'];
    DateTime fechaInicio = fields['Fecha de inicio'] == null || fields['Fecha de inicio'].isEmpty
      ? DateTime.now() // O cualquier otro valor predeterminado que desees
      : DateTime.parse(fields['Fecha de inicio']);
    DateTime fechaEntrega = fields['Fecha de fin'] == null || fields['Fecha de fin'].isEmpty
      ? DateTime.now() // O cualquier otro valor predeterminado que desees
      : DateTime.parse(fields['Fecha de fin']);
    String nombre =  'Pintura ${fields['Nombre del Proyecto']}';


    result.add({
      'id': record['id'], // Agrega el ID del registro
      'AvanceProyecto1': AvanceProyecto1,
      'RestanteProyecto1': RestanteProyecto1,
      'fechaInicio': fechaInicio,
      'fechaEntrega': fechaEntrega,
      'nombre': nombre,
    });
  }
//LIBERACION MONTAJE

 if (fields['Nombre del Proyecto'] == widget.proyecto &&fields['En Linea'] == 'Verdadero') {
    int AvanceProyecto1 = fields['Montaje'];
    int RestanteProyecto1 = fields['Restante Montaje'];
    DateTime fechaInicio = fields['Fecha de inicio'] == null || fields['Fecha de inicio'].isEmpty
      ? DateTime.now() // O cualquier otro valor predeterminado que desees
      : DateTime.parse(fields['Fecha de inicio']);
    DateTime fechaEntrega = fields['Fecha de fin'] == null || fields['Fecha de fin'].isEmpty
      ? DateTime.now() // O cualquier otro valor predeterminado que desees
      : DateTime.parse(fields['Fecha de fin']);
    String nombre =  'Montaje ${fields['Nombre del Proyecto']}';


    result.add({
      'id': record['id'], // Agrega el ID del registro
      'AvanceProyecto1': AvanceProyecto1,
      'RestanteProyecto1': RestanteProyecto1,
      'fechaInicio': fechaInicio,
      'fechaEntrega': fechaEntrega,
      'nombre': nombre,
    });
  }

if (fields['Nombre del Proyecto'] == widget.proyecto &&fields['En Linea'] == 'Verdadero') {
    int AvanceProyecto1 = fields['Entregados'];
    int RestanteProyecto1 = fields['Restante Entregados'];
    DateTime fechaInicio = fields['Fecha de inicio'] == null || fields['Fecha de inicio'].isEmpty
      ? DateTime.now() // O cualquier otro valor predeterminado que desees
      : DateTime.parse(fields['Fecha de inicio']);
    DateTime fechaEntrega = fields['Fecha de fin'] == null || fields['Fecha de fin'].isEmpty
      ? DateTime.now() // O cualquier otro valor predeterminado que desees
      : DateTime.parse(fields['Fecha de fin']);
    String nombre =  'Entregados ${fields['Nombre del Proyecto']}';


    result.add({
      'id': record['id'], // Agrega el ID del registro
      'AvanceProyecto1': AvanceProyecto1,
      'RestanteProyecto1': RestanteProyecto1,
      'fechaInicio': fechaInicio,
      'fechaEntrega': fechaEntrega,
      'nombre': nombre,
    });
  }
}



   return result;
 } else {
   throw Exception('Failed to load data from Airtable');
 }
}

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: fetchAirtableData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: Color(0xFFe5ecf4),
            body: Center(
              child: SpinKitFadingCircle(
                color: Colors.black,
                size: 60.0,
              ),
            ),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            backgroundColor: Color(0xFFe5ecf4),
            body: Center(
              child: Text('Error: ${snapshot.error}'),
            ),
          );
        } else {
          if (snapshot.data!.isEmpty) {
            return Scaffold(
              backgroundColor: Color(0xFFe5ecf4),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search,
                      size: 100,
                      color: Colors.grey,
                    ),
                    Text(
                      'No se encontraron proyectos',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 20,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else {
            return _buildGraph(snapshot.data!);
          }
        }
      },
    );
  }

Widget _buildGraph(List<Map<String, dynamic>> data) {
  List<Widget> charts = [];

  for (var record in data) {
    int avanceProyecto1 = record['AvanceProyecto1'];
    int restanteProyecto1 = record['RestanteProyecto1'];
    DateTime fechaInicio = record['fechaInicio'];  // No se necesita DateTime.parse aquí
    DateTime fechaEntrega = record['fechaEntrega'];  // No se necesita DateTime.parse aquí
    String nombre = record['nombre'];


      charts.add(_buildPieChart(
        context,
        nombre,
        avanceProyecto1,
        restanteProyecto1,
        record,
        onPressed: () {},
        customOnPressed: () {},
        cardHeight: 500,
        cardWidth: 300,
        fechaInicio: fechaInicio,
        fechaEntrega: fechaEntrega,
        targetPage: 'Proyecto1Page',
      ));
    
  }

  return Scaffold(
    backgroundColor: Color(0xFFe5ecf4),
    appBar: AppBar(
      title: Text(
        'Avance del Proyecto',
        style: TextStyle(
          color: Colors.white,
        ),
      ),
      backgroundColor: Color(0xFF313745),
      actions: [
      ],
    ),
    body: LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        bool isPortrait = constraints.maxHeight > constraints.maxWidth;
        int crossAxisCount = isPortrait ? 1 : 3;
        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 10.0,
            crossAxisSpacing: 10.0,
          ),
          itemCount: charts.length,
          itemBuilder: (context, index) {
            return charts[index];
          },
        );
      },
    ),
  );
}

  Widget _buildPieChart(
    BuildContext context,
    String title,
    int value1,
    int value2,
    Map<String, dynamic> data,
    {required VoidCallback onPressed,
    VoidCallback? customOnPressed,
    required double cardHeight,
    required double cardWidth,
    required DateTime fechaInicio,
    required DateTime fechaEntrega,
    required String targetPage}) {
    DateTime fechaActual = DateTime.now();

    Color circleColor;
    if (fechaActual.isBefore(fechaInicio)) {
      circleColor = Colors.blue;
    } else if (fechaActual.isBefore(fechaEntrega.subtract(Duration(days: 7)))) {
      circleColor = Colors.green;
    } else if (fechaActual.isBefore(fechaEntrega)) {
      circleColor = Colors.yellow;
    } else {
      circleColor = Colors.red;
    }

    double screenWidth = MediaQuery.of(context).size.width;
    double textScaleFactor = screenWidth / 950;

    final Color color1 = Colors.green;
    final Color color2 = (value1 / (value1 + value2) < 0.75) ? Colors.red : Colors.yellow;

    double total = value1.toDouble() + value2.toDouble();
    double percentage = (value1.toDouble() / total) * 100;

    double initialChartSize = 16;
    double maxChartSize = 55.0;
    double minChartSize = 40.0;
    double radius = initialChartSize * screenWidth / 375;

    double titleFontSize = 24 * textScaleFactor;
    double minTitleFontSize = 16.0;
    titleFontSize = titleFontSize.clamp(minTitleFontSize, double.infinity);

    double labelTextFontSize = 16 * textScaleFactor;
    double minTextFontSize = 12.0;
    labelTextFontSize = labelTextFontSize.clamp(minTextFontSize, double.infinity);

    if (radius > maxChartSize) {
      radius = maxChartSize;
    } else if (radius < minChartSize) {
      radius = minChartSize;
    }

    double _calculateIconSize(double iconScaleFactor) {
      double initialIconSize = 40;
      double maxIconSize = 40;
      double minIconSize = 25;

      double iconSize = initialIconSize * iconScaleFactor;
      iconSize = iconSize.clamp(minIconSize, maxIconSize);

      return iconSize;
    }

    List<PieChartSectionData> sections = [];

    if (value1 > 0) {
      sections.add(
        PieChartSectionData(
          value: value1.toDouble(),
          color: color1,
          title: '$value1',
          radius: radius * 1,
        ),
      );
    } else {
      sections.add(
        PieChartSectionData(
          value: 0.001,
          color: color1,
          title: '0',
          radius: radius * 1,
        ),
      );
    }

    if (value2 > 0) {
      double secondSegmentRadius = value1 == total ? 0 : radius * 1;
      sections.add(
        PieChartSectionData(
          value: value2.toDouble(),
          color: color2,
          title: '$value2',
          radius: secondSegmentRadius,
        ),
      );
    } else {
      sections.add(
        PieChartSectionData(
          value: 0.001,
          color: color2,
          title: '0',
          radius: radius * 1,
        ),
      );
    }

    return Material(
      child: InkWell(
        onTap: () {},
        onLongPress: () {},
        child: Card(
          elevation: 5,
          margin: EdgeInsets.all(10),
          child: Container(
            height: cardHeight,
            width: cardWidth,
            child: Stack(
              children: [
                Positioned(
                  top: 50,
                  left: 10,
                  child: GestureDetector(
                    onTap: () {},
                    child: Container(
                      width: 30,
                      height: 30 * textScaleFactor,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: circleColor,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: AutoSizeText(
                              title,
                              style: TextStyle(
                                fontSize: titleFontSize,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Row(
                            children: [
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 30),
                      Expanded(
                        child: Stack(
                          children: [
                            PieChart(
                              PieChartData(
                                sections: sections,
                                centerSpaceRadius: radius * .9,
                                sectionsSpace: 0,
                              ),
                            ),
                            Positioned.fill(
                              child: Center(
                                child: Text(
                                  '${percentage.toStringAsFixed(2)}%',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16 * textScaleFactor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 40),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Total ',
                            style: TextStyle(
                              fontSize: labelTextFontSize,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            width: 20 * textScaleFactor,
                            height: 20 * textScaleFactor,
                            color: color1,
                          ),
                          Text(
                            '          Restante ',
                            style: TextStyle(
                              fontSize: labelTextFontSize,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            width: 20 * textScaleFactor,
                            height: 20 * textScaleFactor,
                            color: color2,
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Fecha de Inicio ${fechaInicio.day}/${fechaInicio.month}/${fechaInicio.year}',
                        style: TextStyle(
                          fontSize: labelTextFontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Fecha de Entrega ${fechaEntrega.day}/${fechaEntrega.month}/${fechaEntrega.year}',
                        style: TextStyle(
                          fontSize: labelTextFontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
