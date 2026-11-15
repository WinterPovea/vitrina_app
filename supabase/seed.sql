-- Datos de demostración. UUID fijo para poder usarlo como ORG_ID en env/dev.json
insert into public.organizations (id, name, tagline, whatsapp, currency, timezone)
values ('00000000-0000-0000-0000-000000000001', 'Organización Demo',
        'Tu vitrina de servicios', '593999999999', 'USD', 'America/Guayaquil');

insert into public.categories (id, organization_id, name, sort_order) values
 ('10000000-0000-0000-0000-000000000001','00000000-0000-0000-0000-000000000001','Categoría A',1),
 ('10000000-0000-0000-0000-000000000002','00000000-0000-0000-0000-000000000001','Categoría B',2);

insert into public.specialists (id, organization_id, display_name, title, bio, years_experience, whatsapp) values
 ('20000000-0000-0000-0000-000000000001','00000000-0000-0000-0000-000000000001','Especialista Uno','Título profesional','Biografía de ejemplo.',5,'593999999999'),
 ('20000000-0000-0000-0000-000000000002','00000000-0000-0000-0000-000000000001','Especialista Dos','Título profesional','Biografía de ejemplo.',3,'593999999999');

insert into public.services (id, organization_id, category_id, name, description, duration_minutes, price) values
 ('30000000-0000-0000-0000-000000000001','00000000-0000-0000-0000-000000000001','10000000-0000-0000-0000-000000000001','Servicio 1','Descripción de ejemplo',60,25.00),
 ('30000000-0000-0000-0000-000000000002','00000000-0000-0000-0000-000000000001','10000000-0000-0000-0000-000000000001','Servicio 2','Descripción de ejemplo',90,40.00),
 ('30000000-0000-0000-0000-000000000003','00000000-0000-0000-0000-000000000001','10000000-0000-0000-0000-000000000002','Servicio 3','Descripción de ejemplo',30,15.00);

insert into public.specialist_services (specialist_id, service_id, price_override) values
 ('20000000-0000-0000-0000-000000000001','30000000-0000-0000-0000-000000000001',null),
 ('20000000-0000-0000-0000-000000000001','30000000-0000-0000-0000-000000000002',45.00),
 ('20000000-0000-0000-0000-000000000002','30000000-0000-0000-0000-000000000002',null),
 ('20000000-0000-0000-0000-000000000002','30000000-0000-0000-0000-000000000003',null);

-- Lunes a sábado 09:00-18:00 para ambos especialistas
insert into public.specialist_schedules (specialist_id, weekday, start_time, end_time)
select s.id, d, '09:00', '18:00'
from public.specialists s, generate_series(1,6) d;
