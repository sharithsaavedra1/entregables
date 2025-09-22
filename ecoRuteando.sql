
CREATE DATABASE IF NOT EXISTS ecoRuteando;
USE ecoRuteando;

CREATE TABLE USUARIOS (
    id_usuario INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    documento VARCHAR(50) UNIQUE NOT NULL,
    correo VARCHAR(100) UNIQUE NOT NULL,
    contraseña VARCHAR(255) NOT NULL,
    telefono VARCHAR(20),
    creado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE ALERTAS (
    id_alertas INT AUTO_INCREMENT PRIMARY KEY,
    titulo VARCHAR(150) NOT NULL,
    mensaje TEXT NOT NULL,
    tipo VARCHAR(50) NOT NULL,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NOT NULL,
    id_usuario INT NOT NULL,
    FOREIGN KEY (id_usuario) REFERENCES USUARIOS(id_usuario)
);

CREATE TABLE RUTAS (
    id_ruta INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL,
    descripcion TEXT,
    punto_inicio VARCHAR(150) NOT NULL,
    co2_ahorrado DECIMAL(10,2),
    tiempo_estimado_min INT,
    distancia_km DECIMAL(10,2),
    url_foto VARCHAR(255),
    fecha DATE NOT NULL,
    id_usuario INT NOT NULL,
    FOREIGN KEY (id_usuario) REFERENCES USUARIOS(id_usuario)
);

CREATE TABLE CALIFICACION (
    id_calificacion INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT NOT NULL,
    id_ruta INT NOT NULL,
    fecha DATE NOT NULL,
    comentario TEXT,
    calificacion INT CHECK (calificacion BETWEEN 1 AND 5),
    FOREIGN KEY (id_usuario) REFERENCES USUARIOS(id_usuario),
    FOREIGN KEY (id_ruta) REFERENCES RUTAS(id_ruta)
);

CREATE TABLE REPORTE_OBSTACULOS (
    id_reporte INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT NOT NULL,
    tipo VARCHAR(100) NOT NULL,
    descripcion TEXT NOT NULL,
    ubicacion VARCHAR(200) NOT NULL,
    url_foto VARCHAR(255),
    estado VARCHAR(50) DEFAULT 'pendiente',
    fecha DATE NOT NULL,
    FOREIGN KEY (id_usuario) REFERENCES USUARIOS(id_usuario)
);

CREATE TABLE USO_RUTAS (
    id_usuario INT NOT NULL,
    id_ruta INT NOT NULL,
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_usuario, id_ruta),
    FOREIGN KEY (id_usuario) REFERENCES USUARIOS(id_usuario),
    FOREIGN KEY (id_ruta) REFERENCES RUTAS(id_ruta)
);

CREATE TABLE RUTA_ALERTA (
    id_alertas INT NOT NULL,
    id_ruta INT NOT NULL,
    PRIMARY KEY (id_alertas, id_ruta),
    FOREIGN KEY (id_alertas) REFERENCES ALERTAS(id_alertas),
    FOREIGN KEY (id_ruta) REFERENCES RUTAS(id_ruta)
);

CREATE TABLE SEG_USUARIOS (
    id_usuario INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    estado ENUM('ACTIVO','INACTIVO','BLOQUEADO') DEFAULT 'ACTIVO',
    creado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE SEG_ROLES (
    id_rol INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) UNIQUE NOT NULL,
    descripcion VARCHAR(255)
);

CREATE TABLE SEG_PERMISOS (
    id_permiso INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) UNIQUE NOT NULL,
    descripcion VARCHAR(255)
);

CREATE TABLE SEG_USUARIO_ROL (
    id_usuario INT,
    id_rol INT,
    PRIMARY KEY (id_usuario, id_rol),
    FOREIGN KEY (id_usuario) REFERENCES SEG_USUARIOS(id_usuario),
    FOREIGN KEY (id_rol) REFERENCES SEG_ROLES(id_rol)
);

CREATE TABLE SEG_ROL_PERMISO (
    id_rol INT,
    id_permiso INT,
    PRIMARY KEY (id_rol, id_permiso),
    FOREIGN KEY (id_rol) REFERENCES SEG_ROLES(id_rol),
    FOREIGN KEY (id_permiso) REFERENCES SEG_PERMISOS(id_permiso)
);

