# Reglas de ProGuard para Bovino IA
# Mantener clases de Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Mantener clases de Kotlin
-keep class kotlin.** { *; }
-keep class kotlin.Metadata { *; }
-dontwarn kotlin.**

# Mantener clases de AndroidX
-keep class androidx.** { *; }
-dontwarn androidx.**

# Reglas para plugins específicos
-keep class com.example.bovino.** { *; }

# Reglas para WebSocket y HTTP
-keep class okhttp3.** { *; }
-keep class retrofit2.** { *; }
-dontwarn okhttp3.**
-dontwarn retrofit2.**

# Reglas para logging
-keep class com.orhanobut.logger.** { *; }

# Reglas generales
-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable
-keep public class * extends java.lang.Exception 