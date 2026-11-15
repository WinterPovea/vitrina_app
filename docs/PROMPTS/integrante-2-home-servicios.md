# Prompt — Integrante 2 · Home + Servicios con pestañas (T1 + T2)

> Actúa como desarrollador Flutter senior que trabaja **dentro de un proyecto existente** y debe respetar su arquitectura al pie de la letra. Rama: `feature/home-services`. Lee `docs/PLAN_DE_TRABAJO.md` antes de empezar.

## 1. Análisis técnico previo
**Estado actual (en `main`):** Sign up/in/out, router con rutas protegidas, DI y capa de datos completos. `HomePage` es un `PlaceholderPage`. `SpecialistsPage` es la pantalla de referencia: una lista con búsqueda, `RefreshIndicator` y los 4 estados, alimentada por `SpecialistListViewModel` que **provee el router**. No existe UI para el catálogo de servicios, y `SpecialistRepository` no tiene una consulta "especialistas que ofrecen un servicio".

**Qué debes leer primero:** `docs/ARCHITECTURE.md` (receta "Añadir una funcionalidad"), `docs/CONVENTIONS.md`, `docs/STITCH_ANALYSIS.md` (secciones Home y "Especialistas y Servicios"), `design/stitch_home.html`, `design/stitch_specialists_services.html` (solo referencia visual: **no copies HTML/Tailwind**), y como modelo de código `specialists_page.dart` + `specialist_list_view_model.dart` + `test/features/specialist_list_view_model_test.dart`.

**Trazabilidad con la rúbrica (`RUBRICA_CHECKLIST.md`):**
- Criterio 3 (2.5 pts): tú entregas la **consulta de las dos entidades maestras** en una misma pantalla (pestañas "Por especialistas" / "Por servicios") — es la evidencia clave de la demo.
- Criterio 1 (1.5): navegación entre pestañas del shell y hacia perfil/reserva con parámetros de ruta.
- Criterio 5 (1.0): carga/datos/vacío/error + reintento en Home, lista de servicios y hoja de especialistas.

**Alcance v1 (`STITCH_ANALYSIS.md`):**
✅ Home: cabecera de organización, categorías, servicios destacados, especialistas destacados. ✅ Pestañas, chips de categoría, búsqueda de especialistas.
⏸ Diferido: "próximo turno", portafolios/fotos, "2 turnos hoy". ❌ Descartado: favoritos, banner de esterilización, "100% garantía", glassmorphism.

## 2. Alcance funcional y archivos asignados
### 2.1 Archivos que puedes crear/editar
| Acción | Archivo |
|---|---|
| Editar | `lib/features/home/presentation/pages/home_page.dart` (mantén `const HomePage({super.key})`) |
| Crear | `lib/features/home/presentation/viewmodels/home_view_model.dart` |
| Crear | `lib/features/home/presentation/widgets/*.dart` (p. ej. `home_hero.dart`, `category_chip_row.dart`) |
| Editar | `lib/features/specialists/presentation/pages/specialists_page.dart` (agregar pestañas; mantén `const SpecialistsPage({super.key})` y la parte que usa `SpecialistListViewModel` del router) |
| Crear | `lib/features/services/presentation/viewmodels/service_list_view_model.dart` |
| Crear | `lib/features/services/presentation/viewmodels/service_specialists_view_model.dart` |
| Crear | `lib/features/services/presentation/pages/services_tab.dart` |
| Crear | `lib/features/services/presentation/widgets/service_specialists_sheet.dart` |
| **Agregar un método** (sin modificar los existentes) | `lib/features/specialists/domain/repositories/specialist_repository.dart` y `.../data/repositories/specialist_repository_impl.dart` |
| Crear | `test/features/home/home_view_model_test.dart`, `test/features/services/service_list_view_model_test.dart`, `test/features/services/service_specialists_view_model_test.dart` |
| Crear | `docs/modules/home-servicios.md` |

