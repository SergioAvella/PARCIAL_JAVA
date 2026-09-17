-- =====================================================================
-- SISTEMA INMOBILIARIA UTS - Script DDL + DML
-- Motor: MySQL 8.x  |  Charset: utf8mb4  |  Engine: InnoDB
-- =====================================================================

DROP DATABASE IF EXISTS inmobiliaria_db;
CREATE DATABASE inmobiliaria_db
    DEFAULT CHARACTER SET utf8mb4
    DEFAULT COLLATE utf8mb4_unicode_ci;
USE inmobiliaria_db;

SET FOREIGN_KEY_CHECKS = 0;

-- =====================================================================
-- 1. DDL - DEFINICION DE TABLAS
-- =====================================================================

-- ---------------------------------------------------------------------
-- Tabla: rol
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS rol;
CREATE TABLE rol (
    id_rol          INT UNSIGNED    NOT NULL AUTO_INCREMENT,
    nombre_rol      VARCHAR(50)     NOT NULL,
    descripcion     VARCHAR(150)    NOT NULL,
    activo          TINYINT(1)      NOT NULL DEFAULT 1,
    PRIMARY KEY (id_rol),
    UNIQUE KEY uq_rol_nombre_rol (nombre_rol)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- Tabla: usuario
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS usuario;
CREATE TABLE usuario (
    id_usuario      INT UNSIGNED    NOT NULL AUTO_INCREMENT,
    correo          VARCHAR(120)    NOT NULL,
    contrasena      VARCHAR(100)    NOT NULL,
    estado          ENUM('ACTIVO','INACTIVO','BLOQUEADO') NOT NULL DEFAULT 'ACTIVO',
    fecha_registro  DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ultimo_acceso   DATETIME                 DEFAULT NULL,
    PRIMARY KEY (id_usuario),
    UNIQUE KEY uq_usuario_correo (correo),
    KEY idx_usuario_estado (estado)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- Tabla: perfil  (Relacion 1:1 con usuario -> UNIQUE en id_usuario)
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS perfil;
CREATE TABLE perfil (
    id_perfil           INT UNSIGNED    NOT NULL AUTO_INCREMENT,
    id_usuario          INT UNSIGNED    NOT NULL,
    nombres             VARCHAR(80)     NOT NULL,
    apellidos           VARCHAR(80)     NOT NULL,
    documento           VARCHAR(30)              DEFAULT NULL,
    telefono            VARCHAR(20)              DEFAULT NULL,
    fecha_nacimiento    DATE                     DEFAULT NULL,
    direccion           VARCHAR(150)             DEFAULT NULL,
    foto_url            VARCHAR(255)             DEFAULT NULL,
    biografia           VARCHAR(300)             DEFAULT NULL,
    sitio_web           VARCHAR(150)             DEFAULT NULL,
    actualizado_en      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id_perfil),
    UNIQUE KEY uq_perfil_usuario (id_usuario),
    CONSTRAINT fk_perfil_usuario FOREIGN KEY (id_usuario)
        REFERENCES usuario (id_usuario) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- Tabla intermedia N:M: usuario_rol  (PK compuesta)
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS usuario_rol;
CREATE TABLE usuario_rol (
    id_usuario      INT UNSIGNED    NOT NULL,
    id_rol          INT UNSIGNED    NOT NULL,
    asignado_en     DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_usuario, id_rol),
    CONSTRAINT fk_usuario_rol_usuario FOREIGN KEY (id_usuario)
        REFERENCES usuario (id_usuario) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_usuario_rol_rol FOREIGN KEY (id_rol)
        REFERENCES rol (id_rol) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- Tabla: ciudad
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS ciudad;
CREATE TABLE ciudad (
    id_ciudad       INT UNSIGNED    NOT NULL AUTO_INCREMENT,
    nombre          VARCHAR(80)     NOT NULL,
    departamento    VARCHAR(80)     NOT NULL,
    codigo_dane     VARCHAR(10)     NOT NULL,
    PRIMARY KEY (id_ciudad),
    UNIQUE KEY uq_ciudad_codigo (codigo_dane),
    UNIQUE KEY uq_ciudad_nombre_dep (nombre, departamento)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- Tabla: tipo_propiedad
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS tipo_propiedad;
CREATE TABLE tipo_propiedad (
    id_tipo         INT UNSIGNED    NOT NULL AUTO_INCREMENT,
    nombre          VARCHAR(60)     NOT NULL,
    descripcion     VARCHAR(150)    NOT NULL,
    PRIMARY KEY (id_tipo),
    UNIQUE KEY uq_tipo_nombre (nombre)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- Tabla: inmobiliaria
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS inmobiliaria;
CREATE TABLE inmobiliaria (
    id_inmobiliaria INT UNSIGNED    NOT NULL AUTO_INCREMENT,
    id_usuario      INT UNSIGNED    NOT NULL,
    id_ciudad       INT UNSIGNED    NOT NULL,
    nombre          VARCHAR(120)    NOT NULL,
    nit             VARCHAR(20)     NOT NULL,
    correo          VARCHAR(120)             DEFAULT NULL,
    telefono        VARCHAR(20)              DEFAULT NULL,
    direccion       VARCHAR(150)             DEFAULT NULL,
    estado          ENUM('ACTIVA','INACTIVA','SUSPENDIDA') NOT NULL DEFAULT 'ACTIVA',
    fecha_registro  DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_inmobiliaria),
    UNIQUE KEY uq_inmobiliaria_nit (nit),
    KEY idx_inmobiliaria_usuario (id_usuario),
    KEY idx_inmobiliaria_ciudad (id_ciudad),
    CONSTRAINT fk_inmobiliaria_usuario FOREIGN KEY (id_usuario)
        REFERENCES usuario (id_usuario) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_inmobiliaria_ciudad FOREIGN KEY (id_ciudad)
        REFERENCES ciudad (id_ciudad) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- Tabla: propiedad  (1:N desde inmobiliaria)
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS propiedad;
CREATE TABLE propiedad (
    id_propiedad            INT UNSIGNED    NOT NULL AUTO_INCREMENT,
    id_inmobiliaria         INT UNSIGNED    NOT NULL,
    id_ciudad               INT UNSIGNED    NOT NULL,
    id_tipo                 INT UNSIGNED    NOT NULL,
    titulo                  VARCHAR(150)    NOT NULL,
    descripcion              VARCHAR(500)            DEFAULT NULL,
    direccion               VARCHAR(180)    NOT NULL,
    matricula_inmobiliaria  VARCHAR(40)     NOT NULL,
    precio                  DECIMAL(14,2)   NOT NULL,
    area_m2                 DECIMAL(10,2)   NOT NULL,
    habitaciones            TINYINT UNSIGNED NOT NULL DEFAULT 0,
    banos                   TINYINT UNSIGNED NOT NULL DEFAULT 0,
    estrato                 TINYINT UNSIGNED NOT NULL DEFAULT 1,
    estado                  ENUM('DISPONIBLE','RESERVADA','VENDIDA','ARRIENDADA','INACTIVA') NOT NULL DEFAULT 'DISPONIBLE',
    fecha_publicacion       DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_propiedad),
    UNIQUE KEY uq_propiedad_matricula (matricula_inmobiliaria),
    KEY idx_propiedad_inmobiliaria (id_inmobiliaria),
    KEY idx_propiedad_ciudad (id_ciudad),
    KEY idx_propiedad_tipo (id_tipo),
    KEY idx_propiedad_estado_precio (estado, precio),
    CONSTRAINT fk_propiedad_inmobiliaria FOREIGN KEY (id_inmobiliaria)
        REFERENCES inmobiliaria (id_inmobiliaria) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_propiedad_ciudad FOREIGN KEY (id_ciudad)
        REFERENCES ciudad (id_ciudad) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_propiedad_tipo FOREIGN KEY (id_tipo)
        REFERENCES tipo_propiedad (id_tipo) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- Tabla: imagen_propiedad  (1:N desde propiedad)
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS imagen_propiedad;
CREATE TABLE imagen_propiedad (
    id_imagen       INT UNSIGNED    NOT NULL AUTO_INCREMENT,
    id_propiedad    INT UNSIGNED    NOT NULL,
    url             VARCHAR(255)    NOT NULL,
    descripcion     VARCHAR(150)             DEFAULT NULL,
    es_principal    TINYINT(1)      NOT NULL DEFAULT 0,
    orden           TINYINT UNSIGNED NOT NULL DEFAULT 0,
    fecha_carga     DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_imagen),
    KEY idx_imagen_propiedad (id_propiedad),
    CONSTRAINT fk_imagen_propiedad FOREIGN KEY (id_propiedad)
        REFERENCES propiedad (id_propiedad) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- Tabla: caracteristica
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS caracteristica;
CREATE TABLE caracteristica (
    id_caracteristica   INT UNSIGNED    NOT NULL AUTO_INCREMENT,
    nombre              VARCHAR(60)     NOT NULL,
    icono               VARCHAR(60)              DEFAULT NULL,
    PRIMARY KEY (id_caracteristica),
    UNIQUE KEY uq_caracteristica_nombre (nombre)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- Tabla intermedia N:M: propiedad_caracteristica  (PK compuesta)
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS propiedad_caracteristica;
CREATE TABLE propiedad_caracteristica (
    id_propiedad        INT UNSIGNED    NOT NULL,
    id_caracteristica   INT UNSIGNED    NOT NULL,
    PRIMARY KEY (id_propiedad, id_caracteristica),
    CONSTRAINT fk_propcar_propiedad FOREIGN KEY (id_propiedad)
        REFERENCES propiedad (id_propiedad) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_propcar_caracteristica FOREIGN KEY (id_caracteristica)
        REFERENCES caracteristica (id_caracteristica) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- Tabla: cita  (UNIQUE en id_propiedad + fecha_hora)
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS cita;
CREATE TABLE cita (
    id_cita         INT UNSIGNED    NOT NULL AUTO_INCREMENT,
    id_propiedad    INT UNSIGNED    NOT NULL,
    id_usuario      INT UNSIGNED    NOT NULL,
    fecha_hora      DATETIME        NOT NULL,
    estado          ENUM('PENDIENTE','APROBADA','RECHAZADA','CANCELADA','REALIZADA') NOT NULL DEFAULT 'PENDIENTE',
    observaciones   VARCHAR(300)             DEFAULT NULL,
    fecha_creacion  DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_cita),
    UNIQUE KEY uq_cita_propiedad_fecha (id_propiedad, fecha_hora),
    KEY idx_cita_usuario (id_usuario),
    KEY idx_cita_estado (estado),
    CONSTRAINT fk_cita_propiedad FOREIGN KEY (id_propiedad)
        REFERENCES propiedad (id_propiedad) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_cita_usuario FOREIGN KEY (id_usuario)
        REFERENCES usuario (id_usuario) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- Tabla: solicitud
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS solicitud;
CREATE TABLE solicitud (
    id_solicitud        INT UNSIGNED    NOT NULL AUTO_INCREMENT,
    id_usuario          INT UNSIGNED    NOT NULL,
    id_propiedad        INT UNSIGNED    NOT NULL,
    tipo                ENUM('ARRIENDO','COMPRA','VISITA','AVALUO') NOT NULL,
    estado              ENUM('RADICADA','EN_REVISION','APROBADA','RECHAZADA','CERRADA') NOT NULL DEFAULT 'RADICADA',
    observaciones       VARCHAR(300)             DEFAULT NULL,
    fecha_solicitud     DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_respuesta     DATETIME                 DEFAULT NULL,
    PRIMARY KEY (id_solicitud),
    KEY idx_solicitud_usuario (id_usuario),
    KEY idx_solicitud_propiedad (id_propiedad),
    KEY idx_solicitud_estado (estado),
    CONSTRAINT fk_solicitud_usuario FOREIGN KEY (id_usuario)
        REFERENCES usuario (id_usuario) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_solicitud_propiedad FOREIGN KEY (id_propiedad)
        REFERENCES propiedad (id_propiedad) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- Tabla: documento_solicitud
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS documento_solicitud;
CREATE TABLE documento_solicitud (
    id_documento    INT UNSIGNED    NOT NULL AUTO_INCREMENT,
    id_solicitud    INT UNSIGNED    NOT NULL,
    nombre          VARCHAR(120)    NOT NULL,
    url             VARCHAR(255)    NOT NULL,
    tipo            ENUM('PDF','IMAGEN','OTRO') NOT NULL DEFAULT 'PDF',
    estado          ENUM('PENDIENTE','APROBADO','RECHAZADO') NOT NULL DEFAULT 'PENDIENTE',
    fecha_carga     DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_documento),
    KEY idx_documento_solicitud (id_solicitud),
    CONSTRAINT fk_documento_solicitud FOREIGN KEY (id_solicitud)
        REFERENCES solicitud (id_solicitud) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- Tabla: favorito
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS favorito;
CREATE TABLE favorito (
    id_favorito     INT UNSIGNED    NOT NULL AUTO_INCREMENT,
    id_usuario      INT UNSIGNED    NOT NULL,
    id_propiedad    INT UNSIGNED    NOT NULL,
    fecha_agregado  DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_favorito),
    UNIQUE KEY uq_favorito_usuario_propiedad (id_usuario, id_propiedad),
    KEY idx_favorito_propiedad (id_propiedad),
    CONSTRAINT fk_favorito_usuario FOREIGN KEY (id_usuario)
        REFERENCES usuario (id_usuario) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_favorito_propiedad FOREIGN KEY (id_propiedad)
        REFERENCES propiedad (id_propiedad) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- Tabla: auditoria
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS auditoria;
CREATE TABLE auditoria (
    id_auditoria    BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    id_usuario      INT UNSIGNED             DEFAULT NULL,
    tabla_afectada  VARCHAR(60)     NOT NULL,
    accion          ENUM('INSERT','UPDATE','DELETE','LOGIN','LOGOUT') NOT NULL,
    descripcion     VARCHAR(300)             DEFAULT NULL,
    ip_origen       VARCHAR(45)              DEFAULT NULL,
    fecha_evento    DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_auditoria),
    KEY idx_auditoria_usuario (id_usuario),
    KEY idx_auditoria_tabla (tabla_afectada),
    KEY idx_auditoria_fecha (fecha_evento),
    CONSTRAINT fk_auditoria_usuario FOREIGN KEY (id_usuario)
        REFERENCES usuario (id_usuario) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

SET FOREIGN_KEY_CHECKS = 1;

-- =====================================================================
-- 2. DML - DATOS DE PRUEBA (minimo 10 registros por tabla)
-- =====================================================================

-- ---------------------------------------------------------------------
-- rol (10)
-- ---------------------------------------------------------------------
INSERT INTO rol (id_rol, nombre_rol, descripcion) VALUES
(1,  'Administrador',     'Control total del sistema y configuracion global'),
(2,  'Inmobiliaria',      'Gestiona propiedades, citas y solicitudes propias'),
(3,  'Cliente',           'Busca inmuebles, agenda citas y radica solicitudes'),
(4,  'Moderador',         'Revisa y modera publicaciones e imagenes'),
(5,  'Auditor',           'Consulta reportes y bitacora de auditoria'),
(6,  'Soporte',           'Atiende incidencias de usuarios y accesos'),
(7,  'Superadministrador','Administracion avanzada y gestion de roles'),
(8,  'Analista',          'Analiza metricas y comportamiento comercial'),
(9,  'Publicador',        'Crea y actualiza contenido de propiedades'),
(10, 'Invitado',          'Acceso de solo lectura a la landing publica');

-- ---------------------------------------------------------------------
-- usuario (10)  | contrasena = SHA-256 hexadecimal de "password"
-- SHA-256("password") = 5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8
-- ---------------------------------------------------------------------
INSERT INTO usuario (id_usuario, correo, contrasena, estado, fecha_registro, ultimo_acceso) VALUES
(1,  'admin@inmobiliariauts.com', '5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8', 'ACTIVO',   '2024-01-05 08:00:00', '2024-06-01 09:15:00'),
(2,  'carlos.ramirez@inmoandes.com', '5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8', 'ACTIVO', '2024-01-10 09:30:00', '2024-06-02 10:20:00'),
(3,  'laura.gomez@urbanacol.com', '5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8', 'ACTIVO', '2024-01-12 11:00:00', '2024-06-03 08:45:00'),
(4,  'ana.torres@gmail.com', '5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8', 'ACTIVO', '2024-02-01 14:20:00', '2024-06-04 16:10:00'),
(5,  'pedro.lopez@gmail.com', '5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8', 'ACTIVO', '2024-02-05 15:45:00', '2024-06-05 12:00:00'),
(6,  'marta.sanchez@auditoria.com', '5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8', 'ACTIVO', '2024-02-10 10:10:00', '2024-06-06 09:00:00'),
(7,  'luis.herrera@soporte.com', '5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8', 'ACTIVO', '2024-02-15 08:00:00', '2024-06-07 11:30:00'),
(8,  'sofia.castro@gmail.com', '5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8', 'INACTIVO', '2024-03-01 13:25:00', '2024-05-20 17:40:00'),
(9,  'jorge.medina@gmail.com', '5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8', 'ACTIVO', '2024-03-08 16:00:00', '2024-06-08 14:15:00'),
(10, 'diana.rojas@propiar.com', '5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8', 'ACTIVO', '2024-03-15 09:50:00', '2024-06-09 10:05:00');

-- ---------------------------------------------------------------------
-- usuario_rol (N:M) (12)
-- ---------------------------------------------------------------------
INSERT INTO usuario_rol (id_usuario, id_rol, asignado_en) VALUES
(1,  1,  '2024-01-05 08:05:00'),
(1,  7,  '2024-01-05 08:05:00'),
(2,  2,  '2024-01-10 09:35:00'),
(2,  9,  '2024-01-10 09:35:00'),
(3,  2,  '2024-01-12 11:05:00'),
(4,  3,  '2024-02-01 14:25:00'),
(5,  3,  '2024-02-05 15:50:00'),
(6,  5,  '2024-02-10 10:15:00'),
(7,  6,  '2024-02-15 08:05:00'),
(8,  3,  '2024-03-01 13:30:00'),
(9,  3,  '2024-03-08 16:05:00'),
(10, 2,  '2024-03-15 09:55:00');

-- ---------------------------------------------------------------------
-- perfil (10)  | Relacion 1:1 con usuario
-- ---------------------------------------------------------------------
INSERT INTO perfil (id_perfil, id_usuario, nombres, apellidos, documento, telefono, direccion, fecha_nacimiento, foto_url, biografia, sitio_web) VALUES
(1,  1, 'Miguel',       'Angel Restrepo', 'CC-10203040', '3101112233', 'Calle 12 # 4-56, Bogota',        '1985-04-12', '/uploads/perfiles/admin.jpg',  'Administrador general del sistema inmobiliario UTS', 'https://inmobiliariauts.com'),
(2,  2, 'Carlos Andres','Ramirez Pena',   'CC-20304050', '3102223344', 'Carrera 7 # 45-10, Bogota',      '1988-07-25', '/uploads/perfiles/carlos.jpg', 'Agente inmobiliario con 10 anos de experiencia',     'https://inmoandes.com'),
(3,  3, 'Laura',        'Gomez Ruiz',     'CC-30405060', '3103334455', 'Avenida 68 # 22-33, Medellin',   '1990-02-18', '/uploads/perfiles/laura.jpg',  'Asesora de propiedad raiz en el eje cafetero',       'https://urbanacol.com'),
(4,  4, 'Ana Maria',    'Torres Lozano',  'CC-40506070', '3104445566', 'Calle 100 # 15-20, Bogota',      '1995-11-03', '/uploads/perfiles/ana.jpg',    'Cliente interesada en vivienda familiar',            NULL),
(5,  5, 'Pedro',        'Lopez Marin',    'CC-50607080', '3105556677', 'Transversal 5 # 8-40, Cali',     '1992-06-30', '/uploads/perfiles/pedro.jpg',  'Cliente buscando inversion en arriendos',            NULL),
(6,  6, 'Marta',        'Sanchez Duque',  'CC-60708090', '3106667788', 'Carrera 43 # 12-05, Medellin',   '1983-09-14', '/uploads/perfiles/marta.jpg',  'Auditora de procesos internos',                      NULL),
(7,  7, 'Luis',         'Herrera Gil',    'CC-70809000', '3107778899', 'Calle 30 # 6-18, Barranquilla',  '1991-01-22', '/uploads/perfiles/luis.jpg',   'Analista de soporte tecnico',                        NULL),
(8,  8, 'Sofia',        'Castro Nino',    'CC-80900010', '3108889900', 'Carrera 50 # 70-15, Medellin',   '1998-05-08', '/uploads/perfiles/sofia.jpg',  'Cliente interesada en apartaestudios',               NULL),
(9,  9, 'Jorge',        'Medina Vela',    'CC-90010020', '3109990011', 'Calle 19 # 3-45, Cartagena',     '1987-12-01', '/uploads/perfiles/jorge.jpg',  'Inversionista en propiedades comerciales',           NULL),
(10, 10,'Diana',        'Rojas Marin',    'CC-10111213', '3110001122', 'Carrera 15 # 88-60, Bogota',     '1994-08-17', '/uploads/perfiles/diana.jpg',  'Agente especializada en vivienda campestre',         'https://propiar.com');

-- ---------------------------------------------------------------------
-- ciudad (10)
-- ---------------------------------------------------------------------
INSERT INTO ciudad (id_ciudad, nombre, departamento, codigo_dane) VALUES
(1,  'Bogota',       'Cundinamarca',      '11001'),
(2,  'Medellin',     'Antioquia',         '05001'),
(3,  'Cali',         'Valle del Cauca',   '76001'),
(4,  'Barranquilla', 'Atlantico',         '08001'),
(5,  'Cartagena',    'Bolivar',           '13001'),
(6,  'Bucaramanga',  'Santander',         '68001'),
(7,  'Cucuta',       'Norte de Santander','54001'),
(8,  'Pereira',      'Risaralda',         '66001'),
(9,  'Manizales',    'Caldas',            '17001'),
(10, 'Ibague',       'Tolima',            '73001');

-- ---------------------------------------------------------------------
-- tipo_propiedad (10)
-- ---------------------------------------------------------------------
INSERT INTO tipo_propiedad (id_tipo, nombre, descripcion) VALUES
(1,  'Apartamento',       'Unidad residencial en edificio o conjunto'),
(2,  'Casa',              'Vivienda unifamiliar independiente'),
(3,  'Casa Campestre',    'Vivienda con amplias zonas verdes fuera de la ciudad'),
(4,  'Apartaestudio',     'Unidad compacta con espacio integrado'),
(5,  'Local Comercial',   'Espacio para actividades comerciales'),
(6,  'Oficina',           'Espacio para uso administrativo o profesional'),
(7,  'Bodega',            'Espacio amplio para almacenamiento o logistica'),
(8,  'Lote',              'Terreno sin construccion para desarrollo'),
(9,  'Finca',             'Predio rural con vocacion agricola o recreativa'),
(10, 'Parqueadero',       'Espacio de estacionamiento vehicular');

-- ---------------------------------------------------------------------
-- inmobiliaria (10)
-- ---------------------------------------------------------------------
INSERT INTO inmobiliaria (id_inmobiliaria, id_usuario, id_ciudad, nombre, nit, correo, telefono, direccion, estado, fecha_registro) VALUES
(1,  2,  1,  'Inmobiliaria Andes S.A.S',        'NIT-900111222-1', 'contacto@inmoandes.com',    '6015551010', 'Calle 72 # 10-34, Bogota',        'ACTIVA', '2024-01-11 09:00:00'),
(2,  3,  2,  'Urbana Colombia Ltda.',           'NIT-900222333-2', 'contacto@urbanacol.com',    '6045552020', 'Carrera 43A # 1-50, Medellin',     'ACTIVA', '2024-01-13 10:00:00'),
(3,  10, 1,  'Propiar Inversiones S.A.S',       'NIT-900333444-3', 'contacto@propiar.com',      '6015553030', 'Carrera 15 # 88-60, Bogota',       'ACTIVA', '2024-03-16 09:30:00'),
(4,  2,  1,  'MetroCasa Bienes Raices',         'NIT-900444555-4', 'info@metrocasa.com',        '6015554040', 'Avenida 19 # 114-20, Bogota',      'ACTIVA', '2024-01-20 11:15:00'),
(5,  2,  8,  'Andes Inversiones Inmobiliarias', 'NIT-900555666-5', 'ventas@andesi.com',         '6065555050', 'Carrera 8 # 20-44, Pereira',       'ACTIVA', '2024-02-02 08:45:00'),
(6,  3,  2,  'Ciudad Real Propiedades',         'NIT-900666777-6', 'contacto@ciudadreal.com',   '6045556060', 'Calle 50 # 40-10, Medellin',       'ACTIVA', '2024-02-11 14:00:00'),
(7,  10, 3,  'Hogar Total S.A.S',               'NIT-900777888-7', 'info@hogartotal.com',       '6025557070', 'Avenida 6N # 23-40, Cali',         'ACTIVA', '2024-02-18 15:30:00'),
(8,  3,  5,  'Torres y Asociados',              'NIT-900888999-8', 'contacto@torresasoc.com',   '6055558080', 'Bocagrande Cra 1 # 5-20, Cartagena','ACTIVA','2024-03-01 09:10:00'),
(9,  2,  6,  'Grupo Elite Inmobiliario',        'NIT-900999000-9', 'info@grupoelite.com',       '6075559090', 'Calle 35 # 12-30, Bucaramanga',    'INACTIVA','2024-03-12 10:40:00'),
(10, 10, 4,  'Capital Raiz S.A.S',              'NIT-901000111-0', 'contacto@capitalraiz.com',  '6055550101', 'Calle 84 # 45-12, Barranquilla',   'ACTIVA', '2024-03-25 12:00:00');

-- ---------------------------------------------------------------------
-- propiedad (10)  | 1:N desde inmobiliaria
-- ---------------------------------------------------------------------
INSERT INTO propiedad (id_propiedad, id_inmobiliaria, id_ciudad, id_tipo, titulo, descripcion, direccion, matricula_inmobiliaria, precio, area_m2, habitaciones, banos, estrato, estado, fecha_publicacion) VALUES
(1,  1,  1, 1,  'Apartamento moderno en el norte',      'Amplio apartamento con excelente iluminacion natural', 'Calle 116 # 15-30, Bogota', 'MAT-BOG-0001', 450000000.00, 95.50, 3, 2, 5, 'DISPONIBLE', '2024-03-01 09:00:00'),
(2,  1,  1, 2,  'Casa familiar en Suba',                'Casa de dos pisos con patio y garaje doble',           'Carrera 92 # 145-12, Bogota','MAT-BOG-0002', 620000000.00, 180.00, 4, 3, 4, 'DISPONIBLE', '2024-03-05 10:30:00'),
(3,  2,  2, 1,  'Apartamento en El Poblado',            'Vista panoramica y acabados de lujo',                  'Carrera 34 # 7-50, Medellin','MAT-MED-0003', 530000000.00, 110.00, 3, 2, 6, 'RESERVADA',  '2024-03-08 11:00:00'),
(4,  2,  2, 3,  'Casa campestre en Envigado',           'Rodeada de naturaleza con zona BBQ',                   'Vereda El Vallano, Medellin','MAT-MED-0004', 890000000.00, 340.00, 5, 4, 6, 'DISPONIBLE', '2024-03-12 13:20:00'),
(5,  3,  1, 4,  'Apartaestudio cerca a la universidad', 'Ideal para estudiantes, servicios incluidos',          'Calle 45 # 20-15, Bogota',  'MAT-BOG-0005', 180000000.00, 42.00,  1, 1, 3, 'DISPONIBLE', '2024-03-15 08:40:00'),
(6,  4,  1, 5,  'Local comercial en zona rosa',         'Alto flujo peatonal, excelente vitrina',               'Zona Rosa Calle 85, Bogota','MAT-BOG-0006', 750000000.00, 120.00, 0, 2, 6, 'DISPONIBLE', '2024-03-18 16:00:00'),
(7,  5,  8, 9,  'Finca cafetera productiva',            'Tierra fertil con casa principal y cultivos',          'Vereda La Florida, Pereira','MAT-PER-0007', 1200000000.00, 5000.00, 6, 3, 3, 'DISPONIBLE', '2024-03-22 09:15:00'),
(8,  6,  2, 6,  'Oficina ejecutiva en centro empresarial','Espacio moderno con recepcion y sala de juntas',     'Carrera 43A # 16-38, Medellin','MAT-MED-0008', 390000000.00, 78.00, 0, 2, 5, 'DISPONIBLE', '2024-03-25 10:00:00'),
(9,  7,  3, 2,  'Casa moderna en Ciudad Jardin',        'Diseño contemporaneo con amplios espacios',            'Calle 15 # 100-22, Cali',   'MAT-CAL-0009', 480000000.00, 165.00, 4, 3, 5, 'VENDIDA',    '2024-03-28 14:30:00'),
(10, 10, 4, 7,  'Bodega industrial en zona franca',     'Acceso para tractomula y altura de almacenamiento',    'Zona Franca, Barranquilla', 'MAT-BAQ-0010', 950000000.00, 800.00, 0, 2, 4, 'DISPONIBLE', '2024-04-02 08:50:00');

-- ---------------------------------------------------------------------
-- imagen_propiedad (10)  | 1:N desde propiedad
-- ---------------------------------------------------------------------
INSERT INTO imagen_propiedad (id_imagen, id_propiedad, url, descripcion, es_principal, orden, fecha_carga) VALUES
(1,  1,  '/uploads/propiedades/prop1-fachada.jpg',  'Fachada principal',           1, 1, '2024-03-01 09:10:00'),
(2,  1,  '/uploads/propiedades/prop1-sala.jpg',     'Sala comedor iluminada',      0, 2, '2024-03-01 09:11:00'),
(3,  2,  '/uploads/propiedades/prop2-fachada.jpg',  'Fachada de la casa',          1, 1, '2024-03-05 10:40:00'),
(4,  3,  '/uploads/propiedades/prop3-balcon.jpg',   'Balcon con vista panoramica', 1, 1, '2024-03-08 11:10:00'),
(5,  4,  '/uploads/propiedades/prop4-jardin.jpg',   'Jardin y zona BBQ',           1, 1, '2024-03-12 13:30:00'),
(6,  5,  '/uploads/propiedades/prop5-interior.jpg', 'Apartaestudio amoblado',      1, 1, '2024-03-15 08:50:00'),
(7,  6,  '/uploads/propiedades/prop6-vitrina.jpg',  'Vitrina comercial',           1, 1, '2024-03-18 16:10:00'),
(8,  7,  '/uploads/propiedades/prop7-casa.jpg',     'Casa principal de la finca',  1, 1, '2024-03-22 09:25:00'),
(9,  8,  '/uploads/propiedades/prop8-oficina.jpg',  'Oficina de recepcion',        1, 1, '2024-03-25 10:10:00'),
(10, 10, '/uploads/propiedades/prop10-bodega.jpg',  'Interior de la bodega',       1, 1, '2024-04-02 09:00:00');

-- ---------------------------------------------------------------------
-- caracteristica (10)
-- ---------------------------------------------------------------------
INSERT INTO caracteristica (id_caracteristica, nombre, icono) VALUES
(1,  'Piscina',              'fa-swimming-pool'),
(2,  'Jardin',               'fa-tree'),
(3,  'Balcon',               'fa-building'),
(4,  'Garaje',               'fa-car'),
(5,  'Ascensor',             'fa-sort'),
(6,  'Zona BBQ',             'fa-fire'),
(7,  'Vigilancia 24/7',      'fa-shield'),
(8,  'Gimnasio',             'fa-dumbbell'),
(9,  'Terraza',              'fa-sun'),
(10, 'Aire acondicionado',   'fa-snowflake');

-- ---------------------------------------------------------------------
-- propiedad_caracteristica (N:M) (24)
-- ---------------------------------------------------------------------
INSERT INTO propiedad_caracteristica (id_propiedad, id_caracteristica) VALUES
(1, 2), (1, 4), (1, 5), (1, 8),
(2, 2), (2, 4), (2, 6),
(3, 3), (3, 5), (3, 7),
(4, 1), (4, 2), (4, 6), (4, 9),
(5, 5), (5, 7),
(6, 4), (6, 7),
(7, 2), (7, 6), (7, 9),
(8, 5), (8, 7), (8, 10),
(10, 4), (10, 7);

-- ---------------------------------------------------------------------
-- cita (10)  | UNIQUE (id_propiedad, fecha_hora)
-- ---------------------------------------------------------------------
INSERT INTO cita (id_cita, id_propiedad, id_usuario, fecha_hora, estado, observaciones, fecha_creacion) VALUES
(1,  1,  4, '2024-06-10 10:00:00', 'APROBADA',  'Visita confirmada con el agente',        '2024-06-01 09:00:00'),
(2,  2,  5, '2024-06-10 15:00:00', 'PENDIENTE', 'Prefiere visita en la tarde',            '2024-06-02 10:30:00'),
(3,  3,  8, '2024-06-11 09:30:00', 'APROBADA',  'Cliente interesada en financiacion',     '2024-06-03 11:00:00'),
(4,  4,  9, '2024-06-11 16:00:00', 'PENDIENTE', 'Requiere acompañamiento de familia',     '2024-06-03 12:15:00'),
(5,  5,  4, '2024-06-12 08:00:00', 'REALIZADA', 'Visita realizada sin novedades',         '2024-06-04 08:00:00'),
(6,  6,  5, '2024-06-12 14:30:00', 'CANCELADA', 'El cliente cancela por temas laborales','2024-06-04 14:00:00'),
(7,  7,  9, '2024-06-13 10:30:00', 'PENDIENTE', 'Desea recorrer los cultivos',            '2024-06-05 09:20:00'),
(8,  8,  8, '2024-06-13 17:00:00', 'APROBADA',  'Visita a oficina con el administrador',  '2024-06-05 16:40:00'),
(9,  9,  4, '2024-06-14 11:00:00', 'RECHAZADA', 'Propiedad ya vendida segun el agente',   '2024-06-06 10:00:00'),
(10, 10, 5, '2024-06-14 15:30:00', 'PENDIENTE', 'Requiere revisar capacidad de carga',    '2024-06-06 11:30:00');

-- ---------------------------------------------------------------------
-- solicitud (10)
-- ---------------------------------------------------------------------
INSERT INTO solicitud (id_solicitud, id_usuario, id_propiedad, tipo, estado, observaciones, fecha_solicitud, fecha_respuesta) VALUES
(1,  4,  1,  'COMPRA',   'APROBADA',   'Solicitud de compra con credito hipotecario', '2024-06-01 09:30:00', '2024-06-05 10:00:00'),
(2,  5,  2,  'ARRIENDO', 'EN_REVISION','Interesado en arriendo por un ano',           '2024-06-02 10:45:00', NULL),
(3,  8,  3,  'COMPRA',   'RADICADA',   'Documentos en proceso de recoleccion',        '2024-06-03 11:15:00', NULL),
(4,  9,  4,  'VISITA',   'CERRADA',    'Visita completada, cliente decidira',         '2024-06-03 12:30:00', '2024-06-06 09:00:00'),
(5,  4,  5,  'ARRIENDO', 'APROBADA',   'Arriendo aprobado por 6 meses',               '2024-06-04 08:20:00', '2024-06-07 11:00:00'),
(6,  5,  6,  'ARRIENDO', 'RECHAZADA',  'No cumple con referencias comerciales',       '2024-06-04 14:10:00', '2024-06-08 09:30:00'),
(7,  9,  7,  'COMPRA',   'EN_REVISION','Estudio de titulos en curso',                 '2024-06-05 09:40:00', NULL),
(8,  8,  8,  'ARRIENDO', 'RADICADA',   'Pendiente de validacion de documentos',       '2024-06-05 17:00:00', NULL),
(9,  4,  9,  'COMPRA',   'RECHAZADA',  'Propiedad no disponible, estado vendida',     '2024-06-06 10:10:00', '2024-06-09 10:30:00'),
(10, 5,  10, 'ARRIENDO', 'EN_REVISION','Evaluando condiciones del contrato',          '2024-06-06 11:50:00', NULL);

-- ---------------------------------------------------------------------
-- documento_solicitud (10)
-- ---------------------------------------------------------------------
INSERT INTO documento_solicitud (id_documento, id_solicitud, nombre, url, tipo, estado, fecha_carga) VALUES
(1,  1,  'Cedula ciudadania',        '/uploads/documentos/sol1-cedula.pdf',      'PDF', 'APROBADO',  '2024-06-01 10:00:00'),
(2,  1,  'Certificado laboral',      '/uploads/documentos/sol1-laboral.pdf',     'PDF', 'APROBADO',  '2024-06-01 10:05:00'),
(3,  2,  'Certificado laboral',      '/uploads/documentos/sol2-laboral.pdf',     'PDF', 'PENDIENTE', '2024-06-02 11:00:00'),
(4,  3,  'Extractos bancarios',      '/uploads/documentos/sol3-bancarios.pdf',   'PDF', 'PENDIENTE', '2024-06-03 11:30:00'),
(5,  4,  'Cedula ciudadania',        '/uploads/documentos/sol4-cedula.pdf',      'PDF', 'APROBADO',  '2024-06-03 13:00:00'),
(6,  5,  'Contrato de arriendo',     '/uploads/documentos/sol5-contrato.pdf',    'PDF', 'APROBADO',  '2024-06-04 09:00:00'),
(7,  6,  'Referencias comerciales',  '/uploads/documentos/sol6-referencias.pdf','PDF', 'RECHAZADO', '2024-06-04 15:00:00'),
(8,  7,  'Certificado de tradicion', '/uploads/documentos/sol7-tradicion.pdf',  'PDF', 'PENDIENTE', '2024-06-05 10:00:00'),
(9,  8,  'Camara de comercio',       '/uploads/documentos/sol8-camara.pdf',      'PDF', 'PENDIENTE', '2024-06-05 17:30:00'),
(10, 10, 'Estados financieros',      '/uploads/documentos/sol10-financieros.pdf','PDF', 'PENDIENTE', '2024-06-06 12:30:00');

-- ---------------------------------------------------------------------
-- favorito (10)  | UNIQUE (id_usuario, id_propiedad)
-- ---------------------------------------------------------------------
INSERT INTO favorito (id_favorito, id_usuario, id_propiedad, fecha_agregado) VALUES
(1,  4,  1,  '2024-05-28 09:00:00'),
(2,  4,  5,  '2024-05-29 15:30:00'),
(3,  5,  2,  '2024-05-30 10:15:00'),
(4,  5,  6,  '2024-05-31 11:45:00'),
(5,  8,  3,  '2024-06-01 08:20:00'),
(6,  8,  4,  '2024-06-01 08:25:00'),
(7,  9,  7,  '2024-06-02 13:10:00'),
(8,  9,  10, '2024-06-02 13:15:00'),
(9,  4,  8,  '2024-06-03 16:40:00'),
(10, 5,  9,  '2024-06-04 12:00:00');

-- ---------------------------------------------------------------------
-- auditoria (10)
-- ---------------------------------------------------------------------
INSERT INTO auditoria (id_auditoria, id_usuario, tabla_afectada, accion, descripcion, ip_origen, fecha_evento) VALUES
(1,  1,  'usuario',    'LOGIN',  'Inicio de sesion del administrador',          '192.168.1.10', '2024-06-01 09:15:00'),
(2,  2,  'propiedad',  'INSERT', 'Publicacion de la propiedad MAT-BOG-0001',    '192.168.1.11', '2024-06-01 09:20:00'),
(3,  4,  'favorito',   'INSERT', 'Propiedad agregada a favoritos',              '190.25.10.5',  '2024-06-01 09:25:00'),
(4,  5,  'cita',       'INSERT', 'Cita agendada para el 2024-06-10 15:00',      '190.25.10.6',  '2024-06-02 10:30:00'),
(5,  3,  'solicitud',  'UPDATE', 'Solicitud marcada en revision',               '192.168.1.12', '2024-06-02 11:00:00'),
(6,  1,  'usuario',    'UPDATE', 'Cambio de estado de usuario a INACTIVO',      '192.168.1.10', '2024-06-03 08:00:00'),
(7,  9,  'cita',       'DELETE', 'Cita cancelada por el cliente',               '200.31.20.7',  '2024-06-04 14:00:00'),
(8,  6,  'reporte',    'LOGIN',  'Auditor consulta reportes consolidados',      '192.168.1.20', '2024-06-06 09:00:00'),
(9,  10, 'propiedad',  'UPDATE', 'Actualizacion de precio de MAT-BAQ-0010',     '192.168.1.13', '2024-06-08 10:05:00'),
(10, 4,  'solicitud',  'INSERT', 'Radicacion de solicitud de compra',           '190.25.10.5',  '2024-06-09 09:10:00');

-- =====================================================================
-- 3. VERIFICACION RAPIDA
-- =====================================================================
SELECT 'rol' AS tabla, COUNT(*) AS registros FROM rol
UNION ALL SELECT 'usuario', COUNT(*) FROM usuario
UNION ALL SELECT 'perfil', COUNT(*) FROM perfil
UNION ALL SELECT 'usuario_rol', COUNT(*) FROM usuario_rol
UNION ALL SELECT 'inmobiliaria', COUNT(*) FROM inmobiliaria
UNION ALL SELECT 'ciudad', COUNT(*) FROM ciudad
UNION ALL SELECT 'tipo_propiedad', COUNT(*) FROM tipo_propiedad
UNION ALL SELECT 'propiedad', COUNT(*) FROM propiedad
UNION ALL SELECT 'imagen_propiedad', COUNT(*) FROM imagen_propiedad
UNION ALL SELECT 'caracteristica', COUNT(*) FROM caracteristica
UNION ALL SELECT 'propiedad_caracteristica', COUNT(*) FROM propiedad_caracteristica
UNION ALL SELECT 'cita', COUNT(*) FROM cita
UNION ALL SELECT 'solicitud', COUNT(*) FROM solicitud
UNION ALL SELECT 'documento_solicitud', COUNT(*) FROM documento_solicitud
UNION ALL SELECT 'favorito', COUNT(*) FROM favorito
UNION ALL SELECT 'auditoria', COUNT(*) FROM auditoria;
