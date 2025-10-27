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
  static const Color answerPanel = Color(0xF2000000); // Nearly black with high opacity
}

enum RiddleMode { classic, ai }

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
      title: 'Генератор на Гатанки',
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

class ClassicRiddle {
  const ClassicRiddle({required this.question, required this.answer});

  final String question;
  final String answer;
}

class RiddleHomePage extends StatefulWidget {
  const RiddleHomePage({super.key});

  @override
  State<RiddleHomePage> createState() => _RiddleHomePageState();
}

class _RiddleHomePageState extends State<RiddleHomePage> {
  static const String _welcomeMessage = 'Добре дошли!';
  static const String _systemPrompt =
      'Ти си майстор на гатанките. Твоята задача е да предоставяш класически български гатанки. '
      'Отговори само и единствено с гатанката, последвана от отговора на нов ред. '
      'Гатанката трябва да е кратка (1-3 изречения). Не добавяй никакъв друг текст, поздравления или обяснения.';
  static const String _userQuery = 'Генерирай една нова, оригинална гатанка.';
  static const String _model = 'gemini-2.5-flash-preview-09-2025';
  static const String _apiKey = String.fromEnvironment('GEMINI_API_KEY');

  final List<ClassicRiddle> _classicRiddles = const [
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
  ];

  final math.Random _random = math.Random();

  RiddleMode? _mode;
  String _riddleText = _welcomeMessage;
  String _answerText = '';
  bool _isLoading = false;
  bool _answerExpanded = false;
  String? _errorMessage;
  String? _loadingMessage;

  bool get _hasAnswer => _answerText.trim().isNotEmpty;

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
                    children: [
                      _buildMainContent(),
                      _buildWelcomeOverlay(),
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

  Widget _buildWelcomeOverlay() {
    final bool showWelcome = _mode == null;
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
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Добре дошли!',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'Избери каква гатанка искаш:',
                style: TextStyle(fontSize: 18, color: Colors.white70),
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
                  child: const Text('Класически Гатанки'),
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
                  child: const Text('✨ AI Гатанка'),
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
    return IgnorePointer(
      ignoring: !showContent,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
        opacity: showContent ? 1 : 0,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildTopButtons(),
                  const SizedBox(height: 24),
                  Expanded(child: _buildRiddleArea()),
                  const SizedBox(height: 160),
                ],
              ),
              _buildAnswerPanel(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopButtons() {
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
              child: const Text('Нова'),
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
            child: const Text('✨ AI Гатанка'),
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

  Widget _buildAnswerPanel() {
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
                            _isLoading
                                ? 'Изчакайте отговор...'
                                : 'Отговорът ще се появи тук.',
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
      _riddleText = _welcomeMessage;
      _answerText = '';
      _isLoading = false;
      _answerExpanded = false;
      _errorMessage = null;
      _loadingMessage = null;
    });
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
      _riddleText = 'Възникна грешка!';
      _answerText = '';
      _isLoading = false;
      _loadingMessage = null;
      _answerExpanded = false;
      _errorMessage = message;
    });
  }

  Future<void> _fetchClassicRiddle() async {
    _showLoading('Зареждане на класическа гатанка...');
    await Future.delayed(const Duration(milliseconds: 350));
    final classic = _classicRiddles[_random.nextInt(_classicRiddles.length)];
    _setRiddle(classic.question, classic.answer);
  }

  Future<void> _fetchGeminiRiddle() async {
    _showLoading('✨ AI генерира нова гатанка...');

    if (_apiKey.isEmpty) {
      _showError(
        'Няма конфигуриран Gemini API ключ. Добавете --dart-define=GEMINI_API_KEY=ВАШИЯТ_КЛЮЧ при стартиране на приложението.',
      );
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
            {'text': _userQuery},
          ],
        }
      ],
      'systemInstruction': {
        'parts': [
          {'text': _systemPrompt},
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
          throw const FormatException('Невалиден формат на отговор от AI.');
        }

        final parts = text.trim().split('\n').where((part) => part.trim().isNotEmpty).toList();
        if (parts.length < 2) {
          throw const FormatException('Невалиден формат на отговор от AI.');
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

    var message = 'Неуспешно генериране на гатанка.';
    if (lastError != null) {
      final errorText = lastError.toString();
      if (errorText.contains('HTTP 400')) {
        message += ' (Проверете дали API ключът е валиден.)';
      } else {
        message += ' Грешка: $errorText';
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
