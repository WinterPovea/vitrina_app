# Flujo de trabajo del equipo

La rúbrica penaliza con **100 % menos** a quien no registre participación en el repositorio: **cada integrante debe tener commits propios.**

1. `main` siempre compila (`flutter analyze` + `flutter test` en verde). Nadie hace push directo a `main`.
2. Una rama por tarea: `feature/<tarea>` (ej. `feature/booking-page`).
3. Commits pequeños y descriptivos, en imperativo: `Agrega SlotPicker con TimeSlotChip`.
4. Pull Request a `main` con revisión de al menos otra persona. Checklist del PR:
   - [ ] `flutter analyze` sin errores · [ ] `flutter test` en verde
   - [ ] Sin claves, tokens ni `env/dev.json` en el diff
   - [ ] La pantalla muestra carga, datos, vacío y error con reintento
   - [ ] Respeta [docs/CONVENTIONS.md](docs/CONVENTIONS.md)
5. Cada quien debe poder explicar **cualquier capa** en la demostración (lo evalúa el docente).
