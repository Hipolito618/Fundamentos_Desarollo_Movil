import 'package:flutter/material.dart';

void main() {
  runApp(const ReservaViajeApp());
}

class ReservaViajeApp extends StatelessWidget {
  const ReservaViajeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reserva de Viaje',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const FormularioReservaScreen(),
    );
  }
}

class DatosReserva {
  final String nombre;
  final String correo;
  final String destino;
  final String transporte;
  final bool hotelIncluido;
  final bool tourGuiado;
  final bool seguroViaje;
  final bool recibirNotificaciones;
  final double presupuesto;
  final DateTime fechaViaje;

  DatosReserva({
    required this.nombre,
    required this.correo,
    required this.destino,
    required this.transporte,
    required this.hotelIncluido,
    required this.tourGuiado,
    required this.seguroViaje,
    required this.recibirNotificaciones,
    required this.presupuesto,
    required this.fechaViaje,
  });

  List<String> get listaExtras {
    final List<String> extras = [];
    if (hotelIncluido) extras.add('Hotel incluido (+\$1200)');
    if (tourGuiado) extras.add('Tour guiado (+\$600)');
    if (seguroViaje) extras.add('Seguro de viaje (+\$400)');
    return extras;
  }

  String get fechaFormateada {
    final dia = fechaViaje.day.toString().padLeft(2, '0');
    final mes = fechaViaje.month.toString().padLeft(2, '0');
    final anio = fechaViaje.year.toString();
    return '$dia/$mes/$anio';
  }
}

class FormularioReservaScreen extends StatefulWidget {
  const FormularioReservaScreen({super.key});

  @override
  State<FormularioReservaScreen> createState() => _FormularioReservaScreenState();
}

