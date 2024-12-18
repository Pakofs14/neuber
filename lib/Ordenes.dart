import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:signature/signature.dart';
import 'package:neuber/OrdenesActivas.dart';
import 'package:neuber/OrdenesTerminadas.dart';
import 'package:neuber/OrdenesTrabajando.dart';
import 'package:url_launcher/url_launcher.dart';


void main() => runApp(MaterialApp(home: OrdenesPage()));

class OrdenesPage extends StatefulWidget {
  @override
  _OrdenesPageState createState() => _OrdenesPageState();
}

class _OrdenesPageState extends State<OrdenesPage> {
  SignatureController _signatureController = SignatureController(
    penColor: Colors.black,
    penStrokeWidth: 5,
  );
  bool firmaAceptada = false;
  bool envioHabilitado = false;
  bool asignadoSistemas = false;
  bool asignadoMantenimiento = false;
  bool tipoCritico = false;
  bool tipoNoCritico = false;
  bool correctivo = false;
  bool servicioGeneral = false;
  String tipoMantenimiento = '';
  int pendingCount = 0;
  int trabajandoCount = 0;
  int terminadoCount = 0;
  bool firmaHabilitada = false;

  final TextEditingController tituloController = TextEditingController();
  final TextEditingController solicitanteController = TextEditingController();
  final TextEditingController areaController = TextEditingController();
  final TextEditingController fallaController = TextEditingController();
  final TextEditingController correoController = TextEditingController();
  
  final airtableApiToken = 'patTjJNwpD104BTKG.9352a6a8b38ce585bc3b55de8667ef8e81800fc5cde77e95a95398447a4ca604';
  final airtableApiBaseUrl = 'https://api.airtable.com';
  final airtableBaseId = 'appHba5WGxI7G7VDA';
  final airtableTableName = 'OTSistemas';

