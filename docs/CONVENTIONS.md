# Reglas y límites del proyecto

Fuente: *Trabajo_Autonomo_Flutter_API.docx*. Lo que el documento prohíbe o exige está marcado con 📌.

## Prohibido
- 📌 Guardar tokens/sesión en `shared_preferences`. La sesión vive en `flutter_secure_storage` (ya resuelto en `core/network/secure_session_storage.dart`).
- 📌 Base de datos local, caché de datos de negocio, sincronización diferida o uso offline. La app **requiere conexión**. (`shared_preferences` solo para preferencias no críticas, ej. tema.)
- 📌 Subir claves, contraseñas o `env/dev.json` al repositorio.
- 📌 Que un ViewModel haga solicitudes remotas directamente (usa el repositorio).
- 📌 Que una vista/widget llame a `ApiService` o al SDK de Supabase.
- Importar `supabase_flutter` fuera de `core/network` y de `features/*/data`.
- Crear dependencias dentro del ViewModel (`Repo()` dentro del VM). Se reciben por constructor.
- Agregar paquetes al `pubspec.yaml` sin acordarlo en el equipo (en especial: otros gestores de estado, ORMs, Hive, Isar, sqflite, Dio).
- Hardcodear colores, fuentes o paddings: usar `Theme.of(context)`, `Brand` y `AppSpacing`.
- Strings de ruta sueltos: usar `AppRoutes`.

## Obligatorio
- 📌 Cada pantalla con datos remotos muestra **carga, datos, vacío y error con "Reintentar"** → usa `AsyncStateView` + `BaseViewModel`.
- 📌 Formularios con validación (`core/utils/validators.dart`).
- 📌 Los errores llegan a la UI como `AppException` con mensaje legible (lo hace `ApiService.guard`).
- Tamaño táctil ≥ 48 dp, etiquetas de accesibilidad en iconos/botones sin texto, contenido dentro de `ResponsiveCenter` (bonus: diseño adaptable y accesibilidad).
- Una prueba por ViewModel/caso de uso nuevo, con `mocktail` (bonus: pruebas).

## Dónde va cada cosa
| Quiero… | Va en… |
|---|---|
| Una pantalla nueva | `features/<f>/presentation/pages/` + ruta en `core/router/app_router.dart` |
| Lógica/estado de pantalla | `features/<f>/presentation/viewmodels/` (extiende `BaseViewModel`) |
| Una regla de negocio reutilizable | `features/<f>/domain/usecases/` |
| Una consulta nueva a la BD | método en el contrato (`domain/repositories`) + implementación (`data/repositories`) |
| Un widget que usarán varias pantallas | `shared/widgets/` |
| Un widget de una sola pantalla | `features/<f>/presentation/widgets/` |
| Un cambio de tabla | nuevo archivo `supabase/migrations/000N_descripcion.sql` (nunca editar el 0001 ya aplicado) |
