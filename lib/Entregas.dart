import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:intl/intl.dart';

final airtableApiToken =
    'patTjJNwpD104BTKG.9352a6a8b38ce585bc3b55de8667ef8e81800fc5cde77e95a95398447a4ca604';
final airtableApiBaseUrl = 'https://api.airtable.com';
final airtableBaseId = 'appHba5WGxI7G7VDA';
final airtableTableName = 'Proyectos';

void main() => runApp(MaterialApp(home: EntregasPage()));

class EntregasPage extends StatefulWidget {
  @override
  _EntregasPageState createState() => _EntregasPageState();
}

class _EntregasPageState extends State<EntregasPage> {
  late int AvanceProyecto1, RestanteProyecto1;
  late DateTime fechaInicio, fechaEntrega;
  late String nombre;
  final _usernameController = TextEditingController();
final _passwordController = TextEditingController();

@override
void initState() {
 super.initState();
 fetchAirtableData().then((data) {
 setState(() {
    AvanceProyecto1 = data[0]['AvanceProyecto1'];
    RestanteProyecto1 = data[0]['RestanteProyecto1'];
    fechaInicio = data[0]['fechaInicio'];
    fechaEntrega = data[0]['fechaEntrega'];
    // Aquí puedes asignar el valor de 'piezas' a una variable de estado si es necesario
 });
 }).catchError((error) {
 // Maneja el error aquí
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

 // Filtra los registros proyectos en linea"
 if (fields['En Linea'] == 'Verdadero') {
   int AvanceProyecto1 = fields['Entregados'];
   int RestanteProyecto1 = fields['Restante Entregados'];
   DateTime fechaInicio = fields['Fecha de inicio'] == null || fields['Fecha de inicio'].isEmpty
 ? DateTime.now() // O cualquier otro valor predeterminado que desees
 : DateTime.parse(fields['Fecha de inicio']);

DateTime fechaEntrega = fields['Fecha de fin'] == null || fields['Fecha de fin'].isEmpty
 ? DateTime.now() // O cualquier otro valor predeterminado que desees
 : DateTime.parse(fields['Fecha de fin']);

   String nombre = fields['Nombre del Proyecto'];
   String nota = fields['Nota Entregados']; 
   String hora = fields['Hora'] ?? 'No disponible'; // En lugar de 'hora'
   
   result.add({
     'id': record['id'], // Agrega el ID del registro
     'AvanceProyecto1': AvanceProyecto1,
     'RestanteProyecto1': RestanteProyecto1,
     'fechaInicio': fechaInicio,
     'fechaEntrega': fechaEntrega,
     'nombre': nombre,
     'nota': nota, // Agrega esta línea
     'hora': hora, 
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
        return SizedBox(
          height: 60.0,
          width: 60.0,
          child: SpinKitFadingCircle(
            color: Colors.black,
            size: 60.0,
          ),
        );
      } else if (snapshot.hasError) {
        return Text('Error: ${snapshot.error}');
      } else {
        if (snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search,
                  size: 100,
                  color: Colors.grey,
                ),
                Text(
                  'No se encontraron proyectos en línea',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 20,
                    decoration: TextDecoration.none, // Elimina el subrayado
                  ),
                ),
              ],
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
    int AvanceProyecto1 = record['AvanceProyecto1'];
    int RestanteProyecto1 = record['RestanteProyecto1'];
    DateTime fechaInicio = record['fechaInicio'];
    DateTime fechaEntrega = record['fechaEntrega'];
    String nombre = record['nombre'];

    charts.add(_buildPieChart(
      context,
      nombre,
      AvanceProyecto1,
      RestanteProyecto1,
      record,
      onPressed: () {},
      customOnPressed: () {
        _showCustomInfoDialog(
          context,
          title: 'Info ',
          projectData: record, // Cambia data por record
        );
      },
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
      'Proyectos para Entregas',
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

DateTime _getFechaInicio(String fechaInicio) {
 return DateTime.parse(fechaInicio);
}

DateTime _getFechaEntrega(String fechaEntrega) {
 return DateTime.parse(fechaEntrega);
}

Widget _buildPieChart(
 BuildContext context,
 String title,
 int value1,
 int value2,
 Map<String, dynamic> data, // Agrega los datos de la gráfica como un parámetro
 {
  required VoidCallback onPressed,
  VoidCallback? customOnPressed,
  required double cardHeight,
  required double cardWidth,
  required DateTime fechaInicio,
  required DateTime fechaEntrega,
  required String targetPage,
 }
) {
 //...
 DateTime _fechaInicio = fechaInicio;
 DateTime _fechaEntrega = fechaEntrega;
 //...
 DateTime fechaActual = DateTime.now();

  Color circleColor;
  if (fechaActual.isBefore(fechaInicio)) {
    circleColor = Colors.blue; // Si es antes de la fecha de inicio, gris
  } else if (fechaActual.isBefore(fechaEntrega.subtract(Duration(days: 7)))) {
    circleColor = Colors.green; // Si falta más de una semana, verde
  } else if (fechaActual.isBefore(fechaEntrega)) {
    circleColor = Colors.yellow; // Si falta una semana o menos, amarillo
  } else {
    circleColor = Colors.red; // Si ya pasó la fecha de entrega, rojo
  }

  double screenWidth = MediaQuery.of(context).size.width;
  double textScaleFactor = screenWidth / 950;
  double iconScaleFactor = screenWidth / 950;

  final Color color1 = Colors.green;
  final Color color2 =
      (value1 / (value1 + value2) < 0.75) ? Colors.red : Colors.yellow;

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

  // Sección para el valor 1
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
        value: 0.001, // Valor muy pequeño para representar el segmento
        color: color1,
        title: '0', // Mostrar 0.001 en lugar de 0
        radius: radius * 1,
      ),
    );
  }

  // Sección para el valor 2
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
        value: 0.001, // Valor muy pequeño para representar el segmento
        color: color2,
        title: '0', // Mostrar 0.001 en lugar de 0
        radius: radius * 1,
      ),
    );
  }



  return Material(
    child: InkWell(
      onTap: () {},
      onLongPress: () {
        _showDetailDialog(context, data);
      },
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
                  onTap: () {
                    _showDaysRemainingDialog(fechaEntrega);
                  },
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
                            IconButton(
                              icon: Icon(Icons.info, size: _calculateIconSize(iconScaleFactor)),
                              onPressed: customOnPressed ?? onPressed,
                            ),
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
                      'Fecha de Inicio ${_fechaInicio.day}/${_fechaInicio.month}/${_fechaInicio.year}',
                      style: TextStyle(
                        fontSize: labelTextFontSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Fecha de Entrega ${_fechaEntrega.day}/${_fechaEntrega.month}/${_fechaEntrega.year}',
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

Future<void> updateAirtableRecord(String id, Map<String, dynamic> fields) async {
 final response = await http.patch(
   Uri.parse('$airtableApiBaseUrl/v0/$airtableBaseId/$airtableTableName/$id'),
   headers: {
     'Authorization': 'Bearer $airtableApiToken',
     'Content-type': 'application/json',
   },
   body: jsonEncode({
     'fields': fields,
   }),
 );

 if (response.statusCode != 200) {
   throw Exception('Failed to update record: ${response.body}');
 }
}

void _showLoginDialog(BuildContext context, Map<String, dynamic> data) {
 showDialog(
   context: context,
   builder: (BuildContext context) {
     return AlertDialog(
       title: Text('Iniciar Sesión'),
       content: SingleChildScrollView(
         child: ListBody(
           children: <Widget>[
             TextField(
 controller: _usernameController,
 decoration: InputDecoration(labelText: 'Usuario'),
),
TextField(
 controller: _passwordController,
 decoration: InputDecoration(labelText: 'Contraseña'),
 obscureText: true,
),

           ],
         ),
       ),
       actions: <Widget>[
         TextButton(
 child: Text('Iniciar Sesión'),
 onPressed: () {
   String username = _usernameController.text;
   String password = _passwordController.text;

   // Comprueba las credenciales aquí
   if (username == 'jenifer' && password == '3486') {
     Navigator.of(context).pop();
     _showEditDialog(context, data);
   } else {
     // Muestra un mensaje de error si las credenciales son incorrectas
     ScaffoldMessenger.of(context).showSnackBar(
       SnackBar(content: Text('Usuario o contraseña incorrectos')),
     );
   }
 },
),

       ],
     );
   },
 );
}

void _showLoginDialogNota(BuildContext context, Map<String, dynamic> data) {
 showDialog(
   context: context,
   builder: (BuildContext context) {
     return AlertDialog(
       title: Text('Iniciar Sesión'),
       content: SingleChildScrollView(
         child: ListBody(
           children: <Widget>[
             TextField(
               controller: _usernameController,
               decoration: InputDecoration(labelText: 'Usuario'),
             ),
             TextField(
               controller: _passwordController,
               decoration: InputDecoration(labelText: 'Contraseña'),
               obscureText: true,
             ),
           ],
         ),
       ),
       actions: <Widget>[
         TextButton(
           child: Text('Iniciar Sesión'),
           onPressed: () {
             String username = _usernameController.text;
             String password = _passwordController.text;

             // Comprueba las credenciales aquí
             if (username == 'jenifer' && password == '3486') {
               Navigator.of(context).pop();
               _showEditInfoDialog(context, data['id']); // Call _showEditInfoDialog here
             } else {
               // Muestra un mensaje de error si las credenciales son incorrectas
               ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Usuario o contraseña incorrectos')),
               );
             }
           },
         ),
       ],
     );
   },
 );
}

void _showDetailDialog(BuildContext context, Map<String, dynamic> data) {
 showDialog(
  context: context,
  builder: (BuildContext context) {
    return AlertDialog(
      title: Text('Detalles de la Gráfica'),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            Text('Nombre: ${data['nombre']}'),
            Text('Avance: ${data['AvanceProyecto1']}'),
            Text('Restante: ${data['RestanteProyecto1']}'),
            Text('Última actualización: ${data['hora']}'),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
 child: Text('Editar'),
 onPressed: () {
   Navigator.of(context).pop();
   _showLoginDialog(context, data);
 },
),

        TextButton(
          child: Text('Cerrar'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  },
 );
}

void _showEditDialog(BuildContext context, Map<String, dynamic> data) {
  int restanteSoldadura = data['RestanteProyecto1'];
  int piezasTerminadas = 0;

  TextEditingController textFieldController = TextEditingController();

  ScaffoldMessengerState scaffoldMessenger = ScaffoldMessenger.of(context);

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Editar Piezas Terminadas'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: textFieldController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                errorText: (piezasTerminadas > restanteSoldadura)
                    ? 'El valor no puede ser mayor que Restante .'
                    : null,
              ),
              onChanged: (value) {
                if (value.isNotEmpty) {
                  int parsedValue = int.tryParse(value) ?? 0;
                  piezasTerminadas = parsedValue;
                } else {
                  piezasTerminadas = 0;
                }
              },
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            child: Text('Aceptar'),
            onPressed: () {
              String formattedDateTime = DateFormat('yyyy-MM-dd hh:mm a').format(DateTime.now());
              if (piezasTerminadas <= restanteSoldadura) {
                int avanceProyecto1 = data['AvanceProyecto1'] + piezasTerminadas;
                int restanteProyecto1 = data['RestanteProyecto1'] - piezasTerminadas;

                // Validar que Soldadura no sea negativo
                if (avanceProyecto1 >= 0) {
                  Navigator.of(context).pop();
                  _showUpdatedDialog(context, data, avanceProyecto1, restanteProyecto1);
                  // Actualiza el registro en Airtable
                  updateAirtableRecord(data['id'], {
                    'Entregados': avanceProyecto1,
                    'Restante Entregados': restanteProyecto1,
                    'Hora': 'Fecha: $formattedDateTime',
                  });
                } else {
                  // Muestra un SnackBar con el mensaje de error
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text('El valor ingresado hace que el valor sea negativo.'),
                    ),
                  );
                }
              } else {
                // Muestra un SnackBar con el mensaje de error
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text('El valor no puede ser mayor al real'),
                  ),
                );
              }
            },
          ),
          TextButton(
            child: Text('Cancelar'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

void _showDaysRemainingDialog(DateTime fechaEntrega) {
    DateTime fechaActual = DateTime.now();
    int daysRemaining = fechaEntrega.difference(fechaActual).inDays;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Días Restantes'),
          content: Text('Faltan $daysRemaining días para la entrega.'),
          actions: [
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

void _showCustomInfoDialog(BuildContext context, {required String title, required Map<String, dynamic> projectData}) {
 showDialog(
   context: context,
   builder: (BuildContext context) {
     return AlertDialog(
       title: Text(title),
       content: Text('Nota: ${projectData['nota']}'), // Muestra la información de la celda "Nota"
       actions: [
         TextButton(
           onPressed: () {
             Navigator.of(context).pop();
             _showLoginDialogNota(context, projectData); // Call _showLoginDialogNota here
           },
           child: Text('Editar'),
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

void _showEditInfoDialog(BuildContext context, String recordId) {
  TextEditingController textController = TextEditingController();

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Editar Nota'),
        content: TextField(
          controller: textController,
          maxLines: null,
          expands: true,
          decoration: InputDecoration(hintText: 'Escribe un texto aquí'),
        ),
        actions: [
          TextButton(
            onPressed: () async {
               String newNote = textController.text;
              // Append the current date to the note
              DateFormat formatter = DateFormat('yyyy-MM-dd');
              String formattedDate = formatter.format(DateTime.now());
              newNote += '\n\nFecha: $formattedDate \nEditado por: Jenifer';
              Navigator.of(context).pop();

              // Actualiza el registro en Airtable
              await updateAirtableRecord(recordId, {'Nota Entregados': newNote});

            },
            
            child: Text('Aceptar'),
            
          ),
        ],
      );
      
    },
    
  );
}

void _showUpdatedDialog(BuildContext context, Map<String, dynamic> data, int avanceProyecto1, int restanteProyecto1) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Gráfica Actualizada'),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text('Nombre: ${data['nombre']}'),
              Text('Avance: $avanceProyecto1'),
              Text('Restante: $restanteProyecto1'),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text('Cerrar'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );

  // Comprobación fuera del showDialog original
  if (restanteProyecto1 == 0) {
    print('La condición para mostrar el diálogo de felicitaciones se cumple.');
    _sendAirtable(context, data);
    _showCongratulationsDialog(context, data);
  }
}

void _showCongratulationsDialog(BuildContext context, Map<String, dynamic> data) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('¡Felicidades!'),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text('¡Felicidades!'),
              Text('Has completado el proyecto ${data['nombre']}.'),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text('Cerrar'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

void _sendAirtable(BuildContext context, Map<String, dynamic> projectData) async {
  final parentContext = context;
  try {
    await sendProjectToHistorico(
      apiToken: 'patBvCbD6U2fVpWpL.d5336593f726634610f36dd78f76a50600199b264687cfbac16c7834cc844dae',
      baseId: 'appKMQjDm0niVdfdV',
      tableName: 'Historico',
      projectData: {
        'nombre': projectData['nombre'],
        'AvanceProyecto1': projectData['Entregados'], // Cambia projectData['AvanceProyecto1'] por projectData['Entregados']
        'fechaInicio': projectData['fechaInicio'].toIso8601String(),
        'fechaEntrega': projectData['fechaEntrega'].toIso8601String(),
      },
    );

    // Eliminar el registro del proyecto completado
    await deleteProjectFromAirtable('patTjJNwpD104BTKG.9352a6a8b38ce585bc3b55de8667ef8e81800fc5cde77e95a95398447a4ca604', 'appHba5WGxI7G7VDA', 'Proyectos', projectData['nombre']);
  } catch (e) {
    print('Error al enviar datos a Airtable: $e');
    ScaffoldMessenger.of(parentContext).showSnackBar(
      SnackBar(
        content: Text('Error al enviar datos a Airtable: $e'),
      ),
    );
  }
}

Future<void> sendProjectToHistorico({
  required String apiToken,
  required String baseId,
  required String tableName,
  required Map<String, dynamic> projectData,
}) async {
  final url = Uri.parse('https://api.airtable.com/v0/$baseId/$tableName');

  final response = await http.post(
    url,
    headers: {
      'Authorization': 'Bearer $apiToken',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'fields': {
        'Nombre del Proyecto': projectData['nombre'],
        'Piezas': projectData['Entregados'],
        'Fecha de inicio': projectData['fechaInicio'],
        'Fecha de entrega': projectData['fechaEntrega'],
      },
    }),
  );

  if (response.statusCode != 200) {
    throw Exception('Failed to send project to Historico: ${response.body}');
  }
}

Future<void> deleteProjectFromAirtable(String apiToken, String baseId, String tableName, String projectName) async {
  final url = Uri.parse('https://api.airtable.com/v0/$baseId/$tableName');

  final response = await http.get(
    url,
    headers: {
      'Authorization': 'Bearer $apiToken',
    },
  );

  if (response.statusCode == 200) {
    final records = jsonDecode(response.body)['records'] as List;
    final record = records.firstWhere((record) => record['fields']['Nombre del Proyecto'] == projectName, orElse: () => null);

    if (record != null) {
      final recordId = record['id'];
      final deleteUrl = Uri.parse('https://api.airtable.com/v0/$baseId/$tableName/$recordId');

      final deleteResponse = await http.delete(
        deleteUrl,
        headers: {
          'Authorization': 'Bearer $apiToken',
        },
      );

      if (deleteResponse.statusCode != 200) {
        throw Exception('Failed to delete project from Airtable: ${deleteResponse.body}');
      }
    } else {
      print('No se encontró el proyecto con nombre $projectName.');
    }
  } else {
    throw Exception('Failed to retrieve projects from Airtable: ${response.body}');
  }
}

}