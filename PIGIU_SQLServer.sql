
CREATE DATABASE PIGIU_DB;
GO
USE PIGIU_DB;
GO

CREATE TABLE ciudadanos(
 id_ciudadano INT IDENTITY(1,1) PRIMARY KEY,
 dni VARCHAR(8) UNIQUE NOT NULL,
 nombres VARCHAR(100) NOT NULL,
 apellidos VARCHAR(100) NOT NULL,
 correo VARCHAR(150) UNIQUE NOT NULL,
 contrasena_hash VARCHAR(255) NOT NULL,
 distrito VARCHAR(100),
 fecha_registro DATETIME2 DEFAULT SYSDATETIME(),
 activo BIT DEFAULT 1
);

CREATE TABLE unidades_organicas(
 id_unidad INT IDENTITY PRIMARY KEY,
 nombre VARCHAR(150) NOT NULL,
 descripcion VARCHAR(300)
);

CREATE TABLE funcionarios_municipales(
 id_funcionario INT IDENTITY PRIMARY KEY,
 id_unidad INT REFERENCES unidades_organicas(id_unidad),
 nombres VARCHAR(100),
 apellidos VARCHAR(100),
 correo VARCHAR(150),
 credencial_ldap VARCHAR(150)
);

CREATE TABLE tecnicos_operativos(
 id_tecnico INT IDENTITY PRIMARY KEY,
 id_unidad INT REFERENCES unidades_organicas(id_unidad),
 nombres VARCHAR(100),
 apellidos VARCHAR(100),
 especialidad VARCHAR(100)
);

CREATE TABLE categorias(
 id_categoria INT IDENTITY PRIMARY KEY,
 nombre VARCHAR(100) NOT NULL,
 descripcion VARCHAR(300),
 sla_horas INT NOT NULL,
 activo BIT DEFAULT 1
);

CREATE TABLE subcategorias(
 id_subcategoria INT IDENTITY PRIMARY KEY,
 id_categoria INT NOT NULL REFERENCES categorias(id_categoria),
 nombre VARCHAR(100) NOT NULL,
 activo BIT DEFAULT 1
);

CREATE TABLE reportes(
 id_reporte INT IDENTITY PRIMARY KEY,
 ticket VARCHAR(30) UNIQUE NOT NULL,
 id_ciudadano INT NOT NULL REFERENCES ciudadanos(id_ciudadano),
 id_categoria INT NOT NULL REFERENCES categorias(id_categoria),
 id_subcategoria INT NULL REFERENCES subcategorias(id_subcategoria),
 descripcion VARCHAR(MAX) NOT NULL,
 direccion VARCHAR(250),
 latitud DECIMAL(10,7),
 longitud DECIMAL(10,7),
 estado VARCHAR(20) NOT NULL DEFAULT 'PENDIENTE',
 fecha_registro DATETIME2 DEFAULT SYSDATETIME(),
 fecha_resolucion DATETIME2 NULL,
 id_tecnico INT NULL REFERENCES tecnicos_operativos(id_tecnico)
);

CREATE TABLE evidencias(
 id_evidencia INT IDENTITY PRIMARY KEY,
 id_reporte INT NOT NULL REFERENCES reportes(id_reporte),
 url_archivo VARCHAR(500) NOT NULL,
 tipo VARCHAR(30),
 fecha_subida DATETIME2 DEFAULT SYSDATETIME()
);

CREATE TABLE historial_estados(
 id_historial INT IDENTITY PRIMARY KEY,
 id_reporte INT NOT NULL REFERENCES reportes(id_reporte),
 estado_anterior VARCHAR(20),
 estado_nuevo VARCHAR(20),
 comentario VARCHAR(500),
 fecha DATETIME2 DEFAULT SYSDATETIME()
);

CREATE TABLE historial_interacciones(
 id_interaccion INT IDENTITY PRIMARY KEY,
 id_reporte INT NOT NULL REFERENCES reportes(id_reporte),
 tipo_interaccion VARCHAR(30) NOT NULL,
 contenido VARCHAR(MAX) NOT NULL,
 tipo_actor VARCHAR(20) NOT NULL,
 fecha DATETIME2 DEFAULT SYSDATETIME()
);

CREATE TABLE reglas_derivacion(
 id_regla INT IDENTITY PRIMARY KEY,
 id_categoria INT NOT NULL REFERENCES categorias(id_categoria),
 id_subcategoria INT NULL REFERENCES subcategorias(id_subcategoria),
 id_unidad_destino INT NOT NULL REFERENCES unidades_organicas(id_unidad),
 prioridad_base VARCHAR(10) NOT NULL,
 activo BIT DEFAULT 1
);

CREATE TABLE identidades_externas(
 id_identidad INT IDENTITY PRIMARY KEY,
 id_ciudadano INT NOT NULL REFERENCES ciudadanos(id_ciudadano),
 proveedor VARCHAR(20) NOT NULL,
 id_externo VARCHAR(200) NOT NULL,
 UNIQUE(proveedor,id_externo)
);

CREATE TABLE notificaciones(
 id_notificacion INT IDENTITY PRIMARY KEY,
 id_ciudadano INT REFERENCES ciudadanos(id_ciudadano),
 titulo VARCHAR(200),
 mensaje VARCHAR(MAX),
 fecha_envio DATETIME2 DEFAULT SYSDATETIME()
);

CREATE TABLE valoraciones(
 id_valoracion INT IDENTITY PRIMARY KEY,
 id_reporte INT UNIQUE REFERENCES reportes(id_reporte),
 puntuacion INT CHECK (puntuacion BETWEEN 1 AND 5),
 comentario VARCHAR(500)
);

CREATE TABLE rutas_pigars(
 id_ruta INT IDENTITY PRIMARY KEY,
 nombre VARCHAR(100) NOT NULL,
 activo BIT DEFAULT 1
);

CREATE TABLE horarios_pigars(
 id_horario INT IDENTITY PRIMARY KEY,
 id_ruta INT NOT NULL REFERENCES rutas_pigars(id_ruta),
 dia_semana INT CHECK (dia_semana BETWEEN 0 AND 6),
 hora_inicio TIME NOT NULL,
 hora_fin TIME NOT NULL
);

CREATE TABLE sectores_jurisdiccionales(
 id_sector INT IDENTITY PRIMARY KEY,
 nombre_sector VARCHAR(100) NOT NULL,
 municipalidad VARCHAR(100) NOT NULL
);

CREATE TABLE infraestructura_catastral(
 id_infra INT IDENTITY PRIMARY KEY,
 codigo_catastral VARCHAR(50) NOT NULL,
 descripcion VARCHAR(300),
 id_sector INT REFERENCES sectores_jurisdiccionales(id_sector)
);

CREATE TABLE solicitudes_arco(
 id_solicitud INT IDENTITY PRIMARY KEY,
 id_ciudadano INT NOT NULL REFERENCES ciudadanos(id_ciudadano),
 tipo_derecho VARCHAR(20) NOT NULL,
 descripcion VARCHAR(MAX) NOT NULL,
 estado VARCHAR(20) DEFAULT 'RECIBIDA',
 fecha_solicitud DATETIME2 DEFAULT SYSDATETIME()
);

CREATE INDEX IX_Reportes_Estado ON reportes(estado);
CREATE INDEX IX_Reportes_Categoria ON reportes(id_categoria);
CREATE INDEX IX_HistorialReporte ON historial_interacciones(id_reporte);
