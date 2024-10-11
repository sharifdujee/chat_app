import 'package:flutter/material.dart';

class CustomFormField extends StatelessWidget {
  final String hintText;
  final String labelText;
  final double height;
  final TextEditingController? controller;
  final RegExp validationRegEx;
  final bool obscureText;
  final void Function(String?) onSaved;
  const CustomFormField(
      {super.key,
      required this.hintText,
      required this.labelText,
      required this.height, this.controller,
      required this.validationRegEx,
      this.obscureText = false,
        required this.onSaved
      });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: TextFormField(
        onSaved: onSaved,
        obscureText: obscureText,
        validator: (value) {
          if (value != null && validationRegEx.hasMatch(value)) {
            return null;
          }
          return "Enter a valid ${labelText.toLowerCase()}";
        },
        controller: controller,
        decoration: InputDecoration(
            hintText: hintText,
            labelText: labelText,
            border: OutlineInputBorder()),
      ),
    );
  }
}
