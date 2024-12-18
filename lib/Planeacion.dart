import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:neuber/Editar.dart';
import 'package:neuber/Eliminar.dart';
import 'package:neuber/Buscar.dart';
import 'package:http/http.dart' as http;
import 'package:neuber/Finalizar.dart';

void main() {
  runApp(const PlaneacionApp());
}

class PlaneacionApp extends StatelessWidget {
  const PlaneacionApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Material App',
      home: const PlaneacionPage(),
    );
  }
}

class PlaneacionPage extends StatefulWidget {
  const PlaneacionPage({Key? key}) : super(key: key);

  @override
  _PlaneacionPageState createState() => _PlaneacionPageState();
}

class _PlaneacionPageState extends State<PlaneacionPage> {
  late TextEditingController projectNameController,
      piecesController;

  DateTime? selectedStartDate, selectedEndDate;
  String selectedPausa = 'Falso';
  String selectedAtrasado = 'Falso';
  String selectedCorrecto = 'Falso';
  String selectedProximo = 'Falso';
  String selectedEspera = 'Falso';
  String selectedMontaje = 'Verdadero';

  List<String> pausaOptions = ['Verdadero', 'Falso'];
  List<String> atrasadoOptions = ['Verdadero', 'Falso'];
  List<String> correctoOptions = ['Verdadero', 'Falso'];
  List<String> proximoOptions = ['Verdadero', 'Falso'];
  List<String> esperaOptions = ['Verdadero', 'Falso'];
  List<String> naveOptions = ['Nave 1', 'Nave 2'];
   List<String> Options = ['Verdadero', 'Falso'];
  Set<String> selectedNaveOptions = {}; // Utilizamos un conjunto para permitir la selección múltiple

  List<String> lineOptions = ['Linea 1', 'Linea 2', 'Linea 3', 'Montaje','Textil'];
  Set<String> selectedLineOptions = {}; // Utilizamos un conjunto para permitir la selección múltiple
  List<String> procesosOptions = ['Cama', 'Huacal', 'Soldadura', 'Patines','Interiores'];
  Set<String> selectedProcesos = {}; 
  List<String> procesosOptions2 = ['Cama', 'Huacal', 'Soldadura','Patines', 'Interiores'];
  Set<String> selectedProcesos2 = {}; 
  List<String> procesosOptions3 = ['Cama', 'Huacal', 'Soldadura', 'Patines','Interiores'];
  Set<String> selectedProcesos3 = {}; 

  bool showLinea1Processes = false;
  bool showLinea2Processes = false;
  bool showLinea3Processes = false;
  bool showLinea4Processes = false;
  bool showLinea5Processes = false;


  Map<String, String> selectedProcessStates = {};
  Set<String> allSelectedProcesos = {};

  String selectedCamaL1= 'Falso';
  String selectedHuacalL1 = 'Falso';
  String selectedSoldaduraL1 = 'Falso';
  String selectedPatinesL1 = 'Falso';
  String selectedInterioresL1 = 'Falso';
  String selectedCamaL2= 'Falso';
  String selectedHuacalL2 = 'Falso';
  String selectedSoldaduraL2 = 'Falso';
  String selectedInterioresL2 = 'Falso';
  String selectedPatinesL2 = 'Falso';
  String selectedCamaL3= 'Falso';
  String selectedHuacalL3 = 'Falso';
  String selectedSoldaduraL3 = 'Falso';
  String selectedInterioresL3 = 'Falso';
  String selectedPatinesL3 = 'Falso';


  final airtableApiToken =
      'patTjJNwpD104BTKG.9352a6a8b38ce585bc3b55de8667ef8e81800fc5cde77e95a95398447a4ca604';
  final airtableApiBaseUrl = 'https://api.airtable.com';
  final airtableBaseId = 'appHba5WGxI7G7VDA';
  final airtableTableName = 'Proyectos';



  @override
  void initState() {
    super.initState();
    projectNameController = TextEditingController();
    piecesController = TextEditingController();
    for (String proceso in procesosOptions) {
    selectedProcessStates['$proceso L1'] = 'Falso';
  }
  }

  @override
  void dispose() {
    projectNameController.dispose();
    piecesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    setState(() {
      selectedStartDate = isStartDate ? picked : selectedStartDate;
      selectedEndDate = isStartDate ? selectedEndDate : picked;
    });
  }

  Future<void> _showSuccessDialog() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Éxito'),
          content: const Text('Proyecto creado exitosamente.'),
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

