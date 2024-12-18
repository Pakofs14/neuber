import 'dart:convert';
import 'dart:html' as html;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:neuber/GraficasProyectos.dart';

class CustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    
  };
}

class ProyectosPage extends StatefulWidget {
  const ProyectosPage({Key? key}) : super(key: key);
  

  @override
  _ProyectosPageState createState() => _ProyectosPageState();
}

class _ProyectosPageState extends State<ProyectosPage> {
  final airtableApiToken =
      'patTjJNwpD104BTKG.9352a6a8b38ce585bc3b55de8667ef8e81800fc5cde77e95a95398447a4ca604';
  final airtableApiBaseUrl = 'https://api.airtable.com';
  final airtableBaseId = 'appHba5WGxI7G7VDA';
  final airtableTableName = 'Proyectos';

  String selectedFilter = 'En Linea';
  String? currentImageData;
  
  bool _validateCredentials(String user, String password) {
    return user == 'eduardo' && password == '1901';
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
            // Create a new field for combined line information
            String combinedLine = '';
            if (fields['Linea 1']?.toString() == 'Verdadero') {
              combinedLine += 'Linea 1 ';
            }
            if (fields['Linea 2']?.toString() == 'Verdadero') {
              combinedLine += 'Linea 2 ';
            }
            if (fields['Linea 3']?.toString() == 'Verdadero') {
              combinedLine += 'Linea 3 ';
            }
            if (fields['Linea 4']?.toString() == 'Verdadero') {
              combinedLine += 'Montaje ';
            }
            // Check if combinedLine is still empty, then set it to "Pintura"
            if (combinedLine.isEmpty) {
              combinedLine = 'Pintura';
            }
            fields['CombinedLine'] = combinedLine; // Add the new field to the record
            fields['id'] = record['id'];
            return fields;
          }),
        );

        // Ordenar los proyectos según su estado
        proyectos.sort((a, b) {
          // Primero los proyectos en línea
          if (a['En Linea'].toString() == 'Verdadero' && b['En Linea'].toString() != 'Verdadero') {
            return -1;
          } else if (a['En Linea'].toString() != 'Verdadero' && b['En Linea'].toString() == 'Verdadero') {
            return 1;
          }
          // Luego los Espera de Material
          else if (a['Espera De Material'].toString() == 'Verdadero' && b['Espera De Material'].toString() != 'Verdadero') {
            return -1;
          } else if (a['Espera De Material'].toString() != 'Verdadero' && b['Espera De Material'].toString() == 'Verdadero') {
            return 1;
          }
          // Luego los pausados
          else if (a['Pausa'].toString() == 'Verdadero' && b['Pausa'].toString() != 'Verdadero') {
            return -1;
          } else if (a['Pausa'].toString() != 'Verdadero' && b['Pausa'].toString() == 'Verdadero') {
            return 1;
          }
          // Al final los atrasados
          else if (a['Atrasado'].toString() == 'Verdadero' && b['Atrasado'].toString() != 'Verdadero') {
            return 1;
          } else if (a['Atrasado'].toString() != 'Verdadero' && b['Atrasado'].toString() == 'Verdadero') {
            return -1;
          } else {
            return 0;
          }
        });

        return proyectos;
      }
    } else {
      throw Exception('Error al cargar proyectos desde Airtable');
    }
    return [];
  }

  List<Map<String, dynamic>> _filterProyectos(List<Map<String, dynamic>> proyectos, String filter) {
    return proyectos.where((proyecto) {
      switch (filter) {
        case 'En Linea':
          return proyecto['En Linea'].toString() == 'Verdadero';
        case 'Proximo':
          return proyecto['Proximo'].toString() == 'Verdadero';
        case 'Atrasado':
          return proyecto['Atrasado'].toString() == 'Verdadero';
        case 'Pausa':
          return proyecto['Pausa'].toString() == 'Verdadero';
        case 'Espera De Material':
          return proyecto['Espera De Material'].toString() == 'Verdadero';
        default:
          return false;
      }
    }).toList();
  }

  String _determineStatus(Map<String, dynamic> project) {
    if (project['Proximo'].toString() == 'Verdadero') {
      return 'Proximo';
    } else if (project['Atrasado'].toString() == 'Verdadero') {
      return 'Atrasado';
    } else if (project['Pausa'].toString() == 'Verdadero') {
      return 'Pausa';
    } else if (project['En Linea'].toString() == 'Verdadero') {
      return 'En Linea';
    } else if (project['Espera De Material'].toString() == 'Verdadero') {
      return 'Espera De Material';  
    } else {
      return '';
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
        title: const Text('Buscar Proyectos', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF313745),
        actions: [
          DropdownButton<String>(
            value: selectedFilter,
            icon: Icon(Icons.filter_list, color: Colors.white),
            dropdownColor: const Color(0xFF313745),
            items: <String>['En Linea', 'Proximo', 'Atrasado', 'Pausa', 'Espera De Material']
                .map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value, style: TextStyle(color: Colors.white)),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                selectedFilter = newValue!;
              });
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _loadProyectos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: SpinKitFadingCircle(
                color: Colors.black,
                size: 60.0,
              ),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final proyectos = _filterProyectos(snapshot.data ?? [], selectedFilter);
            return SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: [
                    DataColumn(label: Text('Estado')),
                    DataColumn(label: Text('Nombre del Proyecto')),
                    DataColumn(label: Text('Fecha de Inicio')),
                    DataColumn(label: Text('Fecha de Fin')),
                    DataColumn(label: Text('Línea')),
                    DataColumn(label: Text('Foto')),
                    DataColumn(label: Text('Subir Foto')),
                  ],
                  rows: proyectos.map<DataRow>((proyecto) {
                    // Use the new color calculation method
                    
                    return DataRow(
                      cells: [
                        DataCell(Text(_determineStatus(proyecto))),
                        DataCell(
                          GestureDetector(
                            onTap: () {
                              _navigateToGraficasPage(context, proyecto);
                            },
                            child: Text(proyecto['Nombre del Proyecto'].toString()),
                          ),
                        ),
                        DataCell(Text(proyecto['Fecha de inicio'].toString())),
                        DataCell(
                          Row(
                            children: [
                              Text(proyecto['Fecha de fin'].toString()),
                              _buildDateProximityIcon(proyecto),
                            ],
                          ),
                        ),
                        DataCell(Text(proyecto['CombinedLine'].toString())),
                        DataCell(
                          IconButton(
                            icon: Icon(Icons.camera_alt),
                            onPressed: () {
                              List<dynamic>? photoAttachments = proyecto['Foto'] as List<dynamic>?;
                              if (photoAttachments != null && photoAttachments.isNotEmpty) {
                                String? firstPhotoUrl = photoAttachments.first['url'] as String?;
                                if (firstPhotoUrl != null) {
                                  _showPhotoDialog(firstPhotoUrl);
                                } else {
                                  _showNoPhotosDialog();
                                }
                              } else {
                                _showNoPhotosDialog();
                              }
                            },
                          ),
                        ),
                        DataCell(
                          IconButton(
                            icon: Icon(Icons.upload_file),
                            onPressed: () {
                              String recordId = proyecto['id'].toString();
                              _showLoginDialog(recordId);
                            },
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            );
          }
        },
      ),
    ),
  );
}

