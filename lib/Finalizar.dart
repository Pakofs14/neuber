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

class FinalizarPage extends StatefulWidget {
  const FinalizarPage({Key? key}) : super(key: key);

  @override
  _FinalizarPageState createState() => _FinalizarPageState();
}

class _FinalizarPageState extends State<FinalizarPage> {
  final airtableApiToken =
      'patTjJNwpD104BTKG.9352a6a8b38ce585bc3b55de8667ef8e81800fc5cde77e95a95398447a4ca604';
  final airtableApiBaseUrl = 'https://api.airtable.com';
  final airtableBaseId = 'appHba5WGxI7G7VDA';
  final airtableTableName = 'Proyectos';

  final historicoApiToken =
      'patBvCbD6U2fVpWpL.d5336593f726634610f36dd78f76a50600199b264687cfbac16c7834cc844dae';
  final historicoBaseId = 'appKMQjDm0niVdfdV';
  final historicoTableName = 'Historico';

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
          title: const Text('Finalizar Proyectos', style: TextStyle(color: Colors.white)),
          backgroundColor: const Color(0xFF313745),
        ),
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: [
                DataColumn(label: Text('Finalizar')),
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
                        icon: const Icon(Icons.stop_circle_outlined),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Confirmación'),
                                content: Text(
                                    '¿Estás seguro de que quieres finalizar el proyecto "${proyecto['Nombre del Proyecto']}"?'),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('Cancelar'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      _finalizarProyecto(proyecto);
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('Finalizar'),
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

  // FINALIZAR PROYECTO
  Future<void> _finalizarProyecto(Map<String, dynamic> proyecto) async {
    final historicoUrl = '$airtableApiBaseUrl/v0/$historicoBaseId/$historicoTableName';
    final headers = {
      'Authorization': 'Bearer $historicoApiToken',
      'Content-Type': 'application/json',
    };

    final body = jsonEncode({
      'fields': {
        'Nombre del Proyecto': proyecto['Nombre del Proyecto'],
        'Piezas': proyecto['Piezas'],
        'Fecha de inicio': proyecto['Fecha de inicio'],
        'Fecha de fin': proyecto['Fecha de fin'],
        'Entregados': proyecto['Entregados'] ?? 0,
      }
    });

    try {
      final response = await http.post(
        Uri.parse(historicoUrl),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Eliminar el proyecto de la tabla "Proyectos"
        await _eliminarProyecto(proyecto['id']);
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Éxito'),
              content: const Text('Proyecto finalizado exitosamente.'),
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
        // Actualizar la lista de proyectos después de finalizar uno
        await _loadProyectos(); // Usar 'await' para asegurar que la lista de proyectos se actualice antes de mostrarla
      } else {
        print(
            'Error al finalizar el proyecto en Airtable. Código: ${response.statusCode}, Mensaje: ${response.body}');
        // Manejar el error según tus necesidades
      }
    } catch (e) {
      print('Error de conexión: $e');
      // Manejar el error de conexión según tus necesidades
    }
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
        // Proyecto eliminado exitosamente
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
