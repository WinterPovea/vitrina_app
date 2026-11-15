# Rúbrica → dónde se cumple

| # | Criterio (pts) | Estado | Dónde |
|---|---|---|---|
| 1 | Interfaz y navegación (1.5) | 🟡 base lista | `core/router/app_router.dart`: rutas, parámetros de ruta (`:id`) y query (`serviceId`), redirect protegido. Faltan pantallas: ver TEAM_TASKS |
| 2 | Autenticación y sesión (2.0) | ✅ hecho | Sign up/in/out reales con Supabase Auth; sesión restaurada y guardada con `SecureSessionStorage`; rutas protegidas por `AuthViewModel` |
| 3 | Datos remotos y modelo (2.5) | 🟡 capa lista | Maestras `specialists`, `services`; transaccional `appointments`; repositorios completos. Falta UI de consulta/registro |
| 4 | Clean Architecture, MVVM, Repository (2.0) | ✅ hecho | Ver docs/ARCHITECTURE.md; DI en `core/di/app_providers.dart` |
| 5 | Estado, validación y errores (1.0) | ✅ base | `BaseViewModel`, `AsyncStateView`, `Validators`, `AppException` + reintento |
| 6 | Documento y demostración (1.0) | 🟡 | Esta documentación sirve de insumo para el documento Word (cada integrante debe subirlo) |
| + | Adaptable (+0.4) | 🟡 | `ResponsiveCenter`; probar en horizontal |
| + | Pruebas (+0.3) | ✅ base | `test/`: VM, caso de uso, validadores (con mocktail, sin API) |
| + | Accesibilidad (+0.3) | 🟡 | Semantics en widgets compartidos; verificar contraste y 48 dp en pantallas nuevas |

## Guion de la demo (5 min)
1. *Problema* (1 min): vitrina + turnos para organizaciones.
2. *En vivo* (2 min): Sign up → ver especialistas y servicios → reservar turno → "Mis turnos" (datos desde Supabase) → apagar datos/Wi-Fi para mostrar error + Reintentar.
3. *Código* (2 min): `app_router.dart` → `SpecialistListViewModel` → contrato/implementación de repositorio → `ApiService` → `SecureSessionStorage` (sesión) y por qué no hay datos offline.
