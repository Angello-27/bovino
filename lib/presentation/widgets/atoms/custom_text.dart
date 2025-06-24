import 'package:flutter/material.dart';

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
      overflow: overflow,
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
