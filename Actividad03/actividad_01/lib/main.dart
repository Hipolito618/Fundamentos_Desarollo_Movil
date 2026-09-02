import 'package:flutter/material.dart';
import 'second_Screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Registro de Preferencias',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const RegistroPreferenciasScreen(),
    );
  }
}

class RegistroPreferenciasScreen extends StatefulWidget {
  const RegistroPreferenciasScreen({super.key});

  @override
  State<RegistroPreferenciasScreen> createState() => _RegistroPreferenciasScreenState();
}

class _RegistroPreferenciasScreenState extends State<RegistroPreferenciasScreen> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _edadController = TextEditingController();
  
  String _genero = 'Masculino';
  
  bool _deporte = false;
  bool _musica = false;
  bool _cine = false;
  bool _lectura = false;
  
  String _paisSeleccionado = 'Mexico';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro de Preferencias'),
        backgroundColor: Colors.blue,
      ),
      backgroundColor: const Color(0xFFF7F2F9),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            // Sección 1: Información General
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF90CAF9)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue),
                      SizedBox(width: 8),
                      Text(
                        'Seccion 1: Informacion General',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue, fontSize: 16),
                      ),
                    ],
                  ),
                  SizedBox(height: 6),
                  Text('Completa los siguientes datos personales basicos', style: TextStyle(color: Colors.black54, fontSize: 13)),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Sección 2: Datos Personales
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFA5D6A7)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.person, color: Colors.green),
                      SizedBox(width: 8),
                      Text('Seccion 2: Datos Personales', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _nombreController,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.person_outline),
                      hintText: 'Nombre completo',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _edadController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.calendar_today_outlined),
                      hintText: 'Edad',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Sección 3: Distribucion en Filas
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFFCC80)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.view_agenda, color: Colors.orange),
                      SizedBox(width: 8),
                      Text('Seccion 3: Distribucion en Filas', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange, fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildFilaColor('Fila 1 - Color Rojo', Colors.red, const Color(0xFFFFCDD2)),
                  const SizedBox(height: 8),
                  _buildFilaColor('Fila 2 - Color Amarillo', Colors.amber, const Color(0xFFFFF9C4)),
                  const SizedBox(height: 8),
                  _buildFilaColor('Fila 3 - Color Azul', Colors.blue, const Color(0xFFBBDEFB)),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Sección 4: Cuatro Hijos en Colores
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF3E5F5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFCE93D8)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.grid_view, color: Colors.purple),
                      SizedBox(width: 8),
                      Text('Seccion 4: Cuatro Hijos en Colores', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.purple, fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildHijoBox('Hijo 1', Colors.red, const Color(0xFFFFCDD2)),
                      const SizedBox(width: 8),
                      _buildHijoBox('Hijo 2', Colors.amber, const Color(0xFFFFF9C4)),
                      const SizedBox(width: 8),
                      _buildHijoBox('Hijo 3', Colors.green, const Color(0xFFC8E6C9)),
                      const SizedBox(width: 8),
                      _buildHijoBox('Hijo 4', Colors.deepPurple, const Color(0xFFD1C4E9)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Sección 5: Controles UI
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.add_circle_outline, color: Colors.black87),
                      SizedBox(width: 8),
                      Text('Seccion 5: Controles UI', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text('Genero:', style: TextStyle(fontWeight: FontWeight.bold)),
                  RadioListTile<String>(
                    title: const Text('Masculino'),
                    value: 'Masculino',
                    groupValue: _genero,
                    onChanged: (val) => setState(() => _genero = val!),
                  ),
                  RadioListTile<String>(
                    title: const Text('Femenino'),
                    value: 'Femenino',
                    groupValue: _genero,
                    onChanged: (val) => setState(() => _genero = val!),
                  ),
                  RadioListTile<String>(
                    title: const Text('Otro'),
                    value: 'Otro',
                    groupValue: _genero,
                    onChanged: (val) => setState(() => _genero = val!),
                  ),
                  const Divider(),
                  const Text('Intereses:', style: TextStyle(fontWeight: FontWeight.bold)),
                  CheckboxListTile(
                    title: const Text('Deporte'),
                    value: _deporte,
                    onChanged: (val) => setState(() => _deporte = val!),
                  ),
                  CheckboxListTile(
                    title: const Text('Musica'),
                    value: _musica,
                    onChanged: (val) => setState(() => _musica = val!),
                  ),
                  CheckboxListTile(
                    title: const Text('Cine'),
                    value: _cine,
                    onChanged: (val) => setState(() => _cine = val!),
                  ),
                  CheckboxListTile(
                    title: const Text('Lectura'),
                    value: _lectura,
                    onChanged: (val) => setState(() => _lectura = val!),
                  ),
                  const Divider(),
                  const Text('Pais:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: _paisSeleccionado,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.public),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Mexico', child: Text('Mexico')),
                      DropdownMenuItem(value: 'Estados Unidos', child: Text('Estados Unidos')),
                      DropdownMenuItem(value: 'Espana', child: Text('Espana')),
                    ],
                    onChanged: (val) => setState(() => _paisSeleccionado = val!),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Botones inferiores
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () {
                      List<String> interesesList = [];
                      if (_deporte) interesesList.add('Deporte');
                      if (_musica) interesesList.add('Musica');
                      if (_cine) interesesList.add('Cine');
                      if (_lectura) interesesList.add('Lectura');

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SecondScreen(
                            nombre: _nombreController.text,
                            edad: _edadController.text,
                            genero: _genero,
                            intereses: interesesList.join(', '),
                            pais: _paisSeleccionado,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.visibility),
                    label: const Text('Mostrar Preferencias'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Registro guardado con exito')),
                      );
                    },
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Guardar Registro'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilaColor(String texto, Color dotColor, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          Icon(Icons.circle, color: dotColor, size: 16),
          const SizedBox(width: 10),
          Text(texto, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildHijoBox(String texto, Color textColor, Color bgColor) {
    return Expanded(
      child: Container(
        height: 60,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(10)),
        child: Text(texto, style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
      ),
    );
  }
}