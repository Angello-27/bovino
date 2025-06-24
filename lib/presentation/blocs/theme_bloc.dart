import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:logger/logger.dart';

import '../../core/theme/theme_manager.dart';
import '../../core/errors/failures.dart';

// Events
abstract class ThemeEvent extends Equatable {
  const ThemeEvent();

  @override
  List<Object?> get props => [];
}

class ChangeThemeEvent extends ThemeEvent {
  final bool isDark;

  const ChangeThemeEvent({required this.isDark});

  @override
  List<Object?> get props => [isDark];
}

class ToggleThemeEvent extends ThemeEvent {
  const ToggleThemeEvent();
}

class InitializeThemeEvent extends ThemeEvent {
  const InitializeThemeEvent();
}

// States
abstract class ThemeState extends Equatable {
  const ThemeState();

  @override
  List<Object?> get props => [];
}

class ThemeInitial extends ThemeState {}

class ThemeLoaded extends ThemeState {
  final ThemeData theme;
  final bool isDark;
  final String themeName;

  const ThemeLoaded({
    required this.theme,
    required this.isDark,
    required this.themeName,
  });

  @override
  List<Object?> get props => [theme, isDark, themeName];
}

class ThemeError extends ThemeState {
  final Failure failure;

  const ThemeError({required this.failure});

  @override
  List<Object?> get props => [failure];
}

// BLoC
class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  final Logger _logger = Logger();

  ThemeBloc() : super(ThemeInitial()) {
    on<InitializeThemeEvent>(_onInitializeTheme);
    on<ChangeThemeEvent>(_onChangeTheme);
    on<ToggleThemeEvent>(_onToggleTheme);
  }

  Future<void> _onInitializeTheme(
    InitializeThemeEvent event,
    Emitter<ThemeState> emit,
  ) async {
    try {
      _logger.i('Inicializando tema...');

      // Por defecto usar tema claro
      final theme = ThemeManager.lightTheme;
      final isDark = false;
      final themeName = ThemeManager.getThemeName(theme);

      emit(ThemeLoaded(theme: theme, isDark: isDark, themeName: themeName));

      _logger.i('Tema inicializado: $themeName');
    } catch (e) {
      _logger.e('Error al inicializar tema: $e');
      emit(ThemeError(failure: ThemeFailure(message: e.toString())));
    }
  }

  Future<void> _onChangeTheme(
    ChangeThemeEvent event,
    Emitter<ThemeState> emit,
  ) async {
    try {
      _logger.i('Cambiando tema a: ${event.isDark ? "Oscuro" : "Claro"}');

      final theme = ThemeManager.getThemeByBool(event.isDark);
      final themeName = ThemeManager.getThemeName(theme);

      emit(
        ThemeLoaded(theme: theme, isDark: event.isDark, themeName: themeName),
      );

      _logger.i('Tema cambiado exitosamente: $themeName');
    } catch (e) {
      _logger.e('Error al cambiar tema: $e');
      emit(ThemeError(failure: ThemeFailure(message: e.toString())));
    }
  }

  Future<void> _onToggleTheme(
    ToggleThemeEvent event,
    Emitter<ThemeState> emit,
  ) async {
    try {
      final currentState = state;
      if (currentState is ThemeLoaded) {
        final newIsDark = !currentState.isDark;
        _logger.i(
          'Alternando tema de ${currentState.themeName} a ${newIsDark ? "Oscuro" : "Claro"}',
        );

        final theme = ThemeManager.getThemeByBool(newIsDark);
        final themeName = ThemeManager.getThemeName(theme);

        emit(
          ThemeLoaded(theme: theme, isDark: newIsDark, themeName: themeName),
        );

        _logger.i('Tema alternado exitosamente: $themeName');
      }
    } catch (e) {
      _logger.e('Error al alternar tema: $e');
      emit(ThemeError(failure: ThemeFailure(message: e.toString())));
    }
  }
}
