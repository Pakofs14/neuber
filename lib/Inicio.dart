import 'package:flutter/material.dart';
import 'package:flutter_exit_app/flutter_exit_app.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:neuber/RecursosHumanos.dart';
import 'package:neuber/Asistencia.dart';
import 'package:neuber/Historico.dart';
import 'package:neuber/LibPintura.dart';
import 'package:neuber/Ordenes.dart';
import 'package:neuber/LibSoldadura.dart';
import 'package:neuber/Montaje.dart';
import 'package:neuber/Planeacion.dart';
import 'package:neuber/Nave1.dart';
import 'package:neuber/Prototipos.dart';
import 'package:neuber/Nave2.dart';
import 'package:neuber/Linea1y2.dart';
import 'package:neuber/Linea3y4.dart';
import 'package:neuber/Linea5y6.dart';
import 'package:neuber/Liberacion.dart';
import 'package:neuber/Entregas.dart';
import 'package:neuber/Textil.dart';
import 'package:neuber/Proyectos.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart'; 
import'dart:typed_data';



class InicioPage extends StatefulWidget {
  const InicioPage({Key? key}) : super(key: key);

  @override
  _InicioPageState createState() => _InicioPageState();
}

class _InicioPageState extends State<InicioPage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isLoading = true;

  final List<String> imagePaths = [
    'assets/wallpaper.jpg',
    'assets/neuber1.jpg',
    'assets/neuber2.jpg',
    'assets/neuber3.jpg',
    'assets/neuber4.jpg',
    'assets/neuber5.jpg',
    'assets/neuber6.jpg',
    'assets/neuber7.jpg',
  ];

// Add this at the top of your file or in a utility class
Uint8List kTransparentImage = Uint8List.fromList([
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D,
  0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
  0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00,
  0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49,
  0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82
]);

@override
void initState() {
  super.initState();
  _animationController = AnimationController(
    duration: const Duration(milliseconds: 300),
    vsync: this,
  );
    
  // Ensure binding is initialized before loading images
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _loadImagesAndContent();
  });
}

Future<void> _loadImagesAndContent() async {
  try {
    // Ensure Flutter binding is initialized
    WidgetsFlutterBinding.ensureInitialized();

    // Precache images
    for (String path in imagePaths) {
      await precacheImage(AssetImage(path), context);
    }
    
    // Simulate loading delay
    await Future.delayed(const Duration(seconds: 2));
    
    // Update loading state if the widget is still mounted
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  } catch (e) {
    print('Error loading images: $e');
    // Optionally, set _isLoading to false even if there's an error
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }
}

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

Future<void> _showExitConfirmationDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('¿Estás seguro de que deseas salir?'),
          actions: [
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Salir'),
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el diálogo
                FlutterExitApp.exitApp(); // Cierra la aplicación
              },
            ),
          ],
        );
      },
    );
  }
  
Future<void> _showLoginDialog(BuildContext context) async {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Iniciar sesión para continuar'),
        content: Column(
          mainAxisSize: MainAxisSize.min, // Tamaño más pequeño
          children: [
            TextField(
              controller: usernameController,
              decoration: InputDecoration(labelText: 'Usuario'),  
            ),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Contraseña'),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: Text('Cancelar'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text('Aceptar'),
            onPressed: () {
              // Aquí debes realizar la verificación de las credenciales
              String username = usernameController.text;
              String password = passwordController.text;

              if (username == 'eduardo' && password == '1901') {
                Navigator.of(context).pop(); // Cierra el diálogo
                _navigateToPlaneacionPage(context);
              } else {
                // Muestra un mensaje de error
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Credenciales incorrectas'),
                  ),
                );
              }
            },
          ),
        ],
      );
    },
  );
}

Future<void> _showLoginDialog2(BuildContext context) async {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Iniciar sesión para continuar'),
        content: Column(
          mainAxisSize: MainAxisSize.min, // Tamaño más pequeño
          children: [
            TextField(
              controller: usernameController,
              decoration: InputDecoration(labelText: 'Usuario'),
            ),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Contraseña'),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: Text('Cancelar'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text('Aceptar'),
            onPressed: () {
              // Aquí debes realizar la verificación de las credenciales
              String username = usernameController.text;
              String password = passwordController.text;

              if (username == 'elizabeth' && password == '0000') {
                Navigator.of(context).pop(); // Cierra el diálogo
                _navigateToRHPage(context);
              } else {
                // Muestra un mensaje de error
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Credenciales incorrectas'),
                  ),
                );
              }
            },
          ),
        ],
      );
    },
  );
}

