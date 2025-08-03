import 'package:flutter/material.dart';
import 'splash_screen.dart';
import 'denuncia_focos_screen.dart';

void main() {
  // Função principal que inicializa o aplicativo Flutter
  runApp(const MyApp());
}

// Widget principal do aplicativo
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Widget raiz da sua aplicação.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VTS Public App',
      debugShowCheckedModeBanner: false, // Remove a faixa de debug
      theme: ThemeData(
        // Definição do tema do aplicativo

        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF00619A)),
        useMaterial3: true,
      ),
      // Define a tela inicial como a SplashScreen, que depois navega para MyHomePage
      home: SplashScreen(nextScreen: const MyHomePage(title: 'VTS Public App')),
    );
  }
}

// Tela principal (home) do aplicativo com animações de entrada
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _logoOpacity;
  late Animation<double> _logoScale;
  late Animation<double> _buttonsOpacity;
  late Animation<Offset> _buttonsOffset;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeInOutCubic),
      ),
    );
    _logoScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeInOutCubic),
      ),
    );
    _buttonsOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.35, 0.8, curve: Curves.easeInOutCubic),
      ),
    );
    _buttonsOffset =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.35, 0.8, curve: Curves.easeInOutCubic),
      ),
    );
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color iconColor = Colors.black87;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SlideTransition(
                    position: _buttonsOffset,
                    child: FadeTransition(
                      opacity: _buttonsOpacity,
                      child: AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _logoScale.value,
                            child: Opacity(
                              opacity: _logoOpacity.value,
                              child: child,
                            ),
                          );
                        },
                        child: Image.asset(
                          'assets/images/logo-vts-black.png',
                          width: 32,
                          height: 32,
                        ),
                      ),
                    ),
                  ),
                  SlideTransition(
                    position: _buttonsOffset,
                    child: FadeTransition(
                      opacity: _buttonsOpacity,
                      child: IconButton(
                        icon: const Icon(Icons.notifications_none, size: 32, color: Colors.black87),
                        onPressed: () {},
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SlideTransition(
                position: _buttonsOffset,
                child: FadeTransition(
                  opacity: _buttonsOpacity,
                  child: Column(
                    children: [
                      _HomeButton(
                        icon: Icons.error_outline,
                        title: 'Denúncia de focos',
                        subtitle: 'Send notifications to device.',
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const DenunciaFocosScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      _HomeButton(
                        icon: Icons.security,
                        title: 'Aprenda como prevenir focos',
                        subtitle: 'Send notifications to device.',
                        onTap: () {},
                      ),
                      const SizedBox(height: 16),
                      _HomeButton(
                        icon: Icons.public,
                        title: 'Mapa de denúncias',
                        subtitle: 'Send notifications to device.',
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(left: 24.0, right: 24.0, bottom: 24.0),
              child: Column(
                children: [
                  const Text(
                    'Para mais informações e atualizações, nos siga nas redes sociais',
                    style: TextStyle(fontSize: 10, color: Colors.black38),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.mail_outline, color: iconColor, size: 32),
                      const SizedBox(width: 32),
                      Icon(Icons.public, color: iconColor, size: 32),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _HomeButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(6),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black26, width: 1),
          borderRadius: BorderRadius.circular(6),
          color: Colors.white,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.black87, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black45,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
