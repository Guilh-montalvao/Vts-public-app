// Importações necessárias para o funcionamento da tela de denúncia
import 'package:flutter/material.dart'; // Biblioteca principal do Flutter para widgets Material Design
import 'dart:io'; // Biblioteca para operações de sistema de arquivos (File, Platform)
import 'package:file_picker/file_picker.dart'; // Plugin para seleção de arquivos em dispositivos móveis
import 'package:file_selector/file_selector.dart'; // Plugin para seleção de arquivos em desktop e web
import 'package:permission_handler/permission_handler.dart'; // Plugin para gerenciar permissões do sistema
import 'package:flutter/foundation.dart'
    show kIsWeb; // Utilitário para detectar se está rodando na web

/// Tela principal para criar uma denúncia de foco de mosquito da dengue
/// Esta tela permite ao usuário reportar focos de mosquito com informações
/// como localização, descrição do problema e anexos de imagens/vídeos
class DenunciaFocoScreen extends StatefulWidget {
  const DenunciaFocoScreen({super.key});

  @override
  State<DenunciaFocoScreen> createState() => _DenunciaFocoScreenState();
}

/// Estado da tela de denúncia com gerenciamento de formulário e arquivos
class _DenunciaFocoScreenState extends State<DenunciaFocoScreen> {
  // Chave global para controlar e validar o formulário
  final _formKey = GlobalKey<FormState>();

  // Controladores para os campos de texto do formulário
  final _nomeController =
      TextEditingController(); // Controla o campo de nome do denunciante
  final _enderecoController =
      TextEditingController(); // Controla o campo de endereço do foco
  final _descricaoController =
      TextEditingController(); // Controla o campo de descrição do problema

  // Estado do checkbox para denúncia anônima (false = não selecionado por padrão)
  bool _isAnonimo = false;

  // Lista que armazena os arquivos selecionados pelo usuário (final para evitar reatribuição)
  final List<File> _arquivos = [];

  // Constante que define o número máximo de arquivos que podem ser anexados
  static const int _maxArquivos = 5;

