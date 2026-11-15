# Prompt — Integrante 5 · Mis turnos + Aseguramiento de Calidad (T6 + T7 unificados)

> Actúa como desarrollador Flutter senior **y** ingeniero QA que trabaja dentro de un proyecto existente. Rama: `feature/my-appointments-qa`. Lee `docs/PLAN_DE_TRABAJO.md` antes de empezar. Tienes **dos fases**: Fase 1 (desde ya, en paralelo) y Fase 2 (cuando los Integrantes 2, 3 y 4 hayan integrado sus PR). Eres el último en integrarte a `main`.

## 1. Análisis técnico previo
**Estado actual (en `main`):** `AppointmentsPage` es un `PlaceholderPage`. Ya existen `AppointmentRepository.getMyAppointments()` (filtra por `client_id` del usuario y trae nombres de especialista/servicio con la relación `specialists(display_name), services(name)`), `AppointmentRepository.cancel(id)`, la entidad `Appointment` (`status`, `isActive`, `startAt`, `endAt`, `price`, `specialistName`, `serviceName`) y la política RLS `appt_client_cancel` (el cliente solo puede cambiar **su** turno a `cancelled`). Pruebas existentes: validadores, `SpecialistListViewModel`, `BookAppointmentUseCase`.

**Qué debes leer primero:** `docs/RUBRICA_CHECKLIST.md` (criterios y bonus), `docs/DATABASE.md` (RLS de `appointments`), `docs/CONVENTIONS.md`, el `.docx` (sección de criterios opcionales), `core/state/base_view_model.dart`, `core/error/app_exception.dart`, `shared/widgets/*`, `tool/audit.sh`.

**Trazabilidad con la rúbrica:**
- Criterio 3 (2.5): **consulta de la entidad transaccional** (`appointments`) desde el servicio remoto y su cancelación.
- Criterios 1 y 5: pantalla con 4 estados y refresco; navegación de vuelta tras reservar.
- **Bonus (+1.0):** diseño adaptable (+0.4) · pruebas automatizadas con `mocktail` (+0.3) · accesibilidad (+0.3). Los entregas tú, con aportes ya incluidos por los demás.
- Criterio 4: auditas el cumplimiento de la arquitectura (`tool/audit.sh`) en todo el repo.

**Alcance v1 (`STITCH_ANALYSIS.md`):** ✅ lista de turnos (próximos / historial), estado, cancelación, "Dejar reseña" en turnos `completed`. ❌ Reprogramar turnos, notificaciones, vista para especialistas/admin.

**Limitaciones conocidas que debes manejar (y documentar):**
- Si el RLS rechaza una actualización, PostgREST responde **sin error y con 0 filas**: tras `cancel` debes **recargar y verificar** que el turno quedó `cancelled`.
- No existe consulta "¿ya reseñé este turno?": un segundo intento devuelve `23505` ("Ese registro ya existe."); se muestra como mensaje y se documenta como límite de v1.

## 2. Alcance funcional y archivos asignados
### 2.1 Archivos que puedes crear/editar
| Fase | Acción | Archivo |
|---|---|---|
| 1 | Editar | `lib/features/appointments/presentation/pages/appointments_page.dart` (mantén `const AppointmentsPage({super.key})`) |
| 1 | Crear | `lib/features/appointments/presentation/viewmodels/appointments_view_model.dart` |
| 1 | Crear | `lib/features/appointments/presentation/widgets/appointment_card.dart`, `appointment_status_chip.dart` (**prefijo `appointment_`**; el Integrante 4 usa `booking_`) |
| 1 | Crear | `test/features/appointments/appointments_view_model_test.dart` |
| 1 | Crear | `test/core/app_exception_test.dart`, `test/core/base_view_model_test.dart`, `test/core/formatters_test.dart` |
| 1 | Crear | `test/features/auth/auth_view_model_test.dart` |
| 1 | Crear | `test/shared/async_state_view_test.dart`, `test/shared/accessibility_guidelines_test.dart` |
| 2 | Editar | `docs/RUBRICA_CHECKLIST.md` (estados reales), crear `docs/QA_REPORT.md` y `docs/modules/mis-turnos-qa.md` |
| 2 | Integrar | botón "Dejar reseña" → `showReviewFormSheet` (de `reviews/presentation/widgets/review_form_sheet.dart`, Integrante 3) |
| 2 | Corregir (PR pequeños `fix/a11y-<modulo>` o `fix/adaptive-<modulo>`, **después** de que ese módulo esté en `main`) | `lib/shared/widgets/**` y páginas de otros módulos, **solo** para accesibilidad/adaptable |

