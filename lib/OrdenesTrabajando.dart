import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:signature/signature.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class CustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
  };
}

class OrdenesTrabajandoPage extends StatefulWidget {
  const OrdenesTrabajandoPage({Key? key}) : super(key: key);

  @override
  _OrdenesTrabajandoPageState createState() => _OrdenesTrabajandoPageState();
}

class _OrdenesTrabajandoPageState extends State<OrdenesTrabajandoPage> {
  final airtableApiToken = 'patTjJNwpD104BTKG.9352a6a8b38ce585bc3b55de8667ef8e81800fc5cde77e95a95398447a4ca604';
  final airtableApiBaseUrl = 'https://api.airtable.com';
  final airtableBaseId = 'appHba5WGxI7G7VDA';
  final airtableTableName = 'OTSistemas';

  List<Map<String, dynamic>> _proyectos = [];
  String? _trabajoRealizado;
  String? _refaccionesUtilizadas;
  String? _causaFalla;
  String? _observaciones;
  bool _isLoading = true;  // Añadido para controlar el estado de carga

  SignatureController _signatureController = SignatureController(
    penStrokeWidth: 5,
    penColor: Colors.black,
  );
  bool firmaAceptada = false;

  @override
  void initState() {
    super.initState();
    _recargarProyectos();
    _signatureController.addListener(_onSignatureChange);
  }

  @override
  void dispose() {
    _signatureController.removeListener(_onSignatureChange);
    _signatureController.dispose();
    super.dispose();
  }

