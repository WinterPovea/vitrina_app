# Tareas para el equipo

Cada tarea = una rama y un PR. Cada una reutiliza la capa de datos y los widgets ya hechos. Copia el patrón de `SpecialistsPage` + `SpecialistListViewModel`.

| Tarea | Pantalla / archivo | Usa | Notas |
|---|---|---|---|
| T1 Home | `home/presentation/pages/home_page.dart` | Organization, Category, Specialist, Service repos | Un `HomeViewModel` con varios fetch |
| T2 Servicios + pestañas | nueva `services/presentation/` | `ServiceRepository`, `ServiceCard`, `AppChoiceChip` | Convertir `SpecialistsPage` en pestañas "Por especialistas / Por servicios" |
| T3 Perfil de especialista | `specialist_detail_page.dart` | `getSpecialist`, `getServicesBySpecialist`, `Launchers` | Botón WhatsApp/llamar |
| T4 Reseñas | `reviews/presentation/` | `ReviewRepository` | Lista en el perfil; formulario de reseña desde "Mis turnos" |
| T5 Reservar turno | `booking_page.dart` | `getAvailableSlots`, `BookAppointmentUseCase`, `TimeSlotChip` | Manejar error de horario tomado |
| T6 Mis turnos | `appointments_page.dart` | `getMyAppointments`, `cancel` | Estados y cancelación |
| T7 Calidad | `test/`, accesibilidad, horizontal | — | Bonus (+1.0) |
| T8 Documento Word | — | docs/ | Todos lo suben al aula |
