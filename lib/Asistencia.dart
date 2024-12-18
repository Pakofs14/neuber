import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'package:url_launcher/url_launcher.dart';


void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Asistencias',
      home: const AsistenciasPage(),
    );
  }
}

class AsistenciasPage extends StatefulWidget {
  const AsistenciasPage({Key? key}) : super(key: key);

  @override
  _AsistenciasPageState createState() => _AsistenciasPageState();
}

class _AsistenciasPageState extends State<AsistenciasPage> {
  html.File? selectedFile; // Variable para almacenar el archivo seleccionado
  bool _isButtonEnabled = false; // Estado del botón, inicialmente deshabilitado
  List<Map<String, String>> validationTable = []; // Definición de la tabla
  bool _showTable = false; // Variable para mostrar la tabla 
 TextEditingController queryController = TextEditingController();



  @override
void initState() {
    super.initState();
  }

void _enableButton() {
    setState(() {
      _isButtonEnabled = true;
    });
  }

void _checkFile() {
    if (selectedFile != null && selectedFile!.name.endsWith('.xlsx')) {
      _readExcel(selectedFile!);
    } else {
      _showErrorDialog();
    }
  }

void _showSuccessDialog(int totalRecords, int emptyRecords) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Éxito'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('El archivo Excel se ha cargado correctamente.'),
          SizedBox(height: 10),
          Text('Total de registros encontrados: $totalRecords'),
          Text('Total de registros vacíos: $emptyRecords'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            setState(() {
              _isButtonEnabled = true; // Habilitar los botones solo cuando se confirma el éxito
            });
            Navigator.of(context).pop();
          },
          child: Text('Aceptar'),
        ),
      ],
    ),
  );
}

Future<void> _openFileExplorer() async {
  final html.FileUploadInputElement input = html.FileUploadInputElement();
  input.accept = '.xlsx'; // Solo acepta archivos Excel
  input.click();
  input.onChange.listen((event) {
    final files = input.files;
    if (files != null && files.isNotEmpty) {
      setState(() {
        selectedFile = files[0];
        _isButtonEnabled = false; // Deshabilitar los botones al seleccionar un archivo
      });
      _checkFile();
    }
  });
}

void _showErrorDialog() {
  _isButtonEnabled = false;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text('Por favor, selecciona un archivo Excel (.xlsx).'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Aceptar'),
          ),
        ],
      ),
    );
  }

void _readExcel(html.File file) async {
  final blob = html.Blob([file.slice()], 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
  final url = html.Url.createObjectUrlFromBlob(blob);
  final req = html.HttpRequest();
  req.open('GET', url);
  req.responseType = 'arraybuffer';
  req.send();
  req.onLoadEnd.listen((html.ProgressEvent progressEvent) async {
    if (req.status == 200) {
      final ByteData data = ByteData.view((req.response as ByteBuffer).asUint8List().buffer);
      final excel = Excel.decodeBytes(data.buffer.asUint8List());
      if (excel.tables.keys.contains('Reporte de Asistencia')) {
        final table = excel.tables['Reporte de Asistencia']!;
        int totalRecords = 0;
        int emptyRecords = 0; // Contador para registros vacíos

        for (int i = 4; i < table.rows.length; i++) {
          final row = table.rows[i];
          bool isEmpty = true;

          if (row.length >= 3 &&
              row[0]?.value != null &&
              row[1]?.value != null &&
              row[2]?.value != null) {
            totalRecords++;
            isEmpty = false;
          }

          if (isEmpty) {
            emptyRecords++;
          }
        }

        if (totalRecords > 0) {
          // Si se encontraron registros válidos, muestra el cuadro de diálogo de éxito
          _showSuccessDialog(totalRecords, emptyRecords);
        } else {
          // Si todos los registros son vacíos, muestra un mensaje indicando que no se encontraron registros
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Éxito'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('El archivo Excel se ha cargado correctamente.'),
                  SizedBox(height: 10),
                  Text('No se encontraron registros.'),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Aceptar'),
                ),
              ],
            ),
          );
        }
      } else {
        _isButtonEnabled = false;
        // Si no se encuentra la hoja "Reporte de Asistencia", muestra un mensaje de diálogo
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Error'),
            content: Text('No se encontró la hoja "Reporte de Asistencia" en el archivo Excel.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Aceptar'),
              ),
            ],
          ),
        );
      }
    } else {
      print('Failed to load spreadsheet. Status code: ${req.status}');
    }
    html.Url.revokeObjectUrl(url);
  });
}

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text(
        'Asistencia Reloj Checador',
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
          icon: Icon(Icons.search, color: Colors.white),
          onPressed: _showSearchDialog,
        ),
      ],
    ),

    body: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Flexible(
                flex: 1,
                child: ElevatedButton(
                  onPressed: _openURL,
                  child: Text('Desproteger Archivo Excel'),
                ),
              ),
              Flexible(
                flex: 1,
                child: ElevatedButton(
                  onPressed: _openURL2,
                  child: Text('Actualizar Formato'),
                ),
              ),
              Flexible(
  flex: 1,
  child: ElevatedButton(
    onPressed: _openFileExplorer, 
    child: Text('Seleccionar Archivo Excel'),
  ),
),
              Flexible(
                flex: 1,
                child: ElevatedButton(
                  onPressed: _isButtonEnabled ? _printPreviousRowContent : null,
                  child: Text('Mostrar Registros Vacíos'),
                ),
              ),
              Flexible(
                flex: 1,
                child: ElevatedButton(
                  onPressed: _isButtonEnabled ? _tableValidation: null,
                  child: Text('Mostrar Validación'),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          if (_showTable)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: _buildTable(validationTable),
            ),
        ],
      ),
    ),
  );
}

