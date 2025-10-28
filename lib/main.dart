import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const RiddleApp());
}

class AppColors {
  static const Color background = Color(0xFF0A111F);
  static const Color accent = Color(0xFF00CFFF);
  static const Color secondary = Color(0xFF1F334A);
  static const Color answerPanel = Color(0xF2000000);
}

enum RiddleMode { classic, ai }

class ClassicRiddle {
  const ClassicRiddle({required this.question, required this.answer});

  final String question;
  final String answer;
}

class RiddleCopy {
  const RiddleCopy({
    required this.languageLabel,
    required this.welcomeTitle,
    required this.welcomeSubtitle,
    required this.classicButtonLabel,
    required this.aiButtonLabel,
    required this.newButtonLabel,
    required this.loadingClassic,
    required this.loadingAi,
    required this.answerPlaceholder,
    required this.answerWaiting,
    required this.apiKeyMissing,
    required this.errorTitle,
    required this.aiErrorBase,
    required this.invalidKeySuffix,
    required this.errorPrefix,
  });

  final String languageLabel;
  final String welcomeTitle;
  final String welcomeSubtitle;
  final String classicButtonLabel;
  final String aiButtonLabel;
  final String newButtonLabel;
  final String loadingClassic;
  final String loadingAi;
  final String answerPlaceholder;
  final String answerWaiting;
  final String apiKeyMissing;
  final String errorTitle;
  final String aiErrorBase;
  final String invalidKeySuffix;
  final String errorPrefix;
}

class RiddleLanguage {
  const RiddleLanguage({
    required this.code,
    required this.label,
    required this.classicRiddles,
    required this.systemPrompt,
    required this.userQuery,
    required this.copy,
  });

  final String code;
  final String label;
  final List<ClassicRiddle> classicRiddles;
  final String systemPrompt;
  final String userQuery;
  final RiddleCopy copy;
}

class RiddleApp extends StatelessWidget {
  const RiddleApp({super.key});

  @override
  Widget build(BuildContext context) {
    final baseDarkTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
    );

    final textTheme = GoogleFonts.interTextTheme(baseDarkTheme.textTheme)
        .apply(bodyColor: Colors.white, displayColor: Colors.white);

    return MaterialApp(
      title: 'Riddle Generator',
      debugShowCheckedModeBanner: false,
      theme: baseDarkTheme.copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.accent,
          brightness: Brightness.dark,
          primary: AppColors.accent,
          secondary: AppColors.secondary,
        ),
        textTheme: textTheme,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.all(0),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            side: const BorderSide(color: Colors.white24, width: 1.5),
          ),
        ),
      ),
      home: const RiddleHomePage(),
    );
  }
}

class RiddleHomePage extends StatefulWidget {
  const RiddleHomePage({super.key});

  @override
  State<RiddleHomePage> createState() => _RiddleHomePageState();
}

class _RiddleHomePageState extends State<RiddleHomePage> {
  static const String _model = 'gemini-2.5-flash-preview-09-2025';
  static const String _apiKey = String.fromEnvironment('GEMINI_API_KEY');

