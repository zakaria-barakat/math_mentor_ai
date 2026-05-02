import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/settings_provider.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  // Calculator state
  String _display = '0';
  String _currentInput = '';        // لتخزين الرقم الحالي
  String _fullExpression = '';      // لتخزين المسألة كاملة
  double _firstOperand = 0;
  double _secondOperand = 0;
  String _operation = '';
  bool _isNewOperation = true;
  bool _hasResult = false;
  String _memory = '0';
  bool _isRadians = true;
  bool _isScientificMode = false;

  // متغيرات التبويبات
  int _selectedTabIndex = 0; // 0: أساسي, 1: مثلثات, 2: متقدمة, 3: ذاكرة, 4: متغيرات

  // متغيرات لتخزين القيم (للحاسبة المتقدمة)
  Map<String, double> _variables = {
    'x': 0.0,
    'y': 0.0,
    'z': 0.0,
    'a': 0.0,
    'b': 0.0,
    'c': 0.0,
  };

  String _currentVariable = 'x';
  bool _isVariableMode = false;

  @override
  void initState() {
    super.initState();
    _loadVariables(); // تحميل المتغيرات المحفوظة
  }

  // ==================== دوال الحفظ والتحميل ====================
  Future<void> _saveVariables() async {
    final prefs = await SharedPreferences.getInstance();
    _variables.forEach((key, value) {
      prefs.setDouble('var_$key', value);
    });
  }

  Future<void> _loadVariables() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _variables.forEach((key, value) {
        _variables[key] = prefs.getDouble('var_$key') ?? 0.0;
      });
    });
  }

  // ==================== دوال المتغيرات ====================
  void _clearVariable(String varName) {
    setState(() {
      _variables[varName] = 0.0;
      _display = '✓ تم مسح $varName';
      _hasResult = true;
      _saveVariables(); // حفظ التغييرات

      // إخفاء الرسالة بعد ثانية
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() {
            _display = '0';
            _hasResult = false;
          });
        }
      });
    });
  }

  void _clearAllVariables() {
    setState(() {
      _variables.updateAll((key, value) => 0.0);
      _display = '✓ تم مسح جميع المتغيرات';
      _hasResult = true;
      _saveVariables(); // حفظ التغييرات

      // إخفاء الرسالة بعد ثانية
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() {
            _display = '0';
            _hasResult = false;
          });
        }
      });
    });
  }

  void _showVariableValue(String varName) {
    setState(() {
      _display = _formatResult(_variables[varName]!);
      _currentVariable = varName;
      _isVariableMode = true;
      _fullExpression = '$_currentVariable = ${_variables[varName]}';
    });
  }

  void _setVariable(String varName) {
    setState(() {
      _currentVariable = varName;
      _display = _formatResult(_variables[varName]!);
      _isVariableMode = true;
      _fullExpression = '$_currentVariable = ${_variables[varName]}';
    });
  }

  // ==================== دوال الأرقام ====================
  void _onNumberPressed(String number) {
    setState(() {
      if (_isNewOperation || _display == '0' || _hasResult) {
        _currentInput = number;
        _fullExpression = number;
        _display = number;
        _isNewOperation = false;
        _hasResult = false;
        _isVariableMode = false;
      } else {
        _currentInput += number;
        _fullExpression += number;
        _display += number;
      }
    });
  }

  void _onDecimalPressed() {
    setState(() {
      if (_isNewOperation || _hasResult) {
        _currentInput = '0.';
        _fullExpression = '0.';
        _display = '0.';
        _isNewOperation = false;
        _hasResult = false;
        _isVariableMode = false;
      } else if (!_currentInput.contains('.')) {
        _currentInput += '.';
        _fullExpression += '.';
        _display += '.';
      }
    });
  }

  void _onOperationPressed(String op) {
    setState(() {
      if (_currentInput.isNotEmpty && !_isNewOperation) {
        _firstOperand = double.parse(_currentInput);
        _operation = op;
        _isNewOperation = true;
        _fullExpression += ' $op ';
        _currentInput = '';
        _isVariableMode = false;
      } else if (_operation.isNotEmpty) {
        // تغيير العملية إذا لم يتم إدخال رقم بعد
        _operation = op;
        // تحديث آخر عملية في المسألة
        List<String> parts = _fullExpression.split(' ');
        if (parts.length >= 2) {
          parts[parts.length - 2] = op;
          _fullExpression = parts.join(' ');
        }
      }
    });
  }

  void _onEqualsPressed() {
    if (_operation.isEmpty || _currentInput.isEmpty) return;

    setState(() {
      _secondOperand = double.parse(_currentInput);
      double result = 0;

      switch (_operation) {
        case '+':
          result = _firstOperand + _secondOperand;
          break;
        case '-':
          result = _firstOperand - _secondOperand;
          break;
        case '×':
          result = _firstOperand * _secondOperand;
          break;
        case '÷':
          if (_secondOperand == 0) {
            _display = 'خطأ';
            _fullExpression = '$_firstOperand $_operation $_secondOperand = خطأ';
            _hasResult = true;
            _operation = '';
            return;
          }
          result = _firstOperand / _secondOperand;
          break;
        case '^':
          result = math.pow(_firstOperand, _secondOperand).toDouble();
          break;
        case 'mod':
          result = _firstOperand % _secondOperand;
          break;
      }

      String formattedResult = _formatResult(result);
      _display = formattedResult;
      _fullExpression = '$_firstOperand $_operation $_secondOperand = $formattedResult';
      _currentInput = formattedResult;
      _hasResult = true;
      _operation = '';
    });
  }

  // ==================== الدوال العلمية ====================
  void _onScientificFunction(String func) {
    if (_display.isEmpty || _display == 'خطأ') return;

    setState(() {
      double value = double.parse(_display);
      double result = 0;

      switch (func) {
      // ===== الدوال المثلثية الأساسية =====
        case 'sin':
          result = _isRadians ? math.sin(value) : math.sin(value * math.pi / 180);
          break;
        case 'cos':
          result = _isRadians ? math.cos(value) : math.cos(value * math.pi / 180);
          break;
        case 'tan':
          result = _isRadians ? math.tan(value) : math.tan(value * math.pi / 180);
          if (result.isInfinite || result.isNaN) {
            _display = 'غير معرف';
            return;
          }
          break;
        case 'cot':
          result = 1 / (_isRadians ? math.tan(value) : math.tan(value * math.pi / 180));
          if (result.isInfinite || result.isNaN) {
            _display = 'غير معرف';
            return;
          }
          break;
        case 'sec':
          result = 1 / (_isRadians ? math.cos(value) : math.cos(value * math.pi / 180));
          if (result.isInfinite || result.isNaN) {
            _display = 'غير معرف';
            return;
          }
          break;
        case 'csc':
          result = 1 / (_isRadians ? math.sin(value) : math.sin(value * math.pi / 180));
          if (result.isInfinite || result.isNaN) {
            _display = 'غير معرف';
            return;
          }
          break;

      // ===== الدوال المثلثية العكسية =====
        case 'asin':
          if (value < -1 || value > 1) {
            _display = 'غير معرف';
            return;
          }
          result = _isRadians ? math.asin(value) : math.asin(value) * 180 / math.pi;
          break;
        case 'acos':
          if (value < -1 || value > 1) {
            _display = 'غير معرف';
            return;
          }
          result = _isRadians ? math.acos(value) : math.acos(value) * 180 / math.pi;
          break;
        case 'atan':
          result = _isRadians ? math.atan(value) : math.atan(value) * 180 / math.pi;
          break;
        case 'acot':
          result = math.pi / 2 - (_isRadians ? math.atan(value) : math.atan(value) * 180 / math.pi);
          break;

      // ===== الدوال الزائدية =====
        case 'sinh':
          result = (math.exp(value) - math.exp(-value)) / 2;
          break;
        case 'cosh':
          result = (math.exp(value) + math.exp(-value)) / 2;
          break;
        case 'tanh':
          double e1 = math.exp(value);
          double e2 = math.exp(-value);
          result = (e1 - e2) / (e1 + e2);
          break;
        case 'coth':
          double e1 = math.exp(value);
          double e2 = math.exp(-value);
          result = (e1 + e2) / (e1 - e2);
          break;
        case 'sech':
          result = 2 / (math.exp(value) + math.exp(-value));
          break;
        case 'csch':
          result = 2 / (math.exp(value) - math.exp(-value));
          break;

      // ===== الدوال اللوغاريتمية =====
        case 'log':
          if (value <= 0) {
            _display = 'غير معرف';
            return;
          }
          result = math.log(value) / math.ln10;
          break;
        case 'ln':
          if (value <= 0) {
            _display = 'غير معرف';
            return;
          }
          result = math.log(value);
          break;
        case 'log₂':
          if (value <= 0) {
            _display = 'غير معرف';
            return;
          }
          result = math.log(value) / math.ln2;
          break;

      // ===== الجذور والقوى =====
        case '√':
          if (value < 0) {
            _display = 'غير معرف';
            return;
          }
          result = math.sqrt(value);
          break;
        case '∛':
          result = math.pow(value, 1 / 3).toDouble();
          break;
        case 'x²':
          result = value * value;
          break;
        case 'x³':
          result = value * value * value;
          break;
        case 'xʸ':
          _firstOperand = value;
          _operation = '^';
          _isNewOperation = true;
          _fullExpression += ' ^ ';
          _currentInput = '';
          return;

      // ===== الدوال الأسية =====
        case '10ˣ':
          result = math.pow(10, value).toDouble();
          break;
        case 'eˣ':
          result = math.exp(value);
          break;
        case '2ˣ':
          result = math.pow(2, value).toDouble();
          break;

      // ===== دوال أخرى =====
        case '1/x':
          if (value == 0) {
            _display = 'غير معرف';
            return;
          }
          result = 1 / value;
          break;
        case '|x|':
          result = value.abs();
          break;
        case 'x!':
          if (value < 0 || value != value.floorToDouble()) {
            _display = 'غير معرف';
            return;
          }
          result = _factorial(value.toInt()).toDouble();
          break;

      // ===== الثوابت =====
        case 'π':
          result = math.pi;
          break;
        case 'e':
          result = math.e;
          break;
        case 'φ':
          result = (1 + math.sqrt(5)) / 2; // النسبة الذهبية
          break;

      // ===== دوال التقريب =====
        case 'floor':
          result = value.floorToDouble();
          break;
        case 'ceil':
          result = value.ceilToDouble();
          break;
        case 'round':
          result = value.roundToDouble();
          break;

      // ===== المتغيرات =====
        case 'STO':
          _variables[_currentVariable] = double.parse(_display);
          _display = '✓ تم التخزين في $_currentVariable';
          _hasResult = true;
          _saveVariables(); // حفظ التغييرات
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) {
              setState(() {
                _display = '0';
                _hasResult = false;
              });
            }
          });
          return;

        case 'RCL':
          _display = _formatResult(_variables[_currentVariable]!);
          _fullExpression = '$_currentVariable = ${_variables[_currentVariable]}';
          _hasResult = true;
          return;
      }

      _display = _formatResult(result);
      _fullExpression = '$func($value) = $_display';
      _hasResult = true;
    });
  }

  int _factorial(int n) {
    if (n <= 1) return 1;
    int result = 1;
    for (int i = 2; i <= n; i++) {
      result *= i;
    }
    return result;
  }

  // ==================== دوال التفاضل والتكامل (مبسطة) ====================
  double _derivative(String function, double x, double h) {
    double f_x = _evaluateFunction(function, x);
    double f_x_h = _evaluateFunction(function, x + h);
    return (f_x_h - f_x) / h;
  }

  double _integral(String function, double a, double b, int n) {
    double h = (b - a) / n;
    double sum = _evaluateFunction(function, a) + _evaluateFunction(function, b);

    for (int i = 1; i < n; i++) {
      double x = a + i * h;
      if (i % 2 == 0) {
        sum += 2 * _evaluateFunction(function, x);
      } else {
        sum += 4 * _evaluateFunction(function, x);
      }
    }

    return (h / 3) * sum;
  }

  double _evaluateFunction(String function, double x) {
    switch (function) {
      case 'sin':
        return math.sin(x);
      case 'cos':
        return math.cos(x);
      case 'x²':
        return x * x;
      case 'x³':
        return x * x * x;
      default:
        return x;
    }
  }

  // ==================== دوال التحكم ====================
  void _onClear() {
    setState(() {
      _display = '0';
      _currentInput = '';
      _fullExpression = '';
      _firstOperand = 0;
      _secondOperand = 0;
      _operation = '';
      _isNewOperation = true;
      _hasResult = false;
      _isVariableMode = false;
    });
  }

  void _onClearEntry() {
    setState(() {
      _display = '0';
      _currentInput = '';
      _isNewOperation = true;
    });
  }

  void _onBackspace() {
    setState(() {
      if (_display.length > 1 && _display != '0' && !_hasResult) {
        _display = _display.substring(0, _display.length - 1);
        if (_currentInput.isNotEmpty) {
          _currentInput = _currentInput.substring(0, _currentInput.length - 1);
        }
        if (_fullExpression.isNotEmpty) {
          _fullExpression = _fullExpression.substring(0, _fullExpression.length - 1);
        }
      } else {
        _display = '0';
        _currentInput = '';
        _isNewOperation = true;
      }
    });
  }

  void _onPercent() {
    setState(() {
      double value = double.parse(_display);
      value = value / 100;
      _display = _formatResult(value);
      _currentInput = _display;
      _hasResult = true;
    });
  }

  void _onPlusMinus() {
    setState(() {
      if (_display != '0' && _display != 'خطأ') {
        double value = double.parse(_display);
        value = -value;
        _display = _formatResult(value);
        _currentInput = _display;
      }
    });
  }

  void _memoryOperation(String op) {
    setState(() {
      double currentValue = double.parse(_display);
      double memoryValue = double.parse(_memory);

      switch (op) {
        case 'MC': // Memory Clear
          _memory = '0';
          _display = '✓ تم مسح الذاكرة';
          break;
        case 'MR': // Memory Recall
          _display = _memory;
          _currentInput = _memory;
          _isNewOperation = true;
          _hasResult = false;
          break;
        case 'M+': // Memory Add
          _memory = _formatResult(memoryValue + currentValue);
          _display = '✓ تمت الإضافة للذاكرة';
          break;
        case 'M-': // Memory Subtract
          _memory = _formatResult(memoryValue - currentValue);
          _display = '✓ تم الطرح من الذاكرة';
          break;
        case 'MS': // Memory Store
          _memory = _display;
          _display = '✓ تم التخزين في الذاكرة';
          break;
      }

      // إخفاء الرسالة بعد ثانية
      if (op != 'MR') {
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            setState(() {
              _display = '0';
              _hasResult = false;
            });
          }
        });
      }
      _hasResult = true;
    });
  }

  String _formatResult(double value) {
    if (value.isInfinite) return '∞';
    if (value.isNaN) return 'غير معرف';

    // معالجة الأرقام الصغيرة جداً
    if (value.abs() < 1e-10 && value != 0) {
      return '0';
    }

    // محاولة عرض الرقم بدون صيغة علمية
    String formatted = value.toStringAsFixed(10);

    // إزالة الأصفار الزائدة
    if (formatted.contains('.')) {
      formatted = formatted.replaceAll(RegExp(r'0*$'), '');
      if (formatted.endsWith('.')) {
        formatted = formatted.substring(0, formatted.length - 1);
      }
    }

    // إذا كان الرقم طويلاً جداً، استخدم الصيغة العلمية بشكل محدود
    if (formatted.length > 15) {
      if (value.abs() >= 1e10) {
        formatted = value.toStringAsExponential(2);
      } else {
        formatted = value.toStringAsFixed(5);
      }
    }

    return formatted;
  }

  void _toggleMode() {
    setState(() {
      _isScientificMode = !_isScientificMode;
      _selectedTabIndex = 0;
    });
  }

  void _toggleAngleMode() {
    setState(() {
      _isRadians = !_isRadians;
    });
  }

  // ==================== واجهة المستخدم ====================
  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return Scaffold(
          backgroundColor: settings.isDarkMode ? Colors.grey.shade900 : Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.close,
                color: settings.isDarkMode ? Colors.white : const Color(0xFF0C206D),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              settings.translate('آلة حاسبة علمية متكاملة', 'Advanced Scientific Calculator'),
              style: TextStyle(
                color: settings.isDarkMode ? Colors.white : const Color(0xFF0C206D),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            actions: [
              // Memory indicator
              if (_memory != '0')
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'M',
                    style: TextStyle(
                      color: const Color(0xFF0C206D),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

              // Angle mode indicator
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _isRadians ? 'RAD' : 'DEG',
                  style: TextStyle(
                    color: Colors.orange.shade800,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // Variable indicator
              if (_isVariableMode)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _currentVariable,
                    style: TextStyle(
                      color: Colors.green.shade800,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

              IconButton(
                icon: Icon(
                  _isScientificMode ? Icons.calculate_outlined : Icons.science,
                  color: settings.isDarkMode ? Colors.white : const Color(0xFF0C206D),
                ),
                onPressed: _toggleMode,
              ),
            ],
          ),
          body: Column(
            children: [
              // Display Area
              Expanded(
                flex: 3,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  alignment: Alignment.bottomRight,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Full Expression (المسألة كاملة)
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        decoration: BoxDecoration(
                          color: settings.isDarkMode
                              ? Colors.grey.shade800.withValues(alpha: 0.5)
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _fullExpression.isEmpty ? '0' : _fullExpression,
                          style: TextStyle(
                            fontSize: 20,
                            color: settings.isDarkMode
                                ? Colors.grey.shade400
                                : Colors.grey.shade700,
                            fontFamily: 'monospace',
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Current Input/Result (الرقم الحالي)
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        reverse: true,
                        child: Text(
                          _display,
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: _display == 'خطأ' ||
                                _display == 'غير معرف' || _display == '∞'
                                ? Colors.red
                                : (settings.isDarkMode
                                ? Colors.white
                                : const Color(0xFF0C206D)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Buttons
              Expanded(
                flex: 7,
                child: _isScientificMode
                    ? _buildScientificButtons(settings)
                    : _buildBasicButtons(settings),
              ),
            ],
          ),
        );
      },
    );
  }

  // ==================== الأزرار الأساسية ====================
  Widget _buildBasicButtons(SettingsProvider settings) {
    return GridView.count(
      crossAxisCount: 4,
      padding: const EdgeInsets.all(8),
      childAspectRatio: 1.2,
      children: [
        _buildButton('C', Colors.red.shade100, Colors.red, settings, onTap: _onClear),
        _buildButton('CE', Colors.orange.shade100, Colors.orange, settings, onTap: _onClearEntry),
        _buildButton('⌫', Colors.orange.shade100, Colors.orange, settings, onTap: _onBackspace),
        _buildButton('÷', Colors.blue.shade100, const Color(0xFF0C206D), settings, onTap: () => _onOperationPressed('÷')),

        _buildButton('7', Colors.grey.shade200, Colors.black87, settings, onTap: () => _onNumberPressed('7')),
        _buildButton('8', Colors.grey.shade200, Colors.black87, settings, onTap: () => _onNumberPressed('8')),
        _buildButton('9', Colors.grey.shade200, Colors.black87, settings, onTap: () => _onNumberPressed('9')),
        _buildButton('×', Colors.blue.shade100, const Color(0xFF0C206D), settings, onTap: () => _onOperationPressed('×')),

        _buildButton('4', Colors.grey.shade200, Colors.black87, settings, onTap: () => _onNumberPressed('4')),
        _buildButton('5', Colors.grey.shade200, Colors.black87, settings, onTap: () => _onNumberPressed('5')),
        _buildButton('6', Colors.grey.shade200, Colors.black87, settings, onTap: () => _onNumberPressed('6')),
        _buildButton('-', Colors.blue.shade100, const Color(0xFF0C206D), settings, onTap: () => _onOperationPressed('-')),

        _buildButton('1', Colors.grey.shade200, Colors.black87, settings, onTap: () => _onNumberPressed('1')),
        _buildButton('2', Colors.grey.shade200, Colors.black87, settings, onTap: () => _onNumberPressed('2')),
        _buildButton('3', Colors.grey.shade200, Colors.black87, settings, onTap: () => _onNumberPressed('3')),
        _buildButton('+', Colors.blue.shade100, const Color(0xFF0C206D), settings, onTap: () => _onOperationPressed('+')),

        _buildButton('±', Colors.grey.shade200, Colors.black87, settings, onTap: _onPlusMinus),
        _buildButton('0', Colors.grey.shade200, Colors.black87, settings, onTap: () => _onNumberPressed('0')),
        _buildButton('.', Colors.grey.shade200, Colors.black87, settings, onTap: _onDecimalPressed),
        _buildButton('=', Colors.blue, Colors.white, settings, onTap: _onEqualsPressed),
      ],
    );
  }

  // ==================== الأزرار العلمية مع التبويبات ====================
  Widget _buildScientificButtons(SettingsProvider settings) {
    return Column(
      children: [
        _buildTabBar(settings),
        Expanded(
          child: GridView.count(
            crossAxisCount: 5,
            padding: const EdgeInsets.all(4),
            childAspectRatio: 0.9,
            children: _getButtonsForSelectedTab(settings),
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar(SettingsProvider settings) {
    return Container(
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: settings.isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          _buildTab('أساسي', 0, settings),
          _buildTab('مثلثات', 1, settings),
          _buildTab('متقدمة', 2, settings),
          _buildTab('ذاكرة', 3, settings),
          _buildTab('متغيرات', 4, settings),
        ],
      ),
    );
  }

  Widget _buildTab(String text, int index, SettingsProvider settings) {
    bool isSelected = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTabIndex = index;
          });
        },
        child: Container(
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isSelected
                ? (settings.isDarkMode ? Colors.orange.shade700 : Colors.white)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: isSelected
                    ? (settings.isDarkMode ? Colors.white : Colors.orange.shade700)
                    : (settings.isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ==================== محتوى كل تبويب ====================
  List<Widget> _getButtonsForSelectedTab(SettingsProvider settings) {
    switch (_selectedTabIndex) {
      case 0: // أساسي
        return [
          _buildButton('C', Colors.red.shade100, Colors.red, settings, onTap: _onClear),
          _buildButton('CE', Colors.orange.shade100, Colors.orange, settings, onTap: _onClearEntry),
          _buildButton('⌫', Colors.orange.shade100, Colors.orange, settings, onTap: _onBackspace),
          _buildButton('%', Colors.purple.shade100, const Color(0xFF0C206D), settings, onTap: _onPercent),
          _buildButton('^', Colors.purple.shade100, const Color(0xFF0C206D), settings, onTap: () => _onOperationPressed('^')),

          _buildButton('x²', Colors.purple.shade100, const Color(0xFF0C206D), settings, onTap: () => _onScientificFunction('x²')),
          _buildButton('x³', Colors.purple.shade100, const Color(0xFF0C206D), settings, onTap: () => _onScientificFunction('x³')),
          _buildButton('√', Colors.purple.shade100, const Color(0xFF0C206D), settings, onTap: () => _onScientificFunction('√')),
          _buildButton('∛', Colors.purple.shade100, const Color(0xFF0C206D), settings, onTap: () => _onScientificFunction('∛')),
          _buildButton('1/x', Colors.purple.shade100, const Color(0xFF0C206D), settings, onTap: () => _onScientificFunction('1/x')),

          _buildButton('10ˣ', Colors.purple.shade100, const Color(0xFF0C206D), settings, onTap: () => _onScientificFunction('10ˣ')),
          _buildButton('eˣ', Colors.purple.shade100, const Color(0xFF0C206D), settings, onTap: () => _onScientificFunction('eˣ')),
          _buildButton('2ˣ', Colors.purple.shade100, const Color(0xFF0C206D), settings, onTap: () => _onScientificFunction('2ˣ')),
          _buildButton('|x|', Colors.purple.shade100, const Color(0xFF0C206D), settings, onTap: () => _onScientificFunction('|x|')),
          _buildButton('x!', Colors.purple.shade100, const Color(0xFF0C206D), settings, onTap: () => _onScientificFunction('x!')),

          _buildButton('π', Colors.purple.shade100, const Color(0xFF0C206D), settings, onTap: () => _onScientificFunction('π')),
          _buildButton('e', Colors.purple.shade100, const Color(0xFF0C206D), settings, onTap: () => _onScientificFunction('e')),
          _buildButton('φ', Colors.purple.shade100, const Color(0xFF0C206D), settings, onTap: () => _onScientificFunction('φ')),
          _buildButton('log', Colors.purple.shade100, const Color(0xFF0C206D), settings, onTap: () => _onScientificFunction('log')),
          _buildButton('ln', Colors.purple.shade100, const Color(0xFF0C206D), settings, onTap: () => _onScientificFunction('ln')),

          _buildButton('7', Colors.grey.shade200, Colors.black87, settings, onTap: () => _onNumberPressed('7')),
          _buildButton('8', Colors.grey.shade200, Colors.black87, settings, onTap: () => _onNumberPressed('8')),
          _buildButton('9', Colors.grey.shade200, Colors.black87, settings, onTap: () => _onNumberPressed('9')),
          _buildButton('÷', Colors.blue.shade100, const Color(0xFF0C206D), settings, onTap: () => _onOperationPressed('÷')),
          _buildButton('±', Colors.grey.shade200, Colors.black87, settings, onTap: _onPlusMinus),

          _buildButton('4', Colors.grey.shade200, Colors.black87, settings, onTap: () => _onNumberPressed('4')),
          _buildButton('5', Colors.grey.shade200, Colors.black87, settings, onTap: () => _onNumberPressed('5')),
          _buildButton('6', Colors.grey.shade200, Colors.black87, settings, onTap: () => _onNumberPressed('6')),
          _buildButton('×', Colors.blue.shade100, const Color(0xFF0C206D), settings, onTap: () => _onOperationPressed('×')),
          _buildButton('RAD', Colors.orange.shade100, Colors.orange, settings, onTap: _toggleAngleMode),

          _buildButton('1', Colors.grey.shade200, Colors.black87, settings, onTap: () => _onNumberPressed('1')),
          _buildButton('2', Colors.grey.shade200, Colors.black87, settings, onTap: () => _onNumberPressed('2')),
          _buildButton('3', Colors.grey.shade200, Colors.black87, settings, onTap: () => _onNumberPressed('3')),
          _buildButton('-', Colors.blue.shade100, const Color(0xFF0C206D), settings, onTap: () => _onOperationPressed('-')),
          _buildButton('=', Colors.blue, Colors.white, settings, onTap: _onEqualsPressed),

          _buildButton('0', Colors.grey.shade200, Colors.black87, settings, onTap: () => _onNumberPressed('0'), isLarge: true),
          _buildButton('.', Colors.grey.shade200, Colors.black87, settings, onTap: _onDecimalPressed),
          _buildButton('+', Colors.blue.shade100, const Color(0xFF0C206D), settings, onTap: () => _onOperationPressed('+')),
          _buildButton('mod', Colors.purple.shade100, const Color(0xFF0C206D), settings, onTap: () => _onOperationPressed('mod')),
          _buildButton(' ', Colors.transparent, Colors.transparent, settings, onTap: () {}),
        ];

      case 1: // مثلثات
        return [
          _buildButton('sin', Colors.purple.shade100, const Color(0xFF0C206D), settings, onTap: () => _onScientificFunction('sin')),
          _buildButton('cos', Colors.purple.shade100, const Color(0xFF0C206D), settings, onTap: () => _onScientificFunction('cos')),
          _buildButton('tan', Colors.purple.shade100, const Color(0xFF0C206D), settings, onTap: () => _onScientificFunction('tan')),
          _buildButton('cot', Colors.purple.shade100, const Color(0xFF0C206D), settings, onTap: () => _onScientificFunction('cot')),
          _buildButton('sec', Colors.purple.shade100, const Color(0xFF0C206D), settings, onTap: () => _onScientificFunction('sec')),

          _buildButton('csc', Colors.purple.shade100, const Color(0xFF0C206D), settings, onTap: () => _onScientificFunction('csc')),
          _buildButton('asin', Colors.purple.shade100, const Color(0xFF0C206D), settings, onTap: () => _onScientificFunction('asin')),
          _buildButton('acos', Colors.purple.shade100, const Color(0xFF0C206D), settings, onTap: () => _onScientificFunction('acos')),
          _buildButton('atan', Colors.purple.shade100, const Color(0xFF0C206D), settings, onTap: () => _onScientificFunction('atan')),
          _buildButton('acot', Colors.purple.shade100, const Color(0xFF0C206D), settings, onTap: () => _onScientificFunction('acot')),

          _buildButton('sinh', Colors.purple.shade100, const Color(0xFF0C206D), settings, onTap: () => _onScientificFunction('sinh')),
          _buildButton('cosh', Colors.purple.shade100, const Color(0xFF0C206D), settings, onTap: () => _onScientificFunction('cosh')),
          _buildButton('tanh', Colors.purple.shade100, const Color(0xFF0C206D), settings, onTap: () => _onScientificFunction('tanh')),
          _buildButton('coth', Colors.purple.shade100, const Color(0xFF0C206D), settings, onTap: () => _onScientificFunction('coth')),
          _buildButton('sech', Colors.purple.shade100, const Color(0xFF0C206D), settings, onTap: () => _onScientificFunction('sech')),

          _buildButton('csch', Colors.purple.shade100, const Color(0xFF0C206D), settings, onTap: () => _onScientificFunction('csch')),
          _buildButton('π', Colors.purple.shade100, const Color(0xFF0C206D), settings, onTap: () => _onScientificFunction('π')),
          _buildButton('RAD', Colors.orange.shade100, Colors.orange, settings, onTap: _toggleAngleMode),
          _buildButton('C', Colors.red.shade100, Colors.red, settings, onTap: _onClear),
          _buildButton('⌫', Colors.orange.shade100, Colors.orange, settings, onTap: _onBackspace),

          _buildButton('7', Colors.grey.shade200, Colors.black87, settings, onTap: () => _onNumberPressed('7')),
          _buildButton('8', Colors.grey.shade200, Colors.black87, settings, onTap: () => _onNumberPressed('8')),
          _buildButton('9', Colors.grey.shade200, Colors.black87, settings, onTap: () => _onNumberPressed('9')),
          _buildButton('÷', Colors.blue.shade100, const Color(0xFF0C206D), settings, onTap: () => _onOperationPressed('÷')),
          _buildButton('±', Colors.grey.shade200, Colors.black87, settings, onTap: _onPlusMinus),

          _buildButton('4', Colors.grey.shade200, Colors.black87, settings, onTap: () => _onNumberPressed('4')),
          _buildButton('5', Colors.grey.shade200, Colors.black87, settings, onTap: () => _onNumberPressed('5')),
          _buildButton('6', Colors.grey.shade200, Colors.black87, settings, onTap: () => _onNumberPressed('6')),
          _buildButton('×', Colors.blue.shade100, const Color(0xFF0C206D), settings, onTap: () => _onOperationPressed('×')),
          _buildButton(' ', Colors.transparent, Colors.transparent, settings, onTap: () {}),

          _buildButton('1', Colors.grey.shade200, Colors.black87, settings, onTap: () => _onNumberPressed('1')),
          _buildButton('2', Colors.grey.shade200, Colors.black87, settings, onTap: () => _onNumberPressed('2')),
          _buildButton('3', Colors.grey.shade200, Colors.black87, settings, onTap: () => _onNumberPressed('3')),
          _buildButton('-', Colors.blue.shade100, const Color(0xFF0C206D), settings, onTap: () => _onOperationPressed('-')),
          _buildButton('=', Colors.blue, Colors.white, settings, onTap: _onEqualsPressed),

          _buildButton('0', Colors.grey.shade200, Colors.black87, settings, onTap: () => _onNumberPressed('0'), isLarge: true),
          _buildButton('.', Colors.grey.shade200, Colors.black87, settings, onTap: _onDecimalPressed),
          _buildButton('+', Colors.blue.shade100, const Color(0xFF0C206D), settings, onTap: () => _onOperationPressed('+')),
          _buildButton(' ', Colors.transparent, Colors.transparent, settings, onTap: () {}),
          _buildButton(' ', Colors.transparent, Colors.transparent, settings, onTap: () {}),
        ];

      case 2: // متقدمة
        return [
          _buildButton('∫', Colors.teal.shade100, const Color(0xFF0C206D), settings, onTap: () {}),
          _buildButton('d/dx', Colors.teal.shade100, const Color(0xFF0C206D), settings, onTap: () {}),
          _buildButton('∑', Colors.teal.shade100, const Color(0xFF0C206D), settings, onTap: () {}),
          _buildButton('∏', Colors.teal.shade100, const Color(0xFF0C206D), settings, onTap: () {}),
          _buildButton('lim', Colors.teal.shade100, const Color(0xFF0C206D), settings, onTap: () {}),

          _buildButton('floor', Colors.purple.shade100, const Color(0xFF0C206D), settings, onTap: () => _onScientificFunction('floor')),
          _buildButton('ceil', Colors.purple.shade100, const Color(0xFF0C206D), settings, onTap: () => _onScientificFunction('ceil')),
          _buildButton('round', Colors.purple.shade100, const Color(0xFF0C206D), settings, onTap: () => _onScientificFunction('round')),
          _buildButton('mod', Colors.purple.shade100, const Color(0xFF0C206D), settings, onTap: () => _onOperationPressed('mod')),
          _buildButton('xʸ', Colors.purple.shade100, const Color(0xFF0C206D), settings, onTap: () => _onScientificFunction('xʸ')),

          _buildButton('C', Colors.red.shade100, Colors.red, settings, onTap: _onClear),
          _buildButton('CE', Colors.orange.shade100, Colors.orange, settings, onTap: _onClearEntry),
          _buildButton('⌫', Colors.orange.shade100, Colors.orange, settings, onTap: _onBackspace),
          _buildButton('RAD', Colors.orange.shade100, Colors.orange, settings, onTap: _toggleAngleMode),
          _buildButton(' ', Colors.transparent, Colors.transparent, settings, onTap: () {}),

          _buildButton('7', Colors.grey.shade200, Colors.black87, settings, onTap: () => _onNumberPressed('7')),
          _buildButton('8', Colors.grey.shade200, Colors.black87, settings, onTap: () => _onNumberPressed('8')),
          _buildButton('9', Colors.grey.shade200, Colors.black87, settings, onTap: () => _onNumberPressed('9')),
          _buildButton('÷', Colors.blue.shade100, const Color(0xFF0C206D), settings, onTap: () => _onOperationPressed('÷')),
          _buildButton('±', Colors.grey.shade200, Colors.black87, settings, onTap: _onPlusMinus),

          _buildButton('4', Colors.grey.shade200, Colors.black87, settings, onTap: () => _onNumberPressed('4')),
          _buildButton('5', Colors.grey.shade200, Colors.black87, settings, onTap: () => _onNumberPressed('5')),
          _buildButton('6', Colors.grey.shade200, Colors.black87, settings, onTap: () => _onNumberPressed('6')),
          _buildButton('×', Colors.blue.shade100, const Color(0xFF0C206D), settings, onTap: () => _onOperationPressed('×')),
          _buildButton(' ', Colors.transparent, Colors.transparent, settings, onTap: () {}),

          _buildButton('1', Colors.grey.shade200, Colors.black87, settings, onTap: () => _onNumberPressed('1')),
          _buildButton('2', Colors.grey.shade200, Colors.black87, settings, onTap: () => _onNumberPressed('2')),
          _buildButton('3', Colors.grey.shade200, Colors.black87, settings, onTap: () => _onNumberPressed('3')),
          _buildButton('-', Colors.blue.shade100, const Color(0xFF0C206D), settings, onTap: () => _onOperationPressed('-')),
          _buildButton('=', Colors.blue, Colors.white, settings, onTap: _onEqualsPressed),

          _buildButton('0', Colors.grey.shade200, Colors.black87, settings, onTap: () => _onNumberPressed('0'), isLarge: true),
          _buildButton('.', Colors.grey.shade200, Colors.black87, settings, onTap: _onDecimalPressed),
          _buildButton('+', Colors.blue.shade100, const Color(0xFF0C206D), settings, onTap: () => _onOperationPressed('+')),
          _buildButton(' ', Colors.transparent, Colors.transparent, settings, onTap: () {}),
          _buildButton(' ', Colors.transparent, Colors.transparent, settings, onTap: () {}),
        ];

      case 3: // ذاكرة
        return [
          _buildButton('MC', Colors.blue.shade100, const Color(0xFF0C206D), settings, onTap: () => _memoryOperation('MC')),
          _buildButton('MR', Colors.blue.shade100, const Color(0xFF0C206D), settings, onTap: () => _memoryOperation('MR')),
          _buildButton('M+', Colors.blue.shade100, const Color(0xFF0C206D), settings, onTap: () => _memoryOperation('M+')),
          _buildButton('M-', Colors.blue.shade100, const Color(0xFF0C206D), settings, onTap: () => _memoryOperation('M-')),
          _buildButton('MS', Colors.blue.shade100, const Color(0xFF0C206D), settings, onTap: () => _memoryOperation('MS')),

          _buildButton('C', Colors.red.shade100, Colors.red, settings, onTap: _onClear),
          _buildButton('CE', Colors.orange.shade100, Colors.orange, settings, onTap: _onClearEntry),
          _buildButton('⌫', Colors.orange.shade100, Colors.orange, settings, onTap: _onBackspace),
          _buildButton('RAD', Colors.orange.shade100, Colors.orange, settings, onTap: _toggleAngleMode),
          _buildButton(' ', Colors.transparent, Colors.transparent, settings, onTap: () {}),

          _buildButton('7', Colors.grey.shade200, Colors.black87, settings, onTap: () => _onNumberPressed('7')),
          _buildButton('8', Colors.grey.shade200, Colors.black87, settings, onTap: () => _onNumberPressed('8')),
          _buildButton('9', Colors.grey.shade200, Colors.black87, settings, onTap: () => _onNumberPressed('9')),
          _buildButton('÷', Colors.blue.shade100, const Color(0xFF0C206D), settings, onTap: () => _onOperationPressed('÷')),
          _buildButton('±', Colors.grey.shade200, Colors.black87, settings, onTap: _onPlusMinus),

          _buildButton('4', Colors.grey.shade200, Colors.black87, settings, onTap: () => _onNumberPressed('4')),
          _buildButton('5', Colors.grey.shade200, Colors.black87, settings, onTap: () => _onNumberPressed('5')),
          _buildButton('6', Colors.grey.shade200, Colors.black87, settings, onTap: () => _onNumberPressed('6')),
          _buildButton('×', Colors.blue.shade100, const Color(0xFF0C206D), settings, onTap: () => _onOperationPressed('×')),
          _buildButton(' ', Colors.transparent, Colors.transparent, settings, onTap: () {}),

          _buildButton('1', Colors.grey.shade200, Colors.black87, settings, onTap: () => _onNumberPressed('1')),
          _buildButton('2', Colors.grey.shade200, Colors.black87, settings, onTap: () => _onNumberPressed('2')),
          _buildButton('3', Colors.grey.shade200, Colors.black87, settings, onTap: () => _onNumberPressed('3')),
          _buildButton('-', Colors.blue.shade100, const Color(0xFF0C206D), settings, onTap: () => _onOperationPressed('-')),
          _buildButton('=', Colors.blue, Colors.white, settings, onTap: _onEqualsPressed),

          _buildButton('0', Colors.grey.shade200, Colors.black87, settings, onTap: () => _onNumberPressed('0'), isLarge: true),
          _buildButton('.', Colors.grey.shade200, Colors.black87, settings, onTap: _onDecimalPressed),
          _buildButton('+', Colors.blue.shade100, const Color(0xFF0C206D), settings, onTap: () => _onOperationPressed('+')),
          _buildButton(' ', Colors.transparent, Colors.transparent, settings, onTap: () {}),
          _buildButton(' ', Colors.transparent, Colors.transparent, settings, onTap: () {}),
        ];

      case 4: // متغيرات
        return [
          // أزرار التخزين والاستدعاء
          _buildButton('STO', Colors.green.shade100, const Color(0xFF0C206D), settings, onTap: () => _onScientificFunction('STO')),
          _buildButton('RCL', Colors.green.shade100, const Color(0xFF0C206D), settings, onTap: () => _onScientificFunction('RCL')),

          // أزرار المتغيرات
          _buildButton('x', Colors.green.shade100, const Color(0xFF0C206D), settings, onTap: () => _setVariable('x')),
          _buildButton('y', Colors.green.shade100, const Color(0xFF0C206D), settings, onTap: () => _setVariable('y')),
          _buildButton('z', Colors.green.shade100, const Color(0xFF0C206D), settings, onTap: () => _setVariable('z')),

          _buildButton('a', Colors.green.shade100, const Color(0xFF0C206D), settings, onTap: () => _setVariable('a')),
          _buildButton('b', Colors.green.shade100, const Color(0xFF0C206D), settings, onTap: () => _setVariable('b')),
          _buildButton('c', Colors.green.shade100, const Color(0xFF0C206D), settings, onTap: () => _setVariable('c')),

          // أزرار مسح المتغيرات
          _buildButton('CLR-x', Colors.red.shade100, Colors.red, settings, onTap: () => _clearVariable('x')),
          _buildButton('CLR-y', Colors.red.shade100, Colors.red, settings, onTap: () => _clearVariable('y')),
          _buildButton('CLR-z', Colors.red.shade100, Colors.red, settings, onTap: () => _clearVariable('z')),
          _buildButton('CLR-a', Colors.red.shade100, Colors.red, settings, onTap: () => _clearVariable('a')),
          _buildButton('CLR-b', Colors.red.shade100, Colors.red, settings, onTap: () => _clearVariable('b')),
          _buildButton('CLR-c', Colors.red.shade100, Colors.red, settings, onTap: () => _clearVariable('c')),

          // زر مسح الكل
          _buildButton('CLR ALL', Colors.red.shade100, Colors.red, settings, onTap: _clearAllVariables),

          // أزرار الأرقام الأساسية
          _buildButton('7', Colors.grey.shade200, Colors.black87, settings, onTap: () => _onNumberPressed('7')),
          _buildButton('8', Colors.grey.shade200, Colors.black87, settings, onTap: () => _onNumberPressed('8')),
          _buildButton('9', Colors.grey.shade200, Colors.black87, settings, onTap: () => _onNumberPressed('9')),
          _buildButton('÷', Colors.blue.shade100, const Color(0xFF0C206D), settings, onTap: () => _onOperationPressed('÷')),
          _buildButton('±', Colors.grey.shade200, Colors.black87, settings, onTap: _onPlusMinus),

          _buildButton('4', Colors.grey.shade200, Colors.black87, settings, onTap: () => _onNumberPressed('4')),
          _buildButton('5', Colors.grey.shade200, Colors.black87, settings, onTap: () => _onNumberPressed('5')),
          _buildButton('6', Colors.grey.shade200, Colors.black87, settings, onTap: () => _onNumberPressed('6')),
          _buildButton('×', Colors.blue.shade100, const Color(0xFF0C206D), settings, onTap: () => _onOperationPressed('×')),
          _buildButton('RAD', Colors.orange.shade100, Colors.orange, settings, onTap: _toggleAngleMode),

          _buildButton('1', Colors.grey.shade200, Colors.black87, settings, onTap: () => _onNumberPressed('1')),
          _buildButton('2', Colors.grey.shade200, Colors.black87, settings, onTap: () => _onNumberPressed('2')),
          _buildButton('3', Colors.grey.shade200, Colors.black87, settings, onTap: () => _onNumberPressed('3')),
          _buildButton('-', Colors.blue.shade100, const Color(0xFF0C206D), settings, onTap: () => _onOperationPressed('-')),
          _buildButton('=', Colors.blue, Colors.white, settings, onTap: _onEqualsPressed),

          _buildButton('0', Colors.grey.shade200, Colors.black87, settings, onTap: () => _onNumberPressed('0'), isLarge: true),
          _buildButton('.', Colors.grey.shade200, Colors.black87, settings, onTap: _onDecimalPressed),
          _buildButton('+', Colors.blue.shade100, const Color(0xFF0C206D), settings, onTap: () => _onOperationPressed('+')),
          _buildButton(' ', Colors.transparent, Colors.transparent, settings, onTap: () {}),
          _buildButton(' ', Colors.transparent, Colors.transparent, settings, onTap: () {}),
        ];

      default:
        return [];
    }
  }

  // ==================== دالة بناء الأزرار (مع تحسين الوضع الليلي) ====================
  Widget _buildButton(String text,
      Color bgColor,
      Color textColor,
      SettingsProvider settings, {
        bool isLarge = false,
        required VoidCallback onTap,
      }) {
    // Skip rendering for empty buttons
    if (text == ' ') {
      return Container(
        margin: const EdgeInsets.all(2),
        color: Colors.transparent,
      );
    }

    // تحديد لون الخلفية في الوضع الليلي - تصميم محسن
    Color getBgColor() {
      if (settings.isDarkMode) {
        // الأرقام (0-9, .)
        if (bgColor == Colors.grey.shade200 || RegExp(r'[0-9.]').hasMatch(text)) {
          return const Color(0xFF333333);
        }

        // زر المسح C
        if (bgColor == Colors.red.shade100 || text == 'C' || text.startsWith('CLR')) {
          return const Color(0xFFB71C1C).withOpacity(0.3);
        }

        // أزرار CE, ⌫
        if (bgColor == Colors.orange.shade100 || text == 'CE' || text == '⌫') {
          return const Color(0xFFBF360C).withOpacity(0.3);
        }

        // العمليات الحسابية (+, -, ×, ÷, =, ^, mod)
        if (text == '+' || text == '-' || text == '×' || text == '÷' || text == '^' || text == 'mod' || text == 'xʸ') {
          return const Color(0xFFBF360C).withOpacity(0.5);
        }

        // زر =
        if (bgColor == Colors.blue) {
          return const Color(0xFF4A6FA5);
        }

        // الدوال العلمية
        if (bgColor == Colors.purple.shade100) {
          return const Color(0xFF4A148C).withOpacity(0.4);
        }

        // أزرار الذاكرة
        if (text == 'MC' || text == 'MR' || text == 'M+' || text == 'M-' || text == 'MS') {
          return const Color(0xFF0C206D).withOpacity(0.4);
        }

        // أزرار المتغيرات
        if (bgColor == Colors.green.shade100 || text == 'STO' || text == 'RCL' ||
            text == 'x' || text == 'y' || text == 'z' || text == 'a' || text == 'b' || text == 'c') {
          return const Color(0xFF1B5E20).withOpacity(0.4);
        }

        return const Color(0xFF1E1E1E);
      }
      return bgColor;
    }

    Color getTextColor() {
      if (settings.isDarkMode) {
        // الأرقام - أبيض
        if (textColor == Colors.black87 || RegExp(r'[0-9.]').hasMatch(text)) {
          return Colors.white;
        }

        // العمليات الحسابية - برتقالي فاتح
        if (text == '+' || text == '-' || text == '×' || text == '÷' || text == '^' || text == 'mod' || text == 'xʸ') {
          return const Color(0xFFFFB74D);
        }

        // زر =
        if (text == '=') {
          return Colors.white;
        }

        // زر C وأزرار المسح
        if (text == 'C' || text.startsWith('CLR')) {
          return const Color(0xFFEF5350);
        }

        // أزرار CE, ⌫
        if (text == 'CE' || text == '⌫') {
          return const Color(0xFFFFB74D);
        }

        // RAD/DEG indicator
        if (text == 'RAD' || text == 'DEG') {
          return const Color(0xFFFFB74D);
        }

        // الدوال العلمية
        if (text == 'sin' || text == 'cos' || text == 'tan' || text == 'cot' || text == 'sec' || text == 'csc' ||
            text == 'asin' || text == 'acos' || text == 'atan' || text == 'acot' ||
            text == 'sinh' || text == 'cosh' || text == 'tanh' || text == 'coth' || text == 'sech' || text == 'csch' ||
            text == 'log' || text == 'ln' || text == 'log₂' ||
            text == '√' || text == '∛' || text == 'x²' || text == 'x³' ||
            text == '10ˣ' || text == 'eˣ' || text == '2ˣ' ||
            text == '1/x' || text == '|x|' || text == 'x!' ||
            text == 'π' || text == 'e' || text == 'φ' ||
            text == 'floor' || text == 'ceil' || text == 'round' || text == '%') {
          return const Color(0xFFCE93D8);
        }

        // أزرار الذاكرة
        if (text == 'MC' || text == 'MR' || text == 'M+' || text == 'M-' || text == 'MS') {
          return const Color(0xFF90CAF9);
        }

        // أزرار المتغيرات
        if (text == 'STO' || text == 'RCL' || text == 'x' || text == 'y' || text == 'z' || text == 'a' || text == 'b' || text == 'c') {
          return const Color(0xFF81C784);
        }

        return Colors.white70;
      }
      return textColor;
    }

    // تحديد لون الحدود أو الظل
    BoxDecoration getDecoration() {
      if (settings.isDarkMode) {
        return BoxDecoration(
          color: getBgColor(),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: (text == '+' || text == '-' || text == '×' || text == '÷' || text == '^' || text == 'mod')
                ? Colors.orange.shade700.withValues(alpha: 0.3)
                : Colors.transparent,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: getBgColor().withValues(alpha: 0.5),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        );
      } else {
        return BoxDecoration(
          color: getBgColor(),
          borderRadius: BorderRadius.circular(16),
          gradient: bgColor == Colors.blue
              ? LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade400,
              Colors.blue.shade700,
            ],
          )
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
            if (bgColor != Colors.grey.shade200)
              BoxShadow(
                color: getBgColor().withValues(alpha: 0.3),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
          ],
        );
      }
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(4),
        decoration: getDecoration(),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: isLarge ? 20 : 16,
              fontWeight: text == 'C' || text == 'CE' || text == '⌫' || text.startsWith('CLR')
                  ? FontWeight.bold
                  : FontWeight.w500,
              color: getTextColor(),
              shadows: settings.isDarkMode
                  ? [
                Shadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  offset: const Offset(0, 1),
                  blurRadius: 2,
                ),
              ]
                  : (bgColor == Colors.blue
                  ? [
                Shadow(
                  color: Colors.white.withValues(alpha: 0.3),
                  offset: const Offset(0, 1),
                  blurRadius: 2,
                )
              ]
                  : null),
            ),
          ),
        ),
      ),
    );
  }
}