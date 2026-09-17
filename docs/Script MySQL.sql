-- ==========================================
-- PASO 1: CREACIÓN DE LA BASE DE DATOS
-- ==========================================
DROP DATABASE IF EXISTS inmobiliaria_db;
CREATE DATABASE inmobiliaria_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE inmobiliaria_db;

-- ==========================================
-- ESTRUCTURA DE TABLAS (DDL)
-- ==========================================

-- 1. TABLA PRINCIPAL: USUARIO
CREATE TABLE usuario (
    id_usuario INT AUTO_INCREMENT PRIMARY KEY,
    correo VARCHAR(150) NOT NULL UNIQUE, -- Restricción UNIQUE obligatoria
    contrasena VARCHAR(255) NOT NULL, -- Guardará el Hash SHA-256
    estado ENUM('ACTIVO', 'INACTIVO', 'BLOQUEADO') DEFAULT 'ACTIVO',
    creado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. RELACIÓN 1:1: PERFIL (perfil almacena id_usuario como UNIQUE)
CREATE TABLE perfil (
    id_perfil INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT NOT NULL UNIQUE, -- Garantiza la relación 1:1 de forma estricta
    nombres VARCHAR(100) NOT NULL,
    apellidos VARCHAR(100) NOT NULL,
    documento VARCHAR(20) NOT NULL UNIQUE, -- UNIQUE para documento de identidad
    telefono VARCHAR(20),
    direccion VARCHAR(200),
    foto_url VARCHAR(255) DEFAULT 'default_user.png',
    CONSTRAINT fk_perfil_usuario FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario) ON DELETE CASCADE
);

-- 3. TABLA: ROL
CREATE TABLE rol (
    id_rol INT AUTO_INCREMENT PRIMARY KEY,
    nombre_rol VARCHAR(50) NOT NULL UNIQUE
);

-- 4. RELACIÓN N:M: USUARIO_ROL
CREATE TABLE usuario_rol (
    id_usuario INT NOT NULL,
    id_rol INT NOT NULL,
    PRIMARY KEY (id_usuario, id_rol),
    CONSTRAINT fk_ur_usuario FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario) ON DELETE CASCADE,
    CONSTRAINT fk_ur_rol FOREIGN KEY (id_rol) REFERENCES rol(id_rol) ON DELETE CASCADE
);