### 2.2 Contratos
- **Consumes (Int. 1):** `AppRoutes.refreshParam` y `AppRoutes.appointmentsRefreshed()`. Tras reservar, el Integrante 4 navega a `/appointments?refresh=<ts>`; tu página debe recargar cuando el valor cambie.
- **Consumes (Int. 3):** `Future<bool?> showReviewFormSheet(BuildContext, {required String appointmentId, required String specialistId})` → `true` = reseña creada. Si aún no está en `main`, deja el botón para la Fase 2.

### 2.3 Piezas que debes **reutilizar**
`AppointmentRepository` · `BaseViewModel` · `AsyncStateView` · `AppButton` · `ResponsiveCenter` · `Formatters` (`dateLong`, `price`, `duration`) · `Brand.success/tertiary/muted` y `colorScheme.error` para los chips de estado · `AppRoutes`.

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
Flujo obligatorio: **Page → `AppointmentsViewModel` → `AppointmentRepository` → `ApiService.guard`**.

### FASE 1 — Mis turnos (consulta de la transacción) y pruebas base
1. **`AppointmentsViewModel(AppointmentRepository, {DateTime Function()? now})`** extiende `BaseViewModel`. Estado: `appointments`, `cancelingId` (String?), `actionError` (String?). Getters: `upcoming` (activos cuyo `endAt` es posterior a `now()`, ordenados por `startAt` ascendente) e `history` (el resto, descendente). Reloj inyectable para poder probar.
   - `load()`: `setLoading()` → `getMyAppointments()` → `setLoaded(isEmpty: appointments.isEmpty)`; error → `setFailed(e)`.
   - `cancel(String id)`: marca `cancelingId`, llama `repository.cancel(id)`, **recarga la lista y verifica** que el turno quedó `cancelled`; si no, `actionError = 'No se pudo cancelar el turno.'`. Errores de red → `actionError` con el mensaje del `AppException`; limpia `cancelingId` en `finally`.
2. **`AppointmentStatusChip`**: etiqueta en español (Pendiente / Confirmado / Completado / Cancelado) + color de `Brand`/`colorScheme` (nunca solo color: el texto siempre visible). **`AppointmentCard`**: servicio (`titleMedium`), especialista, `Formatters.dateLong(startAt)`, precio (`Formatters.price`), chip y acciones.
3. **`AppointmentsPage`** (const, se auto-provee `ChangeNotifierProvider(create: (c) => AppointmentsViewModel(c.read<AppointmentRepository>())..load())`): `AppBar('Mis turnos')`, `ResponsiveCenter`, `SegmentedButton` "Próximos / Historial", `RefreshIndicator`, `AsyncStateView` (vacío distinto por pestaña: "No tienes turnos próximos." / "Aún no tienes historial.").
   - **Cancelar:** solo en turnos activos futuros → `AlertDialog` de confirmación → `vm.cancel(id)`; muestra `actionError` con `SnackBar`; comprueba `mounted` tras cada `await`.
   - **Recarga tras reservar:** en el `State` de la vista interna, en `didChangeDependencies`, lee `GoRouterState.of(context).uri.queryParameters[AppRoutes.refreshParam]`; si es distinto del último valor guardado (`_lastRefresh`), guárdalo y llama `context.read<AppointmentsViewModel>().load()` en `addPostFrameCallback` (con `mounted`). **Verifícalo manualmente** (ver QA): si go_router recreara la página y perdiera el estado, repórtalo al Integrante 1 en lugar de inventar otro mecanismo global.
