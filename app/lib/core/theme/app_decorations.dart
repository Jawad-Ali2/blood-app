import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class AppDecorations {
  static const _authOutlineInputBorder = OutlineInputBorder(
    borderSide: BorderSide(color: Color(0xFF757575)),
    borderRadius: BorderRadius.all(Radius.circular(100)),
  );

  static InputDecoration textFieldDecoration({
    required String hintText,
    required String labelText, String? icon, Widget? suffixIcon,
    // Icon? icon,

  }) {
    return InputDecoration(
      hintText: hintText,
      labelText: labelText,
      floatingLabelBehavior: FloatingLabelBehavior.always,
      floatingLabelStyle: TextStyle(color: Colors.black),
      hintStyle: const TextStyle(color: Color(0xFF757575)),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 16,
      ),
      suffix: SvgPicture.string(icon!),
      border: _authOutlineInputBorder,
      enabledBorder: _authOutlineInputBorder,
      focusedBorder: _authOutlineInputBorder.copyWith(
          borderSide: const BorderSide(color: Color(0xFF000000))),
    );
  }
}
