import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
  };
}

class OrdenesActivasPage extends StatefulWidget {
  const OrdenesActivasPage({Key? key}) : super(key: key);

  @override
  _OrdenesActivasPageState createState() => _OrdenesActivasPageState();
}

class _OrdenesActivasPageState extends State<OrdenesActivasPage> {
  final airtableApiToken = 'patTjJNwpD104BTKG.9352a6a8b38ce585bc3b55de8667ef8e81800fc5cde77e95a95398447a4ca604';
  final airtableApiBaseUrl = 'https://api.airtable.com';
  final airtableBaseId = 'appHba5WGxI7G7VDA';
  final airtableTableName = 'OTSistemas';

    bool _isLoading = true; // Indicador de carga
  List<Map<String, dynamic>> _proyectos = [];

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
          fields['recordId'] = record['id']; // Agregar el ID del registro a los datos del proyecto
          return fields;
        }),
      );

      // Filtrar las órdenes de trabajo con estado "Pendiente"
      proyectos = proyectos.where((proyecto) {
        final asignado = proyecto['Asignado']?.toString() ?? '';
        return proyecto['Estado'].toString() == 'Pendiente' &&
               (asignado == 'Sistemas' || asignado == 'Mantenimiento');
      }).toList();

      return proyectos;
    }
  } else {
    throw Exception('Error al cargar proyectos desde Airtable');
  }
  return [];
}

    Future<void> _recargarProyectos() async {
    setState(() {
      _isLoading = true; // Mostrar animación de carga
    });

    try {
      final proyectos = await _loadProyectos();
      setState(() {
        _proyectos = proyectos;
      });
    } catch (e) {
      print('Error al recargar proyectos: $e');
    } finally {
      setState(() {
        _isLoading = false; // Ocultar animación de carga
      });
    }
  }

  Future<bool> _showLoginDialog(BuildContext context) async {
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
                Navigator.of(context).pop(false); // Retorna false al cerrar el diálogo
              },
            ),
            TextButton(
              child: const Text('Aceptar'),
              onPressed: () {
                final username = usernameController.text;
                final password = passwordController.text;

                if (username == 'sistemas' && password == 'TiGpoVisa**') {
                  Navigator.of(context).pop(true); // Retorna true al cerrar el diálogo
                } else {
                  _showErrorLoginDialog(context);
                }
              },
            ),
          ],
        );
      },
    ) ?? false; // Retorna false si el resultado es null
  }

  Future<void> _showConfirmationDialog(BuildContext context, Map<String, dynamic> proyecto) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmación'),
          content: const Text('¿Está seguro de iniciar la orden de trabajo?'),
          actions: <Widget>[
            TextButton(
              child: const Text('No'),
              onPressed: () {
                Navigator.of(context).pop(false); // Cerrar el diálogo y devolver false
              },
            ),
            TextButton(
              child: const Text('Sí'),
              onPressed: () {
                Navigator.of(context).pop(true); // Cerrar el diálogo y devolver true
              },
            ),
          ],
        );
      },
    );

    if (result == true) {
      await _actualizarEstadoProyecto(proyecto);
      await _showSuccessDialog(context);
      await _recargarProyectos(); // Recargar la lista de proyectos después de iniciar la orden
    }
  }

  Future<void> _actualizarEstadoProyecto(Map<String, dynamic> proyecto) async {
  final recordId = proyecto['recordId']; // Asegúrate de que tienes el ID del registro
  final url = '$airtableApiBaseUrl/v0/$airtableBaseId/$airtableTableName/$recordId';
  final headers = {
    'Authorization': 'Bearer $airtableApiToken',
    'Content-Type': 'application/json',
  };

  // Obtener la fecha y hora actual
  final now = DateTime.now();
  final horaInicio = '${now.day}/${now.month}/${now.year} ${now.hour}:${now.minute}${now.hour >= 12 ? 'pm' : 'am'}';

  // El nuevo estado que deseas actualizar
  final body = jsonEncode({
    'fields': {
      'Estado': 'Trabajando',
      'Hora de Inicio': horaInicio, // Actualizar la celda "Hora de Inicio"
    },
  });

  // Actualizar el estado en Airtable
  final response = await http.patch(
    Uri.parse(url),
    headers: headers,
    body: body,
  );

  if (response.statusCode == 200) {
    // Si la actualización en Airtable es exitosa, actualiza el estado localmente
    setState(() {
      // Encuentra el proyecto correspondiente en la lista y actualiza su estado
      final index = _proyectos.indexWhere((p) => p['recordId'] == recordId);
      if (index != -1) {
        _proyectos[index]['Estado'] = 'Trabajando';
        _proyectos[index]['Hora de Inicio'] = horaInicio; // Actualizar la celda "Hora de Inicio" localmente
      }
    });
          _sendEmail(proyecto);
  } else {
    // Manejo de errores en caso de que la actualización falle
    throw Exception('Error al actualizar el estado en Airtable');
  }
}

  void _sendEmail(Map<String, dynamic> proyecto) async {
    final String recipient = proyecto['Correo'] ?? 'sistemas@neuber.com.mx'; // Usa el correo de la celda o un valor por defecto
    final String subject = 'TU ORDEN DE TRABAJO ESTA SIENDO ATENDIDA';
    final String body = '''
Su orden de trabajo está siendo atendida por el área de sistemas.

Detalles de la orden:
Número: ${proyecto['Numero']}
Nombre OT: ${proyecto['NombreOT'] ?? ''}
Prioridad: ${proyecto['Prioridad'] ?? ''}
Área: ${proyecto['Area'] ?? ''}
Falla: ${proyecto['Falla'] ?? ''}
Estado: ${proyecto['Estado'] ?? ''}
Nombre Solicitante: ${proyecto['Nombre Solicitante'] ?? ''}
Hora Enviada: ${proyecto['Hora Enviada'] ?? ''}

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

  String encodeQueryParameters(Map<String, String> params) {
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
          content: const Text('La orden de trabajo ha sido iniciada con éxito.'),
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

  @override
  void initState() {
    super.initState();
    _recargarProyectos(); // Cargar los proyectos al iniciar el widget
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
          title: const Text('Órdenes de Trabajo Pendientes', style: TextStyle(color: Colors.white)),
          backgroundColor: const Color(0xFF313745),
        ),
        body: _isLoading
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
                          DataColumn(label: Text('Acciones')),
                          DataColumn(label: Text('Numero')),
                          DataColumn(label: Text('NombreOT')),
                          DataColumn(label: Text('Prioridad')),
                          DataColumn(label: Text('Area')),
                          DataColumn(label: Text('Falla')),
                          DataColumn(label: Text('Estado')),
                          DataColumn(label: Text('Nombre Solicitante')),
                          DataColumn(label: Text('Hora Enviada')),
                        ],
                        rows: _proyectos.map<DataRow>((proyecto) {
                          return DataRow(
                            cells: [
                              DataCell(
                                ElevatedButton(
                                  onPressed: () async {
                                    bool isLoginSuccessful = await _showLoginDialog(context);
                                    if (isLoginSuccessful) {
                                      await _showConfirmationDialog(context, proyecto);
                                    }
                                  },
                                  child: Text('Iniciar orden'),
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