-- 5. TABLA: CIUDAD Y TIPO_PROPIEDAD (Necesarias para consultas JOIN y Filtros del Parcial)
CREATE TABLE ciudad (
    id_ciudad INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE tipo_propiedad (
    id_tipo INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL UNIQUE
);

-- 6. TABLA PRINCIPAL: INMOBILIARIA
CREATE TABLE inmobiliaria (
    id_inmobiliaria INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    nit VARCHAR(20) NOT NULL UNIQUE,
    telefono VARCHAR(20),
    direccion VARCHAR(200)
);

-- 7. TABLA: PROPIEDAD (Relaciones 1:N con Inmobiliaria, Ciudad y Tipo)
CREATE TABLE propiedad (
    id_propiedad INT AUTO_INCREMENT PRIMARY KEY,
    id_inmobiliaria INT NOT NULL,
    id_ciudad INT NOT NULL,
    id_tipo INT NOT NULL,
    titulo VARCHAR(150) NOT NULL,
    precio DECIMAL(12,2) NOT NULL,
    matricula_inmobiliaria VARCHAR(50) NOT NULL UNIQUE, -- Restricción UNIQUE obligatoria
    direccion VARCHAR(200) NOT NULL,
    estado ENUM('DISPONIBLE', 'VENDIDO', 'ARRENDADO', 'INACTIVO') DEFAULT 'DISPONIBLE',
    CONSTRAINT fk_prop_inmobiliaria FOREIGN KEY (id_inmobiliaria) REFERENCES inmobiliaria(id_inmobiliaria) ON DELETE CASCADE,
    CONSTRAINT fk_prop_ciudad FOREIGN KEY (id_ciudad) REFERENCES ciudad(id_ciudad),
    CONSTRAINT fk_prop_tipo FOREIGN KEY (id_tipo) REFERENCES tipo_propiedad(id_tipo)
);

-- 8. RELACIÓN 1:N: IMAGEN_PROPIEDAD
CREATE TABLE imagen_propiedad (
    id_imagen INT AUTO_INCREMENT PRIMARY KEY,
    id_propiedad INT NOT NULL,
    url VARCHAR(255) NOT NULL,
    es_principal BOOLEAN DEFAULT FALSE,
    CONSTRAINT fk_imagen_propiedad FOREIGN KEY (id_propiedad) REFERENCES propiedad(id_propiedad) ON DELETE CASCADE
);

-- 9. TABLA: CARACTERISTICA Y PROPIEDAD_CARACTERISTICA (N:M)
CREATE TABLE caracteristica (
    id_caracteristica INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE propiedad_caracteristica (
    id_propiedad INT NOT NULL,
    id_caracteristica INT NOT NULL,
    valor VARCHAR(100),
    PRIMARY KEY (id_propiedad, id_caracteristica),
    CONSTRAINT fk_pc_propiedad FOREIGN KEY (id_propiedad) REFERENCES propiedad(id_propiedad) ON DELETE CASCADE,
    CONSTRAINT fk_pc_caracteristica FOREIGN KEY (id_caracteristica) REFERENCES caracteristica(id_caracteristica) ON DELETE CASCADE
);

-- 10. TABLA: CITA (Restricción UNIQUE compuesta id_propiedad + fecha_hora)
CREATE TABLE cita (
    id_cita INT AUTO_INCREMENT PRIMARY KEY,
    id_propiedad INT NOT NULL,
    id_usuario INT NOT NULL,
    fecha_hora DATETIME NOT NULL,
    estado ENUM('PENDIENTE', 'CONFIRMADA', 'CANCELADA', 'REALIZADA') DEFAULT 'PENDIENTE',
    CONSTRAINT fk_cita_propiedad FOREIGN KEY (id_propiedad) REFERENCES propiedad(id_propiedad) ON DELETE CASCADE,
    CONSTRAINT fk_cita_usuario FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario) ON DELETE CASCADE,
    CONSTRAINT uq_propiedad_fechahora UNIQUE (id_propiedad, fecha_hora)
);

-- 11. TABLA: SOLICITUD Y DOCUMENTO_SOLICITUD (Gestión de Arriendos/Compras)
CREATE TABLE solicitud (
    id_solicitud INT AUTO_INCREMENT PRIMARY KEY,
    id_propiedad INT NOT NULL,
    id_usuario INT NOT NULL,
    tipo_solicitud ENUM('COMPRA', 'ARRIENDO') NOT NULL,
    estado ENUM('PENDIENTE', 'APROBADO', 'RECHAZADO') DEFAULT 'PENDIENTE',
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_sol_propiedad FOREIGN KEY (id_propiedad) REFERENCES propiedad(id_propiedad) ON DELETE CASCADE,
    CONSTRAINT fk_sol_usuario FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario) ON DELETE CASCADE
);

CREATE TABLE documento_solicitud (
    id_documento INT AUTO_INCREMENT PRIMARY KEY,
    id_solicitud INT NOT NULL,
    nombre_documento VARCHAR(100) NOT NULL,
    archivo_url VARCHAR(255) NOT NULL,
    CONSTRAINT fk_doc_solicitud FOREIGN KEY (id_solicitud) REFERENCES solicitud(id_solicitud) ON DELETE CASCADE
);

-- 12. TABLA: FAVORITO Y AUDITORIA
CREATE TABLE favorito (
    id_usuario INT NOT NULL,
    id_propiedad INT NOT NULL,
    PRIMARY KEY (id_usuario, id_propiedad),
    CONSTRAINT fk_fav_usuario FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario) ON DELETE CASCADE,
    CONSTRAINT fk_fav_propiedad FOREIGN KEY (id_propiedad) REFERENCES propiedad(id_propiedad) ON DELETE CASCADE
);

CREATE TABLE auditoria (
    id_auditoria INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT,
    accion VARCHAR(255) NOT NULL,
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ip VARCHAR(45)
);


-- ==========================================
-- POBLADO DE DATOS (INSERT - MÍNIMO 10 POR TABLA)
-- ==========================================