void _openURL() {
    const url = 'https://products.aspose.app/cells/es/unlock';
    launch(url);
  }

void _openURL2() {
    const url = 'https://convertio.co/es/xls-xlsx/';
    launch(url);
  }

void _printPreviousRowContent() {
    if (selectedFile != null) {
      final reader = html.FileReader();
      reader.onLoad.listen((event) {
        final data = reader.result;
        final List<int> bytes = data as List<int>;
        final excel = Excel.decodeBytes(Uint8List.fromList(bytes));
        final table = excel.tables[excel.tables.keys.first]!;
        List<String> emptyRowsContent = [];

        for (int i = 8; i < table.rows.length; i++) {
          final row = table.rows[i];
          bool isEmpty = true;

          if (row.length >= 3) {
            for (var cell in row) {
              if (cell?.value != null) {
                isEmpty = false;
                break;
              }
            }
          }

          if (isEmpty) {
            final previousRow = table.rows[i - 1];
            String previousRowContent = '';
            for (int j = 0; j < previousRow.length; j++) {
              final cell = previousRow[j];
              if (cell != null && cell.value != null) {
                String cellValue = cell.value.toString();
                previousRowContent += '$cellValue ';
              }
            }
            emptyRowsContent.add(previousRowContent);
          }
        }

        if (emptyRowsContent.isNotEmpty) {
          _showEmptyRowsDialog(emptyRowsContent);
        } else {
          print('No se encontraron filas vacías.');
        }
      });

      reader.onError.listen((event) {
        print('Error al leer el archivo: ${reader.error}');
      });

      reader.readAsArrayBuffer(selectedFile!);
    }
  }

void _showEmptyRowsDialog(List<String> emptyRowsContent) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Registros Vacíos'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: emptyRowsContent.map((rowContent) => Text(rowContent)).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cerrar'),
          ),
        ],
      ),
    );
  }

