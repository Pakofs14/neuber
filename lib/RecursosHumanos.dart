import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_selector/file_selector.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:neuber/EditarRH.dart';
import 'package:neuber/EliminarRH.dart';
import 'package:neuber/SubirNominas.dart';


final airtableApiToken =
    'patTjJNwpD104BTKG.9352a6a8b38ce585bc3b55de8667ef8e81800fc5cde77e95a95398447a4ca604';
final airtableBaseId = 'appHba5WGxI7G7VDA';
final airtableTableName = 'Correos';
final airtableApiBaseUrl = 'https://api.airtable.com';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recursos Humanos',
      home: const RecursosHumanosPage(),
    );
  }
}

class RecursosHumanosPage extends StatefulWidget {
  const RecursosHumanosPage({Key? key}) : super(key: key);

  @override
  _RecursosHumanosPageState createState() => _RecursosHumanosPageState();
}

class _RecursosHumanosPageState extends State<RecursosHumanosPage> {

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

Future<void> sendEmail(BuildContext context) async {
  final url = Uri.parse("https://api.emailjs.com/api/v1.0/email/send");
  const serviceId = "service_35bsogt";
  const templateId = "template_19wb3pe";
  const userId = "CXEpCaTlay0ECcgSU"; // Aquí debes proporcionar tu userId

  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: json.encode({
      "service_id": serviceId,
      "template_id": templateId,
      "user_id": userId, // Asegúrate de proporcionar el userId aquí
      "template_params": {
        "name": "Trabajador Neuber",
        "subject": "Correo de prueba",
        "message": "Hola soy el correo de prueba",
        "user_email": "pakofs14@gmal.com",
      }
    }),
  );

  if (response.statusCode == 200) {
    // El correo electrónico se envió correctamente
    print("Correo electrónico enviado correctamente.");
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Éxito"),
          content: Text("Correo electrónico enviado correctamente"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Aceptar"),
            ),
          ],
        );
      },
    );
  } else {
    // Hubo un error al enviar el correo electrónico
    print("Error al enviar el correo electrónico: ${response.statusCode}");
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Error"),
          content: Text("Error al enviar el correo electrónico: ${response.statusCode}"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Aceptar"),
            ),
          ],
        );
      },
    );
  }
}

 @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text(
        'Recursos Humanos',
        style: TextStyle(
          color: Colors.white,
        ),
      ),
      backgroundColor: Color(0xFF313745),
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
      actions: <Widget>[
                IconButton(
          icon: Icon(Icons.upload, color: Colors.white),
          onPressed: () {
            _navigateToSubirNominaPage(context);
          },
        ),
        IconButton(
          icon: Icon(Icons.add, color: Colors.white),
          onPressed: () {
            _showUploadRFCDialog(context);
          },
        ),
        IconButton(
          icon: Icon(Icons.edit, color: Colors.white),
          onPressed: () {
            _navigateToEditarRHPage(context);
          },
        ),
        IconButton(
          icon: Icon(Icons.delete, color: Colors.white),
          onPressed: () {
            _navigateToEliminarRHPage(context);
          },
        ),
      ],
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
                DataColumn(label: Text('RFC')),
                DataColumn(label: Text('Correo')),
                DataColumn(label: Text('Nombre')),
              ],
              rows: correos.map<DataRow>((proyecto) {
                return DataRow(
                  cells: [
                    DataCell(Text(proyecto['RFC'].toString())),
                    DataCell(Text(proyecto['Correo'].toString())),
                    DataCell(Text(proyecto['Nombre'].toString())),
                  ],
                );
              }).toList(),
            ),
            
          ElevatedButton(
            onPressed: () async {
              final typeGroup = XTypeGroup(
                label: 'Archivos PDF',
                extensions: ['pdf'],
              );
              final files = await openFiles(acceptedTypeGroups: [typeGroup]);
              if (files.isNotEmpty) {
                final pdfFileNames = files.map((file) => file.name).toList();
                _showFileListDialog(context, pdfFileNames);
              } else {
                print('Usuario canceló la selección de archivos.');
              }
            },
            child: Text('Seleccionar archivos PDF'),
          ),
          SizedBox(height: 20),
        ],
      ),
    ),
  );
}

