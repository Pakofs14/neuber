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

void main() => runApp(MaterialApp(home: LibPinturaPage()));

class LibPinturaPage extends StatefulWidget {
  @override
  _LibPinturaPageState createState() => _LibPinturaPageState();
}

class _LibPinturaPageState extends State<LibPinturaPage> {
  late int AvanceProyecto1, RestanteProyecto1;
  late DateTime fechaInicio, fechaEntrega;
  late String nombre;
      bool showAllGraphs = false; // Estado para controlar qué gráficas mostrar
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
    nombre = data[0]['nombre'];
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

 // Filtra los registros donde la línea es "Linea 1 y 2"
  if (fields['En Linea'] == 'Verdadero'&&((fields['Linea 1'] == 'Verdadero') ||(fields['Linea 2'] == 'Verdadero') ||(fields['Linea 3'] == 'Verdadero'))){
   int AvanceProyecto1 = fields['Liberados Pintura'];
   int RestanteProyecto1 = fields['Restante Liberados Pintura'];
   DateTime fechaInicio = fields['Fecha de inicio'] == null || fields['Fecha de inicio'].isEmpty
 ? DateTime.now() // O cualquier otro valor predeterminado que desees
 : DateTime.parse(fields['Fecha de inicio']);

DateTime fechaEntrega = fields['Fecha de fin'] == null || fields['Fecha de fin'].isEmpty
 ? DateTime.now() // O cualquier otro valor predeterminado que desees
 : DateTime.parse(fields['Fecha de fin']);

   String nombre = 'PINTURA ${fields['Nombre del Proyecto']}';
   String nota = fields['Nota Liberacion Pintura']; // Agrega esta línea
   String hora = fields['Hora'] ?? 'No disponible'; // En lugar de 'hora'

   result.add({
     'id': record['id'], // Agrega el ID del registro
     'AvanceProyecto1': AvanceProyecto1,
     'RestanteProyecto1': RestanteProyecto1,
     'fechaInicio': fechaInicio,
     'fechaEntrega': fechaEntrega,
     'nombre': nombre,
     'hora': hora,
     'nota': nota, // Agrega esta línea
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

    // Controlar si se deben mostrar todas las gráficas o solo las que tienen restante diferente de cero
    if (showAllGraphs || RestanteProyecto1 != 0) {
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
            projectData: record,
          );
        },
        cardHeight: 500,
        cardWidth: 300,
        fechaInicio: fechaInicio,
        fechaEntrega: fechaEntrega,
        targetPage: 'Proyecto1Page',
      ));
    }
  }

  return Scaffold(
    backgroundColor: Color(0xFFe5ecf4),
    appBar: AppBar(
      title: Text(
        'Liberación de Pintura',
        style: TextStyle(
          color: Colors.white,
        ),
      ),
      backgroundColor: Color(0xFF313745),
      actions: [
        IconButton(
          icon: Icon(Icons.remove_red_eye, color: Colors.green), // Icono de ojo verde
          onPressed: () {
            setState(() {
              showAllGraphs = true; // Mostrar todas las gráficas
            });
          },
        ),
        IconButton(
          icon: Icon(Icons.remove_red_eye_outlined, color: Colors.red), // Icono de ojo rojo
          onPressed: () {
            setState(() {
              showAllGraphs = false; // Mostrar solo gráficas con restante diferente de cero
            });
          },
        ),
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
  int value1, // Avance
  int value2, // Restante
  Map<String, dynamic> data,
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
  DateTime _fechaInicio = fechaInicio;
  DateTime _fechaEntrega = fechaEntrega;
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

  double total = value1.toDouble() + value2.toDouble();
  
  // Asegurarse de que el total no sea cero
  if (total == 0) {
    total = 0.001; // Asignar un valor pequeño para evitar la división por cero
  }

  double percentage1 = (value1.toDouble() / total) * 100;

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

// Sección para el Avance (value1)
if (value1 > 0) {
  sections.add(
    PieChartSectionData(
      value: value1.toDouble(),
      color: Colors.green,
      title: '$value1',
      radius: radius * 1,
    ),
  );
} else {
  // Si value1 es 0, agregar una sección mínima para mantener el formato de anillo
  sections.add(
    PieChartSectionData(
      value: 1, // Valor muy pequeño para mantener el formato de anillo
      color: Colors.red,
      title: '0', // Mostrar '0' en lugar de 1
      radius: radius * 1,
    ),
  );
}

// Sección para el Restante (value2)
if (value2 > 0) {
  sections.add(
    PieChartSectionData(
      value: value2.toDouble(),
      color: Colors.red,
      title: '$value2',
      radius: radius * 1,
    ),
  );
} else {
  // Si value2 es 0, agregar una sección mínima para mantener el formato de anillo
  sections.add(
    PieChartSectionData(
      value: 1, // Valor muy pequeño para mantener el formato de anillo
      color: Colors.green,
      title: '0', // Mostrar '0' en lugar de 1
      radius: radius * 1,
    ),
  );
}


  return Material(
    child: InkWell(
      onTap: onPressed,
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
                                '${percentage1.toStringAsFixed(2)}%',
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
                        if (value1 > 0)
                          Text(
                            'Total ',
                            style: TextStyle(
                              fontSize: labelTextFontSize,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        if (value1 > 0)
                          Container(
                            width: 20 * textScaleFactor,
                            height: 20 * textScaleFactor,
                            color: Colors.green,
                          ),
                        if (value2 > 0)
                          Text(
                            '          Restante ',
                            style: TextStyle(
                              fontSize: labelTextFontSize,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        if (value2 > 0)
                          Container(
                            width: 20 * textScaleFactor,
                            height: 20 * textScaleFactor,
                            color: Colors.red,
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
                if ((username == 'tomas' && password == '5020') ||
                 (username == 'roldan' && password == '9001') ||
                 (username == 'omar' && password == '6130')||
                 (username == 'antonio' && password == '2020')||
                 (username == 'maria' && password == '4589')) {
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
             if ((username == 'tomas' && password == '5020') ||
                 (username == 'roldan' && password == '9001') ||
                 (username == 'omar' && password == '6130')||
                 (username == 'antonio' && password == '2020')||
                 (username == 'maria' && password == '4589')
                 ) {
  Navigator.of(context).pop();
  _showEditInfoDialog(context, data['id']);
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
                    ? 'El valor no puede ser mayor que Restante Soldadura.'
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
                    'Liberados Pintura': avanceProyecto1,
                    'Restante Liberados Pintura': restanteProyecto1,
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

void _showUpdatedDialog(BuildContext context, Map<String, dynamic> data, int avanceProyecto1, int restanteProyecto1) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      // Diálogo de "Gráfica Actualizada"
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
              // Cerrar el cuadro de diálogo actual
              Navigator.of(context).pop();
              
              // Verificar si se debe mostrar el cuadro de diálogo de felicitaciones
              if (restanteProyecto1 == 0) {
                // Mostrar el cuadro de diálogo de felicitaciones después de cerrar el primero
                _showCongratulationsDialog(context);
              }
            },
          ),
        ],
      );
    },
  );
}

void _showCongratulationsDialog(BuildContext context) {
  // Diálogo de felicitaciones
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('¡Felicidades!'),
        content: Text('Haz completado todo el proceso.'),
        actions: <Widget>[
          TextButton(
            child: Text('Cerrar'),
            onPressed: () {
              // Cerrar el cuadro de diálogo de felicitaciones
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
              newNote += '\n\nFecha: $formattedDate \nEditado por Supervisor de Liberacion';
              Navigator.of(context).pop();

              // Actualiza el registro en Airtable
              await updateAirtableRecord(recordId, {'Nota Liberacion Pintura': newNote});

            },
            
            child: Text('Aceptar'),
            
          ),
        ],
      );
      
    },
    
  );
}

}