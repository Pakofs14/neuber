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

class HistoricoPage extends StatefulWidget {
 const HistoricoPage({Key? key}) : super(key: key);

 @override
 _HistoricoPageState createState() => _HistoricoPageState();
}

class _HistoricoPageState extends State<HistoricoPage> {
 final airtableApiToken =
'patBvCbD6U2fVpWpL.d5336593f726634610f36dd78f76a50600199b264687cfbac16c7834cc844dae';
 final airtableApiBaseUrl = 'https://api.airtable.com';
 final airtableBaseId = 'appKMQjDm0niVdfdV';
 final airtableTableName = 'Historico';

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

 final response = await http.get(
    Uri.parse(url),
    headers: headers,
 );

 if (response.statusCode == 200) {
    final decodedData = jsonDecode(response.body) as Map<String, dynamic>;
    if (decodedData.containsKey('records')) {
      setState(() {
        proyectos = List<Map<String, dynamic>>.from(
          decodedData['records'].map((record) => record['fields']),
        );
      });
    }
 } else {
    print('Error al cargar proyectos desde Airtable. Código: ${response.statusCode}, Mensaje: ${response.body}');
    // Manejar el error según tus necesidades
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
        title: const Text('Histórico', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF313745),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: [
              DataColumn(label: Text('Nombre del Proyecto')),
              DataColumn(label: Text('Piezas')),
              DataColumn(label: Text('Fecha de inicio')),
              DataColumn(label: Text('Fecha de fin')),
              DataColumn(label: Text('Entregados')),
              DataColumn(label: Text('Foto')),
            ],
            rows: proyectos.map<DataRow>((proyecto) {
              return DataRow(
                cells: [
                  DataCell(Text(proyecto['Nombre del Proyecto'].toString())),
                  DataCell(Text(proyecto['Piezas'].toString())),
                  DataCell(Text(proyecto['Fecha de inicio'].toString())),
                  DataCell(Text(proyecto['Fecha de fin'].toString())),
                  DataCell(Text(proyecto['Entregados'].toString())),
                  DataCell(
                    IconButton(
                      icon: Icon(Icons.camera_alt),
                      onPressed: () {
      List<dynamic>? photoAttachments = proyecto['Foto'] as List<dynamic>?;
      if (photoAttachments != null && photoAttachments.isNotEmpty) {
        // Asume que cada adjunto es un objeto con una propiedad 'url'
        String? firstPhotoUrl = photoAttachments.first['url'] as String?;
        if (firstPhotoUrl != null) {
          _showPhotoDialog(firstPhotoUrl);
        } else {
          // Muestra un AlertDialog informando que no se encontraron fotos
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('No se encontraron fotos para este proyecto'),
              actions: [
                TextButton(
                 onPressed: () {
                    Navigator.pop(context);
                 },
                 child: Text('Aceptar'),
                ),
              ],
            ),
          );
        }
      } else {
        // Muestra un AlertDialog informando que no se encontraron fotos
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('No se encontraron fotos para este proyecto'),
            actions: [
              TextButton(
                onPressed: () {
                 Navigator.pop(context);
                },
                child: Text('Aceptar'),
              ),
            ],
          ),
        );
      }
    },
 ),
),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    ),
  );
}
// Ajusta la función _showPhotoDialog para manejar listas de URLs
void _showPhotoDialog(String? photoUrl) {
 if (photoUrl == null || photoUrl.isEmpty) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('No se encontraron fotos para este proyecto'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Aceptar'),
          ),
        ],
      ),
    );
 } else {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Foto del Proyecto'),
        content: Image.network(
          photoUrl,
          loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
            if (loadingProgress == null) {
              return child;
            } else {
              return Center(
                child: CircularProgressIndicator(
                 value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                      : null,
                ),
              );
            }
          },
          errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
            return Text('No se pudo cargar la imagen');
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Aceptar'),
          ),
        ],
      ),
    );
 }
}


}