  @override
  void initState() {
    super.initState();
    _fetchCounts();
    _addListeners();
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
        print('Firma aceptada: $firmaAceptada');
      });
    }
  }

  Future<void> _fetchCounts() async {
    try {
      await Future.wait([
        _fetchPendingCount(),
        _fetchTrabajandoCount(),
        _fetchTerminadoCount(),
      ]);
    } catch (e) {
      print('Error fetching counts: $e');
    }
  }

  void _addListeners() {
    tituloController.addListener(_validarFormulario);
    solicitanteController.addListener(_validarFormulario);
    areaController.addListener(_validarFormulario);
    fallaController.addListener(_validarFormulario);
  }

  void _validarFormulario() {
  bool camposLlenos = tituloController.text.isNotEmpty && solicitanteController.text.isNotEmpty && areaController.text.isNotEmpty && fallaController.text.isNotEmpty && (asignadoSistemas || asignadoMantenimiento) && (tipoCritico || tipoNoCritico) && (correctivo || servicioGeneral);
  setState(() {
    firmaHabilitada = camposLlenos;
    envioHabilitado = camposLlenos;
  });
}

  Future<void> _fetchPendingCount() async {
    final url = Uri.parse('$airtableApiBaseUrl/v0/$airtableBaseId/$airtableTableName?filterByFormula=({Estado}="Pendiente")');
    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $airtableApiToken',
    });

    if (response.statusCode == 200) {
      final records = json.decode(response.body)['records'];
      setState(() {
        pendingCount = records.length;
      });
    } else {
      throw Exception('Failed to load pending count');
    }
  }

  Future<void> _fetchTrabajandoCount() async {
    final url = Uri.parse('$airtableApiBaseUrl/v0/$airtableBaseId/$airtableTableName?filterByFormula=({Estado}="Trabajando")');
    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $airtableApiToken',
    });

    if (response.statusCode == 200) {
      final records = json.decode(response.body)['records'];
      setState(() {
        trabajandoCount = records.length;
      });
    } else {
      throw Exception('Failed to load trabajando count');
    }
  }

  Future<void> _fetchTerminadoCount() async {
    final url = Uri.parse('$airtableApiBaseUrl/v0/$airtableBaseId/$airtableTableName?filterByFormula=({Estado}="Finalizado")');
    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $airtableApiToken',
    });

    if (response.statusCode == 200) {
      final records = json.decode(response.body)['records'];
      setState(() {
        terminadoCount = records.length;
      });
    } else {
      throw Exception('Failed to load terminado count');
    }
  }
  
  Future<int> obtenerUltimoNumero() async {
    final url = Uri.parse('$airtableApiBaseUrl/v0/$airtableBaseId/$airtableTableName?maxRecords=1&sort[0][field]=Numero&sort[0][direction]=desc');
    
    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $airtableApiToken',
    });

    if (response.statusCode == 200) {
      final records = json.decode(response.body)['records'];
      if (records.isNotEmpty) {
        return records[0]['fields']['Numero'];
      } else {
        return 0;
      }
    } else {
      throw Exception('Error al obtener registros: ${response.body}');
    }
  }

  Future<void> enviarDatosAirtable() async {
    try {
      int ultimoNumero = await obtenerUltimoNumero();
      int nuevoNumero = ultimoNumero + 1;

      final signatureImage = await _signatureController.toPngBytes();
      if (signatureImage == null) {
        throw Exception('No signature drawn');
      }

      final url = Uri.parse('$airtableApiBaseUrl/v0/$airtableBaseId/$airtableTableName');
      final now = DateTime.now();
      final fechaHora = DateFormat('dd/MM/yyyy HH:mm:ss').format(now);

final Map<String, dynamic> data = {
  'fields': {
    'Numero': nuevoNumero,
    'NombreOT': tituloController.text,
    'Nombre Solicitante': solicitanteController.text,
    'Tipo OT': tipoMantenimiento,
    'Prioridad': tipoCritico ? 'Crítico' : 'No Crítico',
    'Tipo de Servicio': correctivo ? 'Correctivo' : 'Servicio General',
    'Area': areaController.text,
    'Falla': fallaController.text,
    'Estado': 'Pendiente',
    'Hora Enviada': fechaHora,
    'Correo': correoController.text,
    'Asignado': asignadoSistemas ? 'Sistemas' : asignadoMantenimiento ? 'Mantenimiento' : '',
  },
};
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $airtableApiToken',
          'Content-Type': 'application/json',
        },
        body: json.encode(data),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
      print('Datos enviados con éxito');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Orden de trabajo enviada con éxito')),
      );
    
        
        // Launch email client after successful submission
        _launchEmailClient(data['fields']);
        
        _limpiarFormulario();
        _fetchPendingCount();
      } else {
        print('Error al enviar datos: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al enviar la orden de trabajo: ${response.body}')),
        );
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al procesar la solicitud: $e')),
      );
    }
  }

  void _launchEmailClient(Map<String, dynamic> orderData) async {
  String emailAddress = asignadoMantenimiento ? 'mantenimiento@neuber.com.mx' : 'sistemas@neuber.com.mx';
  
  final String emailBody = '''
Tienes una nueva orden de trabajo asignada con los siguientes detalles:

Nombre de la OT: ${orderData['NombreOT']}
Nombre del Solicitante: ${orderData['Nombre Solicitante']}
Correo del Solicitante: ${orderData['Correo']}
Prioridad: ${orderData['Prioridad']}
Falla: ${orderData['Falla']}
Hora Enviada: ${orderData['Hora Enviada']}

Favor de revisar más detalles en la aplicación de Neuber: https://neuber-76537.web.app/
''';

  final Uri emailLaunchUri = Uri(
    scheme: 'mailto',
    path: emailAddress,
    query: encodeQueryParameters(<String, String>{
      'subject': 'NUEVA ORDEN DE TRABAJO',
      'body': emailBody,
    }),
  );

  if (await canLaunch(emailLaunchUri.toString())) {
    await launch(emailLaunchUri.toString());
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('No se pudo abrir la aplicación de correo')),
    );
  }
}
 
  String? encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }

  void _limpiarFormulario() {
    setState(() {
      tituloController.clear();
      solicitanteController.clear();
      areaController.clear();
      fallaController.clear();
      tipoMantenimiento = '';
      tipoCritico = false;
      tipoNoCritico = false;
      correctivo = false;
      servicioGeneral = false;
      asignadoSistemas = false;
      asignadoMantenimiento = false;
      firmaAceptada = false;
      envioHabilitado = false;
      _signatureController.clear();
    });
  }

  void _navigateToOrdenesActivasPage(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: Duration(milliseconds: 500),
        pageBuilder: (_, __, ___) => OrdenesActivasPage(),
        transitionsBuilder: (_, Animation<double> animation, __, Widget child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }
    
  void _navigateToOrdenesTrabajandoPage(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: Duration(milliseconds: 500),
        pageBuilder: (_, __, ___) => OrdenesTrabajandoPage(),
        transitionsBuilder: (_, Animation<double> animation, __, Widget child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }
    
  void _navigateToOrdenesTerminadasPage(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: Duration(milliseconds: 500),
        pageBuilder: (_, __, ___) => OrdenesTerminadasPage(),
        transitionsBuilder: (_, Animation<double> animation, __, Widget child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }
    
  void _mostrarDialogoFirma() {
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
                                setState(() {
                                  firmaAceptada = true;
                                  envioHabilitado = true;
                                });
                                Navigator.of(context).pop();
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

  void _mostrarMensajeCorreo(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Información importante'),
        content: Text('El correo seleccionado será el correo al cual notificaremos el avance de tu orden de trabajo.'),
        actions: [
          TextButton(
            child: Text('Entendido'),
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
  Widget build(BuildContext context) {
  bool habilitado = asignadoSistemas || asignadoMantenimiento;

  return Scaffold(
    appBar: AppBar(
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      title: const Text('Órdenes de Trabajo', style: TextStyle(color: Colors.white)),
      backgroundColor: const Color(0xFF313745),
      actions: [
        IconButton(
          icon: Stack(
            children: [
              Icon(Icons.description, color: Colors.red),
              if (pendingCount > 0)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    constraints: BoxConstraints(
                      minWidth: 20,
                      minHeight: 20,
                    ),
                    child: Center(
                      child: Text(
                        '$pendingCount',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          onPressed: () {
            _navigateToOrdenesActivasPage(context);
          },
        ),
        IconButton(
          icon: Stack(
            children: [
              Icon(Icons.description, color: Colors.yellow),
              if (trabajandoCount > 0)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.yellow,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    constraints: BoxConstraints(
                      minWidth: 20,
                      minHeight: 20,
                    ),
                    child: Center(
                      child: Text(
                        '$trabajandoCount',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          onPressed: () {
            _navigateToOrdenesTrabajandoPage(context);
          },
        ),
        IconButton(
          icon: Stack(
            children: [
              Icon(Icons.description, color: Colors.green),
              if (terminadoCount > 0)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    constraints: BoxConstraints(
                      minWidth: 20,
                      minHeight: 20,
                    ),
                    child: Center(
                      child: Text(
                        '$terminadoCount',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          onPressed: () {
            _navigateToOrdenesTerminadasPage(context);
          },
        ),
      ],
    ),
    body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: <Widget>[
          Text(
            "Trabajo Asignado a:",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Row(
  children: [
    Expanded(
      child: CheckboxListTile(
        title: Text("Sistemas"),
        value: asignadoSistemas,
        onChanged: (bool? value) {
          setState(() {
            asignadoSistemas = value ?? false;
            asignadoMantenimiento = false;
          });
        },
      ),
    ),
    Expanded(
      child: CheckboxListTile(
        title: Text("Mantenimiento"),
        value: asignadoMantenimiento,
        onChanged: (bool? value) {
          setState(() {
            asignadoMantenimiento = value ?? false;
            asignadoSistemas = false;
          });
        },
      ),
    ),
  ],
),

          SizedBox(height: 20),
          if (habilitado) ...[
            TextField(
              controller: tituloController,
              decoration: InputDecoration(
                labelText: 'Título de la Orden de Trabajo',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: solicitanteController,
              decoration: InputDecoration(
                labelText: 'Nombre completo de quien solicita el servicio',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: areaController,
              decoration: InputDecoration(
                labelText: 'Área donde se solicita el servicio',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            Text(
              "Tipo de Mantenimiento:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: CheckboxListTile(
                    title: Text("Correctivo"),
                    value: correctivo,
                    onChanged: (bool? value) {
                      setState(() {
                        correctivo = value ?? false;
                        servicioGeneral = false;
                        tipoMantenimiento = 'Correctivo';
                      });
                    },
                  ),
                ),
                Expanded(
                  child: CheckboxListTile(
                    title: Text("Servicio General"),
                    value: servicioGeneral,
                    onChanged: (bool? value) {
                      setState(() {
                        servicioGeneral = value ?? false;
                        correctivo = false;
                        tipoMantenimiento = 'Servicio General';
                      });
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Text(
              "Prioridad del Mantenimiento:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: CheckboxListTile(
                    title: Text("Crítico"),
                    value: tipoCritico,
                    onChanged: (bool? value) {
                      setState(() {
                        tipoCritico = value ?? false;
                        tipoNoCritico = false;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: CheckboxListTile(
                    title: Text("No Crítico"),
                    value: tipoNoCritico,
                    onChanged: (bool? value) {
                      setState(() {
                        tipoNoCritico = value ?? false;
                        tipoCritico = false;
                      });
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            TextField(
              controller: fallaController,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: 'Descripción de la Falla',
                border: OutlineInputBorder(),
              ),
            ),
                        SizedBox(height: 20),
            TextField(
  controller: correoController,
  decoration: InputDecoration(
    labelText: 'Correo electrónico del solicitante',
    border: OutlineInputBorder(),
  ),
  onTap: () {
    _mostrarMensajeCorreo(context);
  },
),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: firmaHabilitada ? () => _mostrarDialogoFirma() : null,
              child: Text('Firmar OT'),
            ),
            ElevatedButton(
              onPressed: firmaAceptada && envioHabilitado ? enviarDatosAirtable : null,
              child: Text('Enviar OT'),
            ),
          ] else
            Text(
              "Por favor seleccione una asignación para habilitar el formulario",
              style: TextStyle(color: Colors.red),
            ),
        ],
      ),
    ),
  );
}

}