# Vitrina — plantilla Flutter de vitrina de servicios con turnos

App móvil **multi-organización**: una organización (salón, clínica, taller…) exhibe sus **servicios** y a los **especialistas** que los ofrecen, con reseñas, contacto directo (WhatsApp/llamada) y un sistema de **turnos**. El mismo código sirve a otra organización cambiando datos y marca (ver [docs/WHITE_LABEL.md](docs/WHITE_LABEL.md)).

Proyecto del **Trabajo Autónomo: Desarrollo de una app Android con Flutter y datos remotos** (MVVM + Clean Architecture, go_router, provider/ChangeNotifier, servicio remoto con autenticación real).

## Stack (todo sale del .docx)
| Necesidad | Elección |
|---|---|
| Navegación + rutas protegidas | `go_router` |
| Estado / DI | `provider` + `ChangeNotifier` |
| Servicio remoto + Auth + BD | **Supabase** (SDK oficial `supabase_flutter`) — Postgres con RLS |
| Sesión segura | `flutter_secure_storage` (JWT **no** va en shared_preferences) |
| Arquitectura | Feature-first, Clean Architecture + MVVM + Repository |
| Pruebas (bonus) | `flutter_test` + `mocktail` |

## Puesta en marcha (≈10 min)
1. **Supabase**: crea un proyecto gratis en supabase.com. En *SQL Editor* ejecuta, en orden, `supabase/migrations/0001_init.sql` y luego `supabase/seed.sql`.
   En *Authentication → Providers → Email* desactiva **Confirm email** (solo para desarrollo/demo).
2. **Claves**: copia `env/dev.example.json` → `env/dev.json` y completa `SUPABASE_URL` y `SUPABASE_ANON_KEY` (Project Settings → API). `ORG_ID` ya apunta a la organización demo. *`env/dev.json` está en .gitignore: nunca lo subas.*
3. **Android**: `bash tool/setup.sh` (genera `android/`, agrega permiso INTERNET y `queries`, fija `minSdk 23`, hace `flutter pub get`).
4. **Validar**: `flutter analyze && flutter test`
5. **Ejecutar**: `flutter run --dart-define-from-file=env/dev.json`

> Esta base se armó sin poder compilar en el entorno donde se generó. El **paso 4 es obligatorio**: si `flutter analyze` marca algo (versiones de paquetes, firmas del SDK), corrígelo en un commit aparte antes de empezar tus pantallas.

## Qué está listo y qué falta
✅ Listo: tema (de `design/DESIGN.md`), router con rutas protegidas, DI, sesión segura, Sign in / Sign up / Cerrar sesión, capa de datos completa (organización, especialistas, servicios, turnos, reseñas), caso de uso de reserva, widgets reutilizables, pantalla de referencia `SpecialistsPage`, pruebas de ejemplo, esquema SQL con RLS y seed.

🟡 Pendiente (ver [docs/TEAM_TASKS.md](docs/TEAM_TASKS.md)): Home, Perfil de especialista, Reservar turno, Mis turnos, Reseñas, listado de servicios.

## Documentación
- [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) — capas, flujo de datos, cómo añadir una funcionalidad paso a paso
- [docs/CONVENTIONS.md](docs/CONVENTIONS.md) — **reglas y límites** (léelo antes de programar)
- [docs/DATABASE.md](docs/DATABASE.md) — modelo de datos, RLS, RPC
- [docs/STITCH_ANALYSIS.md](docs/STITCH_ANALYSIS.md) — análisis del diseño de Stitch: qué se implementa y qué se simplifica
- [docs/RUBRICA_CHECKLIST.md](docs/RUBRICA_CHECKLIST.md) — dónde se cumple cada criterio de la rúbrica
- [docs/WHITE_LABEL.md](docs/WHITE_LABEL.md) — adaptar el proyecto a otra organización
- [CONTRIBUTING.md](CONTRIBUTING.md) — flujo de Git del equipo
- `design/` — DESIGN.md y las 3 pantallas HTML de Stitch (solo referencia visual)
