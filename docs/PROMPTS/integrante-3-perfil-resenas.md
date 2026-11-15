# Prompt — Integrante 3 · Perfil de especialista + Reseñas (T3 + T4)

> Actúa como desarrollador Flutter senior que trabaja **dentro de un proyecto existente** y debe respetar su arquitectura al pie de la letra. Rama: `feature/specialist-profile-reviews`. Lee `docs/PLAN_DE_TRABAJO.md` antes de empezar.

## 1. Análisis técnico previo
**Estado actual (en `main`):** `SpecialistDetailPage` es un `PlaceholderPage` que ya recibe `specialistId` como **parámetro de ruta** (`/specialists/:id`). Toda la capa de datos que necesitas existe: `SpecialistRepository.getSpecialist(id)` (vista `specialist_overview`, con `avgRating` y `reviewCount`), `ServiceRepository.getServicesBySpecialist(id)` (aplica el **precio propio** del especialista si existe) y `ReviewRepository.getBySpecialist(id)` / `create(...)`. `Launchers.whatsapp/call` ya resuelven el contacto directo.

**Qué debes leer primero:** `docs/STITCH_ANALYSIS.md` (sección 3 "Perfil + reserva"), `docs/DATABASE.md` (tablas `reviews`, `specialist_services`, trigger de reseñas), `design/stitch_specialist_profile_booking.html` (solo referencia visual), y como modelo `specialists_page.dart` + `specialist_list_view_model.dart`.

**Trazabilidad con la rúbrica:**
- Criterio 3 (2.5): consulta de las maestras Especialista y Servicio **y su relación** (`specialist_services`) en una sola pantalla; reseñas como dato derivado de la transacción.
- Criterio 1 (1.5): parámetro de ruta `:id` y `serviceId` hacia la reserva.
- Criterio 5 (1.0): 3 secciones independientes, cada una con sus 4 estados; validación del formulario de reseña.

**Alcance v1:** ✅ cabecera (foto, nombre, título, `RatingBadge`, años de experiencia, bio), servicios con selección (un servicio por turno), lista de reseñas, contacto WhatsApp/llamada, CTA "Reservar turno", formulario de reseña. ⏸ Diferido: lookbook/galería (requiere Storage). ❌ Fuera: favoritos, multi-servicio.

**Regla de negocio en BD (no la dupliques en el cliente):** el trigger `reviews_before_insert` solo permite reseñar un turno **propio y `completed`** y llena `author_name`; la columna `appointment_id` es `unique` (una reseña por turno → error `23505`, que `AppException` ya traduce a "Ese registro ya existe.").

## 2. Alcance funcional y archivos asignados
### 2.1 Archivos que puedes crear/editar
| Acción | Archivo |
|---|---|
| Editar | `lib/features/specialists/presentation/pages/specialist_detail_page.dart` (mantén `const SpecialistDetailPage({super.key, required this.specialistId})`) |
| Crear | `lib/features/specialists/presentation/viewmodels/specialist_detail_view_model.dart` |
| Crear | `lib/features/specialists/presentation/viewmodels/specialist_services_view_model.dart` |
| Crear | `lib/features/specialists/presentation/widgets/*.dart` (p. ej. `specialist_header.dart`, `contact_bar.dart`) |
| Crear | `lib/features/reviews/presentation/viewmodels/review_list_view_model.dart` |
| Crear | `lib/features/reviews/presentation/viewmodels/review_form_view_model.dart` |
| Crear | `lib/features/reviews/presentation/widgets/review_tile.dart`, `star_rating_input.dart`, **`review_form_sheet.dart`** |
| Crear | `test/features/specialist_profile/*_test.dart`, `test/features/reviews/*_test.dart` |
| Crear | `docs/modules/perfil-resenas.md` |

