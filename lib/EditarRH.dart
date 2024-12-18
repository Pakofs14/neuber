import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:ui';
import 'package:neuber/RecursosHumanos.dart';

class CustomScrollBehavior extends MaterialScrollBehavior {
  @override

  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}

class EditarRHPage extends StatefulWidget {
  const EditarRHPage({Key? key}) : super(key: key);

  @override
  _EditarRHPageState createState() => _EditarRHPageState();
}

class _EditarRHPageState extends State<EditarRHPage> {
  final airtableApiToken =
      'patTjJNwpD104BTKG.9352a6a8b38ce585bc3b55de8667ef8e81800fc5cde77e95a95398447a4ca604';
  final airtableApiBaseUrl = 'https://api.airtable.com';
  final airtableBaseId = 'appHba5WGxI7G7VDA';
  final airtableTableName = 'Correos';

  List<Map<String, dynamic>> correos = [];

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
          'Editar Base De Datos',
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
                      DataColumn(label: Text('Editar')),
                      DataColumn(label: Text('RFC')),
                      DataColumn(label: Text('Correo')),
                      DataColumn(label: Text('Nombre')),
                    ],
                    // Aquí continúa con el resto de tu código como lo tienes actualmente
                    rows: correos.map<DataRow>((proyecto) {
                      return DataRow(
                        cells: [
                          DataCell(
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                _mostrarDialogoEdicion(proyecto);
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

  void _mostrarDialogoEdicion(Map<String, dynamic> proyecto) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        Map<String, dynamic> nuevosDatos = {
          'RFC': proyecto['RFC'],
          'Correo': proyecto['Correo'],
          'Nombre': proyecto['Nombre'],
        };

        void _actualizarRFC(String value) {
          nuevosDatos['RFC'] = value;
        }

        void _actualizarCorreo(String value) {
          nuevosDatos['Correo'] = value;
        }

        void _actualizarNombre(String value) {
          nuevosDatos['Nombre'] = value;
        }

        return Dialog(
          child: Scrollbar(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Editando Proyecto: ${proyecto['Nombre']}',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                _textFieldEditar(
                  label: 'Nuevo RFC',
                  initialValue: proyecto['RFC'],
                  onChanged: (value) {
                    _actualizarRFC(value);
                  },
                ),
                _textFieldEditar(
                  label: 'Nuevo Correo',
                  initialValue: proyecto['Correo'],
                  onChanged: (value) {
                    _actualizarCorreo(value);
                  },
                ),
                _textFieldEditar(
                  label: 'Nuevo Nombre',
                  initialValue: proyecto['Nombre'],
                  onChanged: (value) {
                    _actualizarNombre(value);
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (nuevosDatos.isNotEmpty) {
                      _editarProyecto(proyecto['id'], nuevosDatos);
                      Navigator.of(context).pop();
                    } else {
                      // Mostrar mensaje de error si no se ingresaron datos
                    }
                  },
                  child: const Text('Guardar'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Función para crear un campo de texto para editar
  Widget _textFieldEditar({
    required String label,
    required ValueChanged<String> onChanged,
    String? initialValue, // Define el parámetro initialValue
  }) {
    return TextField(
      decoration: InputDecoration(labelText: label),
      onChanged: onChanged,
      controller: TextEditingController(
          text: initialValue), // Usa el initialValue para inicializar el campo de texto
    );
  }
 // EDITAR PROYECTO
 Future<void> _editarProyecto(String id, Map<String, dynamic> newData) async {
    final url = '$airtableApiBaseUrl/v0/$airtableBaseId/$airtableTableName/$id';
    final headers = {
      'Authorization': 'Bearer $airtableApiToken',
      'Content-Type': 'application/json',
    };

    try {
      final response = await http.patch(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode({
          'fields': newData,
        }),
      );

      if (response.statusCode == 200) {
        _loadCorreos();
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Éxito'),
              content: const Text('Registro Editado Correctamente'),
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
      } else {
        print(
            'Error al editar el proyecto de Airtable. Código: ${response.statusCode}, Mensaje: ${response.body}');
        // Manejar el error según tus necesidades
      }
    } catch (e) {
      print('Error de conexión:$e');
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