  InputDecoration _buildInputDecoration(String labelText, bool isValid, String errorText) {
    return InputDecoration(
      labelText: labelText,
      border: OutlineInputBorder(
        borderSide: BorderSide(color: isValid ? Colors.black : Colors.red),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: isValid ? Colors.blue : Colors.red),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.red),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: isValid ? Colors.black : Colors.red),
      ),
      errorText: isValid ? null : errorText,
    );
  }

  Widget _buildTextField(String labelText, TextEditingController controller, bool Function(String) validator) {
    return TextField(
      controller: controller,
      onChanged: (text) {
        setState(() {
          // Actualizar el estado al cambiar el texto para mostrar mensajes en tiempo real
        });
      },
      decoration: _buildInputDecoration(labelText, validator(controller.text), 'Dato necesario'),
    );
  }

  bool _validateText(String text) {
    // Valida que el texto contenga solo letras y/o números
    return RegExp(r'^[a-zA-Z0-9\s]+$').hasMatch(text);
  }

  bool _validatePositiveInteger(String text) {
    // Valida que sea un número entero positivo o cero
    try {
      final value = int.parse(text);
      return value >= 0;
    } catch (e) {
      return false;
    }
  }

  bool _validateNave(String text) {
    // Valida que el texto sea 1 o 2
    return text == '1' || text == '2';
  }

  bool _validateDate(DateTime? date) {
    // Valida que no sea una fecha con más de un año de antigüedad
    final currentDate = DateTime.now();
    return date != null && date.isAfter(currentDate.subtract(const Duration(days: 365)));
  }

  bool _validateEndDate(DateTime? endDate, DateTime? startDate) {
    // Valida que la fecha de fin no sea menor a la fecha de inicio
    return endDate != null && (startDate == null || endDate.isAfter(startDate));
  }

  bool _areAllFieldsValid() {
    return _validateText(projectNameController.text) &&
        _validatePositiveInteger(piecesController.text) &&
        _validateDate(selectedStartDate) &&
        _validateEndDate(selectedEndDate, selectedStartDate);
  }

  Future<void> _saveDataToAirtable(Map<String, dynamic> data) async {
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
      _showSuccessDialog();
    } else {
      print('Error al guardar en Airtable. Código: ${response.statusCode}, Mensaje: ${response.body}');
      // Manejar el error según tus necesidades
    }
  }

  
  @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color(0xFFe5ecf4),
    appBar: AppBar(
      title: const Text('Planeación', style: TextStyle(color: Colors.white)),
      iconTheme: IconThemeData(
      color: Colors.white, // Hace que el ícono de regreso sea blanco
      ),
      backgroundColor: const Color(0xFF313745),
      actions: [
        IconButton(icon: const Icon(Icons.add, color: Colors.white), onPressed: () {}),
        IconButton(
          icon: const Icon(Icons.edit, color: Colors.white),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => EditarPage()),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.search, color: Colors.white),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => BuscarPage()),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.delete, color: Colors.white),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => EliminarPage()),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.stop_circle_outlined, color: Colors.white),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => FinalizarPage()),
            );
          },
        ),
      ],
    ),
    body: Padding(
      padding: const EdgeInsets.all(20.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField('Nombre del Proyecto', projectNameController, _validateText),
            const SizedBox(height: 20),
            _buildTextField('Piezas', piecesController, _validatePositiveInteger),
            const SizedBox(height: 20),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Selecciona las líneas donde se va a trabajar el proyecto'), // Title
                Wrap(
                  children: lineOptions.map((String option) {
                    bool optionDisabled = (selectedLineOptions.contains('Montaje') || selectedLineOptions.contains('Textil')) && !selectedLineOptions.contains(option);
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Checkbox(
  value: selectedLineOptions.contains(option),
onChanged: optionDisabled ? null : (bool? value) {
  setState(() {
    if (value != null && value) {
      if (option == 'Montaje' || option == 'Textil') {
        // Si se selecciona 'Montaje' o 'Textil', eliminar todas las demás opciones
        selectedLineOptions.clear();
        selectedLineOptions.add(option);
        selectedMontaje = 'Falso'; // Asignar 'Falso' cuando se selecciona 'Montaje' o 'Textil'
      } else {
        if (!selectedLineOptions.contains('Montaje') && !selectedLineOptions.contains('Textil') && (selectedLineOptions.length < 2 || selectedLineOptions.contains(option))) {
          // Permitir seleccionar la línea si no se han seleccionado dos líneas o si ya está seleccionada
          selectedLineOptions.add(option);
        }
      }
    } else {
      selectedLineOptions.remove(option); // Eliminar la opción deseleccionada

      // Ocultar las opciones de procesos si se desmarca la línea correspondiente
      if (option == 'Linea 1') {
        showLinea1Processes = false;
      } else if (option == 'Linea 2') {
        showLinea2Processes = false;
      } else if (option == 'Linea 3') {
        showLinea3Processes = false;
      } else if (option == 'Linea 4') {
        showLinea4Processes = false;
      } else if (option == 'Linea 5') {
        showLinea5Processes = false;
      }

      // Asignar 'Verdadero' cuando no se selecciona 'Montaje' o 'Textil'
      if (option == 'Montaje' || option == 'Textil') {
        selectedMontaje = 'Verdadero';
      }
    }

    // Aquí colocas el código para establecer showLinea1Processes, showLinea2Processes y showLinea3Processes
    if (selectedLineOptions.length == 1) {
      String selectedLine = selectedLineOptions.first;
      if (selectedLine == 'Linea 1') {
        showLinea1Processes = true;
        showLinea2Processes = false;
        showLinea3Processes = false;
        showLinea4Processes = false;
        showLinea5Processes = false;
      } else if (selectedLine == 'Linea 2') {
        showLinea1Processes = false;
        showLinea2Processes = true;
        showLinea3Processes = false;
        showLinea4Processes = false;
        showLinea5Processes = false;
      } else if (selectedLine == 'Linea 3') {
        showLinea1Processes = false;
        showLinea2Processes = false;
        showLinea3Processes = true;
        showLinea4Processes = false;
        showLinea5Processes = false;
      }
      else if (selectedLine == 'Linea 4') {
        showLinea1Processes = false;
        showLinea2Processes = false;
        showLinea3Processes = false;
        showLinea5Processes = false;
        showLinea4Processes = true;
      }
      else if (selectedLine == 'Linea 5') {
        showLinea1Processes = false;
        showLinea2Processes = false;
        showLinea3Processes = false;
        showLinea4Processes = false;
        showLinea5Processes = true;
      }
    }
    if (selectedLineOptions.length > 1) {
      // Establecer todas las variables de proceso en falso
      showLinea1Processes = false;
      showLinea2Processes = false;
      showLinea3Processes = false;
      showLinea4Processes = false;
      showLinea5Processes = false;
      // Iterar sobre las opciones seleccionadas
      for (String selectedLine in selectedLineOptions) {
        // Establecer la variable de proceso correspondiente en verdadero según la línea seleccionada
        if (selectedLine == 'Linea 1') {
          showLinea1Processes = true;
        } else if (selectedLine == 'Linea 2') {
          showLinea2Processes = true;
        } else if (selectedLine == 'Linea 3') {
          showLinea3Processes = true;
        } else if (selectedLine == 'Linea 4') {
          showLinea4Processes = true;
        } else if (selectedLine == 'Linea 5') {
          showLinea5Processes = true;
        }
      }
    }
  });
},

),
                        Text(option),
                      ],
                    );
                  }).toList(),
                ),
              ],
            ),

         Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    if (showLinea1Processes) // Mostrar este bloque solo si showLinea1Processes es verdadero
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20),
          Text('Selecciona Procesos para Línea 1'), // Title
          Wrap(
            children: procesosOptions.map((String option) {
              bool optionDisabled = false; // Variable para controlar si la opción está deshabilitada

              // Verificar si la opción ya está seleccionada en otra línea
              if (selectedProcesos2.contains(option) || selectedProcesos3.contains(option)) {
                optionDisabled = true; // Deshabilitar la opción si está seleccionada en otra línea
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Checkbox(
                        value: selectedProcesos.contains(option),
                        onChanged: optionDisabled ? null : (bool? value) {
                          setState(() {
                            if (value != null) {
                              if (value) {
                                selectedProcesos.add(option); // Agrega la opción seleccionada al conjunto
                                selectedProcessStates['$option L1'] = 'Verdadero'; // Actualiza el mapa
                                switch (option) {
                                  case 'Cama':
                                    selectedCamaL1 = 'Verdadero';
                                    break;
                                  case 'Huacal':
                                    selectedHuacalL1 = 'Verdadero';
                                    break;
                                  case 'Soldadura':
                                    selectedSoldaduraL1 = 'Verdadero';
                                    break;
                                  case 'Patines':
                                    selectedPatinesL1 = 'Verdadero';
                                    break;   
                                  case 'Interiores':
                                    selectedInterioresL1 = 'Verdadero';
                                    break;
                                  default:
                                    break;
                                }
                              } else {
                                selectedProcesos.remove(option); // Elimina la opción deseleccionada del conjunto
                                selectedProcessStates['$option L1'] = 'Falso'; // Actualiza el mapa
                                switch (option) {
                                  case 'Cama':
                                    selectedCamaL1 = 'Falso';
                                    break;
                                  case 'Huacal':
                                    selectedHuacalL1 = 'Falso';
                                    break;
                                  case 'Soldadura':
                                    selectedSoldaduraL1 = 'Falso';
                                    break;
                                  case 'Patines':
                                    selectedPatinesL1 = 'Falso';
                                    break;   
                                  case 'Interiores':
                                    selectedInterioresL1 = 'Falso';
                                    break;
                                  default:
                                    break;
                                }
                              }
                            }
                          });
                        },
                      ),
                      Text(option),
                    ],
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    if (showLinea2Processes) // Mostrar este bloque solo si showLinea2Processes es verdadero
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20),
          Text('Selecciona Procesos para Línea 2'), // Title
          Wrap(
            children: procesosOptions2.map((String option) {
              bool optionDisabled = false; // Variable para controlar si la opción está deshabilitada

              // Verificar si la opción ya está seleccionada en otra línea
              if (selectedProcesos.contains(option) || selectedProcesos3.contains(option)) {
                optionDisabled = true; // Deshabilitar la opción si está seleccionada en otra línea
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Checkbox(
                        value: selectedProcesos2.contains(option),
                        onChanged: optionDisabled ? null : (bool? value) {
                          setState(() {
                            if (value != null) {
                              if (value) {
                                selectedProcesos2.add(option); // Agrega la opción seleccionada al conjunto
                                selectedProcessStates['$option L2'] = 'Verdadero'; // Actualiza el mapa
                                switch (option) {
                                  case 'Cama':
                                    selectedCamaL2 = 'Verdadero';
                                    break;
                                  case 'Huacal':
                                    selectedHuacalL2 = 'Verdadero';
                                    break;
                                  case 'Soldadura':
                                    selectedSoldaduraL2 = 'Verdadero';
                                    break;
                                  case 'Patines':
                                    selectedPatinesL2 = 'Verdadero';
                                    break;   
                                  case 'Interiores':
                                    selectedInterioresL2 = 'Verdadero';
                                    break;
                                  default:
                                    break;
                                }
                              } else {
                                selectedProcesos2.remove(option); // Elimina la opción deseleccionada del conjunto
                                selectedProcessStates['$option L2'] = 'Falso'; // Actualiza el mapa
                                switch (option) {
                                  case 'Cama':
                                    selectedCamaL2 = 'Falso';
                                    break;
                                  case 'Huacal':
                                    selectedHuacalL2 = 'Falso';
                                    break;
                                  case 'Soldadura':
                                    selectedSoldaduraL2 = 'Falso';  
                                    break;
                                  case 'Patines':
                                    selectedPatinesL2 = 'Falso';
                                    break;   
                                  case 'Interiores':
                                    selectedInterioresL2 = 'Falso';
                                    break;
                                  default:
                                    break;
                                }
                              }
                            }
                          });
                        },
                      ),
                      Text(option),
                    ],
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    if (showLinea3Processes) // Mostrar este bloque solo si showLinea3Processes es verdadero
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20),
          Text('Selecciona Procesos para Línea 3'), // Title
          Wrap(
            children: procesosOptions3.map((String option) {
              bool optionDisabled = false; // Variable para controlar si la opción está deshabilitada

              // Verificar si la opción ya está seleccionada en otra línea
              if (selectedProcesos.contains(option) || selectedProcesos2.contains(option)) {
                optionDisabled = true; // Deshabilitar la opción si está seleccionada en otra línea
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Checkbox(
                        value: selectedProcesos3.contains(option),
                        onChanged: optionDisabled ? null : (bool? value) {
                          setState(() {
                            if (value != null) {
                              if (value) {
                                selectedProcesos3.add(option); // Agrega la opción seleccionada al conjunto
                                selectedProcessStates['$option L3'] = 'Verdadero'; // Actualiza el mapa
                                switch (option) {
                                  case 'Cama':
                                    selectedCamaL3 = 'Verdadero';
                                    break;
                                  case 'Huacal':
                                    selectedHuacalL3 = 'Verdadero';
                                    break;
                                  case 'Soldadura':
                                    selectedSoldaduraL3 = 'Verdadero';
                                    break;
                                  case 'Patines':
                                    selectedPatinesL3 = 'Verdadero';
                                    break;   
                                  case 'Interiores':
                                    selectedInterioresL3 = 'Verdadero';
                                    break;
                                  default:
                                    break;
                                }
                              } else {
                                selectedProcesos3.remove(option); // Elimina la opción deseleccionada del conjunto
                                selectedProcessStates['$option L3'] = 'Falso'; // Actualiza el mapa
                                switch (option) {
                                  case 'Cama':
                                    selectedCamaL3 = 'Falso';
                                    break;
                                  case 'Huacal':
                                    selectedHuacalL3 = 'Falso';
                                    break;
                                  case 'Soldadura':
                                    selectedSoldaduraL3 = 'Falso';
                                    break;
                                  case 'Patines':
                                    selectedPatinesL3 = 'Falso';
                                    break;  
                                  case 'Interiores':
                                    selectedInterioresL3 = 'Falso';
                                    break;
                                  default:
                                    break;
                                }
                              }
                            }
                          });
                        },
                      ),
                      Text(option),
                    ],
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
  ],
),
              const SizedBox(height: 20),
              
              Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    if (!selectedLineOptions.contains('Textil'))
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Selecciona la Nave donde se va a trabajar Pintura'), // Title
          Wrap(
            children: naveOptions.map((String option) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Checkbox(
                    value: selectedNaveOptions.contains(option),
                    onChanged: (bool? value) {
                      setState(() {
                        if (value != null && value) {
                          selectedNaveOptions.add(option); // Agregar la opción seleccionada
                        } else {
                          selectedNaveOptions.remove(option); // Eliminar la opción deseleccionada
                        }
                      });
                    },
                  ),
                  Text(option),
                ],
              );
            }).toList(),
          ),
        ],
      ),
  ],
),

              const SizedBox(height: 20),
              const Text('Pausa'), // Title
              DropdownButton<String>(
                value: selectedPausa,
                items: pausaOptions.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedPausa = newValue!;
                    selectedAtrasado = 'Falso';
                    selectedCorrecto = 'Falso';
                    selectedProximo = 'Falso';
                    selectedEspera = 'Falso';
                  });
                },
              ),
              const SizedBox(height: 20),
              const Text('Atrasado'), // Title
              DropdownButton<String>(
                value: selectedAtrasado,
                items: atrasadoOptions.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedAtrasado = newValue!;
                    selectedPausa = 'Falso';
                    selectedCorrecto = 'Falso';
                    selectedProximo = 'Falso';
                    selectedEspera = 'Falso';
                  });
                },
              ),
              const SizedBox(height: 20),
              const Text('Correcto'), // Title
              DropdownButton<String>(
                value: selectedCorrecto,
                items: correctoOptions.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedCorrecto = newValue!;
                    selectedPausa = 'Falso';
                    selectedAtrasado = 'Falso';
                    selectedProximo = 'Falso';
                    selectedEspera = 'Falso';
                  });
                },
              ),
              const SizedBox(height: 20),
               const Text('Proximo'), // Title
              DropdownButton<String>(
                value: selectedProximo,
                items: proximoOptions.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedProximo = newValue!;
                    selectedPausa = 'Falso';
                    selectedAtrasado = 'Falso';
                    selectedCorrecto = 'Falso';
                    selectedEspera = 'Falso';
                  });
                },
              ),
              const SizedBox(height: 20),
              const Text('Espera de Material'), // Title
              DropdownButton<String>(
                value: selectedEspera,
                items: esperaOptions.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedEspera = newValue!;
                    selectedAtrasado = 'Falso';
                    selectedCorrecto = 'Falso';
                    selectedProximo = 'Falso';
                    selectedPausa = 'Falso';
                  });
                },
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Fecha de Inicio'),
                        ElevatedButton(
                          onPressed: () => _selectDate(context, true),
                          child: Text(selectedStartDate != null ? selectedStartDate.toString() : 'Seleccionar fecha'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Fecha de Fin'),
                        ElevatedButton(
                          onPressed: () => _selectDate(context, false),
                          child: Text(selectedEndDate != null ? selectedEndDate.toString() : 'Seleccionar fecha'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              
              ElevatedButton(
                onPressed: _areAllFieldsValid()
                    ? () {
                        _saveDataToAirtable({
                          'Nombre del Proyecto': projectNameController.text,
                          'Piezas': int.parse(piecesController.text),
                          'Hora': 'No Hay Hora',
                          'Soldadura': 0,
                          'Restante Soldadura': int.parse(piecesController.text),
                          'Avance Soldadura L1': 0,
                          'Restante Soldadura L1': int.parse(piecesController.text),
                          'Avance Soldadura L2': 0,
                          'Restante Soldadura L2': int.parse(piecesController.text),
                          'Avance Soldadura L3': 0,
                          'Restante Soldadura L3': int.parse(piecesController.text),
                          'Pintura': 0,
                          'Restante Patines': int.parse(piecesController.text),
                          'Patines': 0    ,
                          'Restante Pintura': int.parse(piecesController.text),
                          'Montaje Estado': selectedMontaje,
                          'Montaje': 0,
                          'Restante Montaje': int.parse(piecesController.text),
                          'Entregados': 0    ,
                          'Restante Entregados': int.parse(piecesController.text),
                          'Liberados': 0,
                          'Restante Liberados': int.parse(piecesController.text),   
                          'Liberados Pintura': 0,
                          'Restante Liberados Pintura': int.parse(piecesController.text),   
                          'Liberados Soldadura': 0,
                          'Restante Liberados Soldadura': int.parse(piecesController.text),                     
                          'Nave 1': selectedNaveOptions.contains('Nave 1') ? 'Verdadero' : 'Falso',
                          'Nave 2': selectedNaveOptions.contains('Nave 2') ? 'Verdadero' : 'Falso',
                          'Fecha de inicio': selectedStartDate.toString(),
                          'Fecha de fin': selectedEndDate.toString(),
                          'Linea 1': selectedLineOptions.contains('Linea 1') ? 'Verdadero' : 'Falso',
                          'Linea 2': selectedLineOptions.contains('Linea 2') ? 'Verdadero' : 'Falso',
                          'Linea 3': selectedLineOptions.contains('Linea 3') ? 'Verdadero' : 'Falso',
                          'Linea 4': selectedLineOptions.contains('Montaje') ? 'Verdadero' : 'Falso',
                          'Linea 5': selectedLineOptions.contains('Textil') ? 'Verdadero' : 'Falso',
                          'Cama L1': selectedCamaL1,
                          'Huacal L1': selectedHuacalL1 ,
                          'Interiores L1': selectedInterioresL1,
                          'Soldadura L1': selectedSoldaduraL1,
                          'Patines L1': selectedPatinesL1,
                          'Cama L2': selectedCamaL2,
                          'Huacal L2': selectedHuacalL2,
                          'Patines L2': selectedPatinesL2,
                          'Interiores L2': selectedInterioresL2,
                          'Soldadura L2': selectedSoldaduraL2,
                          'Cama L3': selectedCamaL3,
                          'Huacal L3': selectedHuacalL3,
                          'Patines L3': selectedPatinesL3,
                          'Interiores L3': selectedInterioresL3,
                          'Soldadura L3': selectedSoldaduraL1,
                          'Cama': 0,
                          'Restante Cama': int.parse(piecesController.text),
                          'Huacal': 0,
                          'Restante Huacal': int.parse(piecesController.text),  
                          'Textil': 0,
                          'Restante Textil': int.parse(piecesController.text), 
                          'Pausa': selectedPausa,
                          'Atrasado': selectedAtrasado,
                          'En Linea': selectedCorrecto,
                          'Proximo': selectedProximo,
                          'Espera De Material': selectedEspera,
                          'Nota Linea 1 y 2': 'No hay notas',
                          'Nota Linea 3 y 4': 'No hay notas',
                          'Nota Linea 5 y 6': 'No hay notas',
                          'Nota Cama': 'No hay notas',
                          'Nota Huacal': 'No hay notas',
                          'Nota Soldadura Linea': 'No hay notas',
                          'Nota Interiores': 'No hay notas',
                          'Nota Textil': 'No hay notas',
                          'Nota Patines': 'No hay notas',
                          'Nota Nave 1': 'No hay notas',
                          'Nota Nave 2': 'No hay notas',
                          'Nota Soldadura': 'No hay notas',
                          'Nota Montaje': 'No hay notas',
                          'Nota Pintura': 'No hay notas',
                          'Nota Liberacion': 'No hay notas',
                          'Nota Liberacion Pintura': 'No hay notas',
                          'Nota Liberacion Soldadura': 'No hay notas',
                          'Nota Entregados': 'No hay notas',
                        });
                      }
                    : null,
                child: Text('Aceptar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

}
