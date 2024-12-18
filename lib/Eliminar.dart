import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}

class EliminarPage extends StatefulWidget {
  const EliminarPage({Key? key}) : super(key: key);

  @override
  _EliminarPageState createState() => _EliminarPageState();
}

class _EliminarPageState extends State<EliminarPage> {
  final airtableApiToken =
      'patTjJNwpD104BTKG.9352a6a8b38ce585bc3b55de8667ef8e81800fc5cde77e95a95398447a4ca604';
  final airtableApiBaseUrl = 'https://api.airtable.com';
  final airtableBaseId = 'appHba5WGxI7G7VDA';
  final airtableTableName = 'Proyectos';

  List<Map<String, dynamic>> proyectos = [];

  @override
  void initState() {
    super.initState();
    _loadProyectos();
  }

  Future<void> _loadProyectos() async {
    final url = '$airtableApiBaseUrl/v0/$airtableBaseId/$airtableTableName';
    final headers = {
      'Authorization': 'Bearer $airtableApiToken',
    };

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body) as Map<String, dynamic>;
        if (decodedData.containsKey('records')) {
          setState(() {
            proyectos = List<Map<String, dynamic>>.from(
              decodedData['records'].map((record) {
                final fields = record['fields'] as Map<String, dynamic>;
                return {
                  'id': record['id'],
                  ...fields,
                };
              }),
            );
          });
        }
      } else {
        print(
            'Error al cargar proyectos desde Airtable. Código: ${response.statusCode}, Mensaje: ${response.body}');
        // Manejar el error según tus necesidades
      }
    } catch (e) {
      print('Error de conexión: $e');
      // Manejar el error de conexión según tus necesidades
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
          title: const Text('Eliminar Proyectos', style: TextStyle(color: Colors.white)),
          backgroundColor: const Color(0xFF313745),
        ),
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: [
                DataColumn(label: Text('Eliminar')),
                DataColumn(label: Text('Nombre del Proyecto')),
                DataColumn(label: Text('Piezas')),
                DataColumn(label: Text('Fecha de Inicio')),
                DataColumn(label: Text('Fecha de Fin')),
              ],
              rows: proyectos.map<DataRow>((proyecto) {
                return DataRow(
                  cells: [
                    DataCell(
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Confirmación'),
                                content: Text(
                                    '¿Estás seguro de que quieres eliminar el proyecto permanentemente (NO SE GUARDARA EN HISTORICO)"${proyecto['Nombre del Proyecto']}"?'),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('Cancelar'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      _eliminarProyecto(proyecto['id']);
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('Eliminar'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ),
                    DataCell(Text(proyecto['Nombre del Proyecto'].toString())),
                    DataCell(Text(proyecto['Piezas'].toString())),
                    DataCell(Text(proyecto['Fecha de inicio'].toString())),
                    DataCell(Text(proyecto['Fecha de fin'].toString())),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  // ELIMINAR PROYECTO
  Future<void> _eliminarProyecto(String id) async {
    final url = '$airtableApiBaseUrl/v0/$airtableBaseId/$airtableTableName/$id';
    final headers = {
      'Authorization': 'Bearer $airtableApiToken',
    };

    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode == 200) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Éxito'),
              content: const Text('Proyecto eliminado exitosamente.'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
        // Actualizar la lista de proyectos después de eliminar uno
        await _loadProyectos(); // Usar 'await' para asegurar que la lista de proyectos se actualice antes de mostrarla
      } else {
        print(
            'Error al eliminar el proyecto de Airtable. Código: ${response.statusCode}, Mensaje: ${response.body}');
        // Manejar el error según tus necesidades
      }
    } catch (e) {
      print('Error de conexión: $e');
      // Manejar el error de conexión según tus necesidades
    }
  }
}
