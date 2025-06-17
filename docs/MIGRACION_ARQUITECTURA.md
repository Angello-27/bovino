# Guía de Migración a Clean Architecture

## 🎯 Objetivo

Migrar el proyecto Bovino IA de una arquitectura monolítica a Clean Architecture con principios SOLID y Atomic Design.

## 📋 Plan de Migración

### Fase 1: Preparación (Día 1-2)

#### 1.1 Instalar Dependencias
```bash
# Agregar dependencias de Clean Architecture
flutter pub add dartz equatable get_it injectable
flutter pub add flutter_riverpod go_router
flutter pub add sqflite shared_preferences
flutter pub add uuid intl

# Dependencias de desarrollo
flutter pub add --dev build_runner injectable_generator
flutter pub add --dev json_annotation json_serializable
```

#### 1.2 Crear Estructura de Carpetas
```bash
# Crear estructura de Clean Architecture
mkdir -p lib/core/{constants,errors,network,utils,architecture}
mkdir -p lib/data/{datasources/{remote,local},models,repositories}
mkdir -p lib/domain/{entities,repositories,usecases,value_objects}
mkdir -p lib/presentation/{pages,widgets/{atoms,molecules,organisms,templates},providers,utils}
```

### Fase 2: Migración del Dominio (Día 3-4)

#### 2.1 Crear Entidades
```dart
// lib/domain/entities/bovino_entity.dart
class BovinoEntity extends Equatable {
  final String id;
  final String raza;
  final double pesoEstimado;
  final double confianza;
  final String descripcion;
  final List<String> caracteristicas;
  final DateTime fechaAnalisis;
  final String? imagenPath;

  // Constructor y métodos...
}
```

#### 2.2 Definir Interfaces de Repositorios
```dart
// lib/domain/repositories/bovino_repository.dart
abstract class BovinoRepository {
  Future<Either<Failure, BovinoEntity>> analizarImagen(String imagenPath);
  Future<Either<Failure, List<BovinoEntity>>> obtenerHistorial();
  // Otros métodos...
}
```

#### 2.3 Crear Casos de Uso
```dart
// lib/domain/usecases/analizar_imagen_usecase.dart
@injectable
class AnalizarImagenUseCase {
  final BovinoRepository repository;
  
  const AnalizarImagenUseCase(this.repository);
  
  Future<Either<Failure, BovinoEntity>> call(String imagenPath) async {
    // Lógica del caso de uso...
  }
}
```

### Fase 3: Migración de Datos (Día 5-6)

#### 3.1 Crear Modelos de Datos
```dart
// lib/data/models/bovino_model.dart
@JsonSerializable()
class BovinoModel extends Equatable {
  final String id;
  final String raza;
  final double pesoEstimado;
  // Otros campos...
  
  factory BovinoModel.fromJson(Map<String, dynamic> json) =>
      _$BovinoModelFromJson(json);
  
  Map<String, dynamic> toJson() => _$BovinoModelToJson(this);
  
  BovinoEntity toEntity() => BovinoEntity(
    id: id,
    raza: raza,
    pesoEstimado: pesoEstimado,
    // Mapear otros campos...
  );
}
```

#### 3.2 Implementar DataSources
```dart
// lib/data/datasources/remote/openai_datasource.dart
abstract class RemoteDataSource {
  Future<BovinoModel> analizarImagen(String imagenPath);
}

class OpenAIDataSource implements RemoteDataSource {
  final Dio _dio;
  
  @override
  Future<BovinoModel> analizarImagen(String imagenPath) async {
    // Implementación con OpenAI...
  }
}
```

#### 3.3 Implementar Repositorios
```dart
// lib/data/repositories/bovino_repository_impl.dart
class BovinoRepositoryImpl implements BovinoRepository {
  final RemoteDataSource remoteDataSource;
  final LocalDataSource localDataSource;
  
  @override
  Future<Either<Failure, BovinoEntity>> analizarImagen(String imagenPath) async {
    try {
      final bovinoModel = await remoteDataSource.analizarImagen(imagenPath);
      final bovinoEntity = bovinoModel.toEntity();
      
      // Guardar localmente
      await localDataSource.guardarAnalisis(bovinoEntity);
      
      return Right(bovinoEntity);
    } catch (e) {
      return Left(AnalysisFailure(message: e.toString()));
    }
  }
}
```

### Fase 4: Migración de Presentación (Día 7-8)

#### 4.1 Crear Componentes Atomic Design

**Atoms:**
```dart
// lib/presentation/widgets/atoms/custom_button.dart
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonType type;
  // Otros parámetros...
}
```

**Molecules:**
```dart
// lib/presentation/widgets/molecules/analysis_result_card.dart
class AnalysisResultCard extends StatelessWidget {
  final BovinoEntity bovino;
  final VoidCallback? onTap;
  // Implementación...
}
```

**Organisms:**
```dart
// lib/presentation/widgets/organisms/camera_section.dart
class CameraSection extends StatefulWidget {
  final Function(File) onImageCaptured;
  final bool isAnalyzing;
  // Implementación...
}
```

#### 4.2 Implementar State Management
```dart
// lib/presentation/providers/bovino_provider.dart
@riverpod
class BovinoNotifier extends _$BovinoNotifier {
  @override
  FutureOr<List<BovinoEntity>> build() async {
    return _getBovinoRepository().obtenerHistorial();
  }
  
  Future<void> analizarImagen(String imagenPath) async {
    state = const AsyncValue.loading();
    
    final result = await _getAnalizarImagenUseCase()(imagenPath);
    
    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (bovino) => ref.invalidateSelf(),
    );
  }
}
```

