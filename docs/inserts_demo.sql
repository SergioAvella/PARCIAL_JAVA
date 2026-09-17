-- =====================================================================
-- INSERTS DEMO - inmobiliaria_db
-- Datos de prueba para cita, solicitud y favorito
-- Usuarios existentes con rol CLIENTE: 3 (cliente1@email.com),
-- 4 (cliente2@email.com) y 5 (luis.hernandez@email.com).
-- Propiedades existentes: ids 1 a 10.
--
-- NOTA sobre el esquema real simplificado:
--   cita      : id_cita, id_propiedad, id_usuario, fecha_hora, estado
--                estado ENUM('PENDIENTE','CONFIRMADA','CANCELADA','REALIZADA')
--   solicitud : id_solicitud, id_propiedad, id_usuario, tipo_solicitud,
--               estado, fecha_creacion
--                tipo_solicitud ENUM('COMPRA','ARRIENDO')
--                estado ENUM('PENDIENTE','APROBADO','RECHAZADO')
--   favorito  : id_usuario, id_propiedad (PK compuesta)
-- =====================================================================
USE inmobiliaria_db;

-- ---------------------------------------------------------------------
-- favorito (id_usuario, id_propiedad)
-- ---------------------------------------------------------------------
INSERT IGNORE INTO favorito (id_usuario, id_propiedad) VALUES
(3, 1),
(3, 2),
(3, 5),
(3, 6),
(3, 8),
(4, 3),
(4, 4),
(5, 7),
(5, 9);

-- ---------------------------------------------------------------------
-- solicitud (id_propiedad, id_usuario, tipo_solicitud, estado)
-- ---------------------------------------------------------------------
INSERT INTO solicitud (id_propiedad, id_usuario, tipo_solicitud, estado) VALUES
(1, 3, 'COMPRA',    'APROBADO'),
(2, 3, 'ARRIENDO',  'PENDIENTE'),
(3, 3, 'COMPRA',    'PENDIENTE'),
(5, 3, 'ARRIENDO',  'RECHAZADO'),
(1, 4, 'COMPRA',    'PENDIENTE'),
(4, 4, 'ARRIENDO',  'APROBADO'),
(2, 5, 'COMPRA',    'PENDIENTE'),
(6, 5, 'ARRIENDO',  'PENDIENTE');

-- ---------------------------------------------------------------------
-- cita (id_propiedad, id_usuario, fecha_hora, estado)
-- Se eligen fechas futuras (nov/2026) distintas de las ya registradas
-- para no violar el índice único (id_propiedad, fecha_hora).
-- ---------------------------------------------------------------------
INSERT IGNORE INTO cita (id_propiedad, id_usuario, fecha_hora, estado) VALUES
(2, 3, '2026-11-03 09:00:00', 'PENDIENTE'),
(4, 3, '2026-11-05 10:30:00', 'CONFIRMADA'),
(5, 3, '2026-11-08 15:00:00', 'PENDIENTE'),
(3, 3, '2026-11-15 09:30:00', 'REALIZADA'),
(3, 4, '2026-11-10 11:00:00', 'PENDIENTE'),
(6, 5, '2026-11-12 16:30:00', 'CONFIRMADA');

-- ---------------------------------------------------------------------
-- Verificación rápida
-- ---------------------------------------------------------------------
SELECT 'favorito'   AS tabla, COUNT(*) AS filas FROM favorito
UNION ALL SELECT 'solicitud', COUNT(*) FROM solicitud
UNION ALL SELECT 'cita',      COUNT(*) FROM cita;