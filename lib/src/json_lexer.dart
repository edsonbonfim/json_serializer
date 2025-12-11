import 'string_utils.dart';

/// Token kinds produced by [JsonLexer] while scanning JSON text.
enum JsonTokenType {
  leftBrace,
  rightBrace,
  leftBracket,
  rightBracket,
  colon,
  comma,
  string,
  number,
  boolean,
  nullValue,
  eof
}

/// Represents a single JSON token with its parsed value and position context.
class JsonToken {
  /// The token type.
  final JsonTokenType type;

  /// The parsed value for string, number, boolean and null tokens.
  final Object? value;

  /// Byte offset from the start of the source.
  final int offset;

  /// 1-based line index.
  final int line;

  /// 1-based column index.
  final int column;

  /// Creates a token instance.
  ///
  /// @param [type] The classification of the token.
  /// @param [offset] Byte offset from the start of the source.
  /// @param [line] Line number (1-based).
  /// @param [column] Column number (1-based).
  /// @param [value] Optional parsed value for literal tokens.
  /// @returns A new [JsonToken] carrying the parsed data and position.
  JsonToken(
    this.type,
    this.offset,
    this.line,
    this.column, [
    this.value,
  ]);
}

/// Lexes JSON text according to RFC-8259 / ECMA-404 without allocations.
///
/// Uses [StringView] to operate directly on the UTF-16 buffer, emitting tokens
/// for punctuation and literals while skipping insignificant whitespace.
class JsonLexer {
  static const int _contextRadius = 20;
  static const int _space = 0x20;
  static const int _tab = 0x09;
  static const int _newline = 0x0A;
  static const int _carriageReturn = 0x0D;
  static const int _quote = 0x22;
  static const int _backslash = 0x5C;
  static const int _zero = 0x30;
  static const int _nine = 0x39;
  static const int _minus = 0x2D;
  static const int _plus = 0x2B;
  static const int _dot = 0x2E;
  static const int _upperE = 0x45;
  static const int _lowerE = 0x65;
  static const int _leftBrace = 0x7B;
  static const int _rightBrace = 0x7D;
  static const int _leftBracket = 0x5B;
  static const int _rightBracket = 0x5D;
  static const int _comma = 0x2C;
  static const int _colon = 0x3A;

  final String _input;
  final StringView _view;
  final int _length;
  late final String _minified;
  late final List<int> _origToMin;

  int _position = 0;

  /// Creates a lexer for the provided JSON text.
  ///
  /// Builds an internal minified single-line buffer (removing whitespace
  /// outside strings) to produce compact diagnostics while preserving a
  /// mapping back to original offsets for line/column accuracy.
  ///
  /// @param [input] The raw JSON source string.
  /// @returns A lexer ready to emit tokens and emit detailed context on errors.
  JsonLexer(String input)
      : _input = input,
        _view = StringView(input),
        _length = input.length {
    final minified = StringBuffer();
    _origToMin = List<int>.filled(_length + 1, 0, growable: false);

    var inString = false;
    var escaping = false;
    var minIndex = 0;

    for (var i = 0; i < _length; i++) {
      final cu = _input.codeUnitAt(i);
      _origToMin[i] = minIndex;

      if (inString) {
        minified.writeCharCode(cu);
        minIndex++;
        if (escaping) {
          escaping = false;
        } else if (cu == _backslash) {
          escaping = true;
        } else if (cu == _quote) {
          inString = false;
        }
        continue;
      }

      if (cu == _quote) {
        inString = true;
        minified.writeCharCode(cu);
        minIndex++;
        continue;
      }

      // Skip whitespace outside strings.
      if (cu == _space || cu == _tab || cu == _newline || cu == _carriageReturn) {
        continue;
      }

      minified.writeCharCode(cu);
      minIndex++;
    }

    _origToMin[_length] = minIndex;
    _minified = minified.toString();
  }