-- Contraseñas cifradas con SHA-256 (El valor 'ef797c8118f02dfb649607dd5d3f8c7623048c9c063d532cc95c5ed7a898a64f' equivale a '123456')
INSERT INTO usuario (correo, contrasena, estado) VALUES
('admin@inmobiliaria.com', 'ef797c8118f02dfb649607dd5d3f8c7623048c9c063d532cc95c5ed7a898a64f', 'ACTIVO'),
('agente@inmobiliaria.com', 'ef797c8118f02dfb649607dd5d3f8c7623048c9c063d532cc95c5ed7a898a64f', 'ACTIVO'),
('cliente1@email.com', 'ef797c8118f02dfb649607dd5d3f8c7623048c9c063d532cc95c5ed7a898a64f', 'ACTIVO'),
('cliente2@email.com', 'ef797c8118f02dfb649607dd5d3f8c7623048c9c063d532cc95c5ed7a898a64f', 'ACTIVO'),
('luis.hernandez@email.com', 'ef797c8118f02dfb649607dd5d3f8c7623048c9c063d532cc95c5ed7a898a64f', 'ACTIVO'),
('laura.diaz@email.com', 'ef797c8118f02dfb649607dd5d3f8c7623048c9c063d532cc95c5ed7a898a64f', 'ACTIVO'),
('diego.torres@email.com', 'ef797c8118f02dfb649607dd5d3f8c7623048c9c063d532cc95c5ed7a898a64f', 'ACTIVO'),
('sofia.ramirez@email.com', 'ef797c8118f02dfb649607dd5d3f8c7623048c9c063d532cc95c5ed7a898a64f', 'ACTIVO'),
('andres.castro@email.com', 'ef797c8118f02dfb649607dd5d3f8c7623048c9c063d532cc95c5ed7a898a64f', 'ACTIVO'),
('paula.morales@email.com', 'ef797c8118f02dfb649607dd5d3f8c7623048c9c063d532cc95c5ed7a898a64f', 'ACTIVO');

INSERT INTO perfil (id_usuario, nombres, apellidos, documento, telefono, direccion) VALUES
(1, 'Super', 'Admin', '100000001', '3000000000', 'Oficina Central'),
(2, 'María', 'Gómez', '100000002', '3012345678', 'Carrera 15 # 45-10'),
(3, 'Juan', 'Rodríguez', '100000003', '3023456789', 'Avenida 6 # 12-30'),
(4, 'Ana', 'Martínez', '100000004', '3034567890', 'Calle 80 # 11-25'),
(5, 'Luis', 'Hernández', '100000005', '3045678901', 'Carrera 7 # 32-50'),
(6, 'Laura', 'Díaz', '100000006', '3056789012', 'Calle 100 # 19-40'),
(7, 'Diego', 'Torres', '100000007', '3067890123', 'Diagonal 45 # 2-15'),
(8, 'Sofia', 'Ramírez', '100000008', '3078901234', 'Transversal 12 # 8-90'),
(9, 'Andrés', 'Castro', '100000009', '3089012345', 'Calle 53 # 24-11'),
(10, 'Paula', 'Morales', '100000010', '3090123456', 'Carrera 30 # 70-05');

INSERT INTO rol (nombre_rol) VALUES
('ADMINISTRADOR'), ('INMOBILIARIA'), ('CLIENTE'), ('VISITANTE');

INSERT INTO usuario_rol (id_usuario, id_rol) VALUES
(1, 1), (2, 2), (3, 3), (4, 3), (5, 3),
(6, 3), (7, 3), (8, 3), (9, 3), (10, 3);

INSERT INTO ciudad (nombre) VALUES
('Bucaramanga'), ('Bogotá'), ('Medellín'), ('Cali'), ('Barranquilla'),
('Floridablanca'), ('Girón'), ('Piedecuesta'), ('Cartagena'), ('Pereira');

INSERT INTO tipo_propiedad (nombre) VALUES
('Apartamento'), ('Casa'), ('Local'), ('Oficina'), ('Bodega'),
('Lote'), ('Penthouse'), ('Finca'), ('Apartaestudio'), ('Consultorio');

INSERT INTO inmobiliaria (nombre, nit, telefono, direccion) VALUES
('Inmobiliaria Central', '900123456-1', '6011234567', 'Av. Principal # 100'),
('Bienes Raíces Éxito', '900234567-2', '6012345678', 'Calle 50 # 20-30'),
('Hogares y Futuro', '900345678-3', '6013456789', 'Carrera 10 # 80-12'),
('Propiedades del Valle', '900456789-4', '6014567890', 'Diagonal 15 # 40-50'),
('Inversiones Urbana', '900567890-5', '6015678901', 'Calle 127 # 19-20'),
('Inmobiliaria Hábitat', '900678901-6', '6016789012', 'Carrera 15 # 93-40'),
('Casas y Lotes S.A.', '900789012-7', '6017890123', 'Av. Chile # 72-10'),
('Metro Inmobiliaria', '900890123-8', '6018901234', 'Calle 26 # 68-90'),
('Inmobiliaria Del Sol', '900901234-9', '6019012345', 'Carrera 7 # 116-50'),
('Global Real Estate', '901012345-0', '6010123456', 'Calle 90 # 14-26');