void _showUploadRFCDialog(BuildContext context) {
  String rfc = '';
  String correo = '';
  String nombre = '';
  TextEditingController rfcController = TextEditingController();
  TextEditingController correoController = TextEditingController();
  TextEditingController nombreController = TextEditingController();
  bool rfcError = false;
  bool correoError = false;
  bool nombreError = false;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            title: Text('Subir un nuevo RFC'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: rfcController,
                  onChanged: (value) {
                    setState(() {
                      rfc = value;
                      rfcError = false;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'RFC',
                    errorText: rfcError ? 'Validar información' : null,
                    errorStyle: TextStyle(color: Colors.red),
                  ),
                ),
                TextField(
                  controller: correoController,
                  onChanged: (value) {
                    setState(() {
                      correo = value;
                      correoError = false;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Correo',
                    errorText: correoError ? 'Validar información' : null,
                    errorStyle: TextStyle(color: Colors.red),
                  ),
                ),
                TextField(
                  controller: nombreController,
                  onChanged: (value) {
                    setState(() {
                      nombre = value;
                      nombreError = false;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Nombre',
                    errorText: nombreError ? 'Validar información' : null,
                    errorStyle: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () async {
                  bool isValid = true;
                  if (rfc.length != 13) {
                    setState(() {
                      rfcError = true;
                    });
                    isValid = false;
                  }
                  if (!correo.contains('@') || !correo.contains('.')) {
                    setState(() {
                      correoError = true;
                    });
                    isValid = false;
                  }
                  if (!RegExp(r'^[a-zA-Z ]+$').hasMatch(nombre)) {
                    setState(() {
                      nombreError = true;
                    });
                    isValid = false;
                  }
                  if (isValid) {
                    // Aquí llamas a la función para mostrar el diálogo de confirmación
                    bool confirmacion = await _showConfirmationDialog(context, rfc, correo, nombre) ?? false;
                    if (confirmacion) {
                      await _saveDataToAirtable({
                        'RFC': rfc,
                        'Correo': correo,
                        'Nombre': nombre,
                      }, context);
                      Navigator.of(context).pop();
                    }
                  }
                },
                child: Text('Subir'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Cancelar'),
              ),
            ],
          );
        },
      );
    },
  );
}

Future<bool?> _showConfirmationDialog(BuildContext context, String rfc, String correo, String nombre) async {
  return showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Confirmación'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('¿Son correctos los datos que estas a punto de ingresar?'),
            SizedBox(height: 10),
            Text('RFC: $rfc'),
            Text('Correo: $correo'),
            Text('Nombre: $nombre'),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false); // Si el usuario no confirma, retorna false
            },
            child: Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true); // Si el usuario confirma, retorna true
            },
            child: Text('Sí'),
          ),
        ],
      );
    },
  );
} 

Future<void> _saveDataToAirtable(Map<String, dynamic> data, BuildContext context) async {


  // Si todas las validaciones pasan, continúa guardando los datos en Airtable
  final url = '$airtableApiBaseUrl/v0/$airtableBaseId/$airtableTableName';
  final headers = {
    'Authorization': 'Bearer $airtableApiToken',
    'Content-Type': 'application/json',
  };

  final response = await http.post(
    Uri.parse(url),
    headers: headers,
    body: jsonEncode({
      'fields': data,
    }),
  );

  if (response.statusCode == 200) {
    // Recargar los datos después de subir un nuevo RFC
    _loadCorreos();
  }
}

void _showFileListDialog(BuildContext context, List<String> fileNames) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Archivos PDF seleccionados (${fileNames.length})'), // Concatena el número de archivos seleccionados al título
        content: SizedBox(
          height: 200,
          width: double.maxFinite,
          child: ListView.builder(
            itemCount: fileNames.length,
            itemBuilder: (BuildContext context, int index) {
              return ListTile(
                title: Text(fileNames[index]),
                leading: IconTheme(
                  data: IconThemeData(color: Colors.red),
                  child: Icon(Icons.picture_as_pdf),
                ),
              );
            },
          ),
        ),
        actions: <Widget>[
          ElevatedButton(
  onPressed: () async {
    await sendEmail(context); // Asegúrate de llamar a la función con paréntesis y usar await para esperar su finalización
  },
  child: Text('Enviar Nominas'),
),

          TextButton(
            onPressed: () {
              _showCoincidenciasDialog(context, fileNames); // Llamar a la nueva función
            },
            child: Text('Comprobar Archivos'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cerrar'),
          ),
        ],
      );
    },
  );
}

void _showCoincidenciasDialog(BuildContext context, List<String> fileNames) {
  int totalArchivosSeleccionados = fileNames.length;
  int totalRegistros = correos.length;
  int totalCoincidencias = 0;
  List<String> coincidenciasEncontradas = [];

  // Comparar los RFC de Airtable con los nombres de los archivos PDF seleccionados
  for (String fileName in fileNames) {
    for (Map<String, dynamic> correo in correos) {
      if (fileName.contains(correo['RFC'])) {
        totalCoincidencias++;
        coincidenciasEncontradas.add(fileName);
        break;
      }
    }
  }

  // Calcular las coincidencias no encontradas
  int coincidenciasNoEncontradas = totalArchivosSeleccionados - totalCoincidencias;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Resumen de coincidencias'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total de archivos seleccionados: $totalArchivosSeleccionados'),
            Text('Total de registros en la base de datos: $totalRegistros'),
            Text('Total de coincidencias: $totalCoincidencias'),
            Text('Coincidencias no encontradas: $coincidenciasNoEncontradas'),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cerrar'),
          ),
        ],
      );
    },
  );
}

void _navigateToEditarRHPage(BuildContext context) {
  Navigator.of(context).push(
    PageRouteBuilder(
      transitionDuration: Duration(milliseconds: 500), // Puedes ajustar la duración según tus preferencias
      pageBuilder: (_, __, ___) => EditarRHPage(),
      transitionsBuilder: (_, Animation<double> animation, __, Widget child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    ),
  );
}

void _navigateToEliminarRHPage(BuildContext context) {
  Navigator.of(context).push(
    PageRouteBuilder(
      transitionDuration: Duration(milliseconds: 500), // Puedes ajustar la duración según tus preferencias
      pageBuilder: (_, __, ___) => EliminarRHPage(),
      transitionsBuilder: (_, Animation<double> animation, __, Widget child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    ),
  );
}

void _navigateToSubirNominaPage(BuildContext context) {
  Navigator.of(context).push(
    PageRouteBuilder(
      transitionDuration: Duration(milliseconds: 500), // Puedes ajustar la duración según tus preferencias
      pageBuilder: (_, __, ___) => SubirNominasPage(),
      transitionsBuilder: (_, Animation<double> animation, __, Widget child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    ),
  );
}


}