CREATE TABLE SEG_AUDITORIA (
    id_auditoria INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT,
    accion VARCHAR(255) NOT NULL,
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ip_origen VARCHAR(45),
    FOREIGN KEY (id_usuario) REFERENCES SEG_USUARIOS(id_usuario)
);

CREATE TABLE SEG_POLITICAS (
    id_politica INT AUTO_INCREMENT PRIMARY KEY,
    longitud_min_contrasena INT DEFAULT 8,
    requiere_mayusculas BOOLEAN DEFAULT TRUE,
    requiere_numeros BOOLEAN DEFAULT TRUE,
    requiere_caracter_especial BOOLEAN DEFAULT TRUE,
    dias_expiracion INT DEFAULT 90,
    intentos_max_fallidos INT DEFAULT 5
);

CREATE TABLE SEG_SESIONES (
    id_sesion INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT,
    token VARCHAR(255) UNIQUE NOT NULL,
    ip VARCHAR(45),
    inicio TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fin TIMESTAMP NULL,
    FOREIGN KEY (id_usuario) REFERENCES SEG_USUARIOS(id_usuario)
);

CREATE TABLE SEG_LOG_ERRORES (
    id_error INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT NULL,
    mensaje TEXT NOT NULL,
    nivel ENUM('INFO','WARNING','ERROR','CRITICO') DEFAULT 'ERROR',
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_usuario) REFERENCES SEG_USUARIOS(id_usuario)
);

CREATE INDEX idx_usuario_doc ON USUARIOS(documento);
CREATE INDEX idx_ruta_fecha ON RUTAS(fecha);
CREATE INDEX idx_alerta_tipo ON ALERTAS(tipo);
CREATE INDEX idx_segusuario_estado ON SEG_USUARIOS(estado);

INSERT INTO USUARIOS (nombre, documento, correo, contraseña, telefono) VALUES
('Ana Gómez', '1001', 'ana@mail.com', '1234', '3001112233'),
('Luis Pérez', '1002', 'luis@mail.com', 'abcd', '3002223344');

INSERT INTO RUTAS (nombre, descripcion, punto_inicio, co2_ahorrado, tiempo_estimado_min, distancia_km, url_foto, fecha, id_usuario) VALUES
('Ruta Verde', 'Ciclovía centro', 'Plaza Central', 15.50, 30, 5.2, 'foto1.jpg', CURDATE(), 1),
('Ruta Río', 'Sendero junto al río', 'Parque del Río', 25.30, 45, 8.1, 'foto2.jpg', CURDATE(), 2);

INSERT INTO SEG_USUARIOS (username, email, password_hash) VALUES
('admin', 'admin@eco.com', 'hash123'),
('juan', 'juan@eco.com', 'hash456');

INSERT INTO SEG_ROLES (nombre, descripcion) VALUES
('Administrador', 'Acceso total al sistema'),
('Usuario', 'Acceso limitado');

INSERT INTO SEG_PERMISOS (nombre, descripcion) VALUES
('CrearRuta', 'Permite registrar nuevas rutas'),
('VerAlertas', 'Permite ver alertas activas');

INSERT INTO SEG_USUARIO_ROL (id_usuario, id_rol) VALUES
(1,1),
(2,2);

INSERT INTO SEG_ROL_PERMISO (id_rol, id_permiso) VALUES
(1,1),
(1,2),
(2,2);

CREATE VIEW vw_usuarios_rutas AS
SELECT u.nombre, u.correo, r.nombre AS ruta, r.co2_ahorrado, r.distancia_km
FROM USUARIOS u
JOIN RUTAS r ON u.id_usuario = r.id_usuario;

DELIMITER //
CREATE PROCEDURE sp_registrar_auditoria(
    IN p_id_usuario INT,
    IN p_accion VARCHAR(255),
    IN p_ip VARCHAR(45)
)
BEGIN
    INSERT INTO SEG_AUDITORIA (id_usuario, accion, ip_origen)
    VALUES (p_id_usuario, p_accion, p_ip);
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER trg_auditoria_segusuarios
AFTER INSERT ON SEG_USUARIOS
FOR EACH ROW
BEGIN
    INSERT INTO SEG_AUDITORIA (id_usuario, accion, ip_origen)
    VALUES (NEW.id_usuario, 'Registro de nuevo usuario en SEG_USUARIOS', '127.0.0.1');
END //
DELIMITER ;
