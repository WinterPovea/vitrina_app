# Tareas para el equipo (v2 — reparto final entre 5 integrantes)

Integrante 1 ejecutó la base e infraestructura (**T0**). Los Integrantes 2–5 se reparten el resto. **T6 (Mis turnos) y T7 (QA: mocktail, accesibilidad, diseño adaptable) quedaron unificados en un solo módulo.** Cada integrante trabaja en su rama `feature/<modulo>` y solo toca los archivos que se le asignan (ver [PLAN_DE_TRABAJO.md](PLAN_DE_TRABAJO.md) y `docs/prompts/`).

| Id | Módulo | Responsable | Rama | Pantallas / archivos principales | Rúbrica |
|---|---|---|---|---|---|
| T0 | Base e infraestructura (hecho) + integración final + documento consolidado | Integrante 1 | `main` | `core/**`, `supabase/**`, `docs/**` | 2, 4, 5 |
| T1+T2 | **Home + Servicios con pestañas** | Integrante 2 | `feature/home-services` | `home_page.dart`, `specialists_page.dart` (pestañas), `services/presentation/**` | 1, 3, 5 |
| T3+T4 | **Perfil de especialista + Reseñas** | Integrante 3 | `feature/specialist-profile-reviews` | `specialist_detail_page.dart`, `reviews/presentation/**` | 1, 3, 5 |
| T5 | **Reservar turno** (transacción) | Integrante 4 | `feature/booking` | `booking_page.dart` + VM/widgets `booking_*` | 1, 3, 5 |
| T6+T7 | **Mis turnos + QA** (pruebas mocktail, accesibilidad, diseño adaptable, auditoría) | Integrante 5 | `feature/my-appointments-qa` | `appointments_page.dart` + VM/widgets, `test/**` transversal | 1, 3, 5 + bonus (+1.0) |
| T8 | Documento Word | Todos | — | cada quien redacta `docs/modules/<modulo>.md`; Integrante 1 consolida | 6 |

## Orden de integración a `main`
1. Integrante 2 → 2. Integrante 3 → 3. Integrante 4 → 4. Integrante 5 (último: audita e integra el formulario de reseñas). Las ramas 2–4 son independientes entre sí; el orden solo evita rebases innecesarios.

## Carga equilibrada (estimación)
| Integrante | Pantallas | ViewModels | Pruebas | Extra |
|---|---|---|---|---|
| 2 | Home, pestañas Servicios, hoja "especialistas del servicio" | 3 | 3 archivos | 1 método nuevo en repositorio |
| 3 | Perfil, lista de reseñas, formulario de reseña | 4 | 4 archivos | contacto WhatsApp/llamada |
| 4 | Reserva (servicio → fecha → hora → notas) | 1 (complejo) | 1–2 archivos | control de concurrencia de huecos |
| 5 | Mis turnos | 1 | 6+ archivos transversales | auditoría, accesibilidad, adaptable, informe QA |
