import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Importa o pacote para exibir SVG
import 'splash_screen.dart';

void main() {
  // Função principal que inicializa o aplicativo Flutter
  runApp(const MyApp());
}

// Widget principal do aplicativo
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Este widget é a raiz da sua aplicação.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VTS Public App',
      debugShowCheckedModeBanner: false, // Remove a faixa de debug
      theme: ThemeData(
        // Definição do tema do aplicativo
        //
        // DICA: Tente rodar seu aplicativo com "flutter run". Você verá
        // que o aplicativo tem uma barra superior roxa. Depois, sem fechar o app,
        // tente mudar o seedColor no colorScheme abaixo para Colors.green
        // e então use o "hot reload" (salve suas alterações ou pressione o botão
        // "hot reload" em um IDE compatível com Flutter, ou pressione "r" se estiver
        // usando o terminal para rodar o app).
        //
        // Note que o contador não volta para zero; o estado do aplicativo
        // não é perdido durante o reload. Para resetar o estado, use o hot restart.
        //
        // Isso funciona para código também, não apenas valores: a maioria das mudanças
        // de código pode ser testada apenas com hot reload.
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
  // Controlador de animação único para todos os elementos
  late AnimationController _animationController;

  // Animações de opacidade e posição/escala
  late Animation<double> _logoOpacity;
  late Animation<double> _logoScale;
  late Animation<double> _buttonsOpacity;
  late Animation<Offset> _buttonsOffset;
  late Animation<double> _bottomBarOpacity;
  late Animation<Offset> _bottomBarOffset;

  @override
  void initState() {
    super.initState();
    // Um único controlador para todas as animações
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200), // Duração mais suave
    );

    // Animação de opacidade da logo (primeiro a aparecer)
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeInOutCubic),
      ),
    );
    // Animação de escala da logo
    _logoScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeInOutCubic),
      ),
    );
    // Animação dos botões (aparecem logo após a logo)
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
    // Animação da barra inferior (entra por último)
    _bottomBarOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.7, 1.0, curve: Curves.easeInOutCubic),
      ),
    );
    _bottomBarOffset =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.7, 1.0, curve: Curves.easeInOutCubic),
      ),
    );

    // Inicia todas as animações
    _animationController.forward();
  }

  @override
  void dispose() {
    // Libera o controlador de animação
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Cor padrão dos ícones e botões
    const Color primaryColor = Color(0xFF31738A);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Topo com logo SVG centralizada e sino à direita, animados
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Espaço para centralizar a logo
                  const SizedBox(width: 24),
                  // Logo SVG centralizada com animação de ressurgimento (escala + opacidade)
                  Expanded(
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
                      child: Column(
                        children: [
                          // Exibe a logo SVG centralizada
                          SvgPicture.asset(
                            'assets/images/logo-horizontal.svg',
                            width: 100,
                            height: 60,
                            fit: BoxFit.contain,
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Sino de notificação no topo direito (sem animação)
                  IconButton(
                    icon: const Icon(Icons.notifications_none,
                        size: 32, color: Colors.black54),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // Botões principais animados
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: SlideTransition(
                position: _buttonsOffset,
                child: FadeTransition(
                  opacity: _buttonsOpacity,
                  child: Column(
                    children: [
                      _HomeButton(
                        icon: Icons.groups_2,
                        iconSecondary: Icons.error_outline,
                        text: 'Denúncia de focos',
                        onTap: () {},
                      ),
                      const SizedBox(height: 24),
                      _HomeButton(
                        icon: Icons.language,
                        text: 'Site do Projeto',
                        onTap: () {},
                      ),
                      const SizedBox(height: 24),
                      _HomeButton(
                        icon: Icons.sanitizer,
                        text: 'Como prevenir focos',
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const Spacer(),
            // Barra inferior com ícones animados
            Padding(
              padding: const EdgeInsets.only(bottom: 32.0, left: 32, right: 32),
              child: SlideTransition(
                position: _bottomBarOffset,
                child: FadeTransition(
                  opacity: _bottomBarOpacity,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: const [
                      Icon(Icons.mail_outline, color: primaryColor, size: 32),
                      Icon(Icons.phone, color: primaryColor, size: 32),
                      Icon(Icons.language, color: primaryColor, size: 32),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget customizado para os botões grandes da home
class _HomeButton extends StatelessWidget {
  final IconData icon;
  final IconData? iconSecondary;
  final String text;
  final VoidCallback onTap;

  const _HomeButton({
    required this.icon,
    this.iconSecondary,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Botão customizado com ícone grande à esquerda e texto à direita
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black26, width: 1.2),
          borderRadius: BorderRadius.circular(24),
          color: Colors.white,
        ),
        child: Row(
          children: [
            // Ícone principal
            Stack(
              alignment: Alignment.topRight,
              children: [
                Icon(icon, color: Color(0xFF31738A), size: 48),
                if (iconSecondary != null)
                  Positioned(
                    right: 0,
                    top: 0,
                    child:
                        Icon(iconSecondary, color: Color(0xFF31738A), size: 20),
                  ),
              ],
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