4. **Pruebas base (`mocktail`, sin API):**
   - `AppointmentsViewModel`: `upcoming`/`history` correctos con reloj fijo; vacío; error de red y reintento; `cancel` exitoso (recarga y estado `cancelled`); `cancel` que "no surte efecto" (la recarga devuelve el turno activo) → `actionError`; `cancelingId` se limpia siempre.
   - `AppException.from`: `SocketException`/`TimeoutException`/`http.ClientException` → `network` y `isRetryable`; `PostgrestException(message:'x', code:'23P01'|'23505'|'42501'|'P0001'|'PGRST116')` → tipos/mensajes esperados; `AuthException('Invalid login credentials')` → "Correo o contraseña incorrectos."; error desconocido → `unknown`.
   - `BaseViewModel` (con una subclase mínima de prueba): transiciones `idle → loading → data/empty/error`, `canRetry`, **no notifica después de `dispose`**.
   - `AuthViewModel` (con `MockAuthRepository` y un `StreamController<AuthUser?>`): usuario inicial = `currentUser`; el stream actualiza `isAuthenticated` y notifica; `signIn` exitoso → `true`; fallo → `false` + `errorMessage` y `isSubmitting` vuelve a `false`; `signUp` devuelve `SignUpResult`; `signOut`; `clearError`.
   - `Formatters` y casos extra de `Validators`.
   - Widget tests: `AsyncStateView` (los 4 estados; tocar **Reintentar** invoca `onRetry`; sin `onRetry` o `canRetry:false` no hay botón), `AppButton` (con `isLoading` está deshabilitado).
   - Accesibilidad: `flutter_test` guidelines sobre `TimeSlotChip`, `AppChoiceChip`, `RatingBadge`, `AppButton`: `await expectLater(tester, meetsGuideline(androidTapTargetGuideline)); … labeledTapTargetGuideline; … textContrastGuideline;` (con `ensureSemantics()`).
5. Abre PR de Fase 1 cuando todo esté verde; esto **no** requiere esperar a los demás.

### FASE 2 — QA de integración (cuando 2, 3 y 4 estén en `main`)
6. `git switch feature/my-appointments-qa && git rebase origin/main`.
7. **"Dejar reseña":** en `AppointmentCard`, para `completed`, botón que llama `showReviewFormSheet(context, appointmentId: a.id, specialistId: a.specialistId)`; si devuelve `true` → `SnackBar('Gracias por tu reseña')`. Un segundo intento mostrará "Ese registro ya existe." (límite documentado).
8. **Auditoría automática:** `bash tool/audit.sh` debe pasar en el repo integrado. Si falla en código ajeno, abre un issue/avisa al dueño del módulo (no lo corrijas en silencio salvo cambios triviales acordados).
9. **Flujo extremo a extremo manual** (cuenta nueva): Sign up → Home → Especialistas y servicios (ambas pestañas) → perfil → reservar → "Mis turnos" muestra el turno **sin** refrescar a mano → marcar `completed` por SQL (`PLAN_DE_TRABAJO.md §5`) → recargar → reseñar → ver la reseña y el promedio en el perfil → cancelar otro turno → cerrar sesión → volver a entrar.
10. **Sesión:** cierra la app con sesión iniciada y reábrela (restaura); tras cerrar sesión, el botón atrás del sistema **no** debe mostrar pantallas protegidas; abrir con sesión caducada redirige a Sign in.
11. **Accesibilidad (manual, +0.3):** activa TalkBack y recorre Sign in, Home, lista, perfil, reserva y Mis turnos: todo control tiene nombre comprensible y orden lógico; iconos sin texto con `tooltip`/`Semantics`; el estado no depende solo del color; contraste ≥ 4.5:1 en textos (revisa `Brand.muted` sobre `Brand.canvas` con el verificador de contraste de Accessibility Scanner o una herramienta web); objetivos ≥ 48 dp; **escala de fuente 1.5× y 2.0×** (Ajustes → Pantalla → Tamaño de fuente): sin desbordes ni textos cortados. Corrige con PR `fix/a11y-<modulo>`.
12. **Diseño adaptable (+0.4):** prueba en vertical y **horizontal**, y en emulador de tablet (≥ 600 dp): sin franjas amarillas de overflow, formularios y listas centrados por `ResponsiveCenter`, barras inferiores usables en horizontal, `NavigationBar` correcta. En listas/rejillas anchas considera 2 columnas con `LayoutBuilder` solo si hay tiempo. Corrige con PR `fix/adaptive-<modulo>`.
13. **Informe:** `docs/QA_REPORT.md` con tabla *caso · resultado · evidencia · responsable · estado* (incluye cada caso de la sección 4, los hallazgos y su corrección). Actualiza `docs/RUBRICA_CHECKLIST.md` con el estado real de cada criterio y la evidencia (ruta de archivo). Redacta `docs/modules/mis-turnos-qa.md`.

