# Prompt — Integrante 4 · Reservar turno (T5, la transacción)

> Actúa como desarrollador Flutter senior que trabaja **dentro de un proyecto existente** y debe respetar su arquitectura al pie de la letra. Rama: `feature/booking`. Lee `docs/PLAN_DE_TRABAJO.md` antes de empezar. Tu módulo es **el corazón de la demo**: el registro de la entidad transaccional.

## 1. Análisis técnico previo
**Estado actual (en `main`):** `BookingPage` es un `PlaceholderPage` que ya recibe `specialistId` (ruta `/specialists/:id/book`) y `serviceId` opcional (query `?serviceId=`). La capa de datos y las reglas de negocio ya existen y están probadas contra Postgres:
- `ServiceRepository.getServicesBySpecialist(id)` (precio propio aplicado).
- `AppointmentRepository.getAvailableSlots({specialistId, serviceId, date})` → RPC `get_available_slots`: huecos cada 30 min dentro del horario 09:00–18:00 (lun–sáb en el seed), descontando turnos activos y horas pasadas; la duración del servicio define el largo del hueco.
- `BookAppointmentUseCase.call({specialistId, serviceId, slot, notes})`: valida que haya horario, que no sea pasado y que las notas ≤ 300 caracteres (`maxNotesLength`); devuelve `Appointment`.
- La **BD** fija `client_id`, `organization_id`, `end_at`, `price_at_booking` y `status = 'pending'`, y la restricción `no_double_booking` rechaza solapes con error `23P01` → `AppException(conflict, 'Ese horario ya fue tomado. Elige otro.')`. **El cliente no envía ni calcula nada de eso.**

**Qué debes leer primero:** `docs/DATABASE.md` (secciones "Decisiones clave" y RPC), `docs/STITCH_ANALYSIS.md` (sección 3; v1 = **un servicio por turno**), `design/stitch_specialist_profile_booking.html` ("Selecciona Fecha y Hora" y barra "Apartar Cita"), `book_appointment_use_case.dart` y su test.

**Trazabilidad con la rúbrica:**
- Criterio 3 (2.5): **registro de la transacción verificable en el servicio remoto** y relación con ambas maestras (especialista + servicio) y el cliente autenticado.
- Criterio 4 (2.0): uso del caso de uso con reglas de negocio + inyección por constructor.
- Criterio 5 (1.0): estados independientes (servicios / horarios / envío), validación y reintento ante fallo de red.

**Alcance v1:** ✅ elegir servicio → fecha (14 días) → hora → notas → confirmar. ⏸ Realtime: se reemplaza por consulta al elegir + reintento. ❌ Multi-servicio por turno, pago, recordatorios.

## 2. Alcance funcional y archivos asignados
### 2.1 Archivos que puedes crear/editar
| Acción | Archivo |
|---|---|
| Editar | `lib/features/appointments/presentation/pages/booking_page.dart` (mantén `const BookingPage({super.key, required this.specialistId, this.serviceId})`) |
| Crear | `lib/features/appointments/presentation/viewmodels/booking_view_model.dart` |
| Crear | `lib/features/appointments/presentation/widgets/booking_date_strip.dart`, `booking_slot_grid.dart`, `booking_summary_bar.dart` (**siempre con prefijo `booking_`**: el Integrante 5 trabaja en la misma carpeta con prefijo `appointment_`) |
| Crear | `test/features/booking/booking_view_model_test.dart` (puedes añadir casos al test existente `book_appointment_use_case_test.dart`, no renombrarlo) |
| Crear | `docs/modules/reserva.md` |

### 2.2 Contrato que **consumes** del Integrante 1 (Commit 0)
`AppRoutes.appointmentsRefreshed()` → navega a `/appointments?refresh=<ts>` para que "Mis turnos" recargue sola. Si no existe todavía en `main`, haz `git pull --rebase origin main` o avisa al Integrante 1; **no lo agregues tú** (`app_routes.dart` está congelado).