INSERT INTO propiedad (id_inmobiliaria, id_ciudad, id_tipo, titulo, precio, matricula_inmobiliaria, direccion, estado) VALUES
(1, 1, 1, 'Apartamento Moderno Cabecera', 350000000.00, 'MAT-001-2026', 'Calle 48 # 33-20', 'DISPONIBLE'),
(1, 1, 2, 'Casa en Cañaveral', 850000000.00, 'MAT-002-2026', 'Calle 30 # 25-10', 'DISPONIBLE'),
(2, 2, 7, 'Penthouse Vista Panorámica', 1200000000.00, 'MAT-003-2026', 'Carrera 7 # 85-10', 'DISPONIBLE'),
(3, 2, 4, 'Oficina Comercial Financiera', 450000000.00, 'MAT-004-2026', 'Calle 72 # 10-03', 'DISPONIBLE'),
(4, 3, 9, 'Apartaestudio El Poblado', 280000000.00, 'MAT-005-2026', 'Carrera 43A # 1-50', 'DISPONIBLE'),
(5, 1, 3, 'Local Comercial Centro', 950000000.00, 'MAT-006-2026', 'Calle 36 # 15-20', 'DISPONIBLE'),
(6, 6, 2, 'Casa Duplex en Ruitoque', 920000000.00, 'MAT-007-2026', 'Km 2 Vía Ruitoque', 'DISPONIBLE'),
(7, 7, 6, 'Lote Industrial Girón', 600000000.00, 'MAT-008-2026', 'Zona Industrial Chiamonte', 'DISPONIBLE'),
(8, 1, 1, 'Apartamento Familiar Sotomayor', 410000000.00, 'MAT-009-2026', 'Carrera 28 # 45-12', 'DISPONIBLE'),
(9, 8, 5, 'Bodega de Almacenamiento', 780000000.00, 'MAT-010-2026', 'Anillo Vial Km 3', 'DISPONIBLE');

INSERT INTO imagen_propiedad (id_propiedad, url, es_principal) VALUES
(1, 'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2', TRUE),
(1, 'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688', FALSE),
(2, 'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9', TRUE),
(3, 'https://images.unsplash.com/photo-1512917774080-9991f1c4c750', TRUE),
(4, 'https://images.unsplash.com/photo-1497366216548-37526070297c', TRUE),
(5, 'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267', TRUE),
(6, 'https://images.unsplash.com/photo-1441986300917-64674bd600d8', TRUE),
(7, 'https://images.unsplash.com/photo-1600585154340-be6161a56a0c', TRUE),
(8, 'https://images.unsplash.com/photo-1500382017468-9049fed747ef', TRUE),
(9, 'https://images.unsplash.com/photo-1545324418-cc1a3fa10c00', TRUE);

INSERT INTO caracteristica (nombre) VALUES
('Habitaciones'), ('Baños'), ('Parqueadero'),
('Ascensor'), ('Piscina'), ('Área (m2)'),
('Gimnasio'), ('Vigilancia 24/7'), ('Balcón'), ('Depósito');

INSERT INTO propiedad_caracteristica (id_propiedad, id_caracteristica, valor) VALUES
(1, 1, '3'), (1, 2, '2'), (1, 6, '85 m2'),
(2, 1, '4'), (2, 3, '2 Parqueaderos'), (2, 5, 'Si'),
(3, 1, '3'), (3, 4, 'Privado'), (3, 8, 'Si'),
(4, 6, '50 m2');

INSERT INTO cita (id_propiedad, id_usuario, fecha_hora, estado) VALUES
(1, 3, '2026-10-01 10:00:00', 'CONFIRMADA'),
(1, 4, '2026-10-01 11:00:00', 'PENDIENTE'),
(2, 5, '2026-10-01 10:00:00', 'CONFIRMADA'),
(3, 6, '2026-10-02 14:00:00', 'PENDIENTE'),
(4, 7, '2026-10-02 15:30:00', 'REALIZADA'),
(5, 8, '2026-10-03 09:00:00', 'CANCELADA'),
(6, 9, '2026-10-03 11:00:00', 'CONFIRMADA'),
(7, 10, '2026-10-04 16:00:00', 'PENDIENTE'),
(8, 3, '2026-10-05 10:30:00', 'CONFIRMADA'),
(9, 4, '2026-10-05 14:00:00', 'REALIZADA');