  /// Produces the next token in the stream.
  ///
  /// @returns The next [JsonToken], or EOF when consumed.
  /// @throws [FormatException] When the input is malformed.
  JsonToken nextToken() {
    _skipWhitespace();

    if (_position >= _length) {
      final ctx = _contextForOffset(_position);
      return JsonToken(JsonTokenType.eof, _position, ctx.line, ctx.column);
    }

    final codeUnit = _view.codeUnitAt(_position);
    final start = _position;
    final ctx = _contextForOffset(start);

    switch (codeUnit) {
      case _leftBrace:
        _position++;
        return JsonToken(JsonTokenType.leftBrace, start, ctx.line, ctx.column, '{');
      case _rightBrace:
        _position++;
        return JsonToken(JsonTokenType.rightBrace, start, ctx.line, ctx.column, '}');
      case _leftBracket:
        _position++;
        return JsonToken(JsonTokenType.leftBracket, start, ctx.line, ctx.column, '[');
      case _rightBracket:
        _position++;
        return JsonToken(JsonTokenType.rightBracket, start, ctx.line, ctx.column, ']');
      case _colon:
        _position++;
        return JsonToken(JsonTokenType.colon, start, ctx.line, ctx.column, ':');
      case _comma:
        _position++;
        return JsonToken(JsonTokenType.comma, start, ctx.line, ctx.column, ',');
      case _quote:
        return JsonToken(
          JsonTokenType.string,
          start,
          ctx.line,
          ctx.column,
          _readString(),
        );
      case _minus:
      case _zero:
      case 0x31:
      case 0x32:
      case 0x33:
      case 0x34:
      case 0x35:
      case 0x36:
      case 0x37:
      case 0x38:
      case 0x39:
        return JsonToken(
          JsonTokenType.number,
          start,
          ctx.line,
          ctx.column,
          _readNumber(),
        );
      case 0x74: // t
        return JsonToken(
          JsonTokenType.boolean,
          start,
          ctx.line,
          ctx.column,
          _readLiteral('true', true, start),
        );
      case 0x66: // f
        return JsonToken(
          JsonTokenType.boolean,
          start,
          ctx.line,
          ctx.column,
          _readLiteral('false', false, start),
        );
      case 0x6E: // n
        _readLiteral('null', null, start);
        return JsonToken(JsonTokenType.nullValue, start, ctx.line, ctx.column, null);
      default:
        throw _error('Unexpected character', codeUnit, start);
    }
  }

  void _skipWhitespace() {
    while (_position < _length) {
      final cu = _view.codeUnitAt(_position);
      if (cu == _space || cu == _tab || cu == _newline || cu == _carriageReturn) {
        _position++;
        continue;
      }
      break;
    }
  }