  void _onSignatureChange() {
    if (_signatureController.points.isNotEmpty && !firmaAceptada) {
      setState(() {
        firmaAceptada = true;
      });
    }
  }

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
            fields['recordId'] = record['id'];
            return fields;
          }),
        );
        proyectos = proyectos.where((proyecto) => proyecto['Estado'].toString() == 'Trabajando').toList();
        return proyectos;
      }
    } else {
      throw Exception('Error al cargar proyectos desde Airtable');
    }
    return [];
  }

  Future<void> _recargarProyectos() async {
    setState(() {
      _isLoading = true;  // Activar la animación de carga
    });
    final proyectos = await _loadProyectos();
    setState(() {
      _proyectos = proyectos;
      _isLoading = false;  // Desactivar la animación de carga
    });
  }

  Future<bool> _showConfirmationDialog(BuildContext context, Map<String, dynamic> proyecto) async {
  return await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Confirmar'),
        content: const Text('¿Estás seguro de que deseas finalizar esta orden?'),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () {
              Navigator.of(context).pop(false);
            },
          ),
          TextButton(
            child: const Text('Aceptar'),
            onPressed: () async {
              Navigator.of(context).pop(true);
              // Llamar a la pantalla de inicio de sesión con el proyecto seleccionado
              await _showLoginDialog(context, proyecto);
            },
          ),
        ],
      );
    },
  ) ?? false;
}

  Future<bool> _showLoginDialog(BuildContext context, Map<String, dynamic> proyecto) async {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  return await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Iniciar Sesión'),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              TextField(
                controller: usernameController,
                decoration: const InputDecoration(labelText: 'Usuario'),
              ),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: 'Contraseña'),
                obscureText: true,
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () {
              Navigator.of(context).pop(false);
            },
          ),
          TextButton(
            child: const Text('Aceptar'),
            onPressed: () async {
              final username = usernameController.text;
              final password = passwordController.text;

              if (username == 'sistemas' && password == 'TiGpoVisa**') {
                Navigator.of(context).pop(true);
                await _showInputForm(context, proyecto); // Pasa el proyecto aquí
              } else {
                _showErrorLoginDialog(context);
              }
            },
          ),
        ],
      );
    },
  ) ?? false;
}

  Future<void> _showErrorLoginDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: const Text('Usuario o contraseña incorrecta'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
 
  Future<bool> _showLoginDialog2(BuildContext context, Map<String, dynamic> proyecto) async {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  return await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Iniciar Sesión'),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              TextField(
                controller: usernameController,
                decoration: const InputDecoration(labelText: 'Usuario'),
              ),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: 'Contraseña'),
                obscureText: true,
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () {
              Navigator.of(context).pop(false);
            },
          ),
          TextButton(
            child: const Text('Aceptar'),
            onPressed: () async {
              final username = usernameController.text;
              final password = passwordController.text;
              if (username =='sistemas' && password == 'TiGpoVisa**') {
                Navigator.of(context).pop(true);
              } else {
                _showErrorLoginDialog(context);
              }
            },
          ),
        ],
      );
    },
  ) ?? false;
}

  Future<void> _showNotaDialog(BuildContext context, Map<String, dynamic> proyecto) async {
  final notaController = TextEditingController();

  try {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Agregar Nota'),
          content: TextField(
            controller: notaController,
            decoration: const InputDecoration(labelText: 'Nueva nota'),
            maxLines: 3,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Guardar'),
              onPressed: () async {
                final nota = notaController.text.trim();
                if (nota.isNotEmpty) {
                  try {
                    await _guardarNota(proyecto['recordId'], nota);
                    Navigator.of(context).pop();
                    await _recargarProyectos();
                    
                    // Envía el correo electrónico
                    await _sendEmail(proyecto);
                  } catch (e) {
                    print('Error al guardar la nota: $e');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Ocurrió un error al guardar la nota: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('La nota no puede estar vacía.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  } catch (e) {
    print('Error en _showNotaDialog: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Ocurrió un error al mostrar el diálogo de notas: $e'),
        backgroundColor: Colors.red,
      ),
    );
  }
}

  Future<void> _guardarNota(String recordId, String nota) async {
  try {
    final url = '$airtableApiBaseUrl/v0/$airtableBaseId/$airtableTableName/$recordId';
    final headers = {
      'Authorization': 'Bearer $airtableApiToken',
      'Content-Type': 'application/json',
    };
    final body = jsonEncode({
      'fields': {
        'Notas/Progreso': nota,
      },
    });

    final response = await http.patch(
      Uri.parse(url),
      headers: headers,
      body: body,
    );

    if (response.statusCode != 200) {
      print('Error al guardar la nota: ${response.statusCode} - ${response.body}');
      throw Exception('Error al guardar la nota');
    }
    print('Nota guardada correctamente');
  } catch (e) {
    print('Error inesperado al guardar la nota: $e');
    rethrow;
  }
}

  Future<void> _sendEmail(Map<String, dynamic> proyecto) async {
  final String recipient = proyecto['Correo'] ?? 'sistemas@neuber.com.mx'; // Usa el correo de la celda o un valor por defecto
  final String subject = 'Nueva nota agregada a tu orden de trabajo';
  final String body = '''
Una nueva nota ha sido agregada a tu orden de trabajo ${proyecto['Numero'] ?? ''}.
Detalles de la orden:
Nombre OT: ${proyecto['NombreOT'] ?? ''}
Prioridad: ${proyecto['Prioridad'] ?? ''}
Área: ${proyecto['Area'] ?? ''}
Falla: ${proyecto['Falla'] ?? ''}
Estado: ${proyecto['Estado'] ?? ''}
Nombre Solicitante: ${proyecto['Nombre Solicitante'] ?? ''}
Hora Enviada: ${proyecto['Hora Enviada'] ?? ''}
Nota agregada: ${_trabajoRealizado ?? ''}
El equipo de sistemas está trabajando en su solicitud y le mantendrá informado sobre el progreso.

Gracias por su paciencia.
''';

  final Uri emailLaunchUri = Uri(
    scheme: 'mailto',
    path: recipient,
    query: encodeQueryParameters({
      'subject': subject,
      'body': body,
    }),
  );

  if (await canLaunch(emailLaunchUri.toString())) {
    await launch(emailLaunchUri.toString());
  } else {
    print('Could not launch $emailLaunchUri');
  }
}

  String? encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }

  Future<void> _showSuccessDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Éxito'),
          content: const Text('La orden se ha finalizado correctamente'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showInputForm(BuildContext context, Map<String, dynamic> proyecto) async {
    final trabajoController = TextEditingController();
    final refaccionesController = TextEditingController();
    final causaController = TextEditingController();
    final observacionesController = TextEditingController();

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Detalles de la Orden'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  controller: trabajoController,
                  decoration: const InputDecoration(labelText: '¿Cuál fue el trabajo realizado?'),
                ),
                TextField(
                  controller: refaccionesController,
                  decoration: const InputDecoration(labelText: '¿Cuáles fueron las refacciones utilizadas?'),
                ),
                TextField(
                  controller: causaController,
                  decoration: const InputDecoration(labelText: '¿Cuál fue la causa de la falla?'),
                ),
                TextField(
                  controller: observacionesController,
                  decoration: const InputDecoration(labelText: 'Observaciones'),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Continuar'),
              onPressed: () {
                final trabajo = trabajoController.text.trim();
                final refacciones = refaccionesController.text.trim();
                final causa = causaController.text.trim();
                final observaciones = observacionesController.text.trim();

                if (trabajo.isEmpty || refacciones.isEmpty || causa.isEmpty || observaciones.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Todos los campos deben ser completados.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                } else {
                  setState(() {
                    _trabajoRealizado = trabajo;
                    _refaccionesUtilizadas = refacciones;
                    _causaFalla = causa;
                    _observaciones = observaciones;
                  });
                  Navigator.of(context).pop();
                  _mostrarDialogoFirma(context, proyecto['recordId']);
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _finalizarOrden(String recordId) async {
    if (_trabajoRealizado != null && _refaccionesUtilizadas != null && _causaFalla != null && _observaciones != null) {
      final now = DateTime.now();
      final horaFin = '${now.day}/${now.month}/${now.year} ${now.hour}:${now.minute}${now.hour >= 12 ? 'pm' : 'am'}';

      final url = '$airtableApiBaseUrl/v0/$airtableBaseId/$airtableTableName/$recordId';
      final headers = {
        'Authorization': 'Bearer $airtableApiToken',
        'Content-Type': 'application/json',
      };

      final body = jsonEncode({
        'fields': {
          'Estado': 'Finalizado',
          'Hora de Fin': horaFin,
          'Trabajo Realizado': _trabajoRealizado,
          'Refacciones Utilizadas': _refaccionesUtilizadas,
          'Causa Falla': _causaFalla,
          'Observaciones': _observaciones,
        },
      });

      final response = await http.patch(
        Uri.parse(url),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        await _showSuccessDialog(context);
        await _recargarProyectos();
      } else {
        print('Error al actualizar la orden: ${response.body}');
      }
    } else {
      print('Los campos del formulario no están completos.');
    }
  }
  
  void _mostrarDialogoFirma(BuildContext context, String recordId) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setModalState) {
          return Padding(
            padding: MediaQuery.of(context).viewInsets,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Firma la Orden de Trabajo',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  width: double.infinity,
                  height: 200,
                  color: Colors.grey[200],
                  child: Stack(
                    children: [
                      Signature(
                        controller: _signatureController,
                        backgroundColor: Colors.white,
                      ),
                      Positioned.fill(
                        child: GestureDetector(
                          onPanUpdate: (_) {
                            setModalState(() {
                              firmaAceptada = _signatureController.points.isNotEmpty;
                            });
                          },
                          onPanEnd: (_) {
                            setModalState(() {
                              firmaAceptada = _signatureController.points.isNotEmpty;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () {
                        _signatureController.clear();
                        setModalState(() {
                          firmaAceptada = false;
                        });
                      },
                      child: Text('Borrar'),
                    ),
                    TextButton(
                      onPressed: firmaAceptada
                          ? () {
                              Navigator.of(context).pop();
                              _finalizarOrden(recordId); // Pasa el recordId aquí
                            }
                          : null,
                      child: Text('Aceptar'),
                    ),
                  ],
                ),
                SizedBox(height: 20),
              ],
            ),
          );
        },
      );
    },
  );
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
        title: const Text('Órdenes de Trabajo En Curso', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF313745),
      ),
      body: _isLoading  // Verifica si está cargando
                  ? Center(
                child: SpinKitFadingCircle(
                  color: Colors.grey, // Puedes cambiar el color a tu preferencia
                  size: 80.0,
                ),
              )
            : _proyectos.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search, // Ícono de lupa
                    size: 80.0,   // Tamaño del ícono
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 20), // Espacio entre el ícono y el texto
                  const Text(
                    'No se encontraron órdenes activas.',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            )
              : SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: [
                        DataColumn(label: Text('Editar')),
                        DataColumn(label: Text('Acciones')),
                        DataColumn(label: Text('Notas/Progreso')),
                        DataColumn(label: Text('Numero')),
                        DataColumn(label: Text('NombreOT')),
                        DataColumn(label: Text('Prioridad')),
                        DataColumn(label: Text('Area')),
                        DataColumn(label: Text('Falla')),
                        DataColumn(label: Text('Estado')),
                        DataColumn(label: Text('Nombre Solicitante')),
                        DataColumn(label: Text('Hora Enviada')),
                        DataColumn(label: Text('Hora de Inicio')),
                      ],
                      rows: _proyectos.map<DataRow>((proyecto) {
                        return DataRow(
                          cells: [
                            DataCell(
                              IconButton(
                                icon: Icon(Icons.create), // Ícono de lápiz
                                onPressed: () async {
                                  final loginSuccess = await _showLoginDialog2(context, proyecto);
                                  if (loginSuccess) {
                                    await _showNotaDialog(context, proyecto);
                                  }
                                },
                              ),
                            ),
                            DataCell(
                              ElevatedButton(
                                onPressed: () {
                                  _showConfirmationDialog(context, proyecto);
                                },
                                child: Text('Finalizar Orden'),
                              ),
                            ),
                            DataCell(
                              GestureDetector(
                                onTap: () async {
                                  final loginSuccess = await _showLoginDialog2(context, proyecto);
                                  if (loginSuccess) {
                                    await _showNotaDialog(context, proyecto);
                                  }
                                },
                                child: Text(proyecto['Notas/Progreso'] ?? ''),
                              ),
                            ),
                            DataCell(Text(proyecto['Numero'].toString())),
                            DataCell(Text(proyecto['NombreOT'] ?? '')),
                            DataCell(Text(proyecto['Prioridad'] ?? '')),
                            DataCell(Text(proyecto['Area'] ?? '')),
                            DataCell(Text(proyecto['Falla'] ?? '')),
                            DataCell(Text(proyecto['Estado'] ?? '')),
                            DataCell(Text(proyecto['Nombre Solicitante'] ?? '')),
                            DataCell(Text(proyecto['Hora Enviada'] ?? '')),
                            DataCell(Text(proyecto['Hora de Inicio'] ?? '')),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
    ),
  );
}


}