  /// Método responsável por abrir o seletor de arquivos do sistema
  /// Suporta diferentes plataformas com diferentes estratégias:
  /// - Desktop/Web: usa file_selector
  /// - Mobile: usa file_picker
  Future<void> _escolherArquivos() async {
    try {
      // Verifica e solicita permissões apenas em dispositivos móveis
      if (Platform.isAndroid || Platform.isIOS) {
        await _verificarPermissoes();
      }

      // Lista temporária para armazenar os novos arquivos selecionados
      List<File> novosArquivos = [];

      // Estratégia para desktop (Windows, Linux, macOS) e web
      if (Platform.isWindows ||
          Platform.isLinux ||
          Platform.isMacOS ||
          kIsWeb) {
        // Configura grupos de tipos de arquivo aceitos para desktop/web

        // Grupo para tipos de imagem
        const XTypeGroup imageTypeGroup = XTypeGroup(
          label: 'Imagens',
          extensions: <String>['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'],
        );

        // Grupo para tipos de vídeo
        const XTypeGroup videoTypeGroup = XTypeGroup(
          label: 'Vídeos',
          extensions: <String>['mp4', 'avi', 'mov', 'mkv', 'wmv', 'flv'],
        );

        // Abre o seletor de arquivos nativo com os tipos definidos
        final List<XFile> files = await openFiles(
          acceptedTypeGroups: <XTypeGroup>[imageTypeGroup, videoTypeGroup],
        );

        // Converte XFile para File para uso no aplicativo
        novosArquivos = files.map((xFile) => File(xFile.path)).toList();
      } else {
        // Estratégia para dispositivos móveis (Android/iOS)

        // Abre o seletor de arquivos móvel com tipo de mídia
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType
              .media, // Permite apenas arquivos de mídia (imagens e vídeos)
          allowMultiple: true, // Permite seleção múltipla
          allowedExtensions: null, // Usa as extensões padrão de mídia
        );

        // Processa o resultado se houver arquivos selecionados
        if (result != null) {
          novosArquivos = result.paths
              .where((path) => path != null) // Remove caminhos nulos
              .map((path) => File(path!)) // Converte para objeto File
              .toList();
        }
      }

      // Processa os novos arquivos se houver e o widget ainda estiver montado
      if (novosArquivos.isNotEmpty && mounted) {
        // Verifica se o número total de arquivos não excede o limite máximo
        if (_arquivos.length + novosArquivos.length > _maxArquivos) {
          // Mostra mensagem de erro se exceder o limite
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    'Você pode selecionar no máximo $_maxArquivos arquivos'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }

        // Adiciona os novos arquivos à lista se estiver dentro do limite
        if (mounted) {
          setState(() {
            _arquivos.addAll(novosArquivos);
          });
        }
      }
    } catch (e) {
      // Captura e trata erros durante a seleção de arquivos
      debugPrint('Erro ao escolher arquivo: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao selecionar arquivos: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Método para verificar e solicitar permissões de acesso a arquivos
  /// Trata diferentes versões do Android e iOS de forma específica
  Future<void> _verificarPermissoes() async {
    if (Platform.isAndroid) {
      // Tratamento específico para Android

      // Verifica permissão de armazenamento (para Android 10 e inferior)
      var status = await Permission.storage.status;
      if (!status.isGranted) {
        status = await Permission.storage.request();

        // Se ainda não foi concedida, tenta permissões mais específicas
        // (necessário para Android 11+ que tem escopo de armazenamento mais restritivo)
        if (!status.isGranted) {
          // Solicita permissão específica para fotos
          var photosStatus = await Permission.photos.status;
          var videosStatus = await Permission.videos.status;

          if (!photosStatus.isGranted) {
            await Permission.photos.request();
          }
          if (!videosStatus.isGranted) {
            await Permission.videos.request();
          }
        }
      }
    } else if (Platform.isIOS) {
      // Tratamento específico para iOS

      // No iOS, precisamos apenas da permissão de fotos
      var status = await Permission.photos.status;
      if (!status.isGranted) {
        await Permission.photos.request();
      }
    }
  }

  /// Remove um arquivo específico da lista de arquivos selecionados
  /// @param index Índice do arquivo a ser removido na lista
  void _removerArquivo(int index) {
    setState(() {
      _arquivos.removeAt(index);
    });
  }

  /// Método principal para enviar a denúncia
  /// Valida todos os campos obrigatórios antes de processar o envio
  void _enviarDenuncia() {
    // Primeiro valida os campos de texto usando as regras definidas no formulário
    if (_formKey.currentState!.validate()) {
      // Validação adicional: verifica se pelo menos 1 arquivo foi anexado
      if (_arquivos.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'É obrigatório anexar pelo menos 1 arquivo (imagem ou vídeo)'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // (Depois) Implementar lógica real para enviar denúncia ao servidor
      // Por enquanto, apenas mostra mensagem de sucesso
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Denúncia enviada com sucesso!')),
      );

      // Limpa todos os campos após envio bem-sucedido
      _nomeController.clear();
      _enderecoController.clear();
      _descricaoController.clear();
      setState(() {
        _isAnonimo = false; // Desmarca o checkbox anônimo
        _arquivos.clear(); // Remove todos os arquivos selecionados
      });
    }
  }

  /// Método do ciclo de vida do widget para limpar recursos
  /// Libera a memória dos controladores quando o widget é destruído
  @override
  void dispose() {
    _nomeController.dispose();
    _enderecoController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  /// Constrói a interface visual da tela de denúncia
  @override
  Widget build(BuildContext context) {
    // Define a cor principal usada em toda a aplicação
    const Color primaryColor = Color(0xFF31738A);

    return Scaffold(
      // Cor de fundo da tela
      backgroundColor: Colors.white,

      // Barra superior com título e botão de voltar
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0, // Remove sombra da AppBar

        // Título centralizado da tela
        title: const Text(
          'Denúncia de foco',
          style: TextStyle(
            color: Color(0xFF333333),
            fontSize: 24,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,

        // Botão de voltar personalizado
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,
              color: Color(0xFF31738A), size: 22),
          onPressed: () => Navigator.of(context).pop(),
        ),

        // Linha divisória sutil na parte inferior da AppBar
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: Colors.grey.shade300,
            height: 1.0,
          ),
        ),
      ),

      // Corpo principal da tela com scroll para acomodar todo o conteúdo
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),

          // Formulário principal que agrupa e valida todos os campos
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Seção: Campo de nome com opção de denúncia anônima
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Campo de texto para o nome do denunciante
                    Expanded(
                      child: TextFormField(
                        controller: _nomeController,
                        enabled:
                            !_isAnonimo, // Desabilita se for denúncia anônima
                        style: const TextStyle(fontSize: 16),

                        // Validação condicional: obrigatório apenas se não for anônimo
                        validator: (value) {
                          if (!_isAnonimo &&
                              (value == null || value.trim().isEmpty)) {
                            return 'Nome é obrigatório';
                          }
                          return null;
                        },

                        // Estilização do campo de entrada
                        decoration: InputDecoration(
                          hintText: 'Nome',
                          hintStyle:
                              TextStyle(color: Colors.grey[600], fontSize: 16),

                          // Bordas para diferentes estados do campo
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: const BorderSide(
                                color: Colors.black26, width: 1.2),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: const BorderSide(
                                color: Colors.black26, width: 1.2),
                          ),
                          disabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: const BorderSide(
                                color: Colors.black26, width: 1.2),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: const BorderSide(
                                color: Colors.black26, width: 1.2),
                          ),
                          // Bordas vermelhas quando há erro de validação
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide:
                                const BorderSide(color: Colors.red, width: 1.2),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide:
                                const BorderSide(color: Colors.red, width: 1.2),
                          ),

                          // Espaçamento interno do texto
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 16.0,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(
                        width: 16.0), // Espaçamento entre campo e checkbox

                    // Container do checkbox anônimo com padding para alinhamento
                    Container(
                      padding: const EdgeInsets.only(
                          top: 16.0), // Alinha com o centro do campo de texto
                      child: GestureDetector(
                        // Ação ao clicar no checkbox
                        onTap: () {
                          setState(() {
                            _isAnonimo = !_isAnonimo; // Inverte o estado
                            if (_isAnonimo) {
                              _nomeController
                                  .clear(); // Limpa o nome se virar anônimo
                            }
                          });
                          // Nota: removida a revalidação automática para evitar erros prematuros
                        },

                        // Layout do checkbox com texto
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Checkbox customizado (quadrado com cantos arredondados)
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                // Cor de fundo: azul se selecionado, branco se não
                                color: _isAnonimo
                                    ? const Color(0xFF31738A)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(4.0),
                                // Cor da borda: azul se selecionado, cinza se não
                                border: Border.all(
                                  color: _isAnonimo
                                      ? const Color(0xFF31738A)
                                      : Colors.black26,
                                  width: 1.2,
                                ),
                              ),
                              // Ícone de check quando selecionado
                              child: _isAnonimo
                                  ? const Icon(Icons.check,
                                      color: Colors.white, size: 14)
                                  : null,
                            ),

                            const SizedBox(
                                width: 8.0), // Espaço entre checkbox e texto

                            // Texto do label "Anônimo"
                            const Text(
                              'Anônimo',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16.0), // Espaçamento entre seções

                // Seção: Campo de endereço (sempre obrigatório)
                TextFormField(
                  controller: _enderecoController,
                  style: const TextStyle(fontSize: 16),

                  // Validação: endereço é sempre obrigatório
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Endereço é obrigatório';
                    }
                    return null;
                  },

