import 'package:flutter/material.dart';

class SecondScreen extends StatelessWidget {
  final String nombre;
  final String edad;
  final String genero;
  final String intereses;
  final String pais;

  const SecondScreen({
    super.key,
    required this.nombre,
    required this.edad,
    required this.genero,
    required this.intereses,
    required this.pais,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Preferencias Guardadas'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Resumen de tus Datos:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
                ),
                const Divider(),
                const SizedBox(height: 10),
                Text('• Nombre: ${nombre.isEmpty ? "No especificado" : nombre}', style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 8),
                Text('• Edad: ${edad.isEmpty ? "No especificada" : edad}', style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 8),
                Text('• Género: $genero', style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 8),
                Text('• Intereses: ${intereses.isEmpty ? "Ninguno" : intereses}', style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 8),
                Text('• País: $pais', style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Regresar'),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}