Widget _buildDateProximityIcon(Map<String, dynamic> proyecto) {
  DateTime? endDate;
  try {
    endDate = DateTime.parse(proyecto['Fecha de fin'].toString());
  } catch (e) {
    return SizedBox.shrink(); // Retorna un widget vacío si la fecha no es válida
  }

  DateTime now = DateTime.now();
  int daysUntilEnd = endDate.difference(now).inDays;

  void _showDateDialog(BuildContext context, int days) {
    String message;
    if (days >= 0) {
      message = "Quedan $days días para la entrega del proyecto.";
    } else {
      message = "El proyecto tiene ${-days} días de atraso.";
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Información del proyecto"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cerrar"),
            ),
          ],
        );
      },
    );
  }

if (daysUntilEnd <= 7 && daysUntilEnd >= 0) {
  // Advertencia roja: menos de 7 días restantes
  return GestureDetector(
    onTap: () => _showDateDialog(context, daysUntilEnd),
    child: Icon(Icons.warning, color: Colors.orange, size: 20),
  );
} else if (daysUntilEnd <= 14 && daysUntilEnd > 7) {
  // Advertencia naranja: entre 8 y 14 días restantes
  return GestureDetector(
    onTap: () => _showDateDialog(context, daysUntilEnd),
    child: Icon(Icons.error_outline, color: Colors.yellow, size: 20),
  );
} else if (daysUntilEnd < 0) {
  // Caso de atraso: fecha ya vencida
  return GestureDetector(
    onTap: () => _showDateDialog(context, daysUntilEnd),
    child: Icon(Icons.error, color: Colors.red, size: 20),
  );
} else {
  // Todo está bien: más de 14 días restantes
  return GestureDetector(
    onTap: () => _showDateDialog(context, daysUntilEnd),
    child: Icon(Icons.check_circle, color: Colors.green, size: 20),
  );
}
}

  void _navigateToGraficasPage(BuildContext context, Map<String, dynamic> data) {
    String nombreProyecto = data['Nombre del Proyecto']; // Obtén el nombre del proyecto del mapa de datos
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: Duration(milliseconds: 500),
        pageBuilder: (_, __, ___) => GraficasProyectosPage(proyecto: nombreProyecto), // Pasa nombreProyecto en lugar de 'title'
        transitionsBuilder: (_, Animation<double> animation, __, Widget child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }

  void _showNoPhotosDialog() {
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

  void _showLoginDialog(String recordId) {
  final TextEditingController userController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Ingrese sus credenciales'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: userController,
              decoration: InputDecoration(labelText: 'Usuario'),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Contraseña'),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (_validateCredentials(userController.text, passwordController.text)) {
                String userAgent = html.window.navigator.userAgent.toLowerCase();

                // Comprobar si el navegador está en iOS, iPad o Android
                if (userAgent.contains('iphone') || userAgent.contains('ipad') || userAgent.contains('android')) {
                  // Abrir la cámara del dispositivo
                  html.FileUploadInputElement cameraInput = html.FileUploadInputElement();
                  cameraInput.accept = 'image/*';
                  cameraInput.click();

                  cameraInput.onChange.listen((e) {
                    final files = cameraInput.files;
                    if (files != null && files.isNotEmpty) {
                      final file = files[0];
                      final reader = html.FileReader();

                      reader.readAsDataUrl(file);
                      reader.onLoadEnd.listen((e) {
                        String imageData = reader.result as String;
                        _showImagePreviewDialog(imageData, recordId);
                      });
                    }
                  });
                } else if (userAgent.contains('windows')) {
                  // En caso de ser Windows, abrir el explorador de archivos
                  _openFilePicker(recordId, (String newImageData) {
                    _showImagePreviewDialog(newImageData, recordId);
                  });
                } else {
                  // Si no es un sistema compatible, puedes manejarlo de alguna manera
                  Navigator.pop(context);
                }
              } else {
                // Si las credenciales son incorrectas
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Credenciales incorrectas')),
                );
              }
            },
            child: Text('Aceptar'),
          ),
        ],
      );
    },
  );
}
  
  void _openFilePicker(String recordId, Function(String) onFileSelected) {
    html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
    uploadInput.accept = 'image/*';
    uploadInput.click();

    uploadInput.onChange.listen((e) {
      final files = uploadInput.files;
      if (files!.length == 1) {
        final file = files[0];
        final reader = html.FileReader();
        reader.readAsDataUrl(file);
        reader.onLoadEnd.listen((e) {
          onFileSelected(reader.result as String);
        });
      }
    });
  }

  void _showImagePreviewDialog(String? imageData, String recordId) {
    currentImageData = imageData;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Vista previa de la imagen'),
              content: currentImageData != null
                  ? Image.network(currentImageData!)
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.photo, size: 100, color: Colors.grey),
                        SizedBox(height: 20),
                        Text('Aún no hay imágenes', style: TextStyle(fontSize: 18)),
                      ],
                    ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cerrar'),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      currentImageData = null;
                    });
                  },
                  child: Text('Eliminar'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _openFilePicker(recordId, (newImageData) {
                      _showImagePreviewDialog(newImageData, recordId);
                    });
                  },
                  child: Text('Cambiar'),
                ),
                TextButton(
  onPressed: () async {
    if (currentImageData != null) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SpinKitFadingCircle(
                  color: Colors.blue,
                  size: 50.0,
                ),
                SizedBox(height: 20),
                Text('Subiendo imagen...'),
              ],
            ),
          );
        },
      );

      try {
        await _uploadImageToImgBB(currentImageData!, recordId);  // Subir imagen

        // Cerrar todos los cuadros de diálogo abiertos (carga, vista previa, subir foto)
        Navigator.of(context).pop(); // Cerrar el diálogo de carga
        Navigator.of(context).pop(); // Cerrar el cuadro de diálogo de subir foto
        Navigator.of(context).pop(); // Cerrar el cuadro de vista previa

        // Mostrar mensaje emergente de éxito
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Éxito'),
              content: Text('Imagen subida exitosamente'),
              actions: [
                TextButton(
                  child: Text('Aceptar'),
                  onPressed: () {
                    Navigator.of(context).pop(); // Cerrar el diálogo de éxito
                  },
                ),
              ],
            );
          },
        );
      } catch (e) {
        Navigator.of(context).pop(); // Cerrar el diálogo de carga

        // Mostrar mensaje de error si falla la subida
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Error'),
              content: Text('Error al subir la imagen: $e'),
              actions: [
                TextButton(
                  child: Text('Aceptar'),
                  onPressed: () {
                    Navigator.of(context).pop(); // Cerrar el diálogo de error
                  },
                ),
              ],
            );
          },
        );
      }
    }
  },
  child: Text('Subir'),
),
              ],
            );
          },
        );
      },
    );
  }
  
 Future<void> _uploadImageToImgBB(String imageData, String recordId) async {
  final url = 'https://api.imgbb.com/1/upload';
  final apiKey = 'a49c594e3a3152ca5168f2ed879db980';

  // Convertir la imagen a base64, si es necesario
  String base64Image = imageData.split(',').last;

  // Crear el cuerpo de la solicitud para Imgbb
  var body = {
    'key': apiKey,
    'image': base64Image,
  };

  // Enviar la solicitud POST a Imgbb
  var response = await http.post(
    Uri.parse(url),
    body: body,
  );

  // Revisar el estado de la respuesta
  if (response.statusCode == 200) {
    var jsonResponse = jsonDecode(response.body);
    String imageUrl = jsonResponse['data']['url'];

    print('Image uploaded to Imgbb successfully. Image URL: $imageUrl');

    // Una vez que se sube la imagen a Imgbb, se llama a Airtable para guardar la URL
    await _uploadImageUrlToAirtable(imageUrl, recordId);
  } else {
    print('Failed to upload image to Imgbb. Status: ${response.statusCode}, Body: ${response.body}');
    throw Exception('Failed to upload image to Imgbb');
  }
}

  Future<void> _uploadImageUrlToAirtable(String imageUrl, String recordId) async {
  final airtableApiToken = 'patTjJNwpD104BTKG.9352a6a8b38ce585bc3b55de8667ef8e81800fc5cde77e95a95398447a4ca604';
  final airtableBaseId = 'appHba5WGxI7G7VDA';
  final airtableTableName = 'Proyectos';
  
  final url = 'https://api.airtable.com/v0/$airtableBaseId/$airtableTableName/$recordId';

  // Crear el cuerpo de la solicitud para Airtable
  var body = {
    'fields': {
      'Foto': [
        {
          'url': imageUrl
        }
      ]
    }
  };

  // Crear la solicitud PATCH para Airtable
  var response = await http.patch(
    Uri.parse(url),
    headers: {
      'Authorization': 'Bearer $airtableApiToken',
      'Content-Type': 'application/json',
    },
    body: json.encode(body),
  );

  // Revisar el estado de la respuesta
  if (response.statusCode == 200) {
    print('Image URL successfully uploaded to Airtable');
  } else {
    print('Failed to upload image URL to Airtable. Status: ${response.statusCode}, Body: ${response.body}');
    throw Exception('Failed to upload image URL to Airtable');
  }
} 

}


