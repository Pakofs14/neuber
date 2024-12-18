import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:neuber/RecursosHumanos.dart';

class CustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}

class EliminarRHPage extends StatefulWidget {
  const EliminarRHPage({Key? key}) : super(key: key);

  @override
  _EliminarRHPageState createState() => _EliminarRHPageState();
}

class _EliminarRHPageState extends State<EliminarRHPage> {
  final airtableApiToken =
      'patTjJNwpD104BTKG.9352a6a8b38ce585bc3b55de8667ef8e81800fc5cde77e95a95398447a4ca604';
  final airtableApiBaseUrl = 'https://api.airtable.com';
  final airtableBaseId = 'appHba5WGxI7G7VDA';
  final airtableTableName = 'Correos';

  List<Map<String, dynamic>>correos = [];

  @override
  void initState() {
    super.initState();
    _loadCorreos();
  }

  Future<void> _loadCorreos() async {
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
            correos = List<Map<String, dynamic>>.from(
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
    _navigateToRecursosHumanosPage(context);
  },
),

           title: const Text(
          'Eliminar Registro',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF313745),
      ),
       body: SingleChildScrollView(
      child: Column(
       crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 20),
          // Muestra el SpinKitFadingCircle mientras se cargan los datos
          if (correos.isEmpty)
            SpinKitFadingCircle(
              color: Colors.black,
              size: 60.0,
            ),
          // Si hay correos cargados, muestra la tabla de datos
          if (correos.isNotEmpty)
            DataTable(
              columns: [
                DataColumn(label: Text('Eliminar')),
                DataColumn(label: Text('RFC')),
                DataColumn(label: Text('Correos')),
                DataColumn(label: Text('Nombre')),
              ],
              rows: correos.map<DataRow>((proyecto) {
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
                                    '¿Estás seguro de que quieres eliminar el resgistro"?'),
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
                    DataCell(Text(proyecto['RFC'].toString())),
                    DataCell(Text(proyecto['Correo'].toString())),
                    DataCell(Text(proyecto['Nombre'].toString())),
                  ],
                );
              }).toList(),
            ),
            ],
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
              content: const Text('Registrp eliminado exitosamente.'),
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
        await _loadCorreos(); // Usar 'await' para asegurar que la lista de proyectos se actualice antes de mostrarla
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
void _navigateToRecursosHumanosPage(BuildContext context) {
  Navigator.of(context).pushReplacement(
    PageRouteBuilder(
      transitionDuration: Duration(milliseconds: 500), // Puedes ajustar la duración según tus preferencias
      pageBuilder: (_, __, ___) => RecursosHumanosPage(),
      transitionsBuilder: (_, Animation<double> animation, __, Widget child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    ),
  );
}

