import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_spinkit/flutter_spinkit.dart';

class CustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
  };
}

class BuscarPage extends StatefulWidget {
  const BuscarPage({Key? key}) : super(key: key);

  @override
  _BuscarPageState createState() => _BuscarPageState();
}

class _BuscarPageState extends State<BuscarPage> {
  final airtableApiToken =
      'patTjJNwpD104BTKG.9352a6a8b38ce585bc3b55de8667ef8e81800fc5cde77e95a95398447a4ca604';
  final airtableApiBaseUrl = 'https://api.airtable.com';
  final airtableBaseId = 'appHba5WGxI7G7VDA';
  final airtableTableName = 'Proyectos';

  Future<List<Map<String, dynamic>>> _loadProyectos() async {
  final url = '$airtableApiBaseUrl/v0/$airtableBaseId/$airtableTableName';
  final headers = {
    'Authorization': 'Bearer $airtableApiToken',
  };

  final response = await http.get(
    Uri.parse(url),
    headers: headers,
  );

  if (response.statusCode == 200) {
    final decodedData = jsonDecode(response.body) as Map<String, dynamic>;
    if (decodedData.containsKey('records')) {
      List<Map<String, dynamic>> proyectos = List<Map<String, dynamic>>.from(
        decodedData['records'].map((record) {
          var fields = record['fields'];
          // Create a new field for combined line information
          String combinedLine = '';
          if (fields['Linea 1']?.toString() == 'Verdadero') {
            combinedLine += 'Linea 1 ';
          }
          if (fields['Linea 2']?.toString() == 'Verdadero') {
            combinedLine += 'Linea 2 ';
          }
          if (fields['Linea 3']?.toString() == 'Verdadero') {
            combinedLine += 'Linea 3';
          }
          if (fields['Linea 4']?.toString() == 'Verdadero') {
            combinedLine += 'Montaje ';
          }
          // Remove the trailing comma and space if needed
          if (combinedLine.endsWith(' , ')) {
            combinedLine = combinedLine.substring(0, combinedLine.length - 2);
          }
          fields['CombinedLine'] = combinedLine; // Add the new field to the record
          return fields;
        }),
      );

      // Ordenar los proyectos según su estado
      proyectos.sort((a, b) {
        // Primero los proyectos en línea
        if (a['En Linea'].toString() == 'Verdadero' && b['En Linea'].toString() != 'Verdadero') {
          return -1;
        } else if (a['En Linea'].toString() != 'Verdadero' && b['En Linea'].toString() == 'Verdadero') {
          return 1;
        }
        // Luego los pausados
        else if (a['Pausa'].toString() == 'Verdadero' && b['Pausa'].toString() != 'Verdadero') {
          return -1;
        } else if (a['Pausa'].toString() != 'Verdadero' && b['Pausa'].toString() == 'Verdadero') {
          return 1;
        }
        // Al final los atrasados
        else if (a['Atrasado'].toString() == 'Verdadero' && b['Atrasado'].toString() != 'Verdadero') {
          return 1;
        } else if (a['Atrasado'].toString() != 'Verdadero' && b['Atrasado'].toString() == 'Verdadero') {
          return -1;
        } else {
          return 0;
        }
      });

      return proyectos;
    }
  } else {
    throw Exception('Error al cargar proyectos desde Airtable');
  }
  return [];
}

  String _determineStatus(Map<String, dynamic> project) {
    if (project['Proximo'].toString() == 'Verdadero') {
      return 'Proximo';
    } else if (project['Atrasado'].toString() == 'Verdadero') {
      return 'Atrasado';
    } else if (project['Pausa'].toString() == 'Verdadero') {
      return 'Pausa';
    } else if (project['En Linea'].toString() == 'Verdadero') {
      return 'En Linea';
    } else {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scrollBehavior: CustomScrollBehavior(),
      home: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: const Text('Buscar Proyectos', style: TextStyle(color: Colors.white)),
          backgroundColor: const Color(0xFF313745),
        ),
        body: FutureBuilder<List<Map<String, dynamic>>>(
          future: _loadProyectos(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: SpinKitFadingCircle(
                  color: Colors.black,
                  size:   60.0,
                ),
              );
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }  else {
          final proyectos = snapshot.data ?? [];
          return SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: [
                      DataColumn(label: Container()),  
                      DataColumn(label: Text('Estado')),
                      DataColumn(label: Text('Nombre del Proyecto')),
                      DataColumn(label: Text('Fecha de Inicio')),
                      DataColumn(label: Text('Fecha de Fin')),
                      DataColumn(label: Text('Línea')),
                    ],
                    rows: proyectos.map<DataRow>((proyecto) {
                      Color rowColor;
                      if (proyecto['Proximo'].toString() == 'Verdadero') {
                        rowColor = Colors.blue;
                      } else if (proyecto['Atrasado'].toString() == 'Verdadero') {
                        rowColor = Colors.orange;
                      } else if (proyecto['Pausa'].toString() == 'Verdadero') {
                        rowColor = Colors.red;
                      } else if (proyecto['En Linea'].toString() == 'Verdadero') {
                        rowColor = Colors.green;
                      } else {
                        rowColor = Colors.white; // o cualquier otro color por defecto
                      }
                      return DataRow(
                        cells: [
                          DataCell(Container(
                            width:  20,
                            height:  20,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: rowColor,
                            ),
                          )),
                          DataCell(Text(_determineStatus(proyecto))),
                          DataCell(Text(proyecto['Nombre del Proyecto'].toString())),
                          DataCell(Text(proyecto['Fecha de inicio'].toString())),
                          DataCell(Text(proyecto['Fecha de fin'].toString())),
                          DataCell(Text(proyecto['CombinedLine'].toString())),
                        ],
                      );
                    }).toList(),
    ),
     ),
   );
            }
          }
    )
      )
    );

  }

}