void _tableValidation() {
  if (selectedFile != null) {
    final reader = html.FileReader();
    reader.onLoad.listen((event) {
      final data = reader.result;
      final List<int> bytes = data as List<int>; 
      final excel = Excel.decodeBytes(Uint8List.fromList(bytes));
      final table = excel.tables[excel.tables.keys.first]!;
      int totalRecords = 0;
      // ignore: unused_local_variable
      int emptyRecords = 0;
      int comida = 0;
      List<String> diasSemana = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];
      List<Map<String, String>> rowDataList = [];

      for (int i = 4; i < table.rows.length; i++) {
        final row = table.rows[i];
        bool isEmpty = true;
// Declarar cantidadHoras aquí

        if (row.length >= 3 &&
            row[0]?.value != null &&
            row[1]?.value != null &&
            row[2]?.value != null) {
          totalRecords++;
          isEmpty = false;

          final previousRow = table.rows[i - 1];
          String previousRowContent = '';

          for (int j = 0; j < previousRow.length; j++) {
            final cell = previousRow[j];
            if (cell != null && cell.value != null) {
              String cellValue = cell.value.toString();
              previousRowContent += '$cellValue ';
              String hours = cell.value.toString().replaceAllMapped(RegExp(r'\d{2}(?=\d{2})'), (match) => '${match.group(0)} ');
              hours.split(' ');
// Sumar las horas del ciclo actual al total
            }
          }
          
          // Guardar el primer y último chequeo para cada día de la semana
          Map<String, List<DateTime>> firstAndLastChecks = {};

          for (int j = 0; j < row.length; j++) {
            final cell = row[j];
            if (cell != null && cell.value != null) {
              String hours = cell.value.toString().replaceAllMapped(RegExp(r'\d{2}(?=\d{2})'), (match) => '${match.group(0)} ');
              List<String> horasSeparadas = hours.split(' ');
              int cantidadHoras = horasSeparadas.length;

              // Convertir las cadenas de texto a DateTime
              DateTime firstCheckTime = DateTime.parse('1970-01-01T${horasSeparadas.first}:00');
              DateTime lastCheckTime = DateTime.parse('1970-01-01T${horasSeparadas.last}:00');

              if (firstAndLastChecks.containsKey(diasSemana[j])) {
                // Si ya existe una lista para este día, actualiza el último chequeo
                firstAndLastChecks[diasSemana[j]]![1] = lastCheckTime;
              } else {
                // Si no existe una lista para este día, crea una nueva lista con el primer y último chequeo
                firstAndLastChecks[diasSemana[j]] = [firstCheckTime, lastCheckTime];
              }

              // Obtener la cadena del primer chequeo y del último chequeo
              String firstCheckTimeString = firstCheckTime.toIso8601String().substring(11, 16);
              String lastCheckTimeString = lastCheckTime.toIso8601String().substring(11, 16);

              String earlyArrivalMsg = '';
              String onTimeMsg = '';
              String lateArrivalMsg = '';
              String earlyExitMsg = '';
              String onTimeExitMsg = '';
              String lateExitMsg = '';
              String timeWorked = '';

              // Comparar con 08:00
              if (firstCheckTimeString.compareTo('08:00') < 0) {
                // Si el primer chequeo es antes de las 08:00
                earlyArrivalMsg = '${firstCheckTime.toIso8601String().substring(11, 16)} Llegó temprano';
              } else if (firstCheckTimeString.compareTo('08:00') == 0) {
                // Si el primer chequeo es a las 08:00 exactamente
                onTimeMsg = '${firstCheckTime.toIso8601String().substring(11, 16)} Llegó a tiempo';
              } else {
                // Si el primer chequeo es después de las 08:00
                lateArrivalMsg = '${firstCheckTime.toIso8601String().substring(11, 16)} Llegó tarde';
              }

              // Comparar con 17:30
              if (lastCheckTimeString.compareTo('17:30') < 0) {
                // Si el último chequeo es antes de las 17:30
                earlyExitMsg = '${lastCheckTime.toIso8601String().substring(11, 16)} Salió temprano';
              } else if (lastCheckTimeString.compareTo('17:30') == 0) {
                // Si el último chequeo es a las 17:30 exactamente
                onTimeExitMsg = '${lastCheckTime.toIso8601String().substring(11, 16)} Salió a tiempo';
              } else {
                // Si el último chequeo es después de las 17:30
                lateExitMsg = '${lastCheckTime.toIso8601String().substring(11, 16)} Salió tarde';
              }

              // Calcular las horas trabajadas
              Duration timeWorkedDuration = lastCheckTime.difference(firstCheckTime);
              int hoursWorked = timeWorkedDuration.inHours;
              int minutesWorked = timeWorkedDuration.inMinutes.remainder(60);

              // Asegurarse de que las horas trabajadas no sean negativas
              if (hoursWorked < 0 || minutesWorked < 0) {
                hoursWorked = 0;
                minutesWorked = 0;
              }

              // Formatear el tiempo trabajado
              timeWorked = '${hoursWorked.toString().padLeft(2, '0')}:${minutesWorked.toString().padLeft(2, '0')}';
              
              // Asignar el mensaje correspondiente a la variable arrivalMsg y exitMsg
              String arrivalMsg = earlyArrivalMsg.isNotEmpty ? earlyArrivalMsg : onTimeMsg.isNotEmpty ? onTimeMsg : lateArrivalMsg;
              String exitMsg = earlyExitMsg.isNotEmpty ? earlyExitMsg : onTimeExitMsg.isNotEmpty ? onTimeExitMsg : lateExitMsg;

              String secondHour = ''; // Declarar secondHour fuera del bucle para que pueda ser utilizado después
String thirdHour = ''; // Declarar thirdHour fuera del bucle para que pueda ser utilizado después

// Procesar las horas
for (int k = 0; k < horasSeparadas.length; k++) {
  if (k == 1) {
    // Si es la segunda hora registrada
    secondHour = horasSeparadas[k];
  } else if (k == 2) {
    // Si es la tercera hora registrada
    thirdHour = horasSeparadas[k];
  }
}

              // Agregar el mensaje al contenido de la fila
              String horasRegistradas;
              if (horasSeparadas.length == 4) {
                horasRegistradas = '${diasSemana[j]}: $arrivalMsg - $exitMsg - $timeWorked hrs en planta\n';

if (secondHour.isNotEmpty && thirdHour.isNotEmpty) {
  // Convertir las cadenas de texto a objetos DateTime
  DateTime secondTime = DateTime.parse('1970-01-01T$secondHour:00');
  DateTime thirdTime = DateTime.parse('1970-01-01T$thirdHour:00');

  // Calcular la diferencia
  Duration difference = thirdTime.difference(secondTime);

          comida= difference.inMinutes;
}
              } else {
                horasRegistradas = '${diasSemana[j]}: $arrivalMsg - $exitMsg - $timeWorked hrs en planta\n';
              }

              // Guardar los datos en una lista de mapa para pasarlos a _createTable
              Map<String, String> rowData = {
                'Registro': totalRecords.toString(),
                'Datos': previousRowContent,
                'Horas': horasRegistradas,
                'IsLessThanNineHours': timeWorked,
                'comida': comida.toString(),
                'checks': cantidadHoras.toString(), // Convertir a String
              };
              rowDataList.add(rowData);
            }
          }

          firstAndLastChecks.forEach((day, checks) {
            if (checks.length < 2) {
              // Si no hay suficientes registros para calcular el primer y último chequeo
            }
          });
        }

        if (isEmpty) {
          emptyRecords++;
        }
      }

      if (totalRecords > 0) {
        // Activar la variable _showTable cuando se obtengan registros válidos
        setState(() {
          _showTable = true;
        });
        _createTable(rowDataList);
      } else {
        print('No se encontraron registros.');
      }
    });

    reader.onError.listen((event) {
      print('Error al leer el archivo: ${reader.error}');
    });

    reader.readAsArrayBuffer(selectedFile!);
  }
}

