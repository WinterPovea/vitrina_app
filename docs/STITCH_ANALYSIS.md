# Análisis del diseño generado por Stitch

Archivos: `design/DESIGN.md` y 3 pantallas HTML (`stitch_home`, `stitch_specialists_services`, `stitch_specialist_profile_booking`).

## Veredicto general
El diseño es **sólido y totalmente viable en Flutter**: no hay nada que requiera librerías raras. Lo que parece complejo casi siempre se resuelve con un widget estándar del propio Material. Los mayores riesgos no son visuales sino de **alcance** (querer construir todo) y de **datos** (el mockup asume cosas que hay que modelar).

## Hallazgos que hay que corregir antes de programar
1. **Está atado a un rubro** (salón de uñas: "Velvet & Polish", "Acrílico", "Nail Art"). Para que la base sea reutilizable, nada de eso queda en el código: categorías, servicios y textos salen de la BD.
2. **Inconsistencias de Stitch:** el `DESIGN.md` se llama "Lumière & Vernis" y los HTML "Velvet & Polish"; el frontmatter define `primary #500121` pero la prosa y los HTML usan `#6D1A36`; el fondo es `#fdf9f6` en un sitio y `#FAF6F3` en otro; precios `$32.00` vs `$32.000`. **Decisión:** se usa la paleta en prosa (`#6D1A36`, `#FAF6F3`…) → `lib/core/config/brand.dart`; el nombre lo define `Brand.appName`.
3. **Datos de ejemplo hardcodeados** (calendario "Marzo 2025", reseñas, fotos). Todo se reemplaza por datos remotos.
4. El HTML usa Tailwind/CSS: **no se copia código**, solo se toma como referencia visual.

## Pantalla por pantalla

### 1) Home (`stitch_home`)
| Elemento | Decisión | Cómo |
|---|---|---|
| Hero con título y botón "Explorar servicios" | ✅ Implementar | `Container` + texto Bodoni + `FilledButton` |
| Carrusel de categorías (Tendencias, Ofertas…) | ✅ Simplificar | Chips horizontales desde la tabla `categories`; "Ofertas/Tendencias" son solo categorías |
| Servicios estrella (precio, duración, rating, "2 turnos hoy") | ✅ Simplificar | `ServiceCard`; "turnos hoy" se omite en v1 (requiere consultar disponibilidad por servicio) |
| Especialistas del mes | ✅ Implementar | `SpecialistCard`, ordenados por `avg_rating` |
| "100% Garantía", badges "TOP", "Disponible hoy" | ⏸ Opcional | Texto estático o derivado después |

### 2) Especialistas y Servicios (`stitch_specialists_services`)
| Elemento | Decisión | Cómo |
|---|---|---|
| Pestañas "Por especialistas / Por servicios" | ✅ Implementar | `TabBar` con 2 listas. **Es lo que demuestra las 2 entidades maestras de la rúbrica** |
| Búsqueda + chips de filtro | ✅ Implementar | Ya existe en `SpecialistsPage` (búsqueda); chips con `AppChoiceChip` + `categoryId` |
| Tarjeta de especialista (rating, reseñas) | ✅ Implementar | Hecha: `SpecialistCard` |
| "Próximo turno: Hoy 16:30" / badges "Inmediato", "Último cupo" | ⏸ Diferir | Requiere consultar huecos de cada especialista (N consultas). Alternativa simple: botón "Ver horarios" que lleva al perfil |
| Mini-portafolio de 3 fotos por tarjeta + "32 fotos" | ⏸ Diferir | Necesita tabla de fotos y Supabase Storage. v1: una sola foto de perfil/`image_url` |
| Favoritos (corazón) | ❌ Descartar en v1 | Tabla extra y estado extra, sin valor para la rúbrica |
| Banner "Protocolo de esterilización" | ❌ Descartar | Específico del rubro; si una organización lo quiere, va como texto en `organizations` |

### 3) Perfil + reserva (`stitch_specialist_profile_booking`)
| Elemento | Decisión | Cómo |
|---|---|---|
| Cabecera del especialista (foto, rating, años, bio) | ✅ Implementar | Datos ya en `specialist_overview` |
| Lista de servicios con duración/precio y selección | ✅ Simplificar | **Un servicio por turno** (no multi-selección). Evita sumar duraciones y huecos combinados |
| Tira de fechas (14 días) + horas disponibles | ✅ Implementar | `ListView` horizontal + `TimeSlotChip`; huecos desde el RPC `get_available_slots` (ya hecho y probado) |
| "Disponibilidad en vivo" | ✅ Simplificar | Consulta al abrir + pull-to-refresh. Realtime de Supabase queda como mejora futura |
| Botón WhatsApp / Llamar (botón dividido) | ✅ Implementar | `url_launcher` (`Launchers.whatsapp/call`): muy fácil y muy vistoso |
| Reseñas (estrellas, texto, "cliente verificada") | ✅ Implementar | Lista simple; "verificada" es real: solo se reseña un turno completado |
| Lookbook (galería de trabajos) | ⏸ Diferir | Misma razón que el portafolio: Storage + tabla. Si sobra tiempo, `Image.network` con URLs |
| Barra inferior "Apartar cita • Mar 15, 11:30 AM" | ✅ Implementar | `bottomNavigationBar` con `AppButton`, deshabilitado hasta elegir hora |

## Efectos visuales: qué simplificar
| Efecto de Stitch | Alternativa en Flutter |
|---|---|
| Glassmorphism (`backdrop-filter: blur`) | **Evitarlo**: es costoso en gama baja. Usar `Colors.white` con alpha 0.9 |
| Máscara de arco en avatares (`border-radius: 40px 40px 16px 16px`) | `ClipRRect` con `BorderRadius.vertical(top: Radius.circular(40))` si se quiere; el círculo (`AvatarImage`) basta |
| Sombras difusas tintadas | `BoxShadow` suave o ninguna (la tarjeta ya lleva borde hairline) |
| Etiqueta flotante en inputs | Nativa: `InputDecoration.labelText` |
| Carrusel con snap | `ListView` horizontal o `PageView(viewportFraction: .85)` |
| Bodoni Moda + Plus Jakarta Sans | `google_fonts` (ya configurado en el tema) |

## Resultado para el alcance
**v1 (lo que se evalúa):** Sign up/in, Home básico, lista Especialistas/Servicios (2 maestras), Perfil de especialista, Reservar turno (transacción), Mis turnos, contacto WhatsApp, reseñas.
**v2 (si sobra tiempo / bonus):** filtros por categoría, "próximo turno" en tarjetas, fotos de trabajos, diseño adaptable, accesibilidad.
**Fuera:** favoritos, multi-servicio por turno, realtime, glassmorphism.
