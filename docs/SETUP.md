# Guía de configuración e inicio rápido — Vitrina App

La base de datos y los servicios de autenticación del proyecto ya están desplegados en la nube (**Supabase**) con todas sus tablas, reglas de seguridad y datos de prueba cargados.

* **No necesitas crear una cuenta en Supabase** ni ejecutar los scripts `.sql` (`0001_init.sql` o `seed.sql`).
* Todos los usuarios, reservas y cambios que realice cada integrante se sincronizan en tiempo real sobre el mismo entorno compartido.
* La carpeta `android/` ya viene generada y configurada en este repositorio, por lo que no es necesario ejecutar `tool/setup.sh`.

---

## Puesta en marcha (3 pasos únicos)

Tras clonar el repositorio en tu computadora, realiza esta configuración una sola vez:

### 1. Configurar las credenciales de entorno (`env/dev.json`)
Por seguridad, las llaves de conexión no se suben a GitHub.

1. Abre la carpeta `env/` en la raíz del proyecto.
2. Haz una copia del archivo plantilla `dev.example.json` y renómbrala exactamente a **`dev.json`**.
3. Abre `env/dev.json` y pega los 3 valores (`SUPABASE_URL`, `SUPABASE_ANON_KEY` y `ORG_ID`) que **Winter** compartió por privado con el equipo:

```json
{
  "SUPABASE_URL": "PEGAR_SUPABASE_URL_AQUI",
  "SUPABASE_ANON_KEY": "PEGAR_SUPABASE_ANON_KEY_AQUI",
  "ORG_ID": "PEGAR_ORG_ID_AQUI"
}
```

> **Regla de seguridad:** Nunca subas `env/dev.json` al repositorio ni modifiques `env/dev.example.json`. El archivo `env/dev.json` ya está bloqueado en `.gitignore` para evitar filtraciones accidentales.

---

### 2. Descargar las dependencias de Flutter
Abre la terminal de Visual Studio Code en la raíz del proyecto (`vitrina_app`) y ejecuta:

```bash
flutter pub get
```

*(Opcional)* Para comprobar que tu entorno local reconoce el proyecto sin errores de compilación:

```bash
flutter analyze
```

---

### 3. Ejecutar la aplicación
Con un emulador Android encendido o un teléfono físico conectado por cable USB (con la *Depuración USB* activada), inicia la aplicación pasando el archivo de entorno:

```bash
flutter run --dart-define-from-file=env/dev.json
```

> **Importante:** No ejecutes la app usando únicamente `flutter run` ni el botón *Run / Play* por defecto de VS Code sin configurar este parámetro, ya que la aplicación no recibirá las credenciales de Supabase y bloqueará el arranque.

---

## Verificación rápida de funcionamiento

1. Al abrir la aplicación por primera vez, entra a la opción de **registrarse (Sign Up)**.
2. Ingresa un correo de prueba y una contraseña de al menos 6 caracteres.
3. El sistema creará tu perfil automáticamente con el rol de cliente (`client`), iniciará sesión y mostrará los especialistas cargados desde Supabase.
4. Si cierras la aplicación por completo y vuelves a abrirla, tu sesión permanecerá activa.

---

## Flujo de trabajo para el desarrollo de módulos

Antes de empezar a programar tu tarea asignada:

1. **Crea tu rama asignada desde `main` actualizada** (nunca trabajes ni hagas *push* directo sobre `main`):
   ```bash
   git switch main && git pull && git switch -c <nombre-de-tu-rama>
   ```
   * **Integrante 2 (Home + Servicios):** `feature/home-services`
   * **Integrante 3 (Perfil + Reseñas):** `feature/specialist-profile-reviews`
   * **Integrante 4 (Reservar turno):** `feature/booking`
   * **Integrante 5 (Mis turnos + QA):** `feature/my-appointments-qa`

2. **Revisa tu guía detallada y la matriz de archivos:**
   * Consulta **`docs/PLAN_DE_TRABAJO.md`** y **`docs/TEAM_TASKS.md`** para verificar qué archivos tienes asignados y cuáles están congelados (`core/`, `shared/widgets/`, router, providers) para evitar conflictos de *merge*.
   * Abre tu prompt específico dentro de **`docs/prompts/`** y sigue sus instrucciones paso a paso.

3. **Respeta la arquitectura y reglas del proyecto:**
   * Revisa **`docs/ARCHITECTURE.md`** y **`docs/CONVENTIONS.md`** para mantener el flujo MVVM (`Page → ViewModel → Repository → ApiService`), el uso de `AsyncStateView` / `BaseViewModel` y los criterios de la rúbrica.
   * Toma como plantilla funcional la pantalla **`SpecialistsPage`** y su **`SpecialistListViewModel`**, que ya están conectados a Supabase.

4. **Verifica tu código antes de abrir el Pull Request:**
   Asegúrate de actualizar contra `main` y pasar los tres controles obligatorios sin errores:
   ```bash
   git fetch && git rebase origin/main
   flutter analyze && flutter test && bash tool/audit.sh
   ```