void _createTable(List<Map<String, dynamic>> rowDataList) {
  // Convertir cada elemento de tipo Map<String, dynamic> a Map<String, String>
  
  List<Map<String, String>> convertedDataList = rowDataList.map((rowData) {
    Map<String, String> convertedRowData = {};
    rowData.forEach((key, value) {
      convertedRowData[key] = value.toString();
    });
    return convertedRowData;
  }).toList();

  // Actualizar la tabla de validación
  setState(() {
    validationTable = convertedDataList;
  });
}

Widget _buildTable(List<Map<String, dynamic>> rowDataList) {
  // Construir la tabla de Flutter
  List<DataRow> rows = [];
  String previousRegistro = '';
  bool isFirstRegistroFound = false; // Bandera para rastrear si se ha encontrado el primer registro

  for (var data in rowDataList) {
    String registro = data['Registro'].toString();
    String isLessThanNineHours = data['IsLessThanNineHours']; // Cambiar el tipo a String
    int cantidadHoras = int.parse(data['checks']); // Obtener la cantidad de horas como entero
    int comida = int.parse(data['comida']);

    // Verificar si el valor del registro cambió
    if (registro != previousRegistro) {
      // Si ya se encontró el primer registro, se pueden agregar celdas después de él
      if (isFirstRegistroFound) {
        rows.add(DataRow(cells: [
          DataCell(Text('')), // Puedes ajustar esto según el número de columnas
          DataCell(Text('')),
          DataCell(Text('')),
          DataCell(Text('')),
          DataCell(Text('')), 
          DataCell(Text('')), // Agregar una celda vacía si cantidadHoras es igual a 4
        ]));
      } else {
        // Si este es el primer registro, se marca la bandera como verdadera
        isFirstRegistroFound = true;
      }
    }

    // Verificar si los valores no son nulos antes de acceder a ellos
    // Determinar el icono de advertencia a mostrar
    Widget warningIcon;
    if (cantidadHoras == 1) {
      warningIcon = Icon(Icons.punch_clock_outlined, color: Colors.red);
    } else if (cantidadHoras == 2) {
      warningIcon = Icon(Icons.punch_clock_outlined, color: Colors.yellow);
    } else if (cantidadHoras == 4) {
      warningIcon = Icon(Icons.punch_clock_outlined, color: Colors.green);
    } else if (cantidadHoras == 3) {
      warningIcon = Icon(Icons.punch_clock_outlined, color: Colors.orange);  
    } else if (cantidadHoras > 4) {
      warningIcon = Icon(Icons.punch_clock_outlined, color: Colors.orange);
    } else {
      // Handle other cases or set a default icon
      warningIcon = Icon(Icons.error, color: Colors.black); // For example
    }

    // Determinar el icono de check a mostrar
    Widget checkIcon = isLessThanNineHours.compareTo('09:30') < 0 ? Icon(Icons.close, color: Colors.red) : Icon(Icons.check, color: Colors.green);

    // Agregar fila de datos actual con los iconos correspondientes
    // Agregar fila de datos actual con los iconos correspondientes
rows.add(DataRow(cells: [
DataCell(Text(registro, style: TextStyle(fontSize: 10))), // Adjust the font size
DataCell(Text(data['Datos'].toString(), style: TextStyle(fontSize: 10))), // Adjust the font size
DataCell(Text(data['Horas'].toString(), style: TextStyle(fontSize: 10))), // Adjust the font size
DataCell(checkIcon), // Check icon cell
DataCell(
  GestureDetector(
    onTap: () {
      _showChequeosDialog(cantidadHoras); // Show dialog on tap
    },
    child: warningIcon, // Warning icon wrapped with GestureDetector
  ),
),
// Mostrar la celda de comida solo si cantidadHoras es igual a 4
if (cantidadHoras == 4)
  DataCell(
    GestureDetector(
      onTap: () {
        _showMinutosComida(comida);
      },
      child: comida < 30 ? Icon(Icons.apple, color: Colors.green) : Icon(Icons.apple, color: Colors.red), // Determinar el icono de comida según la cantidad de comida
    ),
  )
else // Mostrar el icono de advertencia de color rojo si cantidadHoras no es igual a 4
  DataCell(
    GestureDetector(
      onTap: () {
        _showComidasDialog();
      },
      child: Icon(Icons.warning, color: Colors.red), // Warning icon wrapped with GestureDetector
    ),
  ),
]));
    previousRegistro = registro;
    }

  return SingleChildScrollView(
    scrollDirection: Axis.vertical,
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        
        horizontalMargin: 5, 
        // Adjust the horizontal margin
        columns: [
          DataColumn(label: Text('Registro')),
          DataColumn(label: Text('Datos')),
          DataColumn(label: Text('Horas')),
          DataColumn(label: Text('Check')),
          DataColumn(label: Text('Chequeos')), 
          if (rowDataList.any((data) => int.parse(data['checks']) == 4)) DataColumn(label: Text('Comidas')), // Agregar la columna de comidas solo si hay alguna fila con cantidadHoras igual a 4
        ],
        rows: rows,
      ),
    ),
  );
}

