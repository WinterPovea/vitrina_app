# Arquitectura

Feature-first + Clean Architecture práctica + MVVM.

```
lib/
├── main.dart / app.dart          # arranque, MaterialApp.router
├── core/                         # transversal
│   ├── config/   app_config (dart-define) · brand (colores/nombre)
│   ├── di/       app_providers   # RAÍZ DE COMPOSICIÓN (contrato → implementación)
│   ├── error/    app_exception   # único error que sube a la UI
│   ├── network/  api_service · secure_session_storage · supabase_bootstrap
│   ├── router/   app_router · app_routes
│   ├── state/    base_view_model (ViewStatus + helpers)
│   ├── theme/    app_theme · app_spacing
│   └── utils/    validators · formatters · launchers
├── shared/widgets/               # componentes reutilizables
└── features/<feature>/
    ├── domain/        entities · repositories (contratos) · usecases (opcional)
    ├── data/          models (fromJson) · repositories (implementación)
    └── presentation/  viewmodels · pages · widgets
```

## Flujo de una consulta
```
Page (widget)  ──watch──▶  ViewModel (ChangeNotifier)  ──▶  [UseCase]  ──▶  Repository (contrato)
                                                                               │
                                                      RepositoryImpl ──▶ ApiService.guard ──▶ Supabase
```
Los datos viajan de vuelta como **entidades** (`domain`); `models` solo existe para convertir JSON. Los errores viajan como `AppException`.

## Mapa con la rúbrica
- *ApiService o SDK remoto*: `core/network/api_service.dart` (envuelve el SDK de Supabase).
- *Contrato e implementación del repositorio*: `domain/repositories/*` y `data/repositories/*`.
- *ViewModel con provider y ChangeNotifier*: `presentation/viewmodels/*`, provistos con `ChangeNotifierProvider` en la ruta.
- *go_router*: `core/router/app_router.dart`. *Sesión*: `AuthViewModel` + `SecureSessionStorage`.

## Añadir una funcionalidad (receta)
1. ¿Hace falta dato nuevo? → migración SQL + RLS (docs/DATABASE.md).
2. Entidad en `domain/entities`, contrato en `domain/repositories`.
3. `models` + `RepositoryImpl` usando `_api.guard(...)`. Registrarlo en `core/di/app_providers.dart`.
4. ViewModel que extienda `BaseViewModel` (copia `SpecialistListViewModel`).
5. Página con `AsyncStateView`; ruta en `app_router.dart`; prueba con mocktail.

## Cómo se provee el ViewModel de una pantalla
```dart
GoRoute(
  path: '/algo',
  builder: (context, _) => ChangeNotifierProvider(
    create: (c) => AlgoViewModel(c.read<AlgoRepository>())..load(),
    child: const AlgoPage(),
  ),
)
```
