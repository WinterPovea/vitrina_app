# Adaptar la app a otra organización

| Qué cambia | Dónde |
|---|---|
| Datos (nombre, WhatsApp, moneda, zona horaria, catálogo, especialistas) | tablas en Supabase: insertar una fila en `organizations` y su catálogo |
| ID de la organización | `ORG_ID` en `env/*.json` (una app = una organización) |
| Colores y nombre de la app | `lib/core/config/brand.dart` |
| Tipografías | `lib/core/theme/app_theme.dart` |
| Logo / ícono / nombre en el launcher | `flutter_launcher_icons` (acordar en equipo) y `android/app/src/main/AndroidManifest.xml` |
| Textos específicos del rubro | Evitar hardcodearlos: leer de `organizations`/`categories`/`services` |

Para vender a varias organizaciones: un mismo proyecto de Supabase puede alojarlas a todas (aislamiento por RLS), o un proyecto por cliente. Compilar un APK por organización con su propio `env/<org>.json`:
`flutter build apk --dart-define-from-file=env/<org>.json`

> Regla de diseño: ningún texto, color ni imagen del rubro "uñas/belleza" (de los mockups de Stitch) debe quedar fijo en el código.
