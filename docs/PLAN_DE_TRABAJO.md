# Plan de trabajo — división del desarrollo restante

Fuentes: `Trabajo_Autonomo_Flutter_API.docx`, `ARCHITECTURE.md`, `CONVENTIONS.md`, `DATABASE.md`, `RUBRICA_CHECKLIST.md`, `STITCH_ANALYSIS.md`, `TEAM_TASKS.md`.

## 0. Prerrequisito: "Commit 0" del Integrante 1 (antes de que nadie cree rama)
Un solo commit directo a `main` (o PR relámpago). Sin esto, el diseño "cero conflictos" no se sostiene.

1. **`lib/core/router/app_routes.dart`** — agregar (el único cambio de rutas del proyecto):
   ```dart
   /// Query param para forzar recarga de "Mis turnos" tras reservar o cancelar.
   static const refreshParam = 'refresh';

   /// /appointments?refresh=<marca de tiempo>
   static String appointmentsRefreshed() =>
       '$appointments?$refreshParam=${DateTime.now().millisecondsSinceEpoch}';
   ```
2. **`tool/audit.sh`** — añadir el script entregado (probado: pasa en la base actual y detecta violaciones).
3. **`docs/CONVENTIONS.md`** — corregir la regla del SDK: *"`supabase_flutter` solo en `core/network`, `features/*/data` y dos excepciones de infraestructura ya existentes: `core/error/app_exception.dart` (tipos `AuthException`/`PostgrestException`) y `core/di/app_providers.dart` (`Supabase.instance.client`). No se agregan más."* (La documentación original decía solo las dos primeras; el código base ya tenía estas dos.)
4. **`docs/`** — reemplazar `TEAM_TASKS.md`, agregar `PLAN_DE_TRABAJO.md`, `docs/prompts/*` y `docs/modules/.gitkeep`.
5. **GitHub** — proteger `main` (PR obligatorio, 1 revisión, sin push directo) y confirmar que `flutter analyze && flutter test && bash tool/audit.sh` pasan en `main`.
6. Avisar al equipo: *"Desde este commit, crear rama: `git switch main && git pull && git switch -c feature/<modulo>`"*.

## 1. Cómo se logra "cero conflictos" (Merge-Safe)
**Por qué nadie toca `app_router.dart`:** todas las rutas ya existen (`/`, `/specialists`, `/specialists/:id`, `/specialists/:id/book?serviceId=`, `/appointments`, `/profile`) y apuntan a páginas con constructores fijos. El trabajo de cada integrante vive **dentro de la página**, y cada página **provee su propio ViewModel** (`ChangeNotifierProvider` dentro del `build`). Los repositorios ya están registrados en `app_providers.dart`. Por tanto **no hay que registrar nada** y no hay archivos compartidos que editar. La única excepción (`SpecialistsPage`) ya recibe su `SpecialistListViewModel` desde el router y no se cambia esa parte.

**Archivos congelados** (nadie los edita en su rama): `lib/core/**`, `lib/shared/widgets/**`, `lib/app.dart`, `lib/main.dart`, `pubspec.yaml`, `pubspec.lock`, `analysis_options.yaml`, `supabase/**`, `tool/**`, `env/**`, `android/**`, y los docs que no sean los propios. Si necesitas algo ahí → pídeselo al Integrante 1 (cambio mínimo a `main`, luego haces `git rebase origin/main`). *Excepción acotada:* el Integrante 5 puede tocar `shared/widgets/**` y páginas ajenas solo en su **Fase 2**, en PR pequeños, después de que esas ramas estén integradas.

**Firmas públicas que no se pueden cambiar** (el router las usa):
`HomePage()` · `SpecialistsPage()` · `SpecialistDetailPage({required specialistId})` · `BookingPage({required specialistId, serviceId})` · `AppointmentsPage()`.

**Nombres sin colisión:** dentro de una misma carpeta (p. ej. `appointments/presentation/`), cada integrante usa un prefijo propio de archivos (`booking_*` el 4; `appointment_*`/`appointments_*` el 5). Los tests viven en `test/features/<feature>/` con nombres únicos.

**Antes de abrir el PR:** `git fetch && git rebase origin/main` → `flutter analyze` → `flutter test` → `bash tool/audit.sh`. Si el rebase trae un conflicto en un archivo que **no** es tuyo, no lo resuelvas tú: es señal de que alguien violó el reparto; avisa al Integrante 1.