### 2.2 Contrato que **debes publicar** (lo consume el Integrante 5; no cambies la firma)
```dart
// lib/features/reviews/presentation/widgets/review_form_sheet.dart
Future<bool?> showReviewFormSheet(
  BuildContext context, {
  required String appointmentId,
  required String specialistId,
});   // true = reseña creada · null/false = cancelado o falló
```
### 2.3 Piezas que debes **reutilizar**
`SpecialistRepository.getSpecialist` · `ServiceRepository.getServicesBySpecialist` · `ReviewRepository.getBySpecialist/create` · `BaseViewModel` · `AsyncStateView` · `AvatarImage` · `RatingBadge` · `ServiceCard` (`selected`, `onSelect`, `currencySymbol`) · `SectionHeader` · `AppButton` · `AppTextField` · `ResponsiveCenter` · `Launchers` · `Formatters` · `Brand.success/successSoft` (botón WhatsApp según `DESIGN.md`) · `AppRoutes.book(id, serviceId:)` · `Validators`.

### 2.4 Reglas inamovibles (resumen de `CONVENTIONS.md` + `.docx`)
**Prohibido**
- `shared_preferences` para sesión o datos de negocio · base de datos local, caché de datos o uso offline (la app **requiere conexión**).
- Importar `supabase_flutter` fuera de `core/network` y `features/*/data` (las únicas excepciones son `core/error/app_exception.dart` y `core/di/app_providers.dart`, ya existentes: no las repliques).
- Instanciar repositorios dentro de un ViewModel (se reciben **por constructor**) o dentro de una Page/Widget (`RepositoryImpl(...)` jamás aparece en `presentation`).
- Que una Page/Widget llame a `ApiService` o a un repositorio directamente (siempre vía ViewModel).
- Hardcodear colores, fuentes o textos del rubro de uñas/belleza. Usa `Theme.of(context).colorScheme/textTheme`, `Brand`, `AppSpacing`. Vocabulario neutro: *especialista, servicio, turno, organización*.
- Strings de ruta sueltos: siempre `AppRoutes`.
- Agregar dependencias a `pubspec.yaml`, tocar archivos congelados (`core/**`, `shared/widgets/**`, router, providers, `supabase/**`, `tool/**`) o cambiar la firma pública de las páginas. Si lo necesitas, pídelo al Integrante 1.

**Obligatorio**
- Rama propia: `git switch main && git pull && git switch -c feature/<modulo>`. Nada de push a `main`; todo entra por PR con revisión.
- Toda carga remota se muestra con `AsyncStateView`: **carga, datos, vacío y error con "Reintentar"** (`canRetry` viene del `AppException`).
- Los ViewModels extienden `BaseViewModel` (o `ChangeNotifier` si son de formulario), reciben dependencias por constructor, **no** importan `supabase_flutter`, **no** reciben `BuildContext`, y capturan errores con `setFailed(e)` (ya los convierte a `AppException`).
- En Pages: después de un `await` usa `if (!mounted) return;` (o `context.mounted`) antes de tocar `context`. Controladores (`TextEditingController`) siempre con `dispose()`.
- Contenido dentro de `ResponsiveCenter`; objetivos táctiles ≥ 48 dp; `tooltip`/`Semantics` en iconos sin texto.
- Una prueba `mocktail` por cada ViewModel/caso de uso nuevo, sin API real.

**Patrón obligatorio de Page + ViewModel** (la Page se auto-provee; por eso no se toca el router):
```dart
class XPage extends StatelessWidget {
  const XPage({super.key});                       // firma pública intacta
  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
        create: (c) => XViewModel(c.read<XRepository>())..load(),
        child: const _XView(),
      );
}
class _XView extends StatelessWidget {
  const _XView();
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<XViewModel>();
    return AsyncStateView(
      status: vm.status, errorMessage: vm.errorMessage, canRetry: vm.canRetry, onRetry: vm.load,
      emptyMessage: '…', dataBuilder: (_) => /* UI */ const SizedBox(),
    );
  }
}
```
**Patrón de prueba** (`mocktail`; si un parámetro es `DateTime`/objeto, registra `registerFallbackValue(...)` en `setUpAll`):
```dart
class MockXRepository extends Mock implements XRepository {}
test('error de red permite reintentar', () async {
  when(() => repo.algo()).thenThrow(const AppException(AppErrorType.network, 'Sin conexión'));
  await vm.load();
  expect(vm.status, ViewStatus.error);
  expect(vm.canRetry, isTrue);
});
```
> En tests de widgets no uses `AppTheme.light()` (descarga fuentes de Google): usa `MaterialApp` simple.

