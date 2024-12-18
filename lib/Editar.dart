import 'dart:convert';
import 'dart:ui';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}

class EditarPage extends StatefulWidget {
  const EditarPage({Key? key}) : super(key: key);

  @override
  _EditarPageState createState() => _EditarPageState();
}

class _EditarPageState extends State<EditarPage> {
  final airtableApiToken =
      'patTjJNwpD104BTKG.9352a6a8b38ce585bc3b55de8667ef8e81800fc5cde77e95a95398447a4ca604';
  final airtableApiBaseUrl = 'https://api.airtable.com';
  final airtableBaseId = 'appHba5WGxI7G7VDA';
  final airtableTableName = 'Proyectos';

List<Map<String, dynamic>> proyectos = [];
  Set<String> lineasSeleccionadas = {};
  
  final List<String> opcionesLinea = ['Linea 1', 'Linea 2', 'Linea 3', 'Linea 4','Linea 5'];

@override
void initState() {
  super.initState();
  _loadProyectos();
  // lineasSeleccionadas initialization should be moved out
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
            // Procesar los campos de "Línea" para encontrar los que son "Verdadero"
            List<String> lineasVerdaderas = [];
            for (String opcion in opcionesLinea) {
              if (fields[opcion] == 'Verdadero') {
                lineasVerdaderas.add(opcion);
              }
            }
            // Convertir la lista de líneas verdaderas en una cadena para mostrar
            String lineasActuales = lineasVerdaderas.join(', ');
            return {
              'id': record['id'],
              ...fields,
              'Linea': lineasActuales,
            };
          }),
        );
      });
    }
  } else {
        print(
            'Error al cargar proyectos desde Airtable. Código: ${response.statusCode}, Mensaje: ${response.body}');
      }
    } catch (e) {
      print('Error de conexión: $e');
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
          title: const Text('Editar Proyectos', style: TextStyle(color: Colors.white)),
          backgroundColor: const Color(0xFF313745),
        ),
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: [
                DataColumn(label: Text('Editar')),
                DataColumn(label: Text('Nombre del Proyecto')),
                DataColumn(label: Text('Piezas')),
                DataColumn(label: Text('Fecha de Inicio')),
                DataColumn(label: Text('Fecha de Fin')),
                DataColumn(label: Text('Lineas')),
                DataColumn(label: Text('Estado')),
              ],
              rows: proyectos.map<DataRow>((proyecto) {
                String estado = '';
                final opcionesEstado = ['Proximo', 'En Linea', 'Pausa', 'Atrasado', 'Espera De Material'];
                for (String opcion in opcionesEstado) {
                  if (proyecto[opcion] == 'Verdadero') {
                    estado = opcion;
                    break;
                  }
                }

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
                    DataCell(Text(proyecto['Nombre del Proyecto'].toString())),
                    DataCell(Text(proyecto['Piezas'].toString())),
                    DataCell(Text(proyecto['Fecha de inicio'].toString())),
                    DataCell(Text(proyecto['Fecha de fin'].toString())),
                    DataCell(Text(proyecto['Linea'].toString())),
                    DataCell(Text(estado)),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

void _mostrarDialogoEdicion(Map<String, dynamic> proyecto) {
  lineasSeleccionadas = Set<String>.from(opcionesLinea.where((linea) => proyecto[linea] == 'Verdadero'));

  showDialog(
    context: context,
    builder: (BuildContext context) {
      Map<String, dynamic> nuevosDatos = {};

      Future<void> _seleccionarFecha(String fecha) async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (picked != null) {
          String fechaFormateada = DateFormat('yyyy-MM-dd').format(picked);
          nuevosDatos[fecha] = fechaFormateada;
          setState(() {});
        }
      }

      void _actualizarPiezas(String value) {
        if (value.isNotEmpty && int.tryParse(value) != null) {
          nuevosDatos['Piezas'] = int.parse(value);
          nuevosDatos['Restante Soldadura'] = int.parse(value);
          nuevosDatos['Soldadura']= 0;
          nuevosDatos['Restante Soldadura 2'] = int.parse(value);
          nuevosDatos['Soldadura 1']= 0;
          nuevosDatos['Restante Soldadura 3'] = int.parse(value);
          nuevosDatos['Soldadura L1']= 0;
          nuevosDatos['Soldadura L2']= 0;
          nuevosDatos['Soldadura 3']= 0;
          nuevosDatos['Soldadura 2']= 0;
          nuevosDatos['Restante Linea'] = int.parse(value);
          nuevosDatos['Soldadura Linea']= 0;
          nuevosDatos['Restante Cama'] = int.parse(value);
          nuevosDatos['Cama L1']= 0;
          nuevosDatos['Cama L2']= 0;
          nuevosDatos['Cama L3']= 0;
          nuevosDatos['Restante Patines'] = int.parse(value);
          nuevosDatos['Patines L1']= 0;
          nuevosDatos['Patines L2']= 0;
          nuevosDatos['Patines L3']= 0;
          nuevosDatos['Restante Huacal'] = int.parse(value);
          nuevosDatos['Huacal L1']= 0;
          nuevosDatos['Huacal L2']= 0;
          nuevosDatos['Huacal L3']= 0;
          nuevosDatos['Pintura']= 0;
          nuevosDatos['Restante Interiores'] = int.parse(value);
          nuevosDatos['Interiores L1']= 0;
          nuevosDatos['Interiores L2']= 0;
          nuevosDatos['Interiores L3']= 0;
          nuevosDatos['Restante Pintura'] = int.parse(value);
          nuevosDatos['Pintura']= 0;
          nuevosDatos['Restante Montaje'] = int.parse(value);
          nuevosDatos['Montaje']= 0;
          nuevosDatos['Restante Entregados'] = int.parse(value);
          nuevosDatos['Entregados']= 0;
          nuevosDatos['Restante Liberados'] = int.parse(value);
          nuevosDatos['Liberados']= 0;
          nuevosDatos['Restante Liberados Pintura'] = int.parse(value);
          nuevosDatos['Liberados Pintura']= 0;
          nuevosDatos['Restante Liberados Soldadura'] = int.parse(value);
          nuevosDatos['Liberados Soldadura']= 0;
          nuevosDatos['Restante Liberados'] = int.parse(value);
          nuevosDatos['Liberados']= 0;
          nuevosDatos['Textil']= 0;
          nuevosDatos['Restante Textil'] = int.parse(value);
        }
      }

      void _actualizarNombre(String value) {
        if (value.isNotEmpty) {
          nuevosDatos['Nombre del Proyecto'] = value;
        }
      }

      void _actualizarEstado(String value) {
        final List<String> opcionesEstado = ['Proximo', 'En Linea', 'Pausa', 'Atrasado', 'Espera De Material'];
        for (String opcion in opcionesEstado) {
          nuevosDatos[opcion] = (opcion == value) ? 'Verdadero' : 'Falso';
        }
      }

      void _actualizarLinea() {
  for (String opcion in opcionesLinea) {
    nuevosDatos[opcion] = lineasSeleccionadas.contains(opcion) ? 'Verdadero' : 'Falso';
  }
  // Set "Textil Estado" and "Linea 5" to "Falso" if "Linea 5" is not selected
  if (!lineasSeleccionadas.contains('Linea 5')) {
    nuevosDatos['Textil Estado'] = 'Falso';
    nuevosDatos['Linea 5'] = 'Falso';
  }
}

      final List<String> opcionesComboBox = ['Proximo', 'En Linea', 'Pausa', 'Atrasado', 'Espera De Material'];

      String valorSeleccionadoComboBox = '';
      for (String opcion in opcionesComboBox) {
        if (proyecto[opcion] == 'Verdadero') {
          valorSeleccionadoComboBox = opcion;
          break;
        }
      }

      for (String opcion in opcionesLinea) {
        if (proyecto[opcion] == 'Verdadero') {
          break;
        }
      }

      return Dialog(
        child: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Scrollbar(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Editando Proyecto: ${proyecto['Nombre del Proyecto']}',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  _textFieldEditar(
                    label: 'Nuevo Nombre del Proyecto',
                    onChanged: (value) {
                      setState(() {
                        _actualizarNombre(value);
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  _textFieldEditar(
                    label: 'Nuevas Piezas',
                    onChanged: (value) {
                      setState(() {
                        _actualizarPiezas(value);
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => _seleccionarFecha('Fecha de inicio'),
                    child: Text('Seleccionar Fecha de Inicio'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => _seleccionarFecha('Fecha de fin'),
                    child: Text('Seleccionar Fecha de Fin'),
                  ),
                  const SizedBox(height: 20),
                 Text('Líneas', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            Column(
                                children: opcionesLinea.map((linea) {
  return CheckboxListTile(
    title: Text(linea),
    value: lineasSeleccionadas.contains(linea),
    onChanged: (bool? value) {
      setState(() {
        if (value == true) {
          lineasSeleccionadas.add(linea);
        } else {
          lineasSeleccionadas.remove(linea);
        }
        _actualizarLinea();
      });
    },
  );
}).toList(),
                            ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    value: valorSeleccionadoComboBox,
                    decoration: InputDecoration(
                      labelText: 'Estado del Proyecto',
                      border: OutlineInputBorder(),
                    ),
                    items: opcionesComboBox.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        valorSeleccionadoComboBox = newValue!;
                        _actualizarEstado(newValue);
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      if (nuevosDatos.isNotEmpty) {
                        _editarProyecto(proyecto['id'], nuevosDatos);
                        Navigator.of(context).pop();
                      } else {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Error'),
                              content: const Text('Debes ingresar al menos un campo para editar.'),
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
                      }
                    },
                    child: const Text('Guardar'),
                  ),
                ],
              ),
            );
          },
        ),
      );
    },
  );
}

Widget _textFieldEditar({required String label, required ValueChanged<String> onChanged}) {
  return TextField(
    decoration: InputDecoration(labelText: label),
    onChanged: onChanged,
  );
}

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
        _loadProyectos();
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Éxito'),
              content: const Text('Proyecto editado exitosamente.'),
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
      }
    } catch (e) {
      print('Error de conexión: $e');
    }
  }
}

