import 'package:flutter/material.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  final Widget nextScreen;

  const SplashScreen({super.key, required this.nextScreen});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    // Configurar controlador de animação
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // Animação de escala - usando curva mais suave
    _scaleAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic, // Curva mais suave que easeOutBack
      ),
    );

    // Animação de opacidade
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeIn),
      ),
    );

    // Iniciar animação
    _animationController.forward();

    // Navegar para a próxima tela após 3 segundos
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => widget.nextScreen));
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Pré-renderizar a imagem para evitar recriação durante a animação
    final Widget logoImage = Image.asset(
      'assets/images/logo-vts.png',
      width: 160, // Aumentado em 1/3 (120 * 4/3 = 160)
      height: 160, // Aumentado em 1/3 (120 * 4/3 = 160)
      // Desativar antialiasing pode ajudar em alguns casos
      filterQuality: FilterQuality.medium,
    );

    // Pré-renderizar logos do rodapé
    final Widget fapdfLogo = Image.asset(
      'assets/images/logo-fapdf.png',
      height: 53,
    );

    final Widget idpLogo = Image.asset(
      'assets/images/logo-idp.png',
      height: 53,
    );

    return Scaffold(
      backgroundColor: const Color(0xFF00619A), // Cor de fundo #00619A
      body: SafeArea(
        child: Column(
          children: [
            // Espaçamento ajustado - redução de 1/3 do espaço superior
            SizedBox(
              height: MediaQuery.of(context).size.height *
                  0.1, // Espaço reduzido no topo
            ),
            // Logo principal deslocado para cima
            Expanded(
              flex:
                  2, // Mais espaço para esta seção, empurrando o logo para cima
              child: Center(
                child: AnimatedBuilder(
                  animation: _animationController,
                  // Usar child pré-construído para evitar reconstrução
                  child: logoImage,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      // Usar alignment center para escala a partir do centro
                      alignment: Alignment.center,
                      child: Opacity(
                        opacity: _opacityAnimation.value,
                        child: child,
                      ),
                    );
                  },
                ),
              ),
            ),
            // Espaçador flexível
            Expanded(
              flex: 1, // Espaço flexível entre o logo e o rodapé
              child: Container(),
            ),
            // Rodapé com os logos
            Padding(
              padding: const EdgeInsets.only(bottom: 40.0),
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _opacityAnimation.value,
                    child: Transform.scale(
                      scale: _scaleAnimation.value,
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Logo FAPDF
                          fapdfLogo,
                          const SizedBox(width: 20),
                          // Logo IDP
                          idpLogo,
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