### 2.5 Verificación antes de cada PR (obligatoria)
```bash
git fetch && git rebase origin/main
flutter analyze && flutter test && bash tool/audit.sh
```
Sin errores en los tres. Adjunta capturas de las pantallas (carga/datos/vacío/error) en el PR y en `docs/modules/<modulo>.md`.

## 3. Paso a paso de implementación
Flujo obligatorio: **Page → ViewModel (`BaseViewModel`) → Repository → `ApiService.guard`**. Como `BaseViewModel` tiene un solo `status`, usa **un ViewModel por sección** para que cada una tenga sus 4 estados independientes.

**Parte A — Perfil (maestras Especialista + Servicio)**
1. `SpecialistDetailViewModel(SpecialistRepository, {required String specialistId})`: `Specialist? specialist`; `load()` → `getSpecialist`. Un id inexistente produce `AppException(notFound)` → estado error (sin reintento útil: `canRetry` ya es `false`).
2. `SpecialistServicesViewModel(ServiceRepository, {required String specialistId})`: `services`, `selectedServiceId`, `Service? get selected`; `select(String id)` (tocar de nuevo el mismo servicio lo deselecciona); `load()` → `getServicesBySpecialist`.
3. `ReviewListViewModel(ReviewRepository, {required String specialistId})`: `reviews`; `load()` → `getBySpecialist`; vacío = sin reseñas.
4. `SpecialistDetailPage`: `MultiProvider` con los 3 `ChangeNotifierProvider` (`create: (c) => XViewModel(c.read<XRepository>(), specialistId: specialistId)..load()`). `Scaffold` con `ListView` en `ResponsiveCenter`:
   - **Cabecera** (`AsyncStateView` del detalle): `AvatarImage` grande, `displayName` (`headlineLarge`), `title`, `RatingBadge`, "N años de experiencia" si existe, `bio`. El `dataBuilder` de las secciones dentro de un `ListView` debe devolver un `Column`, nunca otro `ListView`.
   - **Servicios** (`AsyncStateView` de servicios): `ServiceCard(selected: …, onSelect: vm.select, currencySymbol: …)`. Vacío: "Este especialista aún no ofrece servicios."
   - **Reseñas** (`AsyncStateView` de reseñas): `ReviewTile` por reseña. Vacío: "Aún no hay reseñas."
   - **Barra inferior** (`bottomNavigationBar` con `SafeArea`): fila con botón dividido de contacto (WhatsApp: fondo `Brand.successSoft`, texto/icono `Brand.success`; Llamar: fondo neutro) y `AppButton('Reservar turno')` → `context.push(AppRoutes.book(specialistId, serviceId: selectedServiceId))`.
5. Contacto: `Launchers.whatsapp(s.whatsapp!, message: …)` si hay número (si no, oculta/deshabilita el botón); `Launchers.call(s.phone!)`. Si el método devuelve `false` o lanza, `SnackBar('No se pudo abrir la aplicación')`. Comprueba `mounted` tras el `await`.

