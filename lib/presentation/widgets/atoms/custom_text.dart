import 'package:flutter/material.dart';

// Core
import '../../../core/constants/app_ui_config.dart';

/// Átomo para textos personalizados
/// Sigue Atomic Design y las reglas de desarrollo establecidas
class CustomText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final Color? color;

  const CustomText({
    super.key,
    required this.text,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style:
          style?.copyWith(color: color) ??
          Theme.of(context).textTheme.bodyMedium?.copyWith(color: color),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow ?? TextOverflow.ellipsis,
      softWrap: true,
    );
  }
}

/// Átomo para títulos
class TitleText extends StatelessWidget {
  final String text;
  final double? fontSize;
  final FontWeight? fontWeight;
  final Color? color;
  final TextAlign? textAlign;

  const TitleText({
    super.key,
    required this.text,
    this.fontSize,
    this.fontWeight,
    this.color,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    return CustomText(
      text: text,
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
        fontSize: fontSize,
        fontWeight: fontWeight ?? FontWeight.bold,
        color: color,
      ),
      textAlign: textAlign,
    );
  }
}

/// Átomo para subtítulos
class SubtitleText extends StatelessWidget {
  final String text;
  final double? fontSize;
  final Color? color;
  final TextAlign? textAlign;

  const SubtitleText({
    super.key,
    required this.text,
    this.fontSize,
    this.color,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    return CustomText(
      text: text,
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(fontSize: fontSize, color: color),
      textAlign: textAlign,
    );
  }
}

/// Átomo para textos de cuerpo
class BodyText extends StatelessWidget {
  final String text;
  final double? fontSize;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;

  const BodyText({
    super.key,
    required this.text,
    this.fontSize,
    this.color,
    this.textAlign,
    this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    return CustomText(
      text: text,
      style: Theme.of(
        context,
      ).textTheme.bodyMedium?.copyWith(fontSize: fontSize, color: color),
      textAlign: textAlign,
      maxLines: maxLines,
    );
  }
}

/// Átomo para textos pequeños
class CaptionText extends StatelessWidget {
  final String text;
  final double? fontSize;
  final Color? color;
  final TextAlign? textAlign;

  const CaptionText({
    super.key,
    required this.text,
    this.fontSize,
    this.color,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    return CustomText(
      text: text,
      style: Theme.of(
        context,
      ).textTheme.bodySmall?.copyWith(fontSize: fontSize, color: color),
      textAlign: textAlign,
    );
  }
}

/// Átomo para campos de entrada personalizados
/// Maneja correctamente los constraints para evitar errores de layout
class CustomTextField extends StatelessWidget {
  final String? hintText;
  final String? labelText;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool obscureText;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final int? maxLines;
  final int? maxLength;
  final bool enabled;
  final bool readOnly;
  final FocusNode? focusNode;

  const CustomTextField({
    super.key,
    this.hintText,
    this.labelText,
    this.controller,
    this.keyboardType,
    this.obscureText = false,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
    this.maxLength,
    this.enabled = true,
    this.readOnly = false,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: AppUIConfig.inputMinHeight,
        maxHeight: double.infinity,
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        validator: validator,
        onChanged: onChanged,
        onFieldSubmitted: onSubmitted,
        maxLines: maxLines,
        maxLength: maxLength,
        enabled: enabled,
        readOnly: readOnly,
        focusNode: focusNode,
        decoration: InputDecoration(
          hintText: hintText,
          labelText: labelText,
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppUIConfig.borderRadius),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppUIConfig.borderRadius),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppUIConfig.borderRadius),
          ),
          contentPadding: AppUIConfig.inputPadding,
          isDense: false,
        ),
      ),
    );
  }
}