## 4. Criterios de aceptación y pruebas QA
**Mis turnos (funcional)**
- [ ] Muestra los turnos del usuario (consulta remota real); un usuario nuevo ve el vacío "No tienes turnos próximos.".
- [ ] Un turno recién reservado aparece **sin pull-to-refresh** (parámetro `refresh`); si no, hay un hallazgo documentado.
- [ ] Cancelar pide confirmación, cambia a "Cancelado" y pasa a Historial; verificado en la tabla (`status = cancelled`).
- [ ] No se puede cancelar un turno `completed`/`cancelled` (sin botón). Turno de otro usuario nunca aparece (RLS) — comprueba con dos cuentas.
- [ ] Turno `completed` muestra "Dejar reseña" (Fase 2).

**Estados (`AsyncStateView`)**
- [ ] Carga · datos · vacío (por pestaña) · error + **Reintentar** (solo si `canRetry`).

**Pruebas manuales sin conexión (toda la app)**
1. Cancelar con modo avión → mensaje de red, el turno **sigue** activo, sin estados a medias.
2. Abrir Mis turnos sin red → error con Reintentar; con red, carga.
3. Matriz sin red en cada módulo (Home, servicios, perfil, reserva, turnos, login, registro): siempre mensaje comprensible; ninguna pantalla muestra datos de negocio sin conexión (no hay caché local).
4. Iniciar sesión sin red → "Sin conexión…" y el botón se rehabilita.

**Unitarias:** todas las de la Fase 1 en verde; `flutter test` global en verde; cobertura mínima esperada: todos los ViewModels y `AppException`/`BaseViewModel`/`AuthViewModel`.

**Calidad global (tu veredicto de salida)**
- [ ] `flutter analyze` sin errores ni *warnings* nuevos · `bash tool/audit.sh` en verde · `flutter test` en verde.
- [ ] `git grep -n "PlaceholderPage" lib/features` → solo debe quedar en `shared/widgets/placeholder_page.dart` (o vacío si se elimina en acuerdo con el Integrante 1).
- [ ] APK de release instala y abre en un dispositivo real: `flutter build apk --release --dart-define-from-file=env/dev.json`; verifica permiso INTERNET (la app consulta datos fuera de `debug`).
- [ ] `QA_REPORT.md` y `RUBRICA_CHECKLIST.md` actualizados; cada hallazgo tiene dueño y estado.

**Antes del PR final:** rebase sobre `main`, los tres comandos en verde y revisión cruzada de otro integrante.
