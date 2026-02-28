// Romaji ↔ Hiragana conversion and Japanese text utilities.

class RomajiConverter {
  static const Map<String, String> _romajiToHiragana = {
    // Vowels
    'a': 'あ', 'i': 'い', 'u': 'う', 'e': 'え', 'o': 'お',
    // K
    'ka': 'か', 'ki': 'き', 'ku': 'く', 'ke': 'け', 'ko': 'こ',
    // S
    'sa': 'さ', 'shi': 'し', 'si': 'し', 'su': 'す', 'se': 'せ', 'so': 'そ',
    // T
    'ta': 'た', 'chi': 'ち', 'ti': 'ち', 'tsu': 'つ', 'tu': 'つ', 'te': 'て', 'to': 'と',
    // N
    'na': 'な', 'ni': 'に', 'nu': 'ぬ', 'ne': 'ね', 'no': 'の',
    // H
    'ha': 'は', 'hi': 'ひ', 'fu': 'ふ', 'hu': 'ふ', 'he': 'へ', 'ho': 'ほ',
    // M
    'ma': 'ま', 'mi': 'み', 'mu': 'む', 'me': 'め', 'mo': 'も',
    // Y
    'ya': 'や', 'yu': 'ゆ', 'yo': 'よ',
    // R
    'ra': 'ら', 'ri': 'り', 'ru': 'る', 're': 'れ', 'ro': 'ろ',
    // W
    'wa': 'わ', 'wi': 'ゐ', 'we': 'ゑ', 'wo': 'を',
    // N (standalone)
    'nn': 'ん', "n'": 'ん',
    // G
    'ga': 'が', 'gi': 'ぎ', 'gu': 'ぐ', 'ge': 'げ', 'go': 'ご',
    // Z
    'za': 'ざ', 'ji': 'じ', 'zi': 'じ', 'zu': 'ず', 'ze': 'ぜ', 'zo': 'ぞ',
    // D
    'da': 'だ', 'di': 'ぢ', 'du': 'づ', 'de': 'で', 'do': 'ど',
    // B
    'ba': 'ば', 'bi': 'び', 'bu': 'ぶ', 'be': 'べ', 'bo': 'ぼ',
    // P
    'pa': 'ぱ', 'pi': 'ぴ', 'pu': 'ぷ', 'pe': 'ぺ', 'po': 'ぽ',
    // Combo - KY
    'kya': 'きゃ', 'kyu': 'きゅ', 'kyo': 'きょ',
    // Combo - SH
    'sha': 'しゃ', 'shu': 'しゅ', 'sho': 'しょ',
    // Combo - CH
    'cha': 'ちゃ', 'chu': 'ちゅ', 'cho': 'ちょ',
    // Combo - NY
    'nya': 'にゃ', 'nyu': 'にゅ', 'nyo': 'にょ',
    // Combo - HY
    'hya': 'ひゃ', 'hyu': 'ひゅ', 'hyo': 'ひょ',
    // Combo - MY
    'mya': 'みゃ', 'myu': 'みゅ', 'myo': 'みょ',
    // Combo - RY
    'rya': 'りゃ', 'ryu': 'りゅ', 'ryo': 'りょ',
    // Combo - GY
    'gya': 'ぎゃ', 'gyu': 'ぎゅ', 'gyo': 'ぎょ',
    // Combo - JA
    'ja': 'じゃ', 'ju': 'じゅ', 'jo': 'じょ',
    // Combo - BY
    'bya': 'びゃ', 'byu': 'びゅ', 'byo': 'びょ',
    // Combo - PY
    'pya': 'ぴゃ', 'pyu': 'ぴゅ', 'pyo': 'ぴょ',
    // Long vowels
    'aa': 'ああ', 'ii': 'いい', 'uu': 'うう', 'ee': 'ええ', 'oo': 'おお',
    'ou': 'おう',
    // Punctuation
    '-': 'ー', '!': '!', '?': '?',
  };

  /// Convert romaji string to hiragana.
  static String toHiragana(String romaji) {
    final input = romaji.toLowerCase().trim();
    final buffer = StringBuffer();
    int i = 0;

    while (i < input.length) {
      // Check for double consonant (っ) — e.g. "kk", "ss", "tt", "pp"
      if (i + 1 < input.length &&
          input[i] == input[i + 1] &&
          _isConsonant(input[i]) &&
          input[i] != 'n') {
        buffer.write('っ');
        i++;
        continue;
      }

      // Try longest match first (4 chars, 3 chars, 2 chars, 1 char)
      bool matched = false;
      for (int len = 4; len >= 1; len--) {
        if (i + len <= input.length) {
          final substr = input.substring(i, i + len);
          if (_romajiToHiragana.containsKey(substr)) {
            buffer.write(_romajiToHiragana[substr]);
            i += len;
            matched = true;
            break;
          }
        }
      }

      // Handle standalone 'n' before non-vowel or end
      if (!matched && i < input.length && input[i] == 'n') {
        if (i + 1 >= input.length ||
            (!_isVowel(input[i + 1]) && input[i + 1] != 'y')) {
          buffer.write('ん');
          i++;
          matched = true;
        }
      }

      if (!matched) {
        // Pass through non-romaji characters (spaces, Japanese chars, etc.)
        buffer.write(input[i]);
        i++;
      }
    }

    return buffer.toString();
  }

  static bool _isConsonant(String c) {
    return 'bcdfghjklmnpqrstvwxyz'.contains(c);
  }

  static bool _isVowel(String c) {
    return 'aiueo'.contains(c);
  }

  /// Check if text contains Japanese characters (hiragana, katakana, or kanji).
  static bool containsJapanese(String text) {
    return _japaneseRegex.hasMatch(text);
  }

  /// Check if text is primarily romaji (Latin letters).
  static bool isRomaji(String text) {
    if (text.trim().isEmpty) return false;
    final latinChars = text.runes.where((r) =>
        (r >= 0x0041 && r <= 0x005A) || // A-Z
        (r >= 0x0061 && r <= 0x007A)); // a-z
    return latinChars.length > text.trim().replaceAll(' ', '').length * 0.5;
  }

  /// Check if text appears to be English (common English words).
  static bool isEnglish(String text) {
    final lower = text.toLowerCase();
    const englishWords = [
      'yes', 'no', 'i', 'want', 'like', 'the', 'is', 'am', 'are',
      'hello', 'hi', 'please', 'thank', 'what', 'where', 'how',
      'hungry', 'food', 'eat', 'drink', 'go', 'have', 'do',
    ];
    final words = lower.split(RegExp(r'\s+'));
    int englishCount = 0;
    for (final w in words) {
      if (englishWords.contains(w)) englishCount++;
    }
    return englishCount >= 2 || (words.length == 1 && englishWords.contains(words[0]));
  }

  static final RegExp _japaneseRegex = RegExp(
    r'[\u3040-\u309F\u30A0-\u30FF\u4E00-\u9FAF\u3400-\u4DBF]',
  );

  /// Count Japanese characters in text.
  static int countJapaneseChars(String text) {
    return _japaneseRegex.allMatches(text).length;
  }
}
