import 'package:flutter/services.dart';

class DateTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // this will be our formatted text
    String newText = newValue.text;

    // if the user is deleting, we don't want to auto-format
    if (oldValue.text.length > newText.length) {
      return newValue;
    }

    var text = newText.replaceAll('/', '');
    String formattedText = '';
    for (int i = 0; i < text.length; i++) {
      formattedText += text[i];
      if ((i == 1 || i == 3) && i != text.length - 1) {
        formattedText += '/';
      }
    }

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}