### 2.3 Piezas que debes **reutilizar**
`ServiceRepository.getServicesBySpecialist` · `AppointmentRepository.getAvailableSlots` · `BookAppointmentUseCase` · `Appointment`/`TimeSlot` · `BaseViewModel` · `ViewStatus` · `AsyncStateView` (acepta cualquier `ViewStatus`) · `ServiceCard` · `TimeSlotChip` · `AppButton` · `AppTextField` · `SectionHeader` · `ResponsiveCenter` · `Formatters` (`weekdayShort`, `time`, `price`, `dateLong`) · `Brand.tertiary` para el punto dorado del día elegido.

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
Flujo obligatorio: **Page → `BookingViewModel` → `BookAppointmentUseCase` / Repository → `ApiService.guard` → Supabase**.

1. **`BookingViewModel`** (extiende `BaseViewModel`; el `status` base = carga de servicios del especialista). Constructor: `(ServiceRepository, AppointmentRepository, BookAppointmentUseCase, {required String specialistId, String? preselectedServiceId})`. Estado:
   - `services`, `Service? selectedService`; `days` (14 fechas desde hoy, solo fecha: `DateTime(n.year, n.month, n.day)`), `selectedDate`;
   - `slots`, `TimeSlot? selectedSlot`, `ViewStatus slotsStatus`, `AppException? slotsError`;
   - `isSubmitting`, `AppException? submitError`.
2. **Métodos:** `load()` (servicios; si `preselectedServiceId` coincide con uno, lo selecciona y carga horarios; si no existe en la lista, ignóralo), `selectService(Service)`, `selectDate(DateTime)` (limpia `selectedSlot`), `selectSlot(TimeSlot?)`, `retrySlots()`, `Future<Appointment?> confirm({String? notes})`.
3. **Horarios sin condiciones de carrera:** al pedir huecos incrementa un contador `_slotsRequestId`; al volver la respuesta, descártala si el contador cambió (el usuario ya eligió otra fecha/servicio). Mientras carga: `slotsStatus = loading`; vacío: `empty`; error: `error` con `slotsError` (reintentable si es de red).
4. **`confirm`:** `isSubmitting = true` → `await _useCase(specialistId:…, serviceId:…, slot: selectedSlot, notes: notes)`. Éxito → devuelve el `Appointment`. `AppException` → guárdala en `submitError`; si el tipo es `conflict` (23P01), **recarga los horarios** y limpia `selectedSlot`; devuelve `null`. `finally` → `isSubmitting = false`. El caso de uso ya valida sin horario / hora pasada / notas largas: **no dupliques** esas reglas en el VM ni en la Page.
5. **`BookingPage`** (se auto-provee con `ChangeNotifierProvider(create: (c) => BookingViewModel(c.read<ServiceRepository>(), c.read<AppointmentRepository>(), c.read<BookAppointmentUseCase>(), specialistId: …, preselectedServiceId: …)..load())`). `Scaffold` con `AppBar('Reservar turno')`, `ResponsiveCenter` y secciones numeradas:
   1. **Servicio** — `AsyncStateView(status: vm.status, …)`; `ServiceCard(selected, onSelect: () => vm.selectService(s))`. Vacío: "Este especialista aún no ofrece servicios."
   2. **Fecha** (solo con servicio elegido) — `BookingDateStrip`: `ListView` horizontal de 14 días; abreviatura `Formatters.weekdayShort` + número; día elegido = círculo `colorScheme.primary` con texto `onPrimary` y puntito `Brand.tertiary`; cada ítem ≥ 48 dp con `Semantics(label: 'Martes 18, seleccionado')`.
   3. **Hora** — `AsyncStateView(status: vm.slotsStatus, …)` con `BookingSlotGrid` (`Wrap` de `TimeSlotChip(label: Formatters.time(slot.start), selected: …, onTap: …)`). Vacío: "No hay horarios libres este día. Prueba con otra fecha." Error: mensaje + **Reintentar** (`vm.retrySlots`).
   4. **Notas (opcional)** — `AppTextField` 3 líneas con contador `x/300` (`BookAppointmentUseCase.maxNotesLength`).
   5. **Barra inferior** `BookingSummaryBar`: resumen "servicio · día y hora (`Formatters.dateLong`) · precio (`Formatters.price`)" y `AppButton('Confirmar turno', isLoading: vm.isSubmitting)` deshabilitado hasta tener servicio **y** hora.