### 2.2 Contratos y piezas que debes **reutilizar** (no reescribir)
`OrganizationRepository.getCurrent()` · `ServiceRepository.getCategories()` / `getServices({categoryId})` · `SpecialistRepository.getSpecialists({query})` · `BaseViewModel` · `AsyncStateView` · `SpecialistCard` · `ServiceCard` · `AppChoiceChip` · `SectionHeader` · `ResponsiveCenter` · `AppButton` · `Formatters` · `AppRoutes.specialists / specialistDetail(id) / book(id, serviceId:)`. Entidades: `Organization`, `Category`, `Service`, `Specialist`. **Base de datos (`DATABASE.md`):** vista `specialist_overview` (promedio/conteo de reseñas), tablas `categories`, `services`, `specialist_services`; no necesitas migraciones.

### 2.3 Reglas inamovibles (resumen de `CONVENTIONS.md` + `.docx`)
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

### 2.4 Verificación antes de cada PR (obligatoria)
```bash
git fetch && git rebase origin/main
flutter analyze && flutter test && bash tool/audit.sh
```
Sin errores en los tres. Adjunta capturas de las pantallas (carga/datos/vacío/error) en el PR y en `docs/modules/<modulo>.md`.

## 3. Paso a paso de implementación
Flujo obligatorio: **Page → ViewModel (`BaseViewModel`) → Repository (contrato) → `ApiService.guard` → Supabase**.

**Parte A — Extensión mínima del repositorio (hazla primero y empuja un commit propio)**
1. En `specialist_repository.dart` agrega `Future<List<Specialist>> getSpecialistsByService(String serviceId);`.
2. En `specialist_repository_impl.dart` impleméntalo con `_api.guard`: consulta `specialist_services` (`select('specialist_id').eq('service_id', serviceId)`), arma la lista de ids y, si no está vacía, consulta la vista `specialist_overview` con `.inFilter('id', ids).eq('is_active', true).order('display_name')`; si no hay ids devuelve `[]`. Mapea con `SpecialistModel.fromJson`. *(Si tu versión del SDK nombra distinto al filtro `in`, ajusta según `flutter analyze`; no importes nada nuevo.)* El RLS (`specsvc_read`, `spec_read`) ya limita todo a la organización.
3. No toques `getSpecialists` ni `getSpecialist` (los usa otro integrante).

**Parte B — Servicios (maestra 2)**
4. `ServiceListViewModel(ServiceRepository)`: estado `categories`, `services`, `selectedCategoryId`. `load()` hace `setLoading()`, carga categorías y servicios con `Future.wait`, y `setLoaded(isEmpty: services.isEmpty)`. `selectCategory(String? id)` actualiza la selección y recarga **solo** los servicios con `getServices(categoryId: id)`. Errores → `setFailed(e)`.
5. `ServicesTab` (widget en `services_tab.dart`): se auto-provee el VM (patrón 2.3) y muestra: fila horizontal de `AppChoiceChip` ("Todos" + categorías), y la lista de servicios con `ServiceCard` (sin `onSelect`: el botón no aplica aquí). Envuelve cada tarjeta en `InkWell` con `Semantics(button: true)` para abrir la hoja del paso 6. Estado vacío: "No hay servicios en esta categoría."
6. `ServiceSpecialistsViewModel(SpecialistRepository)` + `ServiceSpecialistsSheet` (bottom sheet con `showModalBottomSheet`, `useSafeArea`, radio superior `AppSpacing.radiusSheet`): lista `SpecialistCard` de quienes ofrecen el servicio (`getSpecialistsByService`). Al tocar uno: captura `final router = GoRouter.of(context)`, cierra la hoja (`Navigator.pop`) y haz `router.push(AppRoutes.book(s.id, serviceId: service.id))` (la reserva llega con el servicio preseleccionado). Vacío: "Aún no hay especialistas para este servicio."
7. `SpecialistsPage`: envuelve el `Scaffold` en `DefaultTabController(length: 2)`; `AppBar.bottom: TabBar` con "Por especialistas" y "Por servicios"; `TabBarView` con (a) el cuerpo actual extraído a un widget privado `_SpecialistsTab` (misma lógica de búsqueda/refresh/estados, usando el `SpecialistListViewModel` del router) y (b) `ServicesTab()`. Título genérico: "Especialistas y servicios".