Future<void> _showLoginDialog3(BuildContext context) async {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Iniciar sesión para continuar'),
        content: Column(
          mainAxisSize: MainAxisSize.min, // Tamaño más pequeño
          children: [
            TextField(
              controller: usernameController,
              decoration: InputDecoration(labelText: 'Usuario'),
            ),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Contraseña'),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: Text('Cancelar'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text('Aceptar'),
            onPressed: () {
              // Aquí debes realizar la verificación de las credenciales
              String username = usernameController.text;
              String password = passwordController.text;

              if (username == 'elizabeth' && password == '0000') {
                Navigator.of(context).pop(); // Cierra el diálogo
                _navigateToAssistPage(context);
              } else {
                // Muestra un mensaje de error
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Credenciales incorrectas'),
                  ),
                );
              }
            },
          ),
        ],
      );
    },
  );
}

void _navigateToInicioPage(BuildContext context) {
  Navigator.of(context).push(
    PageRouteBuilder(
      transitionDuration: Duration(milliseconds: 500), // Puedes ajustar la duración según tus preferencias
      pageBuilder: (_, __, ___) => InicioPage(),
      transitionsBuilder: (_, Animation<double> animation, __, Widget child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    ),
  );
}

void _navigateToProyectosPage(BuildContext context) {
  Navigator.of(context).push(
    PageRouteBuilder(
      transitionDuration: Duration(milliseconds: 500), // Puedes ajustar la duración según tus preferencias
      pageBuilder: (_, __, ___) => ProyectosPage(),
      transitionsBuilder: (_, Animation<double> animation, __, Widget child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    ),
  );
}

void _navigateToLinea1y2Page(BuildContext context) {
  Navigator.of(context).push(
    PageRouteBuilder(
      transitionDuration: Duration(milliseconds: 500), // Puedes ajustar la duración según tus preferencias
      pageBuilder: (_, __, ___) => Linea1y2Page(),
      transitionsBuilder: (_, Animation<double> animation, __, Widget child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    ),
  );
}

void _navigateToLinea3y4Page(BuildContext context) {
  Navigator.of(context).push(
    PageRouteBuilder(
      transitionDuration: Duration(milliseconds: 500), // Puedes ajustar la duración según tus preferencias
      pageBuilder: (_, __, ___) => Linea3y4Page(),
      transitionsBuilder: (_, Animation<double> animation, __, Widget child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    ),
  );
}

void _navigateToLinea5y6Page(BuildContext context) {
  Navigator.of(context).push(
    PageRouteBuilder(
      transitionDuration: Duration(milliseconds: 500), // Puedes ajustar la duración según tus preferencias
      pageBuilder: (_, __, ___) => Linea5y6Page(),
      transitionsBuilder: (_, Animation<double> animation, __, Widget child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    ),
  );
}

void _navigateToMontajePage(BuildContext context) {
  Navigator.of(context).push(
    PageRouteBuilder(
      transitionDuration: Duration(milliseconds: 500), // Puedes ajustar la duración según tus preferencias
      pageBuilder: (_, __, ___) => MontajePage(),
      transitionsBuilder: (_, Animation<double> animation, __, Widget child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    ),
  );
}

void _navigateToTextilPage(BuildContext context) {
  Navigator.of(context).push(
    PageRouteBuilder(
      transitionDuration: Duration(milliseconds: 500), // Puedes ajustar la duración según tus preferencias
      pageBuilder: (_, __, ___) => TextilPage(),
      transitionsBuilder: (_, Animation<double> animation, __, Widget child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    ),
  );
}

void _navigateToPlaneacionPage(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: Duration(milliseconds: 500),
        pageBuilder: (_, __, ___) => PlaneacionPage(),
        transitionsBuilder: (_, Animation<double> animation, __, Widget child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }
  
void _navigateToNave1Page(BuildContext context) {
  Navigator.of(context).push(
    PageRouteBuilder(
      transitionDuration: Duration(milliseconds: 500), // Puedes ajustar la duración según tus preferencias
      pageBuilder: (_, __, ___) => Nave1Page(),
      transitionsBuilder: (_, Animation<double> animation, __, Widget child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    ),
  );
}

void _navigateToNave2Page(BuildContext context) {
  Navigator.of(context).push(
    PageRouteBuilder(
      transitionDuration: Duration(milliseconds: 500), // Puedes ajustar la duración según tus preferencias
      pageBuilder: (_, __, ___) => Nave2Page(),
      transitionsBuilder: (_, Animation<double> animation, __, Widget child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    ),
  );
}

void _navigateToHistoricoPage(BuildContext context) {

  Navigator.of(context).push(
    PageRouteBuilder(
      transitionDuration: Duration(milliseconds: 500), // Puedes ajustar la duración según tus preferencias
      pageBuilder: (_, __, ___) => HistoricoPage(),
      transitionsBuilder: (_, Animation<double> animation, __, Widget child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    ),
  );
}

void _navigateToRHPage(BuildContext context) {
  Navigator.of(context).push(
    PageRouteBuilder(
      transitionDuration: Duration(milliseconds: 500), // Puedes ajustar la duración según tus preferencias
      pageBuilder: (_, __, ___) => RecursosHumanosPage(),
      transitionsBuilder: (_, Animation<double> animation, __, Widget child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    ),
  );
}

void _navigateToAssistPage(BuildContext context) {
  Navigator.of(context).push(
    PageRouteBuilder(
      transitionDuration: Duration(milliseconds: 500), // Puedes ajustar la duración según tus preferencias
      pageBuilder: (_, __, ___) => AsistenciasPage(),
      transitionsBuilder: (_, Animation<double> animation, __, Widget child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    ),
  );
}

void _navigateToEntregasPage(BuildContext context) {
  Navigator.of(context).push(
    PageRouteBuilder(
      transitionDuration: Duration(milliseconds: 500), // Puedes ajustar la duración según tus preferencias
      pageBuilder: (_, __, ___) => EntregasPage(),
      transitionsBuilder: (_, Animation<double> animation, __, Widget child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    ),
  );
}

void _navigateToLiberacionPage(BuildContext context) {
  Navigator.of(context).push(
    PageRouteBuilder(
      transitionDuration: Duration(milliseconds: 500), // Puedes ajustar la duración según tus preferencias
      pageBuilder: (_, __, ___) => LiberacionPage(),
      transitionsBuilder: (_, Animation<double> animation, __, Widget child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    ),
  );
}

void _navigateToLibSoldaduraPage(BuildContext context) {
  Navigator.of(context).push(
    PageRouteBuilder(
      transitionDuration: Duration(milliseconds: 500), // Puedes ajustar la duración según tus preferencias
      pageBuilder: (_, __, ___) => LibSoldaduraPage(),
      transitionsBuilder: (_, Animation<double> animation, __, Widget child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    ),
  );
}

void _navigateToLibPinturaPage(BuildContext context) {
  Navigator.of(context).push(
    PageRouteBuilder(
      transitionDuration: Duration(milliseconds: 500), // Puedes ajustar la duración según tus preferencias
      pageBuilder: (_, __, ___) => LibPinturaPage(),
      transitionsBuilder: (_, Animation<double> animation, __, Widget child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    ),
  );
}

void _navigateToOrdenesPage(BuildContext context) {
  Navigator.of(context).push(
    PageRouteBuilder(
      transitionDuration: Duration(milliseconds: 500), // Puedes ajustar la duración según tus preferencias
      pageBuilder: (_, __, ___) => OrdenesPage(),
      transitionsBuilder: (_, Animation<double> animation, __, Widget child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    ),
  );
}

void _navigateToPrototiposPage(BuildContext context) {
  Navigator.of(context).push(
    PageRouteBuilder(
      transitionDuration: Duration(milliseconds: 500), // Puedes ajustar la duración según tus preferencias
      pageBuilder: (_, __, ___) => PrototiposPage(),
      transitionsBuilder: (_, Animation<double> animation, __, Widget child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    ),
  );
}

  Future<void> _showPopupMenu(
      BuildContext context, List<String> options, Function(String) onTap) async {
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final String? selectedOption = await showMenu(
      context: context,
      position: RelativeRect.fromRect(
          _getLongPressRect(overlay), Offset.zero & overlay.size),
      items: options.map((String option) {
        return PopupMenuItem<String>(
          value: option,
          child: Text(option),
        );
      }).toList(),
    );

    if (selectedOption != null) {
      onTap(selectedOption);
    }
  }

  Rect _getLongPressRect(RenderBox overlay) {
    // Adjust the position and size based on your requirements
    return Rect.fromPoints(
      overlay.localToGlobal(const Offset(50, 50)),
      overlay.localToGlobal(overlay.size.bottomRight(Offset.zero)),
    );
  }
 
 @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Custom back button behavior
        _showExitConfirmationDialog(context);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'NEUBER',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          backgroundColor: const Color(0xFF313745),
          leading: Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: AnimatedIcon(
                  icon: AnimatedIcons.menu_arrow,
                  progress: _animationController,
                  color: Colors.white,
                ),
                onPressed: () {
                  _animationController.isCompleted
                      ? _animationController.reverse()
                      : _animationController.forward();
                  Scaffold.of(context).openDrawer();
                },
              );
            },
          ),
        ),
        body: Stack(
          children: [
            CarouselSlider(
              options: CarouselOptions(
                height: double.infinity,
                viewportFraction: 1.0,
                enableInfiniteScroll: true,
                autoPlay: true,
                autoPlayInterval: const Duration(seconds: 10),
                autoPlayAnimationDuration: const Duration(milliseconds: 2500),
              ),
              items: imagePaths.map((path) {
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    FadeInImage(
  placeholder: MemoryImage(kTransparentImage),
  image: AssetImage(path),
  fit: BoxFit.cover,
  fadeInDuration: const Duration(milliseconds: 800),
),
                    const Center(
                      child: Text(
                        'NEUBER',
                        style: TextStyle(
                          fontSize: 60,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              blurRadius: 10.0,
                              color: Colors.black54,
                              offset: Offset(2.0, 2.0),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
            if (_isLoading)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                  child: Center(
                    child: SpinKitFadingCircle(
                      color: Colors.grey.shade700,
                      size: 60.0,
                    ),
                  ),
                ),
              ),
          ],
        ),
      drawer: Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Color(0xFF282C34),
            ),
            child: Image.asset(
              'assets/neuber.png',
              width: 200,
              height: 300,
            ),
          ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Inicio'),
              onTap: () {
                Navigator.of(context).pop();
                _navigateToInicioPage(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.list),
              title: Text('Proyectos'),
              onTap: () {
                Navigator.of(context).pop();
                _navigateToProyectosPage(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.fireplace_rounded),
              title: Text('Prototipos'),
              onTap: () {
                Navigator.of(context).pop();
                _navigateToPrototiposPage(context);
              },
            ),
            ExpansionTile(
              leading: Icon(FontAwesomeIcons.fireFlameCurved),
              title: Text('Soldadura'),
              children: [
                ListTile(
                  title: Text('Línea 1'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _navigateToLinea1y2Page(context);
                  },
                ),
                ListTile(
                  title: Text('Línea 2'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _navigateToLinea3y4Page(context);
                  },
                ),
                ListTile(
                  title: Text('Línea 3'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _navigateToLinea5y6Page(context);
                  },
                ),
              ],
            ),
            ExpansionTile(
              leading: Icon(FontAwesomeIcons.paintBrush),
              title: Text('Pintura'),
              children: [
                ListTile(
                  title: Text('Nave 1'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _navigateToNave1Page(context);
                  },
                ),
                ListTile(
                  title: Text('Nave 2'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _navigateToNave2Page(context);
                  },
                ),
              ],
            ),
            ListTile(
              leading: Icon(FontAwesomeIcons.box),
              title: Text('Montaje'),
              onTap: () {
                Navigator.of(context).pop();
                _navigateToMontajePage(context);
              },
            ),
            ListTile(
              leading: Icon(FontAwesomeIcons.scissors),
              title: Text('Textil'),
              onTap: () {
                Navigator.of(context).pop();
                _navigateToTextilPage(context);
              },
            ),
            ExpansionTile(
              leading: Icon(FontAwesomeIcons.fireFlameCurved),
              title: Text('Liberacion'),
              children: [
                ListTile(
                  title: Text('Liberacion Soldadura'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _navigateToLibSoldaduraPage(context);
                  },
                ),
                ListTile(
                  title: Text('Liberacion Pintura'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _navigateToLibPinturaPage(context);
                  },
                ),
                ListTile(
                  title: Text('Liberacion PT'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _navigateToLiberacionPage(context);
                  },
                ),
              ],
            ),
            ListTile(
              leading: Icon(FontAwesomeIcons.boxesPacking),
              title: Text('Entregados'),
              onTap: () {
                Navigator.of(context).pop();
                _navigateToEntregasPage(context);
              },
            ),
            ListTile(
              leading: Icon(FontAwesomeIcons.tableCells),
              title: Text('Historico'),
              onTap: () {
                Navigator.of(context).pop();
                _navigateToHistoricoPage(context);
              },
            ),
            ExpansionTile(
              leading: Icon(FontAwesomeIcons.person),
              title: Text('Recursos Humanos'),
              children: [
                ListTile(
                  title: Text('Asistencia'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _showLoginDialog3(context);
                  },
                ),
                ListTile(
                  title: Text('Nomina'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _showLoginDialog2(context);
                  },
                ),
              ],
            ),
            ListTile(
              leading: Icon(Icons.lightbulb),
              title: Text('Planeación'),
              onTap: () {
                Navigator.of(context).pop();
                _showLoginDialog(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.edit_document),
              title: Text('Ordenes De Trabajo'),
              onTap: () {
                _navigateToOrdenesPage(context);
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text('Salir'),
              onTap: () {
                _showExitConfirmationDialog(context);
              },
            ),
          ],
        ),
      ),
    )
    );
  }

}