void _showChequeosDialog(int cantidadChequeos) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Chequeos'),
        content: Text('Este empleado cumplio con $cantidadChequeos chequeos.'),
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

void _showComidasDialog() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Chequeos'),
        content: Text('Este empleado no chequeo su comida'),
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

void _showMinutosComida(int comida) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Chequeos'),
        content: Text('Este empleado uso $comida min de comida.'),
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

void _showSearchDialog() {
    if (_showTable == false){
    // Mostrar mensaje emergente si no se ha cargado ningún archivo Excel ni se ha mostrado la tabla
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Alerta'),
          content: Text('La tabla no está visible.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el diálogo
              },
              child: Text('Aceptar'),
            ),
          ],
        );
      },
    );
  } else {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Buscar'),
        content: TextField(
          controller: queryController,
          decoration: InputDecoration(
            labelText: 'Ingrese el nombre',
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _searchText(queryController.text);
            },
            child: Text('Buscar'),
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
}
}

void _searchText(String searchText) {
  bool found = false;
  Set<String> matchedRecords = Set(); // Usar un Set en lugar de una lista

  // Iterar sobre la lista de registros y buscar coincidencias parciales
  for (var data in validationTable) {
    if (data['Datos']!.toLowerCase().contains(searchText.toLowerCase())) {
      found = true;
      matchedRecords.add(data['Registro']!); // Agregar el registro coincidente al Set
    }
  }

  // Mostrar un diálogo con los resultados de la búsqueda
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Resultado de la Búsqueda'),
        content: found
            ? Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Se encontro a "$searchText"'),
                  SizedBox(height: 10),
                  Text('Es el Registro: ${matchedRecords.join(", ")}'),
                ],
              )
            : Text('No se encontraron registros con el texto "$searchText" '),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Aceptar'),
          ),
        ],
      );
    },
  );
}

}