  static final List<RiddleLanguage> _languages = [
    RiddleLanguage(
      code: 'bg',
      label: 'Български',
      classicRiddles: const [
        ClassicRiddle(question: 'Винаги тича, а никога не мърда. Що е то?', answer: 'Вода'),
        ClassicRiddle(question: 'Когато го кажеш, то изчезва. Що е то?', answer: 'Мълчание'),
        ClassicRiddle(question: 'Пълна къща, а прозорците стърчат навън. Що е то?', answer: 'Тиква'),
        ClassicRiddle(question: 'Имам очи, а не виждам. Що е то?', answer: 'Игла'),
        ClassicRiddle(question: 'Все върви, а крака няма. Що е то?', answer: 'Времето'),
        ClassicRiddle(question: 'Старо кога се роди, младо кога умре. Що е то?', answer: 'Луната'),
        ClassicRiddle(question: 'Не пия вода, а без вода умирам. Що е то?', answer: 'Риба'),
        ClassicRiddle(question: 'Висока, тънка, глас няма, а песни пее. Що е то?', answer: 'Сопа'),
        ClassicRiddle(question: 'Глава има, очи няма, крила има, лети не може. Що е то?', answer: 'Игла с конец'),
        ClassicRiddle(question: 'Сто зъба, а не хапе. Що е то?', answer: 'Гребен'),
        ClassicRiddle(question: 'Без ръце държи, без крака бяга. Що е то?', answer: 'Часовник'),
        ClassicRiddle(question: 'Малко, бяло и сладко, на езика се топи. Що е то?', answer: 'Захар'),
        ClassicRiddle(question: 'Черно теле в бяла кошара щипе и от врата не пита. Що е то?', answer: 'Писалка'),
        ClassicRiddle(question: 'Една къщурка без врата и прозорци, а вътре златни хора. Що е то?', answer: 'Яйце'),
        ClassicRiddle(question: 'Сгрява без огън, свети без лампа. Що е то?', answer: 'Слънцето'),
        ClassicRiddle(question: 'Виси на стената и все на змия прилича. Що е то?', answer: 'Календар'),
        ClassicRiddle(question: 'Без език говори, без уши слуша. Що е то?', answer: 'Ехо'),
        ClassicRiddle(question: 'Снощи съм бил, днеска ме няма. Що е то?', answer: 'Сянка'),
        ClassicRiddle(question: 'Бяла пелена земята покрива, а слънце я стопява. Що е то?', answer: 'Сняг'),
        ClassicRiddle(question: 'На сто врати, на сто ключа. Що е то?', answer: 'Домат'),
        ClassicRiddle(question: 'Свети, гори, не изгори. Що е то?', answer: 'Светулка'),
        ClassicRiddle(question: 'Има си легло, ама не спи. Що е то?', answer: 'Река'),
      ],
      systemPrompt:
          'Ти си майстор на гатанките. Твоята задача е да предоставяш класически български гатанки. '
          'Отговори само и единствено с гатанката, последвана от отговора на нов ред. '
          'Гатанката трябва да е кратка (1-3 изречения). Не добавяй никакъв друг текст, поздравления или обяснения.',
      userQuery: 'Генерирай една нова, оригинална гатанка.',
      copy: const RiddleCopy(
        languageLabel: 'Език',
        welcomeTitle: 'Добре дошли!',
        welcomeSubtitle: 'Избери каква гатанка искаш:',
        classicButtonLabel: 'Класически Гатанки',
        aiButtonLabel: '✨ AI Гатанка',
        newButtonLabel: 'Нова',
        loadingClassic: 'Зареждане на класическа гатанка...',
        loadingAi: '✨ AI генерира нова гатанка...',
        answerPlaceholder: 'Отговорът ще се появи тук.',
        answerWaiting: 'Изчакайте отговор...',
        apiKeyMissing:
            'Няма конфигуриран Gemini API ключ. Добавете --dart-define=GEMINI_API_KEY=ВАШИЯТ_КЛЮЧ при стартиране на приложението.',
        errorTitle: 'Възникна грешка!',
        aiErrorBase: 'Неуспешно генериране на гатанка.',
        invalidKeySuffix: ' (Проверете дали API ключът е валиден.)',
        errorPrefix: 'Грешка',
      ),
    ),
    RiddleLanguage(
      code: 'en',
      label: 'English',
      classicRiddles: const [
        ClassicRiddle(question: 'What has keys but can’t open locks?', answer: 'A piano.'),
        ClassicRiddle(question: 'I speak without a mouth and hear without ears. What am I?', answer: 'An echo.'),
        ClassicRiddle(question: 'What can travel around the world while staying in a corner?', answer: 'A stamp.'),
        ClassicRiddle(question: 'What has a heart that doesn’t beat?', answer: 'An artichoke.'),
        ClassicRiddle(question: 'The more of this there is, the less you see. What is it?', answer: 'Darkness.'),
        ClassicRiddle(question: 'What has cities, but no houses; forests, but no trees; and water, but no fish?', answer: 'A map.'),
        ClassicRiddle(question: 'I have branches, but no fruit, trunk, or leaves. What am I?', answer: 'A bank.'),
        ClassicRiddle(question: 'What building has the most stories?', answer: 'A library.'),
        ClassicRiddle(question: 'What is so fragile that saying its name breaks it?', answer: 'Silence.'),
        ClassicRiddle(question: 'What runs around a backyard yet never moves?', answer: 'A fence.'),
        ClassicRiddle(question: 'I shave every day, but my beard stays the same. Who am I?', answer: 'A barber.'),
        ClassicRiddle(question: 'I’m light as a feather, yet the strongest person can’t hold me for five minutes.', answer: 'Their breath.'),
        ClassicRiddle(question: 'What has many teeth, but can’t bite?', answer: 'A comb.'),
        ClassicRiddle(question: 'If you drop me I’m sure to crack, but give me a smile and I’ll always smile back.', answer: 'A mirror.'),
        ClassicRiddle(question: 'What begins with T, finishes with T, and has T inside it?', answer: 'A teapot.'),
        ClassicRiddle(question: 'What has hands but can’t clap?', answer: 'A clock.'),
        ClassicRiddle(question: 'What invention lets you look right through a wall?', answer: 'A window.'),
        ClassicRiddle(question: 'What has one eye, but can “see” very little?', answer: 'A needle.'),
        ClassicRiddle(question: 'What has ears but cannot hear?', answer: 'A cornfield.'),
        ClassicRiddle(question: 'Where does today come before yesterday?', answer: 'In the dictionary.'),
        ClassicRiddle(question: 'What kind of room has no doors or windows?', answer: 'A mushroom.'),
        ClassicRiddle(question: 'What gets wetter the more it dries?', answer: 'A towel.'),
        ClassicRiddle(question: 'What is full of holes but still holds water?', answer: 'A sponge.'),
      ],
      systemPrompt:
          'You are a master of riddles. Provide classic riddles in English. Respond only with the riddle, '
          'followed by the answer on a new line. The riddle must be short (1-3 sentences). Do not add any other text, greetings, or explanations.',
      userQuery: 'Generate a single original riddle.',
      copy: const RiddleCopy(
        languageLabel: 'Language',
        welcomeTitle: 'Welcome!',
        welcomeSubtitle: 'Choose which kind of riddle you want:',
        classicButtonLabel: 'Classic Riddles',
        aiButtonLabel: '✨ AI Riddle',
        newButtonLabel: 'New',
        loadingClassic: 'Loading a classic riddle...',
        loadingAi: '✨ AI is crafting a new riddle...',
        answerPlaceholder: 'The answer will appear here.',
        answerWaiting: 'Waiting for the answer...',
        apiKeyMissing:
            'No Gemini API key configured. Launch the app with --dart-define=GEMINI_API_KEY=YOUR_KEY.',
        errorTitle: 'An error occurred!',
        aiErrorBase: 'Failed to generate a riddle.',
        invalidKeySuffix: ' (Check that the API key is valid.)',
        errorPrefix: 'Error',
      ),
    ),
    RiddleLanguage(
      code: 'es',
      label: 'Español',
      classicRiddles: const [
        ClassicRiddle(question: 'Blanca por dentro, verde por fuera. Si quieres que te lo diga, espera.', answer: 'La pera.'),
        ClassicRiddle(question: 'Cae de la torre y no se rompe, cae en el agua y se deshace.', answer: 'La nieve.'),
        ClassicRiddle(question: 'Tiene ojos y no ve, tiene agua y no la bebe.', answer: 'La aguja.'),
        ClassicRiddle(question: 'Va por el campo sin moverse del sitio.', answer: 'La valla.'),
        ClassicRiddle(question: 'Vuelo de noche, duermo en el día, y nunca verás plumas en ala mía.', answer: 'El murciélago.'),
        ClassicRiddle(question: 'Dos hermanas diligentes van al campo continuamente. Como son tan buen amigas, siempre van de buena gana.', answer: 'Las manos.'),
        ClassicRiddle(question: 'Oro parece, plata no es. Abre la cortina y verás quién es.', answer: 'El plátano.'),
        ClassicRiddle(question: 'Espero a que pase el agua para poderla cruzar y, aunque todos me usan, nadie me puede pisar.', answer: 'El puente.'),
        ClassicRiddle(question: 'Tiene dientes y no come, guarda casas y no es hombre.', answer: 'La llave.'),
        ClassicRiddle(question: 'Agua pasa por mi casa, cate de mi corazón.', answer: 'La aguacate (aguacate).'),
        ClassicRiddle(question: 'Más largo que ancho, más blanco que la nieve y todo lo come.', answer: 'El mantel.'),
        ClassicRiddle(question: 'Sube llena y baja vacía, si no se da prisa se queda vacía.', answer: 'La cuchara.'),
        ClassicRiddle(question: 'Tiene cama y no duerme, tiene boca y no habla, y, aunque no tiene pies, sabe andar.', answer: 'El río.'),
        ClassicRiddle(question: 'Cuanto más grande soy, menos se me ve.', answer: 'La oscuridad.'),
        ClassicRiddle(question: 'Sin alas vuelo, sin ojos veo, sin boca hablo y sin manos toco.', answer: 'El viento.'),
        ClassicRiddle(question: 'Soy un animal muy andador, y en cada vuelta dejo el zapato del revés.', answer: 'El caracol.'),
        ClassicRiddle(question: 'Tengo agujas y no sé coser, tengo números y no sé leer.', answer: 'El reloj.'),
        ClassicRiddle(question: 'Salgo al campo muy derechito, voy a la plaza y me muero al grito.', answer: 'El cohete.'),
        ClassicRiddle(question: 'No es cama ni es león y desaparece en un rincón.', answer: 'El camaleón.'),
        ClassicRiddle(question: 'Va de boca en boca y no es melodía, a veces da miedo y otras alegría.', answer: 'La noticia.'),
        ClassicRiddle(question: 'De noche tienen sueño y se duermen boca abajo; de día todos trabajan sin descanso.', answer: 'Los murciélagos.'),
      ],
      systemPrompt:
          'Eres un maestro de acertijos. Proporciona acertijos clásicos en español. Responde solo con el acertijo, '
          'seguido de la respuesta en una nueva línea. El acertijo debe ser breve (1-3 oraciones). No añadas saludos ni explicaciones.',
      userQuery: 'Genera un acertijo original en español.',
      copy: const RiddleCopy(
        languageLabel: 'Idioma',
        welcomeTitle: '¡Bienvenido!',
        welcomeSubtitle: 'Elige qué tipo de acertijo quieres:',
        classicButtonLabel: 'Acertijos Clásicos',
        aiButtonLabel: '✨ Acertijo IA',
        newButtonLabel: 'Nuevo',
        loadingClassic: 'Cargando un acertijo clásico...',
        loadingAi: '✨ La IA está creando un nuevo acertijo...',
        answerPlaceholder: 'La respuesta aparecerá aquí.',
        answerWaiting: 'Esperando la respuesta...',
        apiKeyMissing:
            'No se ha configurado la clave de la API de Gemini. Inicia la app con --dart-define=GEMINI_API_KEY=TU_CLAVE.',
        errorTitle: '¡Ha ocurrido un error!',
        aiErrorBase: 'No se pudo generar un acertijo.',
        invalidKeySuffix: ' (Verifica que la clave de API sea válida.)',
        errorPrefix: 'Error',
      ),
    ),
  ];

