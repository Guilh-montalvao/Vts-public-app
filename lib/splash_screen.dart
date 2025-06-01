import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io' show Platform;

// Tela de splash animada que aparece ao iniciar o app
class SplashScreen extends StatefulWidget {
  // Próxima tela para navegar após o splash
  final Widget nextScreen;

  const SplashScreen({super.key, required this.nextScreen});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController; // Controlador das animações
  late Animation<double> _scaleAnimation; // Animação de escala do logo
  late Animation<double> _opacityAnimation; // Animação de opacidade do logo
  late bool _isDesktop; // Indica se está rodando em desktop

  @override
  void initState() {
    super.initState();

    // Detecta se a plataforma é desktop (Windows, Linux ou MacOS)
    _isDesktop = _isDesktopPlatform();

    // Configura o controlador de animação
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: _isDesktop ? 2200 : 1800),
    );

    // Configura as animações de escala e opacidade de acordo com a plataforma
    if (_isDesktop) {
      // Animação para Windows (evita tremulação)
      _scaleAnimation = Tween<double>(
        begin: 0.9,
        end: 1.0,
      ).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Curves.easeOutCirc,
        ),
      );

      // Animação de opacidade para Windows
      _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
        ),
      );
    } else {
      // Animação original para Chrome/web (mantém comportamento exato)
      _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Curves.easeOutQuad,
        ),
      );

      // Animação de opacidade original para Chrome/web
      _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: const Interval(0.0, 0.7, curve: Curves.easeIn),
        ),
      );
    }

    // Inicia a animação
    _animationController.forward();

    // Navega para a próxima tela após 3 segundos
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => widget.nextScreen));
    });
  }

  // Função auxiliar para detectar se está em plataforma desktop
  bool _isDesktopPlatform() {
    try {
      return Platform.isWindows || Platform.isLinux || Platform.isMacOS;
    } catch (e) {
      // Em ambiente web, Platform não está disponível
      return false;
    }
  }

  @override
  void dispose() {
    // Libera o controlador de animação ao destruir o widget
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Pré-renderiza a imagem para evitar recriação durante a animação
    final Widget logoImage = Image.asset(
      'assets/images/logo-vts.png',
      width: 160,
      height: 160,
      filterQuality: FilterQuality.high,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Espaço superior proporcional à altura da tela
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.1,
            ),
            Expanded(
              flex: 2,
              child: Center(
                child: AnimatedBuilder(
                  animation: _animationController,
                  child: logoImage,
                  builder: (context, child) {
                    return RepaintBoundary(
                      child: _isDesktop
                          // Implementação otimizada para desktop (resolve tremulação)
                          ? FadeTransition(
                              opacity: _opacityAnimation,
                              child: AnimatedScale(
                                scale: _scaleAnimation.value,
                                duration: const Duration(milliseconds: 100),
                                curve: Curves.linear,
                                child: child,
                              ),
                            )
                          // Implementação original para web (comportamento idêntico ao anterior)
                          : Transform.scale(
                              scale: _scaleAnimation.value,
                              alignment: Alignment.center,
                              transformHitTests: false,
                              child: Opacity(
                                opacity: _opacityAnimation.value,
                                child: child,
                              ),
                            ),
                    );
                  },
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(), // Espaço vazio para balancear o layout
            ),
            const SizedBox(height: 40.0), // Espaço inferior
          ],
        ),
      ),
    );
  }
}