class _FormularioReservaScreenState extends State<FormularioReservaScreen> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();

  String _destinoSeleccionado = 'Playa';
  String _transporteSeleccionado = 'Avión';

  bool _hotelIncluido = false;
  bool _tourGuiado = false;
  bool _seguroViaje = false;
  bool _recibirNotificaciones = true;

  double _presupuesto = 3000;
  DateTime? _fechaSeleccionada;

  final List<String> _opcionesTransporte = ['Avión', 'Autobús', 'Tren', 'Barco'];

  @override
  void dispose() {
    _nombreController.dispose();
    _correoController.dispose();
    super.dispose();
  }

  void _mostrarSnackBar(String mensaje) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _reiniciarCampos() {
    setState(() {
      _nombreController.clear();
      _correoController.clear();
      _destinoSeleccionado = 'Playa';
      _transporteSeleccionado = 'Avión';
      _hotelIncluido = false;
      _tourGuiado = false;
      _seguroViaje = false;
      _recibirNotificaciones = true;
      _presupuesto = 3000;
      _fechaSeleccionada = null;
    });
    _mostrarSnackBar('Formulario reiniciado correctamente');
  }

  bool _validarDatos() {
    final nombre = _nombreController.text.trim();
    final correo = _correoController.text.trim();

    if (nombre.isEmpty || !correo.contains('@') || _fechaSeleccionada == null) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          icon: const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 40),
          title: const Text('Faltan datos'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (nombre.isEmpty) const Text('• El nombre completo es obligatorio.'),
              if (!correo.contains('@')) const Text('• Ingresa un correo electrónico válido con @.'),
              if (_fechaSeleccionada == null) const Text('• Debes seleccionar una fecha para el viaje.'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Entendido'),
            ),
          ],
        ),
      );
      return false;
    }
    return true;
  }

  DatosReserva _generarDatosReserva() {
    return DatosReserva(
      nombre: _nombreController.text.trim(),
      correo: _correoController.text.trim(),
      destino: _destinoSeleccionado,
      transporte: _transporteSeleccionado,
      hotelIncluido: _hotelIncluido,
      tourGuiado: _tourGuiado,
      seguroViaje: _seguroViaje,
      recibirNotificaciones: _recibirNotificaciones,
      presupuesto: _presupuesto,
      fechaViaje: _fechaSeleccionada!,
    );
  }

  Future<void> _elegirFecha() async {
    final DateTime inicial = _fechaSeleccionada ?? DateTime.now();
    final DateTime? seleccionada = await showDatePicker(
      context: context,
      initialDate: inicial,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
    );

    if (seleccionada != null) {
      setState(() {
        _fechaSeleccionada = seleccionada;
      });
      final dia = seleccionada.day.toString().padLeft(2, '0');
      final mes = seleccionada.month.toString().padLeft(2, '0');
      final anio = seleccionada.year.toString();
      _mostrarSnackBar('Fecha seleccionada: $dia/$mes/$anio');
    }
  }

  void _mostrarResumenDialog() {
    if (!_validarDatos()) return;

    final datos = _generarDatosReserva();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.assignment, color: Colors.teal),
            SizedBox(width: 8),
            Text('Resumen de Reserva'),
          ],
        ),
        content: SingleChildScrollView(
          child: ListBody(
            children: [
              _itemResumen('Viajero', datos.nombre),
              _itemResumen('Correo', datos.correo),
              _itemResumen('Destino', datos.destino),
              _itemResumen('Transporte', datos.transporte),
              _itemResumen('Fecha', datos.fechaFormateada),
              _itemResumen(
                'Extras',
                datos.listaExtras.isEmpty ? 'Ninguno' : datos.listaExtras.join('\n'),
              ),
              _itemResumen(
                'Notificaciones',
                datos.recibirNotificaciones ? 'Activadas' : 'Desactivadas',
              ),
              _itemResumen('Presupuesto', '\$${datos.presupuesto.toStringAsFixed(0)}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cerrar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              _confirmarYNavegar();
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  Widget _itemResumen(String etiqueta, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(etiqueta, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
          Text(valor, style: const TextStyle(fontSize: 15)),
          const Divider(height: 12),
        ],
      ),
    );
  }

  void _confirmarYNavegar() {
    if (!_validarDatos()) return;

    final datos = _generarDatosReserva();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MiBoletoScreen(datos: datos),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Reserva de Viaje',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.cleaning_services, color: Colors.white),
            tooltip: 'Reiniciar formulario',
            onPressed: _reiniciarCampos,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 2. Sección 1 · Información general
        
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              color: Colors.teal.shade50,
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sección 1 · Información general',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Completa tu reserva paso a paso',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Llena tus datos, elige destino y confirma tu viaje.',
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 3. Sección 2 · Datos del viajero
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(' Seccion 2 · Datos del viajero', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _nombreController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre completo',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _correoController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Correo electrónico',
                        prefixIcon: Icon(Icons.email),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 4. Sección 3 · Destino y transporte
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Sección 3 · Destino y transporte', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const Text( 'Elige tu aventura',style: TextStyle(color: Colors.grey, fontSize: 12),),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildDestinoCard(
                          nombre: 'Playa',
                          icono: Icons.beach_access,
                          color: Colors.blue,
                        ),
                        const SizedBox(width: 8),
                        _buildDestinoCard(
                          nombre: 'Ciudad',
                          icono: Icons.location_city,
                          color: Colors.orange,
                        ),
                        const SizedBox(width: 8),
                        _buildDestinoCard(
                          nombre: 'Montaña',
                          icono: Icons.terrain,
                          color: Colors.green,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _transporteSeleccionado,
                      decoration: const InputDecoration(
                        labelText: 'Transporte',
                        prefixIcon: Icon(Icons.directions_transit),
                        border: OutlineInputBorder(),
                      ),
                      items: _opcionesTransporte.map((String opcion) {
                        return DropdownMenuItem<String>(
                          value: opcion,
                          child: Text(opcion),
                        );
                      }).toList(),
                      onChanged: (nuevo) {
                        if (nuevo != null) {
                          setState(() {
                            _transporteSeleccionado = nuevo;
                          });
                          _mostrarSnackBar('Transporte seleccionado: $nuevo');
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 5. Sección 4 · Extras y preferencias
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Sección 4 · Extras y preferencias', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const Text( 'Personaliza tu experiencia', style: TextStyle(color: Colors.grey, fontSize: 12),),
                    const SizedBox(height: 8),
                    Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      elevation: 0,
                      color: _hotelIncluido ? Colors.teal.shade50 : Colors.grey.shade50,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      child: CheckboxListTile(
                        title: const Text('Hotel incluido (+\$1200)'),
                        secondary: const Icon(Icons.hotel),
                        value: _hotelIncluido,
                        onChanged: (val) {
                          setState(() => _hotelIncluido = val ?? false);
                          _mostrarSnackBar(_hotelIncluido ? 'Hotel incluido agregado' : 'Hotel incluido removido');
                        },
                      ),
                    ),
                    Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      elevation: 0,
                      color: _tourGuiado ? Colors.teal.shade50 : Colors.grey.shade50,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      child: CheckboxListTile(
                        title: const Text('Tour guiado (+\$600)'),
                        secondary: const Icon(Icons.tour),
                        value: _tourGuiado,
                        onChanged: (val) {
                          setState(() => _tourGuiado = val ?? false);
                          _mostrarSnackBar(_tourGuiado ? 'Tour guiado agregado' : 'Tour guiado removido');
                        },
                      ),
                    ),
                    Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      elevation: 0,
                      color: _seguroViaje ? Colors.teal.shade50 : Colors.grey.shade50,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      child: CheckboxListTile(
                        title: const Text('Seguro de viaje (+\$400)'),
                        secondary: const Icon(Icons.health_and_safety),
                        value: _seguroViaje,
                        onChanged: (val) {
                          setState(() => _seguroViaje = val ?? false);
                          _mostrarSnackBar(_seguroViaje ? 'Seguro de viaje agregado' : 'Seguro de viaje removido');
                        },
                      ),
                    ),
                    const Divider(height: 24),
                    SwitchListTile(
                      title: const Text('Recibir notificaciones'),
                      subtitle: Text(_recibirNotificaciones ? 'Activadas' : 'Desactivadas'),
                      secondary: Icon(
                        _recibirNotificaciones ? Icons.notifications_active : Icons.notifications_off,
                        color: _recibirNotificaciones ? Colors.teal : Colors.grey,
                      ),
                      value: _recibirNotificaciones,
                      onChanged: (val) {
                        setState(() => _recibirNotificaciones = val);
                      },
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Presupuesto:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.purple.shade50,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.purple),
                          ),
                          child: Text(
                            '\$${_presupuesto.toStringAsFixed(0)}',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.purple, fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: Colors.purple,
                        thumbColor: Colors.purple,
                        overlayColor: Colors.purple.withValues(alpha: 0.2),
                        activeTickMarkColor: Colors.white,
                      ),
                      child: Slider(
                        value: _presupuesto,
                        min: 500,
                        max: 10000,
                        divisions: 20,
                        label: '\$${_presupuesto.toStringAsFixed(0)}',
                        onChanged: (val) {
                          setState(() => _presupuesto = val);
                        },
                      ),
                    ),
                    const Divider(height: 24),
                    InkWell(
                      onTap: _elegirFecha,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_month, color: Colors.teal),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _fechaSeleccionada == null
                                    ? 'Toca para elegir fecha'
                                    : '${_fechaSeleccionada!.day.toString().padLeft(2, '0')}/${_fechaSeleccionada!.month.toString().padLeft(2, '0')}/${_fechaSeleccionada!.year}',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: _fechaSeleccionada == null ? Colors.grey.shade600 : Colors.black87,
                                  fontWeight: _fechaSeleccionada == null ? FontWeight.normal : FontWeight.w600,
                                ),
                              ),
                            ),
                            const Icon(Icons.arrow_drop_down, color: Colors.grey),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 6. Sección 5 · Confirmar
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.green.shade300, width: 1.5),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: Colors.teal, width: 2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: _mostrarResumenDialog,
                      child: const Text(
                        'Ver Resumen',
                        style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        elevation: 2,
                      ),
                      onPressed: _confirmarYNavegar,
                      child: const Text(
                        'Confirmar',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildDestinoCard({
    required String nombre,
    required IconData icono,
    required MaterialColor color,
  }) {
    final bool seleccionado = _destinoSeleccionado == nombre;
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          setState(() {
            _destinoSeleccionado = nombre;
          });
          _mostrarSnackBar('Destino seleccionado: $nombre');
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
          decoration: BoxDecoration(
            color: seleccionado ? color.shade100 : color.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: seleccionado ? color.shade700 : color.shade200,
              width: seleccionado ? 2.5 : 1.0,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icono,
                color: seleccionado ? color.shade900 : color.shade700,
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                nombre,
                style: TextStyle(
                  color: seleccionado ? color.shade900 : color.shade800,
                  fontWeight: seleccionado ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MiBoletoScreen extends StatelessWidget {
  final DatosReserva datos;

  const MiBoletoScreen({super.key, required this.datos});

  String _obtenerImagenDestino(String destino) {
    switch (destino) {
      case 'Playa':
        return 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800&auto=format&fit=crop';
      case 'Ciudad':
        return 'https://images.unsplash.com/photo-1480714378408-67cf0d13bc1b?auto=format&fit=crop&w=800&q=80';
      case 'Montaña':
        return 'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?w=800&auto=format&fit=crop';
      default:
        return 'https://images.unsplash.com/photo-1488646953014-85cb44e25828?w=800&auto=format&fit=crop';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mi Boleto',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.teal,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Tarjeta de boleto
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Encabezado verde con saludo
                  Container(
                    padding: const EdgeInsets.all(20),
                    color: Colors.teal,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'BOARDING PASS',
                              style: TextStyle(
                                color: Colors.white70,
                                letterSpacing: 2,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                            Icon(
                              datos.transporte == 'Avión'
                                  ? Icons.flight_takeoff
                                  : datos.transporte == 'Autobús'
                                      ? Icons.directions_bus
                                      : datos.transporte == 'Tren'
                                          ? Icons.train
                                          : Icons.directions_boat,
                              color: Colors.white,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '¡Buen viaje, ${datos.nombre}!',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.place, color: Colors.white70, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              datos.destino,
                              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(width: 16),
                            const Icon(Icons.calendar_today, color: Colors.white70, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              datos.fechaFormateada,
                              style: const TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Fotografía de referencia del destino
                  Image.network(
                    _obtenerImagenDestino(datos.destino),
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: 180,
                        color: Colors.grey.shade200,
                        child: const Center(child: CircularProgressIndicator()),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 140,
                        color: Colors.teal.shade100,
                        child: Center(
                          child: Icon(Icons.landscape, size: 64, color: Colors.teal.shade700),
                        ),
                      );
                    },
                  ),

                  // Simulación de corte perforado
                  CustomPaint(
                    painter: CortePerforadoPainter(),
                    child: Container(
                      height: 24,
                      color: Colors.white,
                    ),
                  ),

                  // Lista con los datos de la reserva
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Column(
                      children: [
                        _filaDatoBoleto(Icons.email, 'Correo', datos.correo),
                        _filaDatoBoleto(Icons.map, 'Destino', datos.destino),
                        _filaDatoBoleto(Icons.directions_transit, 'Transporte', datos.transporte),
                        _filaDatoBoleto(
                          Icons.check_circle_outline,
                          'Extras',
                          datos.listaExtras.isEmpty ? 'Sin extras' : datos.listaExtras.join(', '),
                        ),
                        _filaDatoBoleto(
                          Icons.notifications,
                          'Notificaciones',
                          datos.recibirNotificaciones ? 'Activadas' : 'Desactivadas',
                        ),
                        _filaDatoBoleto(
                          Icons.attach_money,
                          'Presupuesto total',
                          '\$${datos.presupuesto.toStringAsFixed(0)}',
                          destacado: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Botón inferior 'Regresar y editar'
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.edit),
                label: const Text(
                  'Regresar y editar',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filaDatoBoleto(IconData icono, String titulo, String valor, {bool destacado = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icono, size: 20, color: destacado ? Colors.teal : Colors.grey.shade700),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              titulo,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              valor,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 14,
                fontWeight: destacado ? FontWeight.bold : FontWeight.w600,
                color: destacado ? Colors.teal.shade800 : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Pintor personalizado para la simulación del corte perforado del boleto
class CortePerforadoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1.5;

    const dashWidth = 6.0;
    const dashSpace = 4.0;
    double startX = 20.0;
    final endX = size.width - 20.0;
    final y = size.height / 2;

    while (startX < endX) {
      canvas.drawLine(
        Offset(startX, y),
        Offset(startX + dashWidth, y),
        paint,
      );
      startX += dashWidth + dashSpace;
    }

    // Muescas semicirculares laterales
    final notchPaint = Paint()..color = const Color(0xFFE0E0E0);
    canvas.drawCircle(Offset(0, y), 10, notchPaint);
    canvas.drawCircle(Offset(size.width, y), 10, notchPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