  final math.Random _random = math.Random();

  late RiddleLanguage _selectedLanguage;
  RiddleMode? _mode;
  late String _riddleText;
  String _answerText = '';
  bool _isLoading = false;
  bool _answerExpanded = false;
  String? _errorMessage;
  String? _loadingMessage;

  bool get _hasAnswer => _answerText.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _selectedLanguage = _languages.first;
    _riddleText = _selectedLanguage.copy.welcomeTitle;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        color: AppColors.background,
        child: SafeArea(
          child: Center(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final double targetHeight = constraints.maxHeight.isFinite
                    ? (constraints.maxHeight * 0.85).clamp(420.0, 720.0)
                    : 560.0;

                return Container(
                  height: targetHeight,
                  constraints: const BoxConstraints(maxWidth: 480),
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.accent, width: 2),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black54,
                        blurRadius: 30,
                        offset: Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      _buildMainContent(),
                      _buildWelcomeOverlay(),
                      _buildLanguageSelector(),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageSelector() {
    return Positioned(
      top: 12,
      left: 16,
      right: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _selectedLanguage.copy.languageLabel,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _languages.map((language) {
              final bool isSelected = language == _selectedLanguage;
              return InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () => _changeLanguage(language),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.accent : Colors.white10,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isSelected ? AppColors.accent : Colors.white24,
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    language.label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? Colors.black : Colors.white,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeOverlay() {
    final bool showWelcome = _mode == null;
    final copy = _selectedLanguage.copy;
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
      opacity: showWelcome ? 1 : 0,
      child: IgnorePointer(
        ignoring: !showWelcome,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.secondary,
            borderRadius: BorderRadius.circular(24),
          ),
          padding: const EdgeInsets.fromLTRB(24, 96, 24, 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                copy.welcomeTitle,
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                copy.welcomeSubtitle,
                style: const TextStyle(fontSize: 18, color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.black,
                  ),
                  onPressed: () => _startGame(RiddleMode.classic),
                  child: Text(copy.classicButtonLabel),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                  ),
                  onPressed: () => _startGame(RiddleMode.ai),
                  child: Text(copy.aiButtonLabel),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    final bool showContent = _mode != null;
    final copy = _selectedLanguage.copy;
    return IgnorePointer(
      ignoring: !showContent,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
        opacity: showContent ? 1 : 0,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 80, 24, 24),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildTopButtons(copy),
                  const SizedBox(height: 24),
                  Expanded(child: _buildRiddleArea()),
                  const SizedBox(height: 160),
                ],
              ),
              _buildAnswerPanel(copy),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopButtons(RiddleCopy copy) {
    final bool showClassicButton = _mode == RiddleMode.classic;
    final List<Widget> children = [];

    if (showClassicButton) {
      children
        ..add(
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.black,
              ),
              onPressed: _fetchClassicRiddle,
              child: Text(copy.newButtonLabel),
            ),
          ),
        )
        ..add(const SizedBox(width: 12));
    }

    children
      ..add(
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
            ),
            onPressed: _fetchGeminiRiddle,
            child: Text(copy.aiButtonLabel),
          ),
        ),
      )
      ..add(const SizedBox(width: 12))
      ..add(
        SizedBox(
          height: 48,
          width: 48,
          child: OutlinedButton(
            onPressed: _resetGame,
            child: const Icon(Icons.refresh_rounded, color: Colors.white),
          ),
        ),
      );