## 2. Matriz de propiedad de archivos
| Integrante | Rama | Puede crear/editar |
|---|---|---|
| **2** | `feature/home-services` | `features/home/presentation/pages/home_page.dart` · `home/presentation/{viewmodels,widgets}/**` · `features/specialists/presentation/pages/specialists_page.dart` · `features/services/presentation/**` · **solo agregar** un método en `specialists/domain/repositories/specialist_repository.dart` y `specialists/data/repositories/specialist_repository_impl.dart` · `test/features/{home,services}/**` · `docs/modules/home-servicios.md` |
| **3** | `feature/specialist-profile-reviews` | `features/specialists/presentation/pages/specialist_detail_page.dart` · `specialists/presentation/viewmodels/specialist_{detail,services}_view_model.dart` · `specialists/presentation/widgets/**` · `features/reviews/presentation/**` · `test/features/{specialist_profile,reviews}/**` · `docs/modules/perfil-resenas.md` |
| **4** | `feature/booking` | `features/appointments/presentation/pages/booking_page.dart` · `appointments/presentation/viewmodels/booking_view_model.dart` · `appointments/presentation/widgets/booking_*.dart` · `test/features/booking/**` · `docs/modules/reserva.md` |
| **5** | `feature/my-appointments-qa` | `features/appointments/presentation/pages/appointments_page.dart` · `appointments/presentation/viewmodels/appointments_view_model.dart` · `appointments/presentation/widgets/appointment_*.dart` · `test/core/**`, `test/shared/**`, `test/features/{auth,appointments}/**` · `docs/RUBRICA_CHECKLIST.md` · `docs/QA_REPORT.md` · `docs/modules/mis-turnos-qa.md` · (Fase 2) correcciones de accesibilidad/adaptable |

Los tests existentes (`test/core_validators_test.dart`, `test/features/specialist_list_view_model_test.dart`, `test/features/book_appointment_use_case_test.dart`) no se mueven ni se renombran.

## 3. Contratos entre módulos (no cambiarlos sin avisar)
| Quién produce | Contrato | Quién consume |
|---|---|---|
| Int. 1 (Commit 0) | `AppRoutes.appointmentsRefreshed()` y `AppRoutes.refreshParam` | Int. 4 (navega tras reservar), Int. 5 (escucha el parámetro) |
| Int. 3 | `Future<bool?> showReviewFormSheet(BuildContext, {required String appointmentId, required String specialistId})` en `reviews/presentation/widgets/review_form_sheet.dart`; devuelve `true` si se creó la reseña | Int. 5 (botón "Dejar reseña" en turnos `completed`) |
| Int. 2 | `SpecialistRepository.getSpecialistsByService(String serviceId)` | Int. 2 (hoja de especialistas); nadie más lo necesita |
| Rutas existentes | `AppRoutes.specialistDetail(id)` · `AppRoutes.book(id, serviceId:)` · `AppRoutes.specialists` | Int. 2 (Home y Servicios navegan), Int. 3 (CTA reservar) |

## 4. Trazabilidad con la rúbrica
| Criterio | Quién lo cubre |
|---|---|
| 1. Interfaz y navegación (1.5) | 2, 3, 4, 5 (cada pantalla; parámetros `:id` y `serviceId`; rutas protegidas ya listas) |
| 2. Autenticación (2.0) | Hecho (Int. 1) · QA lo verifica (Int. 5) |
| 3. Datos remotos y modelo (2.5) | Consulta de maestras: **2** (servicios, especialistas) y **3** (perfil) · Registro de transacción: **4** · Consulta de transacción: **5** |
| 4. Clean Architecture/MVVM (2.0) | Todos (flujo Page → ViewModel → Repository → ApiService); lo audita Int. 5 con `tool/audit.sh` |
| 5. Estado, validación y errores (1.0) | Todos (`AsyncStateView` 4 estados) |
| 6. Documento y demostración (1.0) | Todos (`docs/modules/*.md`); consolida Int. 1 |
| Bonus (+1.0) | Int. 5 (adaptable +0.4, pruebas +0.3, accesibilidad +0.3) con aportes de todos |

## 5. Datos de prueba comunes
- Organización demo: `00000000-0000-0000-0000-000000000001`. Especialistas `2000…0001`/`…0002`; servicios `3000…0001/2/3`; categorías `1000…0001/2` (ver `supabase/seed.sql`).
- Especialista 1 ofrece servicios 1 y 2 (el 2 con **precio propio 45.00**, base 40.00). Especialista 2 ofrece servicios 2 y 3. Horario lunes–sábado 09:00–18:00. No hay reseñas.
- **Crear un turno `completed` para probar reseñas** (SQL Editor; sustituye `<UUID_USUARIO>` por el id del usuario en *Authentication → Users*):
  ```sql
  insert into public.appointments (organization_id, client_id, specialist_id, service_id, start_at)
  values ('00000000-0000-0000-0000-000000000001', '<UUID_USUARIO>',
          '20000000-0000-0000-0000-000000000001', '30000000-0000-0000-0000-000000000001',
          now() + interval '30 days');
  update public.appointments set status = 'completed'
   where client_id = '<UUID_USUARIO>' and status = 'pending' and start_at > now() + interval '29 days';
  ```
- Cada integrante usa **su propia cuenta de prueba** (Sign up en la app) para no pisar los turnos de otros.

## 6. Definition of Done (todos)
`flutter analyze` sin errores · `flutter test` en verde · `bash tool/audit.sh` en verde · 4 estados verificados en cada pantalla con datos remotos · prueba manual sin conexión · `docs/modules/<modulo>.md` con pantallas, VM, repos usados, decisiones y capturas · PR con checklist de `CONTRIBUTING.md` y revisión de otro integrante.