  String _readString() {
    _position++; // skip opening quote
    final buffer = StringBuffer();

    while (_position < _length) {
      final cu = _view.codeUnitAt(_position++);
      if (cu == _quote) {
        return buffer.toString();
      }
      if (cu == _backslash) {
        if (_position >= _length) {
          throw _error('Incomplete escape sequence', cu, _position - 1);
        }
        final esc = _view.codeUnitAt(_position++);
        switch (esc) {
          case 0x22:
            buffer.write('"');
            break;
          case 0x5C:
            buffer.write(r'\');
            break;
          case 0x2F:
            buffer.write('/');
            break;
          case 0x62:
            buffer.write('\b');
            break;
          case 0x66:
            buffer.write('\f');
            break;
          case 0x6E:
            buffer.write('\n');
            break;
          case 0x72:
            buffer.write('\r');
            break;
          case 0x74:
            buffer.write('\t');
            break;
          case 0x75:
            buffer.writeCharCode(_readUnicodeEscape());
            break;
          default:
            throw _error('Invalid escape character', esc, _position - 1);
        }
        continue;
      }

      if (cu < 0x20) {
        throw _error('Control characters not allowed in strings', cu, _position - 1);
      }

      buffer.writeCharCode(cu);
    }

    throw _error('Unterminated string', _quote, _position);
  }

  int _readUnicodeEscape() {
    if (_position + 4 > _length) {
      throw _error('Incomplete unicode escape', _quote, _position);
    }
    var value = 0;
    for (var i = 0; i < 4; i++) {
      final cu = _view.codeUnitAt(_position++);
      final digit = _hexDigit(cu);
      if (digit < 0) throw _error('Invalid unicode escape', cu, _position - 1);
      value = (value << 4) | digit;
    }
    return value;
  }

  int _hexDigit(int cu) {
    if (cu >= 0x30 && cu <= 0x39) return cu - 0x30;
    if (cu >= 0x41 && cu <= 0x46) return cu - 0x41 + 10;
    if (cu >= 0x61 && cu <= 0x66) return cu - 0x61 + 10;
    return -1;
  }

  num _readNumber() {
    final start = _position;

    // Sign
    if (_view.codeUnitAt(_position) == _minus) {
      _position++;
      _ensureDigit('Expected digit after "-"');
    }

    // Integer part
    if (_view.codeUnitAt(_position) == _zero) {
      _position++;
      if (_position < _length) {
        final next = _view.codeUnitAt(_position);
        if (_isDigit(next)) {
          throw _error('Leading zeros are not allowed', next, _position);
        }
      }
    } else {
      _consumeDigits();
    }

    // Fraction
    if (_position < _length && _view.codeUnitAt(_position) == _dot) {
      _position++;
      _ensureDigit('Expected digit after decimal point');
      _consumeDigits();
    }

    // Exponent
    if (_position < _length) {
      final cu = _view.codeUnitAt(_position);
      if (cu == _upperE || cu == _lowerE) {
        _position++;
        if (_position < _length) {
          final sign = _view.codeUnitAt(_position);
          if (sign == _plus || sign == _minus) {
            _position++;
          }
        }
        _ensureDigit('Expected digit in exponent');
        _consumeDigits();
      }
    }

    final slice = _view.sliceToString(start, _position);
    return slice.contains('.') || slice.contains('e') || slice.contains('E')
        ? double.parse(slice)
        : int.parse(slice);
  }

  void _consumeDigits() {
    while (_position < _length && _isDigit(_view.codeUnitAt(_position))) {
      _position++;
    }
  }

  bool _isDigit(int cu) => cu >= _zero && cu <= _nine;

  Object? _readLiteral(String expected, Object? value, int startOffset) {
    final end = _position + expected.length;
    if (end > _length) {
      throw _error('Unexpected end while reading literal', 0, startOffset);
    }
    final literal = _view.sliceToString(_position, end);
    if (literal != expected) {
      throw _error(
        'Invalid literal, expected "$expected"',
        _view.codeUnitAt(_position),
        startOffset,
      );
    }
    _position = end;
    return value;
  }

  void _ensureDigit(String message) {
    if (_position >= _length || !_isDigit(_view.codeUnitAt(_position))) {
      final cu = _position < _length ? _view.codeUnitAt(_position) : 0;
      throw _error(message, cu, _position);
    }
  }

  FormatException _error(String message, int codeUnit, int errorPos) {
    final ctx = _minifiedContext(errorPos);
    final pointer = ' ' * ctx.snippetCaret + '^';
    final charDesc = codeUnit == 0 ? 'EOF' : "'${String.fromCharCode(codeUnit)}'";
    return FormatException(
      '$message: $charDesc at line ${ctx.line}, column ${ctx.column} (offset $errorPos).\n'
      '${ctx.snippet}\n'
      '$pointer',
    );
  }

  _ErrorContext _contextForOffset(int offset) {
    var line = 1;
    var column = 1;
    for (var i = 0; i < offset && i < _length; i++) {
      final cu = _input.codeUnitAt(i);
      if (cu == _newline) {
        line++;
        column = 1;
      } else {
        column++;
      }
    }

    final searchStart = offset > 0 ? offset - 1 : 0;
    final lastBreak = _input.lastIndexOf('\n', searchStart);
    final lineStart = lastBreak == -1 ? 0 : lastBreak + 1;
    var lineEnd = _input.indexOf('\n', offset);
    if (lineEnd == -1) lineEnd = _length;
    final lineText = _input.substring(lineStart, lineEnd);
    final snippetStart = offset - _contextRadius < 0 ? 0 : offset - _contextRadius;
    var snippetEnd = offset + _contextRadius;
    if (snippetEnd > _length) snippetEnd = _length;
    final snippet = _input.substring(snippetStart, snippetEnd);
    final caretPos = offset - snippetStart;
    return _ErrorContext(
      line,
      column,
      lineText,
      snippet,
      caretPos < 0 ? 0 : caretPos,
    );
  }

  /// Exposes line/column context for a given offset (used by parser diagnostics).
  _ErrorContext contextForOffset(int offset) => _contextForOffset(offset);

  /// Exposes minified single-line context for diagnostics (always one line).
  ///
  /// @param [offset] Offset in the original source.
  /// @returns Snippet, caret index, and original line/column info.
  _MinifiedContext _minifiedContext(int offset) {
    final minOffset = offset < _origToMin.length ? _origToMin[offset] : _minified.length;

    final snippetStart = minOffset - _contextRadius < 0 ? 0 : minOffset - _contextRadius;
    var snippetEnd = minOffset + _contextRadius;
    if (snippetEnd > _minified.length) snippetEnd = _minified.length;
    final snippet = _minified.substring(snippetStart, snippetEnd);
    final caret = minOffset - snippetStart;

    // Compute line/column based on original text for accuracy.
    final ctx = _contextForOffset(offset);
    return _MinifiedContext(snippet, caret < 0 ? 0 : caret, ctx.line, ctx.column);
  }

  /// Exposes minified single-line context for parser diagnostics.
  _MinifiedContext minifiedContextForOffset(int offset) => _minifiedContext(offset);
}

class _ErrorContext {
  final int line;
  final int column;
  final String lineText;
  final String snippet;
  final int snippetCaret;

  const _ErrorContext(
    this.line,
    this.column,
    this.lineText,
    this.snippet,
    this.snippetCaret,
  );
}

class _MinifiedContext {
  final String snippet;
  final int snippetCaret;
  final int line;
  final int column;

  const _MinifiedContext(this.snippet, this.snippetCaret, this.line, this.column);
}