    return Row(children: children);
  }

  Widget _buildRiddleArea() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (_isLoading) ...[
          if (_loadingMessage != null)
            Text(
              _loadingMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
            ),
          const SizedBox(height: 24),
          const SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(color: AppColors.accent, strokeWidth: 4),
          ),
        ] else ...[
          Text(
            _riddleText,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w400, height: 1.4),
          ),
        ],
        if (_errorMessage != null) ...[
          const SizedBox(height: 24),
          Text(
            _errorMessage!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600),
          ),
        ],
      ],
    );
  }

  Widget _buildAnswerPanel(RiddleCopy copy) {
    const double panelHeight = 240;
    const double collapsedOffset = panelHeight - 48;
    final double offset = _answerExpanded ? 0 : collapsedOffset;

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0, offset, 0),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            if (!_hasAnswer || _answerExpanded) {
              return;
            }
            setState(() => _answerExpanded = true);
          },
          child: Container(
            height: panelHeight,
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
            decoration: const BoxDecoration(
              color: AppColors.answerPanel,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black54,
                  blurRadius: 24,
                  offset: Offset(0, -8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 4),
                Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Center(
                    child: _hasAnswer
                        ? AnimatedOpacity(
                            duration: const Duration(milliseconds: 300),
                            opacity: _answerExpanded ? 1 : 0,
                            child: Text(
                              _answerText,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w700,
                                color: AppColors.accent,
                                height: 1.3,
                              ),
                            ),
                          )
                        : Text(
                            _isLoading ? copy.answerWaiting : copy.answerPlaceholder,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.white70,
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

  void _startGame(RiddleMode mode) {
    setState(() {
      _mode = mode;
      _errorMessage = null;
    });

    if (mode == RiddleMode.classic) {
      _fetchClassicRiddle();
    } else {
      _fetchGeminiRiddle();
    }
  }

  void _resetGame() {
    setState(() {
      _mode = null;
      _riddleText = _selectedLanguage.copy.welcomeTitle;
      _answerText = '';
      _isLoading = false;
      _answerExpanded = false;
      _errorMessage = null;
      _loadingMessage = null;
    });
  }

  void _changeLanguage(RiddleLanguage language) {
    if (_selectedLanguage == language) {
      return;
    }
    setState(() {
      _selectedLanguage = language;
      _errorMessage = null;
      if (_mode == null) {
        _riddleText = language.copy.welcomeTitle;
      }
    });

    if (_mode == RiddleMode.classic) {
      _fetchClassicRiddle();
    } else if (_mode == RiddleMode.ai) {
      _fetchGeminiRiddle();
    }
  }

  void _showLoading(String message) {
    setState(() {
      _isLoading = true;
      _loadingMessage = message;
      _answerExpanded = false;
      _answerText = '';
      _errorMessage = null;
    });
  }

  void _setRiddle(String riddle, String answer) {
    setState(() {
      _riddleText = riddle;
      _answerText = answer;
      _isLoading = false;
      _loadingMessage = null;
      _answerExpanded = false;
      _errorMessage = null;
    });
  }

  void _showError(String message) {
    setState(() {
      _riddleText = _selectedLanguage.copy.errorTitle;
      _answerText = '';
      _isLoading = false;
      _loadingMessage = null;
      _answerExpanded = false;
      _errorMessage = message;
    });
  }

  Future<void> _fetchClassicRiddle() async {
    _showLoading(_selectedLanguage.copy.loadingClassic);
    await Future.delayed(const Duration(milliseconds: 350));
    final classics = _selectedLanguage.classicRiddles;
    final classic = classics[_random.nextInt(classics.length)];
    _setRiddle(classic.question, classic.answer);
  }

  Future<void> _fetchGeminiRiddle() async {
    _showLoading(_selectedLanguage.copy.loadingAi);

    if (_apiKey.isEmpty) {
      _showError(_selectedLanguage.copy.apiKeyMissing);
      return;
    }

    final uri = Uri.https(
      'generativelanguage.googleapis.com',
      '/v1beta/models/$_model:generateContent',
      {'key': _apiKey},
    );

    final payload = <String, dynamic>{
      'contents': [
        {
          'parts': [
            {'text': _selectedLanguage.userQuery},
          ],
        }
      ],
      'systemInstruction': {
        'parts': [
          {'text': _selectedLanguage.systemPrompt},
        ],
      },
    };

    Object? lastError;

    for (var attempt = 1; attempt <= 3; attempt++) {
      try {
        final response = await http.post(
          uri,
          headers: const {'Content-Type': 'application/json'},
          body: jsonEncode(payload),
        );

        if (response.statusCode < 200 || response.statusCode >= 300) {
          throw Exception('HTTP ${response.statusCode} ${response.reasonPhrase ?? ''}'.trim());
        }

        final Map<String, dynamic> data = jsonDecode(response.body) as Map<String, dynamic>;
        final String? text = _extractGeneratedText(data);

        if (text == null) {
          throw const FormatException('Invalid AI response format.');
        }

        final parts = text.trim().split('\n').where((part) => part.trim().isNotEmpty).toList();
        if (parts.length < 2) {
          throw const FormatException('Invalid AI response format.');
        }

        final String riddle = parts.first.trim();
        final String answer = parts.last.trim();

        _setRiddle(riddle, answer);
        return;
      } catch (error, stackTrace) {
        lastError = error;
        if (kDebugMode) {
          debugPrint('Gemini attempt $attempt failed: $error');
          debugPrint(stackTrace.toString());
        }
        if (attempt < 3) {
          final delayMilliseconds = (math.pow(2, attempt) * 400).round();
          await Future.delayed(Duration(milliseconds: delayMilliseconds));
        }
      }
    }

    var message = _selectedLanguage.copy.aiErrorBase;
    if (lastError != null) {
      final errorText = lastError.toString();
      if (errorText.contains('HTTP 400')) {
        message += _selectedLanguage.copy.invalidKeySuffix;
      } else {
        message += ' ${_selectedLanguage.copy.errorPrefix}: $errorText';
      }
    }
    _showError(message);
  }

  String? _extractGeneratedText(Map<String, dynamic> data) {
    final candidates = data['candidates'];
    if (candidates is List && candidates.isNotEmpty) {
      final content = candidates.first['content'];
      if (content is Map<String, dynamic>) {
        final parts = content['parts'];
        if (parts is List && parts.isNotEmpty) {
          final firstPart = parts.first;
          if (firstPart is Map<String, dynamic>) {
            final text = firstPart['text'];
            if (text is String && text.trim().isNotEmpty) {
              return text;
            }
          }
        }
      }
    }
    return null;
  }
}
