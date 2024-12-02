import 'package:flutter/material.dart';

Widget defaultFormField({
  required TextEditingController controller,
  required TextInputType type,
  required String label,
  required IconData prefix,
  Function? onSubmit,
  Function? onChange,
  Function? onTap,
  bool isPassword = false,
  required Function validate,
  Function? suffixPressed,
  IconData? suffix,
  String? hintText,
  bool readOnly = false,
}) =>
    Builder(builder: (context) {
      return TextFormField(
        controller: controller,
        keyboardType: type,
        readOnly: readOnly,
        obscureText: isPassword,
        onFieldSubmitted: (value) {
          if (onSubmit != null) onSubmit(value);
        },
        onChanged: (value) {
          if (onChange != null) onChange(value);
        },
        onTap: () {
          if (onTap != null) onTap();
        },
        validator: (value) => validate(value),
        decoration: InputDecoration(
          hintText: hintText ?? 'Enter your $label',
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide:
                  BorderSide(color: Theme.of(context).colorScheme.secondary)),
          filled: true,
          fillColor: Theme.of(context).colorScheme.onSecondary.withOpacity(0.7),
          prefixIcon:
              Icon(prefix, color: Theme.of(context).colorScheme.secondary),
          suffixIcon: suffix != null
              ? IconButton(
                  onPressed: () {
                    if (suffixPressed != null) suffixPressed();
                  },
                  icon: Icon(
                    suffix,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                )
              : null,
        ),
      );
    });
Widget defaultFormButton({
  required VoidCallback onPressed,
  required Widget child,
  required double screenWidth,
}) =>
    FilledButton.tonal(
      onPressed: onPressed,
      style: ButtonStyle(
        minimumSize: WidgetStatePropertyAll(Size(screenWidth * 0.8, 50)),
      ),
      child: child,
    );