**Parte C — Home**
8. `HomeViewModel(OrganizationRepository, ServiceRepository, SpecialistRepository)`: `organization`, `categories`, `featuredServices` (primeros 4 de `getServices()`), `topSpecialists` (de `getSpecialists()` ordenados por `avgRating` desc., máx. 5). `load()` usa `Future.wait` de las 4 consultas; un solo `status` (si algo falla → error con reintento); vacío si no hay servicios ni especialistas.
9. `HomePage` (const, se auto-provee): `ListView` dentro de `ResponsiveCenter` y `RefreshIndicator(onRefresh: vm.load)`. Secciones: hero (nombre y tagline de la organización con `textTheme.headlineLarge/bodyLarge`, `AppButton('Explorar servicios')` → `context.go(AppRoutes.specialists)`), `SectionHeader('Categorías')` con chips, `SectionHeader('Servicios destacados', actionLabel: 'Ver todos')`, `SectionHeader('Especialistas destacados')` con `SpecialistCard` → `context.go(AppRoutes.specialistDetail(id))`. Usa **`go`** (no `push`) al cruzar de pestaña, para que el shell cambie de rama correctamente. Símbolo de moneda: función privada `_symbol(org.currency)` (`'USD'` → `r'$'`) pasada a `ServiceCard(currencySymbol:)`.
10. Elimina el uso de `PlaceholderPage` en Home. Ningún texto del rubro: todo viene de la BD o es genérico.

**Parte D — Pruebas y documento**
11. `HomeViewModel`: carga ok (orden por `avgRating`, máx. 5), vacío, error de red → `canRetry` true → reintento exitoso. `ServiceListViewModel`: carga, `selectCategory` llama `getServices(categoryId:)` con el id correcto, vacío, error. `ServiceSpecialistsViewModel`: datos/vacío/error.
12. `docs/modules/home-servicios.md`: pantallas, VMs, repos usados, el método nuevo, decisiones (p. ej. por qué `go` y no `push`), capturas.

## 4. Criterios de aceptación y pruebas QA
**Funcional**
- [ ] Home muestra organización, categorías, hasta 4 servicios y hasta 5 especialistas (datos del `seed.sql`), sin textos de uñas/belleza.
- [ ] Pestaña "Por especialistas": búsqueda, pull-to-refresh y tarjetas → perfil (`/specialists/:id`).
- [ ] Pestaña "Por servicios": chips filtran; al tocar un servicio se abre la hoja con sus especialistas; elegir uno abre la reserva con ese servicio preseleccionado (`?serviceId=`).
- [ ] Servicio 1 → solo Especialista 1; servicio 2 → ambos; servicio 3 → solo Especialista 2 (coincide con `seed.sql`).
- [ ] Botón atrás del sistema desde detalle/reserva vuelve a la pantalla de origen sin salir de la app.

**Estados (`AsyncStateView`) — verifícalos uno por uno**
- [ ] *Carga:* indicador visible al abrir/refrescar. *Datos:* listas pobladas. 
- [ ] *Vacío:* en SQL Editor crea una categoría sin servicios (`insert into categories(organization_id,name) values ('00000000-0000-0000-0000-000000000001','Vacía');`) y selecciónala → mensaje de vacío. Para la hoja, un servicio sin especialistas.
- [ ] *Error + Reintentar:* ver pruebas sin conexión.

**Pruebas manuales sin conexión**
1. Modo avión **antes** de abrir Home → mensaje "Sin conexión…" y botón **Reintentar**; reactiva la red y pulsa Reintentar → carga datos.
2. Con datos ya cargados, modo avión y arrastra para refrescar → error con reintento; **no deben quedar datos viejos "fantasma" como si fueran nuevos** (no hay caché: la app muestra el error).
3. Cierra y reabre la app sin red: la sesión se restaura (almacén seguro) pero los datos **no** aparecen (no hay offline).

**Pruebas unitarias (mocktail):** los 3 archivos del paso 11 en verde; incluye casos de error y reintento.

**Antes del PR:** `flutter analyze`, `flutter test`, `bash tool/audit.sh`; `git grep -n "Placeholder" lib/features/home` debe quedar vacío; revisa que no tocaste archivos fuera de la tabla 2.1.
