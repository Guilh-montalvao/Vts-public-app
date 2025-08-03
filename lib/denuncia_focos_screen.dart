import 'package:flutter/material.dart';

class DenunciaFocosScreen extends StatefulWidget {
  const DenunciaFocosScreen({super.key});

  @override
  State<DenunciaFocosScreen> createState() => _DenunciaFocosScreenState();
}

class _DenunciaFocosScreenState extends State<DenunciaFocosScreen> {
  bool isAnonimo = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AnimatedBuilder(
                      animation: Listenable.merge([]), // No animation, but keeps structure similar
                      builder: (context, child) => child!,
                      child: Image.asset(
                        'assets/images/logo-vts-black.png',
                        width: 32,
                        height: 32,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.notifications_none, size: 32, color: Colors.black87),
                      onPressed: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Nome',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: const BorderSide(color: Colors.black26, width: 1),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: const BorderSide(color: Colors.black26, width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: const BorderSide(color: Colors.black26, width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
                const SizedBox(height: 0),
                Row(
                  children: [
                    Checkbox(
                      value: isAnonimo,
                      onChanged: (v) => setState(() => isAnonimo = v ?? false),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      side: const BorderSide(color: Colors.black26, width: 1),
                      checkColor: Colors.white,
                      activeColor: Colors.black,
                    ),
                    const Text('Anônimo', style: TextStyle(color: Colors.black45, fontSize: 16)),
                  ],
                ),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Endereço',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: const BorderSide(color: Colors.black26, width: 1),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: const BorderSide(color: Colors.black26, width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: const BorderSide(color: Colors.black26, width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  minLines: 4,
                  maxLines: 6,
                  decoration: InputDecoration(
                    hintText: 'Conte mais sobre o problema',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: const BorderSide(color: Colors.black26, width: 1),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: const BorderSide(color: Colors.black26, width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: const BorderSide(color: Colors.black26, width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black26, width: 1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Icon(Icons.insert_drive_file_outlined, size: 40, color: Colors.black38),
                      Image.asset(
                        'assets/images/file.png',
                        width: 40,
                        height: 40,
                        color: Colors.black,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Envie seu vídeo, tire uma foto ou',
                        style: TextStyle(fontSize: 13, color: Colors.black38),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black26,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
                          shape: StadiumBorder(),
                          elevation: 0,
                        ),
                        child: const Text('Escolha o arquivo', style: TextStyle(fontSize: 13)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    shape: StadiumBorder(),
                    padding: const EdgeInsets.symmetric(vertical: 0),
                    elevation: 0,
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Text('Enviar Denúncia', style: TextStyle(fontSize: 12)),
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.black45,
                    side: const BorderSide(color: Colors.black26, width: 1),
                    shape: StadiumBorder(),
                    padding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Text('Cancelar', style: TextStyle(fontSize: 12)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}