### Fase 5: Configuración de Inyección de Dependencias (Día 9)

#### 5.1 Configurar GetIt
```dart
// lib/core/di/injection.dart
@InjectableInit()
Future<void> configureDependencies() async => $initGetIt(getIt);

@module
abstract class AppModule {
  @lazySingleton
  Dio get dio => Dio();
  
  @lazySingleton
  BovinoRepository get bovinoRepository => BovinoRepositoryImpl(
    remoteDataSource: OpenAIDataSource(getIt<Dio>()),
    localDataSource: LocalDataSourceImpl(),
  );
}
```

#### 5.2 Configurar Riverpod
```dart
// lib/presentation/providers/providers.dart
final bovinoRepositoryProvider = Provider<BovinoRepository>((ref) {
  return getIt<BovinoRepository>();
});

final analizarImagenUseCaseProvider = Provider<AnalizarImagenUseCase>((ref) {
  return getIt<AnalizarImagenUseCase>();
});
```

### Fase 6: Migración de Páginas (Día 10)

#### 6.1 Actualizar Páginas Principales
```dart
// lib/presentation/pages/home_page.dart
class HomePage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bovinoState = ref.watch(bovinoNotifierProvider);
    
    return Scaffold(
      appBar: AppBar(title: const Text('Bovino IA')),
      body: bovinoState.when(
        data: (bovinos) => BovinoListView(bovinos: bovinos),
        loading: () => const LoadingWidget(),
        error: (error, stack) => ErrorWidget(error: error),
      ),
    );
  }
}
```

## 🔄 Pasos de Migración Gradual

### Paso 1: Migrar Dominio
1. Crear entidades y value objects
2. Definir interfaces de repositorios
3. Implementar casos de uso básicos

### Paso 2: Migrar Datos
1. Crear modelos de datos
2. Implementar data sources
3. Implementar repositorios

### Paso 3: Migrar Presentación
1. Crear componentes Atomic Design
2. Implementar state management
3. Migrar páginas una por una

### Paso 4: Configurar DI
1. Configurar GetIt
2. Configurar Riverpod
3. Conectar todas las capas

## 🧪 Testing

### Tests de Dominio
```dart
// test/domain/usecases/analizar_imagen_usecase_test.dart
void main() {
  group('AnalizarImagenUseCase', () {
    late MockBovinoRepository mockRepository;
    late AnalizarImagenUseCase useCase;
    
    setUp(() {
      mockRepository = MockBovinoRepository();
      useCase = AnalizarImagenUseCase(mockRepository);
    });
    
    test('should return BovinoEntity when successful', () async {
      // Arrange
      when(mockRepository.analizarImagen(any))
          .thenAnswer((_) async => Right(tBovinoEntity));
      
      // Act
      final result = await useCase('test_image.jpg');
      
      // Assert
      expect(result, Right(tBovinoEntity));
    });
  });
}
```

### Tests de Presentación
```dart
// test/presentation/widgets/atoms/custom_button_test.dart
void main() {
  testWidgets('CustomButton should display text and handle tap', (tester) async {
    bool tapped = false;
    
    await tester.pumpWidget(
      MaterialApp(
        home: CustomButton(
          text: 'Test Button',
          onPressed: () => tapped = true,
        ),
      ),
    );
    
    expect(find.text('Test Button'), findsOneWidget);
    
    await tester.tap(find.byType(CustomButton));
    expect(tapped, true);
  });
}
```

## 📊 Beneficios de la Migración

### Antes (Arquitectura Monolítica)
- ❌ Código acoplado
- ❌ Difícil testing
- ❌ Escalabilidad limitada
- ❌ Mantenimiento complejo

### Después (Clean Architecture)
- ✅ Código desacoplado
- ✅ Testing fácil
- ✅ Escalabilidad alta
- ✅ Mantenimiento simple
- ✅ Principios SOLID aplicados
- ✅ Componentes reutilizables

## 🚀 Comandos de Migración

```bash
# 1. Generar código
flutter packages pub run build_runner build --delete-conflicting-outputs

# 2. Ejecutar tests
flutter test

# 3. Analizar código
flutter analyze

# 4. Ejecutar aplicación
flutter run
```

## 📝 Checklist de Migración

- [ ] Instalar dependencias de Clean Architecture
- [ ] Crear estructura de carpetas
- [ ] Migrar entidades del dominio
- [ ] Definir interfaces de repositorios
- [ ] Implementar casos de uso
- [ ] Crear modelos de datos
- [ ] Implementar data sources
- [ ] Implementar repositorios
- [ ] Crear componentes Atomic Design
- [ ] Configurar state management
- [ ] Configurar inyección de dependencias
- [ ] Migrar páginas principales
- [ ] Implementar tests
- [ ] Validar funcionamiento
- [ ] Documentar cambios

## 🎯 Resultado Final

Al final de la migración tendrás:

1. **Arquitectura limpia** con separación clara de responsabilidades
2. **Principios SOLID** aplicados correctamente
3. **Componentes Atomic Design** reutilizables
4. **Testing completo** de todas las capas
5. **Inyección de dependencias** configurada
6. **State management** robusto
7. **Código mantenible** y escalable 