                  // Estilização similar ao campo de nome
                  decoration: InputDecoration(
                    hintText: 'Endereço',
                    hintStyle: TextStyle(color: Colors.grey[600], fontSize: 16),

                    // Bordas idênticas ao campo de nome
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide:
                          const BorderSide(color: Colors.black26, width: 1.2),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide:
                          const BorderSide(color: Colors.black26, width: 1.2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide:
                          const BorderSide(color: Colors.black26, width: 1.2),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide:
                          const BorderSide(color: Colors.red, width: 1.2),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide:
                          const BorderSide(color: Colors.red, width: 1.2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 16.0,
                    ),
                  ),
                ),

                const SizedBox(height: 16.0), // Espaçamento entre seções

                // Seção: Campo de descrição (sempre obrigatório com múltiplas linhas)
                TextFormField(
                  controller: _descricaoController,
                  style: const TextStyle(fontSize: 16),

                  // Validação: descrição obrigatória com mínimo de 10 caracteres
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Conte mais sobre o problema é obrigatório';
                    }
                    if (value.trim().length < 10) {
                      return 'Descrição deve ter pelo menos 10 caracteres';
                    }
                    return null;
                  },

                  // Estilização similar aos outros campos
                  decoration: InputDecoration(
                    hintText: 'Conte mais sobre o problema.',
                    hintStyle: TextStyle(color: Colors.grey[600], fontSize: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide:
                          const BorderSide(color: Colors.black26, width: 1.2),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide:
                          const BorderSide(color: Colors.black26, width: 1.2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide:
                          const BorderSide(color: Colors.black26, width: 1.2),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide:
                          const BorderSide(color: Colors.red, width: 1.2),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide:
                          const BorderSide(color: Colors.red, width: 1.2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 16.0,
                    ),
                  ),
                  maxLines:
                      8, // Permite múltiplas linhas para descrição detalhada
                ),

                const SizedBox(
                    height: 16.0), // Espaçamento antes da seção de arquivos

                // Seção: Área para upload e gerenciamento de arquivos
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black26, width: 1.2),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Column(
                    children: [
                      // Ícone de anexo
                      Icon(
                        Icons.attach_file,
                        color: primaryColor,
                        size: 48,
                      ),

                      const SizedBox(height: 8.0),

                      // Texto explicativo com indicação de obrigatoriedade
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                          ),
                          children: [
                            // Texto principal com limite de arquivos
                            TextSpan(
                              text:
                                  'Envie seus vídeos, tire fotos ou anexe arquivos (máx. $_maxArquivos)',
                            ),
                            // Aviso em vermelho sobre obrigatoriedade
                            const TextSpan(
                              text: '\n* Pelo menos 1 arquivo é obrigatório',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16.0),

                      // Lista horizontal de arquivos selecionados (se houver)
                      if (_arquivos.isNotEmpty) ...[
                        SizedBox(
                          height: 120, // Altura fixa para a lista horizontal
                          child: ListView.builder(
                            scrollDirection:
                                Axis.horizontal, // Scroll horizontal
                            itemCount: _arquivos.length,
                            itemBuilder: (context, index) {
                              final arquivo = _arquivos[index];

                              // Detecta se o arquivo é uma imagem baseado na extensão
                              final isImage = arquivo.path
                                  .toLowerCase()
                                  .contains(RegExp(
                                      r'\.(jpg|jpeg|png|gif|bmp|webp)$'));

                              return Container(
                                margin: const EdgeInsets.only(
                                    right: 8.0), // Espaço entre itens
                                width: 100,
                                child: Stack(
                                  children: [
                                    // Container principal do arquivo
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        border: Border.all(
                                            color: Colors.grey.shade300),
                                      ),
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        child: isImage
                                            ? // Para imagens: mostra preview da imagem
                                            Image.file(
                                                arquivo,
                                                width: 100,
                                                height: 100,
                                                fit: BoxFit.cover,
                                              )
                                            : // Para vídeos: mostra ícone de vídeo
                                            Container(
                                                width: 100,
                                                height: 100,
                                                color: Colors.grey.shade200,
                                                child: const Icon(
                                                  Icons.videocam,
                                                  size: 40,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                      ),
                                    ),

                                    // Botão X para remover o arquivo
                                    Positioned(
                                      top: 4,
                                      right: 4,
                                      child: GestureDetector(
                                        onTap: () => _removerArquivo(index),
                                        child: Container(
                                          decoration: const BoxDecoration(
                                            color: Colors.red,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.close,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 16.0),
                      ],

                      // Botão para escolher arquivos (só aparece se não atingiu o limite)
                      if (_arquivos.length < _maxArquivos)
                        Container(
                          width: 200,
                          height: 40,
                          decoration: BoxDecoration(
                            color: primaryColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: TextButton(
                            onPressed: _escolherArquivos,
                            style: ButtonStyle(
                              overlayColor:
                                  WidgetStateProperty.all(Colors.transparent),
                            ),
                            child: Text(
                              // Texto dinâmico baseado se já há arquivos ou não
                              _arquivos.isEmpty
                                  ? 'Escolher arquivos'
                                  : 'Adicionar mais',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(
                    height: 30.0), // Espaçamento antes dos botões finais

                // Botão principal para enviar a denúncia
                Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: TextButton(
                    onPressed: _enviarDenuncia, // Chama o método de envio
                    style: ButtonStyle(
                      overlayColor: WidgetStateProperty.all(Colors.transparent),
                    ),
                    child: const Center(
                      child: Text(
                        'Enviar Denúncia',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16.0), // Espaçamento entre os botões

                // Botão secundário para cancelar e voltar
                Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: Colors.black26, width: 1.2),
                  ),
                  child: TextButton(
                    onPressed: () => Navigator.of(context)
                        .pop(), // Volta para a tela anterior
                    style: ButtonStyle(
                      overlayColor: WidgetStateProperty.all(Colors.transparent),
                    ),
                    child: const Center(
                      child: Text(
                        'Cancelar',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
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