**Parte B — Reseñas (lectura y alta)**
6. `ReviewTile`: nombre (`authorName ?? 'Cliente'`), estrellas (`Icons.star_rounded` con `colorScheme.tertiary`, `Semantics(label: 'Calificación N de 5')`), comentario, fecha (`'${d.day} de ${Formatters.monthName(d)} de ${d.year}'`).
7. `StarRatingInput`: 5 `IconButton` de **48 dp** con `tooltip: 'N estrellas'`; callback `onChanged(int)`.
8. `ReviewFormViewModel(ReviewRepository, {appointmentId, specialistId})` (extiende `ChangeNotifier`): `rating`, `isSubmitting`, `errorMessage`; `Future<bool> submit(String? comment)`: valida `rating` entre 1 y 5 y `comment` ≤ 500 caracteres (lanza/guarda `AppException(validation)` **sin llamar al repositorio** si es inválido), llama `create(...)`, captura `AppException` (conflicto 23505 y trigger `P0001` incluidos) y expone el mensaje.
9. `showReviewFormSheet(...)`: `showModalBottomSheet<bool>` (`isScrollControlled: true`, `useSafeArea: true`) con su propio `ChangeNotifierProvider(create: (c) => ReviewFormViewModel(c.read<ReviewRepository>(), …))`; contenido: título, `StarRatingInput`, `AppTextField` (comentario, 3 líneas), mensaje de error en `colorScheme.error`, `AppButton('Enviar reseña', isLoading: …)`. Éxito → `Navigator.pop(context, true)`.
10. Para probarlo **sin esperar al Integrante 5**: agrega un botón temporal local que llame `showReviewFormSheet` con un `appointmentId` real (SQL de `PLAN_DE_TRABAJO.md §5`) y **elimínalo antes del commit** (no se permiten `kDebugMode`/botones de prueba en el PR).

**Parte C — Pruebas y documento**
11. Tests (`mocktail`): `SpecialistDetailViewModel` (datos; error `notFound` → `canRetry` false), `SpecialistServicesViewModel` (carga, vacío, `select` alterna selección), `ReviewListViewModel` (datos, vacío, error de red + reintento), `ReviewFormViewModel` (rating 0 → no llama a `create`; comentario > 500 → validación; éxito → `true`; conflicto → mensaje y `false`).
12. `docs/modules/perfil-resenas.md` con pantallas, VMs, contrato `showReviewFormSheet`, decisiones (un VM por sección) y capturas.

## 4. Criterios de aceptación y pruebas QA
**Funcional**
- [ ] Desde la lista abres `/specialists/<uuid>`: se ven foto/iniciales, nombre, título, estrellas, bio y años.
- [ ] Especialista 1: servicio 2 se muestra a **$45.00** (precio propio), no $40.00. Especialista 2: servicio 2 a $40.00.
- [ ] Seleccionar un servicio y pulsar "Reservar turno" abre `/specialists/<id>/book?serviceId=<uuid>`; sin selección, abre sin `serviceId`.
- [ ] WhatsApp abre `wa.me/<número>`; Llamar abre el marcador. Sin número → control oculto/deshabilitado.
- [ ] Tras crear una reseña (SQL de prueba + formulario), la lista de reseñas y el promedio (`specialist_overview`) se actualizan al recargar.
- [ ] Reseñar dos veces el mismo turno muestra "Ese registro ya existe." (no un error genérico).

**Estados — por sección (cabecera, servicios, reseñas)**
- [ ] Carga · datos · vacío (servicio sin especialista no aplica; usa un especialista nuevo sin servicios ni reseñas creado en SQL) · error + **Reintentar** que solo recarga **esa** sección.
- [ ] Un `id` inexistente (`/specialists/00000000-0000-0000-0000-000000000000`) muestra error sin botón Reintentar.

**Pruebas manuales sin conexión**
1. Modo avión, abre el perfil → cada sección muestra error de red con **Reintentar**; reactiva red → recargan.
2. Envía una reseña con modo avión → el formulario muestra "Sin conexión…", **no** se crea la reseña y el botón vuelve a habilitarse; reactiva red y reenvía → se crea una sola vez.
3. Pulsar WhatsApp sin la app instalada no debe cerrar la app (SnackBar).

**Unitarias:** los 4 grupos del paso 11 en verde.

**Antes del PR:** `flutter analyze` · `flutter test` · `bash tool/audit.sh` · confirma que **no** quedó el botón temporal del paso 10 ni `PlaceholderPage` en `specialist_detail_page.dart`.