6. **Resultado:** `final appt = await vm.confirm(notes: …); if (!mounted) return;` Éxito → `SnackBar('Turno reservado')` y `context.go(AppRoutes.appointmentsRefreshed())`. Fallo → `SnackBar` con `vm.submitError!.message` (el usuario permanece en la pantalla con los horarios ya actualizados si hubo conflicto).
7. **Husos horarios:** `TimeSlot` llega en UTC; muestra siempre `toLocal()` (ya lo hace `Formatters.time`). Supuesto documentado: el dispositivo está en la misma zona que `organizations.timezone` (Ecuador); anótalo en `docs/modules/reserva.md`.
8. **Pruebas (`mocktail`)** — `BookingViewModel` con `MockServiceRepository`, `MockAppointmentRepository` y el `BookAppointmentUseCase` real sobre el mock (así pruebas la integración VM + caso de uso): servicio preseleccionado dispara `getAvailableSlots` con los ids y fecha correctos; `selectDate` limpia el horario; **respuesta tardía descartada** (usa `Completer`); `confirm` exitoso devuelve el turno y llama `create` con `startAt = slot.start`; `confirm` sin horario → `submitError` de validación y **sin** llamar a `create`; conflicto 23P01 → recarga horarios y limpia selección; error de red → `canRetry` true; `isSubmitting` vuelve a `false` siempre. Registra `registerFallbackValue(DateTime(2026))` en `setUpAll`.
9. `docs/modules/reserva.md`: flujo, decisiones (un servicio por turno, control de concurrencia), reglas que viven en la BD (no en el cliente) y capturas.

## 4. Criterios de aceptación y pruebas QA
**Funcional (cuenta propia, datos del `seed.sql`)**
- [ ] Llegando desde el perfil con servicio elegido, la reserva abre con ese servicio ya seleccionado; llegando sin `serviceId`, se debe elegir.
- [ ] Los horarios corresponden al servicio: servicio 1 (60 min) → huecos 09:00…17:00 cada 30 min; servicio 2 (90 min) → último hueco 16:30; hoy no aparecen horas pasadas; domingo → vacío.
- [ ] Especialista 1 + servicio 2 muestra y registra **$45.00** (`price_at_booking = 45.00` en la tabla `appointments`), no 40.00.
- [ ] Tras confirmar, en **Supabase → Table Editor → `appointments`** aparece la fila con `status = pending`, `end_at = start_at + duración`, tu `client_id`.
- [ ] Tras confirmar, la app va a "Mis turnos" y el turno aparece (tras el Integrante 5; mientras tanto verifica en la tabla).
- [ ] Reservar 09:00–10:30 (servicio 2) y volver a consultar el mismo día: desaparecen los huecos que se solapan (09:00, 09:30, 10:00 para un servicio de 60 min).
- [ ] **Doble reserva:** con dos cuentas/dispositivos elige el mismo hueco; el segundo en confirmar ve "Ese horario ya fue tomado. Elige otro." y los horarios se refrescan sin el hueco.
- [ ] Notas de 301 caracteres → mensaje de validación y no se envía.

**Estados:** servicios (carga/datos/vacío/error+reintento) · horarios (carga/datos/vacío/error+reintento independientes de los servicios) · envío (botón con indicador, no permite doble toque).

**Pruebas manuales sin conexión**
1. Modo avión al abrir la reserva → error con **Reintentar**; al volver la red, carga.
2. Con servicio y hora elegidos, modo avión y **Confirmar** → mensaje de red, el botón se rehabilita, la selección se conserva y **no** se crea el turno. Reactiva red y confirma → se crea **una sola** vez.
3. Si la respuesta se perdió pero el turno sí se guardó, reintentar dará conflicto (23P01): es el comportamiento esperado; verifica la tabla y documéntalo.
4. Cambia rápido de fecha varias veces: la lista final corresponde a la última fecha (sin parpadeos de datos viejos).

**Unitarias:** todos los casos del paso 8 en verde.

**Antes del PR:** `flutter analyze` · `flutter test` · `bash tool/audit.sh` · `git grep -n "Placeholder" lib/features/appointments/presentation/pages/booking_page.dart` vacío · solo archivos de la tabla 2.1.
