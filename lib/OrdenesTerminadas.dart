import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:pdf/widgets.dart' as pw;

class OrdenesTerminadasPage extends StatefulWidget {
  const OrdenesTerminadasPage({Key? key}) : super(key: key);

  @override
  _OrdenesTerminadasPageState createState() => _OrdenesTerminadasPageState();
}

class _OrdenesTerminadasPageState extends State<OrdenesTerminadasPage> {
  final airtableApiToken = 'patTjJNwpD104BTKG.9352a6a8b38ce585bc3b55de8667ef8e81800fc5cde77e95a95398447a4ca604';
  final airtableApiBaseUrl = 'https://api.airtable.com';
  final airtableBaseId = 'appHba5WGxI7G7VDA';
  final airtableTableName = 'OTSistemas';

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
        List<Map<String, dynamic>> proyectos =
            List<Map<String, dynamic>>.from(
          decodedData['records'].map((record) {
            var fields = record['fields'];
            fields['recordId'] = record['id'];
            return fields;
          }),
        );
        proyectos = proyectos
            .where((proyecto) => proyecto['Estado'].toString() == 'Finalizado')
            .toList();
        return proyectos;
      }
    } else {
      throw Exception('Error al cargar proyectos desde Airtable');
    }
    return [];
  }

  Future<void> _recargarProyectos() async {
    final proyectos = await _loadProyectos();
    setState(() {
      _proyectos = proyectos;
    });
  }

  @override
  void initState() {
    super.initState();
    _recargarProyectos();
  }

  Future<void> _mostrarDetalleOrden(BuildContext context, Map<String, dynamic> proyecto) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Detalles de la Orden de Trabajo'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('Número:', proyecto['Numero'].toString()),
                _buildDetailRow('Nombre OT:', proyecto['NombreOT'] ?? ''),
                _buildDetailRow('Tipo OT:', proyecto['Tipo OT'] ?? ''),
                _buildDetailRow('Prioridad:', proyecto['Prioridad'] ?? ''),
                _buildDetailRow('Área:', proyecto['Area'] ?? ''),
                _buildDetailRow('Falla:', proyecto['Falla'] ?? ''),
                _buildDetailRow('Estado:', proyecto['Estado'] ?? ''),
                _buildDetailRow('Nombre Solicitante:', proyecto['Nombre Solicitante'] ?? ''),
                _buildDetailRow('Hora Enviada:', proyecto['Hora Enviada'] ?? ''),
                _buildDetailRow('Hora de Inicio:', proyecto['Hora de Inicio'] ?? ''),
                _buildDetailRow('Hora de Fin:', proyecto['Hora de Fin'] ?? ''),
                _buildDetailRow('Trabajo Realizado:', proyecto['Trabajo Realizado'] ?? ''),
                _buildDetailRow('Refacciones Utilizadas:', proyecto['Refacciones Utilizadas'] ?? ''),
                _buildDetailRow('Causa Falla:', proyecto['Causa Falla'] ?? ''),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('Descargar orden de trabajo'),
              onPressed: () async {
                Navigator.of(context).pop(); // Cerrar el diálogo
                await _downloadOrderAsPDF(proyecto, context);
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

  Future<void> _downloadOrderAsPDF(Map<String, dynamic> proyecto, BuildContext context) async {
  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Detalles de la Orden de Trabajo', style: pw.TextStyle(fontSize: 20)),
            pw.SizedBox(height: 10),
            _buildPDFRow('Número:', proyecto['Numero'].toString()),
            _buildPDFRow('Nombre OT:', proyecto['NombreOT'] ?? ''),
            _buildPDFRow('Tipo OT:', proyecto['Tipo OT'] ?? ''),
            _buildPDFRow('Prioridad:', proyecto['Prioridad'] ?? ''),
            _buildPDFRow('Área:', proyecto['Area'] ?? ''),
            _buildPDFRow('Falla:', proyecto['Falla'] ?? ''),
            _buildPDFRow('Estado:', proyecto['Estado'] ?? ''),
            _buildPDFRow('Nombre Solicitante:', proyecto['Nombre Solicitante'] ?? ''),
            _buildPDFRow('Hora Enviada:', proyecto['Hora Enviada'] ?? ''),
            _buildPDFRow('Hora de Inicio:', proyecto['Hora de Inicio'] ?? ''),
            _buildPDFRow('Hora de Fin:', proyecto['Hora de Fin'] ?? ''),
            _buildPDFRow('Trabajo Realizado:', proyecto['Trabajo Realizado'] ?? ''),
            _buildPDFRow('Refacciones Utilizadas:', proyecto['Refacciones Utilizadas'] ?? ''),
            _buildPDFRow('Causa Falla:', proyecto['Causa Falla'] ?? ''),
          ],
        );
      },
    ),
  );

  final pdfData = await pdf.save();

  // Descargar el PDF
  final blob = html.Blob([pdfData], 'application/pdf');
  final url = html.Url.createObjectUrlFromBlob(blob);
  html.Url.revokeObjectUrl(url);

  // Mostrar un diálogo de éxito
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Descarga Exitosa'),
        content: Text('El PDF de la orden de trabajo se ha descargado exitosamente.'),
        actions: [
          TextButton(
            child: Text('Aceptar'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

  pw.Widget _buildPDFRow(String label, String value) {
    return pw.Padding(
      padding: pw.EdgeInsets.only(bottom: 5),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(label, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(width: 5),
          pw.Text(value),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(value, textAlign: TextAlign.right),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: const Text('Órdenes de Trabajo Finalizadas',
              style: TextStyle(color: Colors.white)),
          backgroundColor: const Color(0xFF313745),
        ),
        body: _proyectos.isEmpty
            ? Center(
                child: SpinKitFadingCircle(
                  color: Colors.black,
                  size: 60.0,
                ),
              )
            : SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: [
                      DataColumn(label: Text('Numero')),
                      DataColumn(label: Text('NombreOT')),
                      DataColumn(label: Text('Nombre Solicitante')),
                      DataColumn(label: Text('Area')),
                      DataColumn(label: Text('Acciones')),
                    ],
                    rows: _proyectos.map<DataRow>((proyecto) {
                      return DataRow(
                        cells: [
                          DataCell(Text(proyecto['Numero'].toString()), onTap: () => _mostrarDetalleOrden(context, proyecto)),
                          DataCell(Text(proyecto['NombreOT'] ?? ''), onTap: () => _mostrarDetalleOrden(context, proyecto)),
                          DataCell(Text(proyecto['Nombre Solicitante'] ?? ''), onTap: () => _mostrarDetalleOrden(context, proyecto)),
                          DataCell(Text(proyecto['Area'] ?? ''), onTap: () => _mostrarDetalleOrden(context, proyecto)),
                          DataCell(
                            Row(
                              children: [
                                ElevatedButton(
                                  onPressed: () => _mostrarDetalleOrden(context, proyecto),
                                  child: Text('Ver orden de trabajo'),
                                ),
                              ],
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

}
