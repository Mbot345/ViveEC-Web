USE master
GO

CREATE DATABASE ViveEC
GO

USE ViveEC
GO
--========================================================================================================================================================================
--                                                                           ESQUEMAS                                                                                   --
--========================================================================================================================================================================

--========================================================================================================================================================================
-- ESQUEMA: MUSICA
-- - Artista
-- - Discográficas
-- - Albumes
-- - Canciones
-- - Géneros
-- - CancionGenero
--========================================================================================================================================================================
CREATE SCHEMA Musica
GO

--========================================================================================================================================================================
-- ESQUEMA: USUARIOS
-- - Usuario
-- - SeguimientoArtista
-- - LikeCancion
-- - AlbumGuardado
-- - Playlist
-- - PlaylistUsuarioColaborador
-- - PlaylistCancion
--========================================================================================================================================================================
CREATE SCHEMA Usuarios
GO

--========================================================================================================================================================================
-- ESQUEMA: OPERACIONES
-- - Suscripción 
-- - Pago
-- - ReproduccionCancion
-- - Reglia
--========================================================================================================================================================================
CREATE SCHEMA Operaciones
GO

---========================================================================================================================================================================
--                                                                   CREACION TABLAS                                                                                     --
---========================================================================================================================================================================

-- TABLA USUARIO
CREATE TABLE Usuarios.Usuario( 
IdUsuario CHAR(4) PRIMARY KEY,
correoUsuario NVARCHAR(100) UNIQUE NOT NULL CHECK (correoUsuario LIKE '%_@__%.%'),
contraseñaUsuario NVARCHAR(8) NOT NULL,
nombreUsuario NVARCHAR(100) NOT NULL,
pais NVARCHAR(50) NOT NULL
)
GO

-- TABLA DISCOGRAFICA
CREATE TABLE Musica.Discografica(
idDiscografica CHAR(4) PRIMARY KEY,
nombreDiscografica NVARCHAR(100) UNIQUE NOT NULL
)
GO

-- TABLA ARTISTA
CREATE TABLE Musica.Artista(
idArtista CHAR(4) PRIMARY KEY,
nombreArtista NVARCHAR(100) NOT NULL,
correoArtista NVARCHAR(100) UNIQUE NOT NULL CHECK (correoArtista LIKE '%_@__%.%'),
contraseñaArtista NVARCHAR(8) NOT NULL,
idDiscografica CHAR(4), --FK
FOREIGN KEY (idDiscografica) REFERENCES Musica.Discografica (idDiscografica)
)
GO

-- TABLA REGALIA
CREATE TABLE Operaciones.Regalia(
idRegalia CHAR(4) PRIMARY KEY,
fechaInicio DATE NOT NULL,
fechaFin DATE NOT NULL,
totalReproducciones INT NOT NULL CHECK (totalReproducciones >= 0) DEFAULT 0 ,
montoTotal DECIMAL(10,2) NOT NULL CHECK (montoTotal >= 0.00) DEFAULT 0.00,
fechaPago DATE NOT NULL,
idArtista CHAR(4) NOT NULL, --FK
FOREIGN KEY (idArtista) REFERENCES Musica.Artista (idArtista),
CHECK (fechaFin >= fechaInicio)
)
GO

-- TABLA ALBUM
CREATE TABLE Musica.Album(
idAlbum CHAR(4) PRIMARY KEY,
nombreAlbum NVARCHAR(100) NOT NULL,
fechaLanzamientoAlbum DATE NOT NULL,
idArtista CHAR(4) NOT NULL, --FK
FOREIGN KEY (idArtista) REFERENCES Musica.Artista (idArtista)
)
GO

-- TABLA CANCION
CREATE TABLE Musica.Cancion(
idCancion CHAR(4) PRIMARY KEY,
nombreCancion NVARCHAR(100) NOT NULL,
duracionCancion INTEGER NOT NULL CHECK (duracionCancion > 0),
fechaLanzamientoCancion DATE NOT NULL,
calidadAudio NVARCHAR(100) CHECK (calidadAudio IN ('Estándar','Alta')) DEFAULT 'Estándar',
estadoCancion NVARCHAR(15) CHECK (estadoCancion IN ('Activo','Inactivo')) DEFAULT 'Activo',
idAlbum char(4) NOT NULL, --FK
FOREIGN KEY (idAlbum) REFERENCES Musica.Album (idAlbum)
)
GO

-- TABLA GENERO
CREATE TABLE Musica.Genero(
idGenero CHAR(4) PRIMARY KEY,
nombreGenero NVARCHAR(100) NOT NULL,
)
GO

-- TABLA CANCION_GENERO
CREATE TABLE Musica.CancionGenero(
idCancion CHAR(4) NOT NULL, --FK
idGenero CHAR(4) NOT NULL, --FK
PRIMARY KEY (idCancion, idGenero),
FOREIGN KEY (idCancion) REFERENCES Musica.Cancion(idCancion),
FOREIGN KEY (idGenero) REFERENCES Musica.Genero(idGenero)
)
GO

-- TABLA LIKE_CANCION
CREATE TABLE Usuarios.LikeCancion(
idCancion CHAR(4) NOT NULL, --FK
IdUsuario CHAR(4) NOT NULL, --FK
PRIMARY KEY (idCancion, IdUsuario),
FOREIGN KEY (idCancion) REFERENCES Musica.Cancion(idCancion),
FOREIGN KEY (IdUsuario) REFERENCES Usuarios.Usuario(IdUsuario)
)
GO

-- TABLA ALBUM_USUARIO
CREATE TABLE Usuarios.AlbumGuardado(
idAlbum CHAR(4) NOT NULL, --FK
IdUsuario CHAR(4) NOT NULL, --FK
PRIMARY KEY (idAlbum, IdUsuario),
FOREIGN KEY (idAlbum) REFERENCES Musica.Album(idAlbum),
FOREIGN KEY (IdUsuario) REFERENCES Usuarios.Usuario(IdUsuario)
)
GO

-- TABLA ARTISTA_USUARIO
CREATE TABLE Usuarios.SeguimientoArtistas(
idArtista CHAR(4) NOT NULL, --FK
IdUsuario CHAR(4) NOT NULL, --FK
PRIMARY KEY (idArtista, IdUsuario),
FOREIGN KEY (idArtista) REFERENCES Musica.Artista(idArtista),
FOREIGN KEY (IdUsuario) REFERENCES Usuarios.Usuario(IdUsuario)
)
GO

-- TABLA REPRODUCCION CANCION
CREATE TABLE Operaciones.ReproduccionCancion(
idReproduccion INT IDENTITY(1,1) PRIMARY KEY,
idCancion CHAR(4) NOT NULL, --FK
IdUsuario CHAR(4) NOT NULL, --FK
paisReproduccion NVARCHAR(50) NOT NULL,
fechaReproduccion DATETIME NOT NULL,
duracionReproduccion INT NOT NULL CHECK (duracionReproduccion > 0),
FOREIGN KEY (idCancion) REFERENCES Musica.Cancion(idCancion),
FOREIGN KEY (IdUsuario) REFERENCES Usuarios.Usuario(IdUsuario)
)
GO

-- TABLA PLAYLIST
CREATE TABLE Usuarios.Playlist(
idPlaylist CHAR(4) PRIMARY KEY,
nombrePlaylist NVARCHAR(100) NOT NULL,
descripcionPlaylist NVARCHAR(500),
visibilidad NVARCHAR(10) CHECK(visibilidad IN('Pública','Privada')) DEFAULT 'Privada',
idUsuarioPropietario CHAR(4) NOT NULL, --FK
FOREIGN KEY (idUsuarioPropietario) REFERENCES Usuarios.Usuario(IdUsuario)
)
GO

-- TABLA PLAYLIST_USUARIOS COLABORADORES
CREATE TABLE Usuarios.PlaylistUsuarioColaborador(
idPlaylist CHAR(4) NOT NULL, --FK
IdUsuarioColaborador CHAR(4) NOT NULL, --FK
PRIMARY KEY (idPlaylist, IdUsuarioColaborador),
FOREIGN KEY (idPlaylist) REFERENCES Usuarios.Playlist(idPlaylist),
FOREIGN KEY (IdUsuarioColaborador) REFERENCES Usuarios.Usuario(IdUsuario)

)
GO

-- TABLA PLAYLIST_CANCION
CREATE TABLE Usuarios.PlaylistCancion(
idPlaylist CHAR(4) NOT NULL, --FK
idCancion CHAR(4) NOT NULL, --FK
PRIMARY KEY (idPlaylist, idCancion),
FOREIGN KEY (idPlaylist) REFERENCES Usuarios.Playlist(idPlaylist),
FOREIGN KEY (idCancion) REFERENCES Musica.Cancion(idCancion)
)
GO

-- TABLA SUSCRIPCION
CREATE TABLE Operaciones.Suscripcion(
idSuscripcion CHAR(4) PRIMARY KEY,
tipoSuscripcion NVARCHAR(15) NOT NULL CHECK(tipoSuscripcion IN ('Individual', 'Estudiante', 'Familiar')),
fechaInicioSuscripcion DATE NOT NULL,
fechaFinSuscripcion DATE NOT NULL,
estadoSuscripcion NVARCHAR(15) NOT NULL CHECK(estadoSuscripcion IN ('Activa', 'Cancelada', 'Vencida')),
idUsuario CHAR(4) NOT NULL, --FK
FOREIGN KEY (IdUsuario) REFERENCES Usuarios.Usuario (IdUsuario),
CHECK (fechaFinSuscripcion >= fechaInicioSuscripcion)
)
GO

-- TABLA PAGO
CREATE TABLE Operaciones.Pago(
idPago CHAR(4) PRIMARY KEY,
monto DECIMAL(10,2) NOT NULL CHECK(monto > 0),
fechaPago DATE NOT NULL,
metodoPago NVARCHAR(50) NOT NULL,
resultadoPago NVARCHAR(15) CHECK (resultadoPago IN ('Aprobado', 'Fallido')) NOT NULL,
idSuscripcion CHAR(4) NOT NULL, --FK
FOREIGN KEY (idSuscripcion) REFERENCES Operaciones.Suscripcion(idSuscripcion)
)
GO

--========================================================================================================================================================================
--                                                                          INDICES                                                                                     --
--========================================================================================================================================================================

-- INDICES PROPUESTOS:

-- INDICE PARA LA TABLA CANCION CON EL PARAMETRO DE NOMBRE:
CREATE NONCLUSTERED INDEX IDX_CANCION_NOMBRE ON Musica.Cancion (nombreCancion)
GO

-- INDICE PARA LA TABLA ARTISTAS CON EL PARAMETRO DE NOMBRE:
CREATE NONCLUSTERED INDEX IDX_ARTISTA_NOMBRE ON Musica.Artista (nombreArtista)
GO

-- INDICE PARA LA TABLA USUARIOS CON EL PARAMETRO DE NOMBRE:
CREATE NONCLUSTERED INDEX IDX_USUARIO_NOMBRE ON Usuarios.Usuario(nombreUsuario)
GO

-- INDICE PARA LA TABLA DE REPRODUCCION DE CANCION CON EL PARAMETRO DE FECHA DE REPRODUCCION:
CREATE NONCLUSTERED INDEX IDX_HISTORIAL_REPRODUCCION ON Operaciones.ReproduccionCancion (fechaReproduccion)
GO

-- INDICE PARA LA TABLA DE REPRODUCCION DE CANCION CON EL PARAMETRO DE PAIS DE REPRODUCCION:
CREATE NONCLUSTERED INDEX IDX_REPRODUCCION_PAIS ON Operaciones.ReproduccionCancion (paisReproduccion)
GO

--========================================================================================================================================================================
--                                                                      LOGIN Y PERMISOS                                                                                --
--========================================================================================================================================================================

-- USUARIO ================================================================================================================================================================

-- Crear Login:
CREATE LOGIN ViveEC_Login
WITH PASSWORD = 'ViveEC123*'
GO

-- Crear Usuario dentro de la Base de datos:
CREATE USER ViveEC_User
FOR LOGIN ViveEC_Login
GO

-- Dar permisos:
ALTER ROLE db_datareader ADD MEMBER ViveEC_User
GO

ALTER ROLE db_datawriter ADD MEMBER ViveEC_User
GO

GRANT EXECUTE TO ViveEC_User
GO

--ADMIN ===================================================================================================================================================================

-- Crear Login:
CREATE LOGIN ViveEC_AdminLogin
WITH PASSWORD = 'Admin123*'
GO

-- Crear Usuario admin dentro de la Base de datos:
CREATE USER ViveEC_Admin
FOR LOGIN ViveEC_AdminLogin
GO

-- Dar permisos:
ALTER ROLE db_owner ADD MEMBER ViveEC_Admin
GO

--========================================================================================================================================================================
--                                                                CARGA MASIVA DE INFORMACION                                                                           --
--========================================================================================================================================================================
-- CARGA DE DISCOGRÁFICAS (5 Reales)
INSERT INTO Musica.Discografica (idDiscografica, nombreDiscografica) VALUES
('D001', 'Sony Music Entertainment'),
('D002', 'Universal Music Group'),
('D003', 'Warner Music Group'),
('D004', 'XL Recordings'),
('D005', 'EMI Records');
GO

-- CARGA DE GÉNEROS (10 Variados)
INSERT INTO Musica.Genero (idGenero, nombreGenero) VALUES
('G001', 'Rock'),
('G002', 'Pop'),
('G003', 'Reggaeton'),
('G004', 'Jazz'),
('G005', 'Indie'),
('G006', 'Metal'),
('G007', 'Trap'),
('G008', 'Lo-fi'),
('G009', 'Salsa'),
('G010', 'Techno');
GO

-- CARGA DE USUARIOS (10 Iniciales)
-- El formato de correo cumple con: %_@__%.%
INSERT INTO Usuarios.Usuario (IdUsuario, correoUsuario, contraseñaUsuario, nombreUsuario, pais) VALUES
('U001', 'mateo_dev@mail.com', 'Pass123*', 'Mateo', 'Ecuador'),
('U002', 'ma.garcia@test.ec', 'Magi2026', 'Maria Garcia', 'Colombia'),
('U003', 'juan.perez@web.net', 'JPerez1!', 'Juan Perez', 'Argentina'),
('U004', 'elena.ro@mail.org', 'Elenita9', 'Elena Rodriguez', 'España'),
('U005', 'admin_sys@vive.ec', 'Root4321', 'Admin ViveEC', 'Ecuador'),
('U006', 'carla_m@music.com', 'Carla88*', 'Carla Mendoza', 'México'),
('U007', 'luis.t@serv.net', 'Lucho123', 'Luis Torres', 'Chile'),
('U008', 'sofia.b@web.com', 'Sofi_202', 'Sofia Benitez', 'Perú'),
('U009', 'diego.a@mail.ec', 'Dieg_555', 'Diego Aguirre', 'Uruguay'),
('U010', 'vale.v@test.com', 'ValeV_21', 'Valeria Vargas', 'Ecuador');
GO


-- CARGA DE ARTISTAS 
-- Vinculados a las discográficas: D001 (Sony), D002 (Universal), D003 (Warner), D004 (XL), D005 (Independiente/Otra)
INSERT INTO Musica.Artista (idArtista, nombreArtista, correoArtista, contraseñaArtista, idDiscografica) VALUES
('A001', 'Taylor Swift', 'taylorswift@music.com', 'Pass2026', 'D002'),
('A002', 'Bad Bunny', 'badbunny@music.com', 'Pass2026', 'D001'),
('A003', 'Arctic Monkeys', 'arcticmonkeys@music.com', 'Pass2026', 'D004'),
('A004', 'Dua Lipa', 'dualipa@music.com', 'Pass2026', 'D003'),
('A005', 'Metallica', 'metallica@music.com', 'Pass2026', 'D002'),
('A006', 'The Weeknd', 'theweeknd@music.com', 'Pass2026', 'D002'),
('A007', 'Shakira', 'shakira@music.com', 'Pass2026', 'D001'),
('A008', 'Soda Stereo', 'sodastereo@music.com', 'Pass2026', 'D001'),
('A009', 'Bruno Mars', 'brunomars@music.com', 'Pass2026', 'D003'),
('A010', 'Karol G', 'karolg@music.com', 'Pass2026', 'D002'),
('A011', 'Julio Jaramillo', 'juliojaramillo@music.com', 'Pass2026', 'D005'),
('A012', 'Juan Fernando Velasco', 'juanfernandovelasco@music.com', 'Pass2026', 'D001'),
('A013', 'Fausto Miño', 'faustomino@music.com', 'Pass2026', 'D002'),
('A014', 'Daniel Betancourt', 'danielbetancourt@music.com', 'Pass2026', 'D002'),
('A015', 'Pancho Teran', 'panchoteran@music.com', 'Pass2026', 'D003'),
('A016', 'Gerardo Moran', 'gerardomoran@music.com', 'Pass2026', 'D005'),
('A017', 'Paulina Tamayo', 'paulinatamayo@music.com', 'Pass2026', 'D005'),
('A018', 'Verde 70', 'verde70@music.com', 'Pass2026', 'D001'),
('A019', 'Guardarraya', 'guardarraya@music.com', 'Pass2026', 'D004'),
('A020', 'Swing Original Monks', 'swingoriginalmonks@music.com', 'Pass2026', 'D004'),
('A021', 'Papá Changó', 'papachango@music.com', 'Pass2026', 'D003'),
('A022', 'Tierra Canela', 'tierracanela@music.com', 'Pass2026', 'D005'),
('A023', 'Jombriel', 'jombriel@music.com', 'Pass2026', 'D002'),
('A024', 'Machaka', 'machaka@music.com', 'Pass2026', 'D002'),
('A025', 'AU-D', 'aud@music.com', 'Pass2026', 'D001'),
('A026', 'La Toquilla', 'latoquilla@music.com', 'Pass2026', 'D004'),
('A027', 'Mateo Kingman', 'mateokingman@music.com', 'Pass2026', 'D004'),
('A028', 'Nicola Cruz', 'nicolacruz@music.com', 'Pass2026', 'D004'),
('A029', 'Mirella Cesa', 'mirellacesa@music.com', 'Pass2026', 'D002'),
('A030', 'Marques', 'marques@music.com', 'Pass2026', 'D002'),
('A031', 'Los Intrépidos', 'losintrepidos@music.com', 'Pass2026', 'D005'),
('A032', 'Widinson', 'widinson@music.com', 'Pass2026', 'D002'),
('A033', 'Dayanara', 'dayanara@music.com', 'Pass2026', 'D002'),
('A034', 'Jorge Luis del Hierro', 'jorgeluisdelhierro@music.com', 'Pass2026', 'D003'),
('A035', 'Rocko y Blasty', 'rockoyblasty@music.com', 'Pass2026', 'D001');
GO

-- CARGA DE ÁLBUMES 
-- Fechas reales para que el reporte de "Lanzamientos" se vea bien.
INSERT INTO Musica.Album (idAlbum, nombreAlbum, fechaLanzamientoAlbum, idArtista) VALUES
('AL01', 'Midnights', '2022-10-21', 'A001'),
('AL02', 'Folklore', '2020-07-24', 'A001'),
('AL03', 'Un Verano Sin Ti', '2022-05-06', 'A002'),
('AL04', 'YHLQMDLG', '2020-02-29', 'A002'),
('AL05', 'AM', '2013-09-09', 'A003'),
('AL06', 'Future Nostalgia', '2020-03-27', 'A004'),
('AL07', 'Master of Puppets', '1986-03-03', 'A005'),
('AL08', 'After Hours', '2020-03-20', 'A006'),
('AL09', 'Starboy', '2016-11-25', 'A006'),
('AL10', 'El Dorado', '2017-05-26', 'A007'),
('AL11', 'Laundry Service', '2001-11-13', 'A007'),
('AL12', 'Comfort y Música para Volar', '1996-09-25', 'A008'),
('AL13', 'Canción Animal', '1990-08-07', 'A008'),
('AL14', '24K Magic', '2016-11-18', 'A009'),
('AL15', 'Mañana Será Bonito', '2023-02-24', 'A010'),
('AL16','Nuestro Juramento','1965-05-10','A011'),
('AL17','El Ruiseñor de América','1970-03-20','A011'),
('AL18','El Más Querido','2005-06-01','A012'),
('AL19','Ídolo del Pueblo','2010-09-15','A012'),
('AL20','Seductor','2008-07-12','A013'),
('AL21','De Cantina','2013-04-05','A013'),
('AL22','A Mil','2011-08-10','A014'),
('AL23','Instinto Natural','2016-10-22','A014'),
('AL24','Vida','2009-02-14','A015'),    x
('AL25','Tu Amor','2014-05-30','A015'),
('AL26','El Dueño del Swing','2001-01-01','A016'),
('AL27','Escándalo','2004-03-18','A016'),
('AL28','A Contraluz','2000-11-11','A017'),
('AL29','Frenesí','2006-06-06','A017'),
('AL30','Hijos del Dolor','1999-09-09','A018'),
('AL31','Despierta','2003-08-20','A018'),
('AL32','Guardarraya','2002-07-07','A019'),
('AL33','Entre el Barro','2008-12-12','A019'),
('AL34','La Santa Fanesca','2014-03-03','A020'),
('AL35','Somos','2018-04-21','A020'),
('AL36','Raíces','2010-05-05','A021'),
('AL37','Somos Uno','2015-09-09','A021'),
('AL38','Ciudad Gris','2012-02-02','A022'),
('AL39','Resistencia','2017-07-07','A022'),
('AL40','Verano en Coma','2015-11-11','A023'),
('AL41','Sol','2020-01-20','A023'),
('AL42','Cumbia del Ecuador','2003-03-03','A024'),
('AL43','Fiesta Tropical','2008-08-08','A024'),
('AL44','Nueva Ola','2022-06-01','A025'),
('AL45','Flow Ecuatoriano','2024-02-15','A025'),
('AL46','Canto Mestizo','2016-03-10','A026'),
('AL47','Origen','2021-09-05','A026'),
('AL48','Respira','2017-04-14','A027'),
('AL49','Astro','2020-10-10','A027'),
('AL50','Prender el Alma','2015-09-25','A028'),
('AL51','Siku','2019-06-21','A028'),
('AL52','La Corriente','2013-11-11','A029'),
('AL53','Dejé','2018-02-02','A029'),
('AL54','Romance Urbano','2019-08-08','A030'),
('AL55','Historias','2023-01-15','A030'),
('AL56','Rock del Barrio','2007-07-07','A031'),
('AL57','Generación','2012-12-12','A031'),
('AL58','Trap Latino','2021-03-03','A032'),
('AL59','Modo Calle','2024-01-01','A032'),
('AL60','El Inicio','2018-05-05','A033'),
('AL61','Renacer','2023-03-03','A033'),
('AL62','Agradecido','2006-06-06','A034'),
('AL63','Evolución','2011-11-11','A034'),
('AL64','La Unión','2010-10-10','A035'),
('AL65','Movimiento','2016-06-16','A035');
GO

-- CARGA DE CANCIONES 
INSERT INTO Musica.Cancion 
(idCancion, nombreCancion, duracionCancion, fechaLanzamientoCancion, calidadAudio, estadoCancion, idAlbum) 
VALUES
('C001', 'Anti-Hero', 200, '2022-10-21', 'Alta', 'Activo', 'AL01'),
('C002', 'Lavender Haze', 202, '2022-10-21', 'Alta', 'Activo', 'AL01'),
('C003', 'Cardigan', 239, '2020-07-24', 'Alta', 'Activo', 'AL02'),
('C004', 'Exile', 285, '2020-07-24', 'Alta', 'Activo', 'AL02'),
('C005', 'Titi Me Pregunto', 243, '2022-05-06', 'Alta', 'Activo', 'AL03'),
('C006', 'Me Porto Bonito', 178, '2022-05-06', 'Alta', 'Activo', 'AL03'),
('C007', 'Safaera', 295, '2020-02-29', 'Estándar', 'Activo', 'AL04'),
('C008', 'La Santa', 206, '2020-02-29', 'Estándar', 'Activo', 'AL04'),
('C009', 'Do I Wanna Know?', 272, '2013-09-09', 'Alta', 'Activo', 'AL05'),
('C010', 'R U Mine?', 200, '2013-09-09', 'Alta', 'Activo', 'AL05'),
('C011', 'Levitating', 203, '2020-03-27', 'Alta', 'Activo', 'AL06'),
('C012', 'Dont Start Now', 183, '2020-03-27', 'Alta', 'Activo', 'AL06'),
('C013', 'Master of Puppets', 515, '1986-03-03', 'Estándar', 'Activo', 'AL07'),
('C014', 'Battery', 312, '1986-03-03', 'Estándar', 'Activo', 'AL07'),
('C015', 'Blinding Lights', 200, '2020-03-20', 'Alta', 'Activo', 'AL08'),
('C016', 'Save Your Tears', 215, '2020-03-20', 'Alta', 'Activo', 'AL08'),
('C017', 'Starboy', 230, '2016-11-25', 'Alta', 'Activo', 'AL09'),
('C018', 'I Feel It Coming', 269, '2016-11-25', 'Alta', 'Activo', 'AL09'),
('C019', 'Chantaje', 195, '2017-05-26', 'Estándar', 'Activo', 'AL10'),
('C020', 'Me Enamore', 186, '2017-05-26', 'Estándar', 'Activo', 'AL10'),
('C021', 'Whenever Wherever', 196, '2001-11-13', 'Estándar', 'Inactivo', 'AL11'),
('C022', 'Underneath Your Clothes', 224, '2001-11-13', 'Estándar', 'Activo', 'AL11'),
('C023', 'En la Ciudad de la Furia', 510, '1996-09-25', 'Estándar', 'Activo', 'AL12'),
('C024', 'Te para Tres', 233, '1996-09-25', 'Estándar', 'Activo', 'AL12'),
('C025', 'De Musica Ligera', 213, '1990-08-07', 'Estándar', 'Activo', 'AL13'),
('C026', 'Entre Canibales', 246, '1990-08-07', 'Estándar', 'Activo', 'AL13'),
('C027', '24K Magic', 226, '2016-11-18', 'Alta', 'Activo', 'AL14'),
('C028', 'That is What I Like', 206, '2016-11-18', 'Alta', 'Activo', 'AL14'),
('C029', 'Provenza', 210, '2023-02-24', 'Alta', 'Activo', 'AL15'),
('C030', 'TQG', 199, '2023-02-24', 'Alta', 'Activo', 'AL15'),
('C031','Nuestro Juramento',210,'1965-05-10','Estándar','Activo','AL16'),
('C032','Fatalidad',195,'1965-05-10','Estándar','Activo','AL16'),
('C033','Cinco Centavitos',205,'1970-03-20','Estándar','Activo','AL17'),
('C034','Rondando tu Esquina',200,'1970-03-20','Estándar','Activo','AL17'),
('C035','El Provinciano',230,'2005-06-01','Alta','Activo','AL18'),
('C036','Amor de Pobre',215,'2005-06-01','Alta','Activo','AL18'),
('C037','Lágrimas de Amor',225,'2010-09-15','Alta','Activo','AL19'),
('C038','Nunca Te Olvidaré',210,'2010-09-15','Alta','Activo','AL19'),
('C039','Seductor',200,'2008-07-12','Alta','Activo','AL20'),
('C040','Amarte Así',205,'2008-07-12','Alta','Activo','AL20'),
('C041','De Cantina',215,'2013-04-05','Alta','Activo','AL21'),
('C042','Entre Copas',220,'2013-04-05','Alta','Activo','AL21'),
('C043','A Mil',198,'2011-08-10','Alta','Activo','AL22'),
('C044','Baila Conmigo',205,'2011-08-10','Alta','Activo','AL22'),
('C045','Instinto Natural',210,'2016-10-22','Alta','Activo','AL23'),
('C046','Corazón Abierto',215,'2016-10-22','Alta','Activo','AL23'),
('C047','Vida',190,'2009-02-14','Alta','Activo','AL24'),
('C048','Te Amaré',200,'2009-02-14','Alta','Activo','AL24'),
('C049','Tu Amor',210,'2014-05-30','Alta','Activo','AL25'),
('C050','Eres Tú',205,'2014-05-30','Alta','Activo','AL25'),
('C051','El Dueño del Swing',210,'2001-01-01','Estándar','Activo','AL26'),
('C052','Latino Caliente',200,'2001-01-01','Estándar','Activo','AL26'),
('C053','Escándalo',215,'2004-03-18','Estándar','Activo','AL27'),
('C054','Fiesta Total',220,'2004-03-18','Estándar','Activo','AL27'),
('C055','En Otros Mundos',240,'2000-11-11','Alta','Activo','AL28'),
('C056','Si No Es Contigo',230,'2000-11-11','Alta','Activo','AL28'),
('C057','Frenesí',235,'2006-06-06','Alta','Activo','AL29'),
('C058','Irremediablemente Tarde',225,'2006-06-06','Alta','Activo','AL29'),
('C059','Hijos del Dolor',300,'1999-09-09','Estándar','Activo','AL30'),
('C060','Guerreros',290,'1999-09-09','Estándar','Activo','AL30'),
('C061','Despierta',280,'2003-08-20','Estándar','Activo','AL31'),
('C062','Metal Andino',295,'2003-08-20','Estándar','Activo','AL31'),
('C063','Guardarraya',240,'2002-07-07','Alta','Activo','AL32'),
('C064','Camino',230,'2002-07-07','Alta','Activo','AL32'),
('C065','Entre el Barro',235,'2008-12-12','Alta','Activo','AL33'),
('C066','Ciudad',220,'2008-12-12','Alta','Activo','AL33'),
('C067','La Santa Fanesca',250,'2014-03-03','Alta','Activo','AL34'),
('C068','Ritual',245,'2014-03-03','Alta','Activo','AL34'),
('C069','Somos',230,'2018-04-21','Alta','Activo','AL35'),
('C070','Raíz',225,'2018-04-21','Alta','Activo','AL35');
GO

-- CARGA DE CANCION_GENERO (Relación de las canciones con sus géneros)
-- Usando los géneros: G001(Rock), G002(Pop), G003(Reggaeton), G006(Metal), etc.
INSERT INTO Musica.CancionGenero (idCancion, idGenero) VALUES
('C001', 'G002'), ('C002', 'G002'), -- Taylor (Pop)
('C003', 'G005'), ('C004', 'G005'), -- Taylor (Indie)
('C005', 'G003'), ('C006', 'G003'), -- Bad Bunny (Reggaeton)
('C007', 'G003'), ('C008', 'G007'), -- Bad Bunny (Reggaeton/Trap)
('C009', 'G001'), ('C010', 'G001'), -- Arctic Monkeys (Rock)
('C011', 'G002'), ('C012', 'G002'), -- Dua Lipa (Pop)
('C013', 'G006'), ('C014', 'G006'), -- Metallica (Metal)
('C015', 'G002'), ('C016', 'G010'), -- Weeknd (Pop/Techno)
('C017', 'G002'), ('C018', 'G002'), -- Weeknd (Pop)
('C019', 'G003'), ('C020', 'G002'), -- Shakira (Reggaeton/Pop)
('C021', 'G002'), ('C022', 'G002'), -- Shakira (Pop)
('C023', 'G001'), ('C024', 'G001'), -- Soda Stereo (Rock)
('C025', 'G001'), ('C026', 'G001'), -- Soda Stereo (Rock)
('C027', 'G002'), ('C028', 'G002'), -- Bruno Mars (Pop)
('C029', 'G003'), ('C030', 'G003'), -- Karol G (Reggaeton)
('C031','G009'),('C032','G009'),('C033','G009'),('C034','G009'),-- Julio Jaramillo (adaptado a catálogo moderno)
('C035','G002'),('C036','G002'),('C037','G002'),('C038','G002'),-- Daniel Betancourt (Pop)
('C039','G002'),('C039','G009'),('C040','G002'),('C041','G009'),('C042','G009'),-- Gerardo Morán (Pop / Salsa)
('C043','G002'),('C043','G005'),('C044','G002'),('C045','G005'),('C046','G002'),-- Fausto Miño (Pop / Indie)
('C047','G001'),('C048','G001'),('C049','G001'),('C050','G001'),-- Pancho Terán (Rock)
('C051','G003'),('C051','G007'),('C052','G003'),('C053','G007'),('C054','G003'),-- AU-D (Urbano ? Reggaeton / Trap)
('C055','G001'),('C055','G005'),('C056','G001'),('C057','G005'),('C058','G001'),-- Verde70 (Rock / Indie)
('C059','G006'),('C060','G006'),('C061','G006'),('C062','G006'),-- Basca (Metal)
('C063','G005'),('C063','G004'),('C064','G005'),('C065','G004'),('C066','G005'),-- Swing Original Monks (Indie / Jazz fusión)
('C067','G008'),('C067','G010'),('C068','G010'),('C069','G008'),('C070','G010');-- Nicola Cruz (Lo-fi / Techno)SSSS
GO

-- 1. CARGA DE SUSCRIPCIONES (Una para cada usuario)
-- Tipos: 'Individual', 'Estudiante', 'Familiar' | Estados: 'Activa', 'Cancelada', 'Vencida'
INSERT INTO Operaciones.Suscripcion (idSuscripcion, tipoSuscripcion, fechaInicioSuscripcion, fechaFinSuscripcion, estadoSuscripcion, idUsuario) VALUES
('S001', 'Individual', '2026-04-20', '2026-05-20', 'Activa', 'U001'),
('S002', 'Estudiante', '2026-04-20', '2026-05-20', 'Activa', 'U002'),
('S003', 'Familiar',   '2026-04-21', '2026-05-21', 'Activa', 'U003'),
('S004', 'Individual', '2026-04-22', '2026-05-21', 'Activa', 'U004'),
('S005', 'Individual', '2026-04-22', '2026-05-22', 'Activa', 'U005'),
('S006', 'Estudiante', '2026-04-20', '2026-05-20', 'Activa', 'U006'),
('S007', 'Familiar',   '2026-04-23', '2026-05-23', 'Activa', 'U007'),
('S008', 'Individual', '2025-04-20', '2025-05-20', 'Vencida', 'U008'),
('S009', 'Individual', '2026-04-20', '2026-05-20', 'Cancelada', 'U009'),
('S010', 'Estudiante', '2026-04-24', '2026-05-24', 'Activa', 'U010');
GO

-- CARGA DE LIKES (Interacción de usuarios con canciones)
-- Esto alimenta el reporte de "Canciones con Like"
INSERT INTO Usuarios.LikeCancion (idCancion, IdUsuario) VALUES
('C001', 'U001'), ('C009', 'U001'), ('C023', 'U001'), -- Mateo prefiere Pop y Rock
('C005', 'U002'), ('C029', 'U002'), ('C030', 'U002'), -- Maria prefiere Reggaeton
('C013', 'U003'), ('C014', 'U003'), ('C009', 'U003'), -- Juan prefiere Rock/Metal
('C011', 'U004'), ('C015', 'U004'), ('C027', 'U004'); -- Elena prefiere Pop
GO

-- CARGA DE PLAYLISTS
INSERT INTO Usuarios.Playlist (idPlaylist, nombrePlaylist, descripcionPlaylist, visibilidad, idUsuarioPropietario) VALUES
('P001', 'Rock Argentino', 'Lo mejor de Soda y más', 'Pública', 'U001'),
('P002', 'Perreo 2026', 'Para el fin de semana', 'Pública', 'U002'),
('P003', 'Focus Coding', 'Música para programar en .NET', 'Privada', 'U001'),
('P004', 'Gym Hits', 'Energía pura', 'Pública', 'U004'),
('P005', 'Colab Metal', 'Playlist compartida de clásicos', 'Pública', 'U003');
GO

-- VINCULAR CANCIONES A PLAYLISTS
INSERT INTO Usuarios.PlaylistCancion (idPlaylist, idCancion) VALUES
('P001', 'C023'), ('P001', 'C024'), ('P001', 'C025'),
('P002', 'C005'), ('P002', 'C006'), ('P002', 'C030'),
('P003', 'C015'), ('P003', 'C017'), ('P003', 'C018'),
('P005', 'C013'), ('P005', 'C014'), ('P005', 'C009');
GO

-- COLABORADORES EN PLAYLIST (Probando la lógica del Profe)
-- El dueño de P005 es Juan (U003), pero Mateo (U001) es colaborador.
INSERT INTO Usuarios.PlaylistUsuarioColaborador (idPlaylist, IdUsuarioColaborador) VALUES
('P005', 'U001'),
('P005', 'U004');
GO

-- CARGA DE PAGOS (Relacionados a las suscripciones activas)
-- Precios sugeridos: Individual $9.99, Estudiante $5.99, Familiar $14.99
INSERT INTO Operaciones.Pago (idPago, monto, fechaPago, metodoPago, resultadoPago, idSuscripcion) VALUES
('P001', 9.99, '2026-04-20', 'Tarjeta de Crédito', 'Aprobado', 'S001'),
('P002', 5.99, '2026-04-20', 'PayPal', 'Aprobado', 'S002'),
('P003', 14.99, '2026-04-21', 'Tarjeta de Débito', 'Aprobado', 'S003'),
('P004', 9.99, '2026-04-22', 'Tarjeta de Crédito', 'Aprobado', 'S004'),
('P005', 9.99, '2026-04-22', 'Transferencia', 'Aprobado', 'S005'),
('P006', 5.99, '2026-04-20', 'PayPal', 'Aprobado', 'S006'),
('P007', 14.99, '2026-04-23', 'Tarjeta de Crédito', 'Aprobado', 'S007'),
('P008', 9.99, '2025-04-20', 'Tarjeta de Crédito', 'Aprobado', 'S008'),
('P009', 5.99, '2026-04-20', 'Efectivo', 'Aprobado', 'S010'),
('P010', 9.99, '2026-04-24', 'Tarjeta de Crédito', 'Fallido', 'S001'); -- Un pago fallido para probar
GO

-- CARGA DE REPRODUCCIONES (Volumen para reportes)
-- Formato: idCancion, IdUsuario, Pais, Fecha, Duración (seg)
INSERT INTO Operaciones.ReproduccionCancion (idCancion, IdUsuario, paisReproduccion, fechaReproduccion, duracionReproduccion) VALUES
-- Taylor Swift (A001) - Muy escuchada en USA y Ecuador
('C001', 'U001', 'Ecuador', '2026-04-20 10:30:00', 200),
('C001', 'U004', 'USA', '2026-04-21 14:20:00', 200),
('C001', 'U006', 'USA', '2026-04-22 08:15:00', 150),
('C003', 'U001', 'Ecuador', '2026-04-20 11:00:00', 239),

-- Bad Bunny (A002) - Dominando en México y Colombia
('C005', 'U002', 'Mexico', '2026-04-23 22:00:00', 243),
('C005', 'U007', 'Colombia', '2026-04-23 23:15:00', 243),
('C006', 'U002', 'Mexico', '2026-04-24 01:00:00', 178),
('C006', 'U010', 'Ecuador', '2026-04-24 09:00:00', 178),

-- Arctic Monkeys (A003) - Popular en Argentina y UK (simulado)
('C009', 'U001', 'Argentina', '2026-04-15 18:00:00', 272),
('C009', 'U003', 'Argentina', '2026-04-16 19:30:00', 272),
('C010', 'U003', 'Argentina', '2026-04-16 20:00:00', 200),

-- The Weeknd (A006) - Global
('C015', 'U004', 'USA', '2026-04-10 12:00:00', 200),
('C015', 'U005', 'Ecuador', '2026-04-11 13:00:00', 200),
('C016', 'U008', 'España', '2026-04-12 15:45:00', 215),

-- Soda Stereo (A008) - Leyendas en Latam
('C023', 'U001', 'Ecuador', '2026-04-05 09:00:00', 510),
('C025', 'U001', 'Argentina', '2026-04-06 10:00:00', 213),
('C025', 'U007', 'Colombia', '2026-04-07 11:00:00', 213),
('C023', 'U009', 'Mexico', '2026-04-08 12:00:00', 400); -- Escucha parcial
GO

-- CARGA DE SEGUIMIENTO DE ARTISTAS (Quién sigue a quién)
-- Esto alimenta el reporte "Artistas seguidos"
INSERT INTO Usuarios.SeguimientoArtistas (idArtista, IdUsuario) VALUES
('A001', 'U001'), ('A008', 'U001'), ('A003', 'U001'), -- Mateo sigue a Taylor, Soda y Arctic
('A002', 'U002'), ('A010', 'U002'), ('A007', 'U002'), -- Maria sigue al bloque urbano
('A005', 'U003'), ('A008', 'U003'), ('A003', 'U003'), -- Juan sigue Rock/Metal
('A001', 'U004'), ('A004', 'U004'), ('A006', 'U004'), -- Elena sigue Pop/Indie
('A002', 'U010'), ('A010', 'U010');
GO

-- CARGA DE ÁLBUMES GUARDADOS (Biblioteca personal)
-- Esto alimenta el reporte "Álbumes guardados"
INSERT INTO Usuarios.AlbumGuardado (idAlbum, IdUsuario) VALUES
('AL01', 'U001'), ('AL12', 'U001'), ('AL13', 'U001'), -- Mateo guardó Midnights y Soda Stereo
('AL03', 'U002'), ('AL15', 'U002'),                  -- Maria guardó Bad Bunny y Karol G
('AL07', 'U003'), ('AL05', 'U003'),                  -- Juan guardó Metallica y Arctic Monkeys
('AL01', 'U004'), ('AL06', 'U004'), ('AL08', 'U004'); -- Elena guardó Taylor, Dua Lipa y Weeknd
GO

-- CARGA DE REGALÍAS (Pago por reproducciones)
-- Basado en un promedio de $0.004 por reproducción (como Spotify real)
INSERT INTO Operaciones.Regalia (idRegalia, fechaInicio, fechaFin, totalReproducciones, montoTotal, fechaPago, idArtista) VALUES
-- Taylor Swift: 500k repros (simuladas para el registro)
('R001', '2026-03-01', '2026-03-31', 500000, 2000.00, '2026-04-10', 'A001'),
-- Bad Bunny: 750k repros
('R002', '2026-03-01', '2026-03-31', 750000, 3000.00, '2026-04-10', 'A002'),
-- Soda Stereo: 100k repros
('R003', '2026-03-01', '2026-03-31', 100000, 400.00, '2026-04-10', 'A008'),
-- Metallica: 200k repros
('R004', '2026-03-01', '2026-03-31', 200000, 800.00, '2026-04-10', 'A005'),
-- Karol G: 400k repros
('R005', '2026-03-01', '2026-03-31', 400000, 1600.00, '2026-04-10', 'A010');
GO

--========================================================================================================================================================================
--                                                                 REGLAS DE NEGOCIO                                                                                    --
--========================================================================================================================================================================

-- ´Para la creación de objetos programables se tomaron en cuenta las reglas de negocio como:

-- - Registro y autenticación de usuarios.

-- - Reglas de Suscripciones: Un usuario solo puede tener una suscripción activa a la vez.

-- - Procesamiento de pagos: Una suscripción no se activa si el pago falla.

-- - Reproducción de canciones: Una canción inactiva no puede reproducirse

-- - Cálculo de regalías para artistas: Las regalías se calculan según el número de reproducciones.

-- Tomando en cuenta esas restricciones y reglas se realizaron 4 store procedures resolviendo las principales reglas Identificadas.

-- STORE PROCEDURE PARA SUSCRIPCIONES ====================================================================================================================================

CREATE PROCEDURE SP_CrearSuscripcion
@idSuscripcion CHAR(4),
@idPago CHAR(4),
@idUsuario CHAR(4),
@tipoSuscripcion NVARCHAR(15),
@monto DECIMAL(10,2),
@metodo NVARCHAR(50),
@resultado NVARCHAR(15)
AS
BEGIN
    BEGIN TRY
        DECLARE @estado NVARCHAR(15)

        IF NOT EXISTS (
            SELECT 1 
            FROM Usuarios.Usuario 
            WHERE IdUsuario = @IdUsuario
        )
        BEGIN
            THROW 50001, 'El usuario no existe.', 1;
        END

        IF EXISTS (
            SELECT 1
            FROM Operaciones.Suscripcion
            WHERE IdUsuario = @IdUsuario
            AND estadoSuscripcion = 'Activa'
        )
        BEGIN
            THROW 50002, 'El usuario ya tiene una suscripción activa.', 1;
        END

        IF @monto <= 0
        BEGIN
            THROW 50003, 'El monto debe ser mayor a 0.', 1;
        END

        IF @tipoSuscripcion NOT IN ('Individual', 'Estudiante', 'Familiar')
        BEGIN
            THROW 50004, 'Tipo de suscripción inválido.', 1;
        END

        IF @resultado = 'Aprobado'
            SET @estado = 'Activa'
        ELSE
            SET @estado = 'Cancelada'

        INSERT INTO Operaciones.Suscripcion (idSuscripcion, tipoSuscripcion, fechaInicioSuscripcion, fechaFinSuscripcion, estadoSuscripcion, idUsuario)
        VALUES (@idSuscripcion, @tipoSuscripcion, GETDATE(), DATEADD(MONTH,1,GETDATE()), @estado, @idUsuario)

        INSERT INTO Operaciones.Pago (idPago, monto, fechaPago, metodoPago, resultadoPago, idSuscripcion)
        VALUES (@idPago, @monto, GETDATE(), @metodo, @resultado, @idSuscripcion)

    END TRY
        BEGIN CATCH
        SELECT 
            ERROR_NUMBER() AS ErrorNumber,
            ERROR_MESSAGE() AS ErrorMessage,
            ERROR_SEVERITY() AS ErrorSeverity,
            ERROR_STATE() AS ErrorState,
            ERROR_LINE() AS ErrorLine,
            ERROR_PROCEDURE() AS ErrorProcedure;
    END CATCH
END
GO


-- STORE PROCEDURE PARA EL REGISTRO DE REPRODUCCION ======================================================================================================================

CREATE PROCEDURE SP_RegistrarReproduccion
@idCancion CHAR(4),
@IdUsuario CHAR(4), 
@paisReproduccion NVARCHAR(50),
@duracion INT
AS
BEGIN
	BEGIN TRY
	IF NOT EXISTS (
            SELECT 1 
            FROM Musica.Cancion 
            WHERE idCancion = @idCancion
        )
        BEGIN
            THROW 50005, 'la canción no existe.', 1;
        END

        IF NOT EXISTS (
            SELECT 1 
            FROM Usuarios.Usuario 
            WHERE IdUsuario = @IdUsuario
        )
        BEGIN
            THROW 50006, 'El usuario no existe.', 1;
        END

        IF @duracion <= 0
        BEGIN
            THROW 50007, 'La duración debe ser mayor a 0.', 1;
        END

		IF EXISTS (
            SELECT 1
            FROM Musica.Cancion
            WHERE idCancion = @idCancion
            AND estadoCancion = 'Inactivo'
        )
        BEGIN
            THROW 50008, 'La canción está inactiva.', 1;

        END
		INSERT INTO Operaciones.ReproduccionCancion (idCancion, IdUsuario, paisReproduccion, fechaReproduccion, duracionReproduccion)
		VALUES (@idCancion, @IdUsuario, @paisReproduccion, GETDATE(), @duracion)
	END TRY

    BEGIN CATCH
        SELECT 
			ERROR_NUMBER() AS ErrorNumber,
			ERROR_MESSAGE() AS ErrorMessage,
			ERROR_SEVERITY() AS ErrorSeverity,
			ERROR_STATE() AS ErrorState,
			ERROR_LINE() AS ErrorLine,
			ERROR_PROCEDURE() AS ErrorProcedure;
    END CATCH
END
GO

-- FUNCION PARA CALCULAR EL MONTO TOTAL SEGUN REPS  ======================================================================================================================

CREATE FUNCTION FN_CalcularMontoRegalia
(
    @totalReproducciones INT
)
RETURNS DECIMAL(10,2)
AS
BEGIN
    DECLARE @monto DECIMAL(10,2)

    SET @monto = @totalReproducciones * 0.05

    RETURN @monto
END
GO

-- STORE PROCEDURE PARA CALCULAR REGALIAS Y ASIGNAR A CADA ARTISTA =======================================================================================================

CREATE PROCEDURE SP_GenerarRegalias
@IdRegalia CHAR(4),
@IdArtista CHAR(4),
@fechaInicio DATE,
@fechaFin DATE
AS
BEGIN
    BEGIN TRY
        DECLARE @monto DECIMAL(10,2)
        DECLARE @totalRep INT

        IF NOT EXISTS (
            SELECT 1 
            FROM Musica.Artista 
            WHERE idArtista = @IdArtista
        )
        BEGIN
            THROW 50009, 'El artista no existe.', 1;
        END

        IF @fechaFin < @fechaInicio
        BEGIN
            THROW 50010, 'La fecha fin no puede ser menor a la fecha inicio.', 1;
        END

        IF EXISTS (
            SELECT 1
            FROM Operaciones.Regalia
            WHERE idRegalia = @IdRegalia
        )
        BEGIN
            THROW 50011, 'Ya existe un registro de regalía con ese identificador.', 1;
        END

        IF EXISTS (
            SELECT 1
            FROM Operaciones.Regalia
            WHERE idArtista = @IdArtista
            AND (
                @fechaInicio BETWEEN fechaInicio AND fechaFin
                OR @fechaFin BETWEEN fechaInicio AND fechaFin
                OR (fechaInicio BETWEEN @fechaInicio AND @fechaFin)
            )
        )
        BEGIN
            THROW 50012, 'Ya existe una regalía activa o en ese rango de fechas para este artista.', 1;
        END

        SELECT @totalRep = COUNT(*) 
        FROM Operaciones.ReproduccionCancion AS OC
        INNER JOIN Musica.Cancion AS MC 
        ON OC.idCancion = MC.idCancion
        INNER JOIN Musica.Album MA 
        ON MC.idAlbum = MA.idAlbum 
        WHERE MA.idArtista = @IdArtista
        AND OC.fechaReproduccion BETWEEN @fechaInicio AND @fechaFin

        SET @monto = dbo.FN_CalcularMontoRegalia(@totalRep) -- Funcion

        INSERT INTO Operaciones.Regalia(idRegalia, fechaInicio, fechaFin, totalReproducciones, montoTotal, fechaPago, idArtista)
        VALUES (@IdRegalia, @fechaInicio, @fechaFin,@totalRep, @monto, GETDATE(), @IdArtista)
    END TRY

    BEGIN CATCH
        SELECT 
            ERROR_NUMBER() AS ErrorNumber,
            ERROR_MESSAGE() AS ErrorMessage,
            ERROR_SEVERITY() AS ErrorSeverity,
            ERROR_STATE() AS ErrorState,
            ERROR_LINE() AS ErrorLine,
            ERROR_PROCEDURE() AS ErrorProcedure;
    END CATCH
END
GO

-- CRUSOR DE REGALIAS MASIVAS ============================================================================================================================================

CREATE PROCEDURE SP_GenerarRegaliasMasivas
@fechaInicio DATE,
@fechaFin DATE
AS
BEGIN

    BEGIN TRY

        DECLARE @IdArtista CHAR(4)
        DECLARE @totalRep INT
        DECLARE @monto DECIMAL(10,2)
        DECLARE @IdRegalia CHAR(4)

        DECLARE CursorRegalias CURSOR FOR

        SELECT idArtista
        FROM Musica.Artista

        OPEN CursorRegalias

        FETCH NEXT FROM CursorRegalias INTO @IdArtista

        WHILE @@FETCH_STATUS = 0
        BEGIN

            SELECT @totalRep = COUNT(*)
            FROM Operaciones.ReproduccionCancion AS OC
            INNER JOIN Musica.Cancion AS MC
            ON OC.idCancion = MC.idCancion
            INNER JOIN Musica.Album AS MA
            ON MC.idAlbum = MA.idAlbum
            WHERE MA.idArtista = @IdArtista
            AND OC.fechaReproduccion BETWEEN @fechaInicio AND @fechaFin

            SET @monto = dbo.FN_CalcularMontoRegalia(@totalRep)

            SET @IdRegalia =
            'R' + RIGHT('000' + CAST(
            ISNULL(
                (SELECT COUNT(*) + 1
                 FROM Operaciones.Regalia),1)
            AS VARCHAR),3)

            INSERT INTO Operaciones.Regalia(idRegalia, fechaInicio, fechaFin, totalReproducciones, montoTotal, fechaPago, idArtista)
            VALUES(@IdRegalia, @fechaInicio, @fechaFin, @totalRep, @monto, GETDATE(), @IdArtista)

            FETCH NEXT FROM CursorRegalias INTO @IdArtista

        END

        CLOSE CursorRegalias

        DEALLOCATE CursorRegalias

        PRINT 'Regalías generadas correctamente'

    END TRY

    BEGIN CATCH

        SELECT
            ERROR_NUMBER() AS ErrorNumber,
            ERROR_MESSAGE() AS ErrorMessage,
            ERROR_SEVERITY() AS ErrorSeverity,
            ERROR_STATE() AS ErrorState,
            ERROR_LINE() AS ErrorLine,
            ERROR_PROCEDURE() AS ErrorProcedure;

    END CATCH

END
GO

-- TRIGGER PARA IMPEDIR REPRODUCIR CANCIONES INACTIVAS ====================================================================================================================

CREATE TRIGGER TR_NoReproducirCancionInactiva
ON Operaciones.ReproduccionCancion
INSTEAD OF INSERT
AS
BEGIN

    IF EXISTS (
        SELECT 1
        FROM inserted i
        INNER JOIN Musica.Cancion c
        ON i.idCancion = c.idCancion
        WHERE c.estadoCancion = 'Inactivo'
    )
    BEGIN
        RAISERROR('No se puede reproducir una canción inactiva.',16,1)
        RETURN
    END

    INSERT INTO Operaciones.ReproduccionCancion(idCancion, IdUsuario, paisReproduccion, fechaReproduccion, duracionReproduccion)
    SELECT idCancion, IdUsuario, paisReproduccion, fechaReproduccion,duracionReproduccion
    FROM inserted

END
GO

-- TRIGGER PARA PAGOS FALLIDOS  ===========================================================================================================================================

CREATE TRIGGER TR_PagoFallido
ON Operaciones.Pago
AFTER INSERT
AS
BEGIN

    UPDATE S
    SET estadoSuscripcion = 'Cancelada'
    FROM Operaciones.Suscripcion S
    INNER JOIN inserted i
    ON S.idSuscripcion = i.idSuscripcion
    WHERE i.resultadoPago = 'Fallido'

END

-- OBJETOS PROGRAMABLES OPERACIONES CRUD EN LA TABLA CANCION ==============================================================================================================

-- INSERT: PROCEDIMIENTO PARA CREAR CANCION -------------------------------------------------------------------------------------------------------------------------------

CREATE PROCEDURE SP_InsertarCancion
@IdCancion CHAR(4),
@nombre NVARCHAR(100),
@duracion INT,
@fechaLanzamiento DATE,
@calidad NVARCHAR(100),
@estado NVARCHAR(15),
@Album NVARCHAR(100)
AS
BEGIN
    BEGIN TRY
        DECLARE @idAlbum CHAR(4)

        IF EXISTS (
            SELECT 1 
            FROM Musica.Cancion
            WHERE idCancion = @IdCancion
        )
        BEGIN
            THROW 50031, 'La cancion ya existe.', 1;
        END

        IF @duracion <= 0
        BEGIN
            THROW 50032, 'La duracion debe ser mayor a 0.', 1;
        END

       IF @calidad NOT IN ('Estándar', 'Alta')
        BEGIN
            THROW 50033, 'Calidad Inválida', 1;
        END

       IF @estado NOT IN ('Activo', 'Inactivo')
        BEGIN
            THROW 50034, 'Estado Inválido', 1;
        END

        IF NOT EXISTS (
            SELECT 1 
            FROM Musica.Album
            WHERE nombreAlbum = @Album
        )
        BEGIN
            THROW 50035, 'El Album no existe.', 1;
        END
        
        SELECT @idAlbum = MA.idAlbum
        FROM  Musica.Album AS MA
        WHERE MA.nombreAlbum = @Album;

        INSERT INTO Musica.Cancion(idCancion, nombreCancion, duracionCancion, fechaLanzamientoCancion, calidadAudio, estadoCancion, idAlbum)
        VALUES(@IdCancion, @nombre, @duracion, @fechaLanzamiento,@calidad, @estado, @idAlbum)

    END TRY
    BEGIN CATCH
        SELECT 
            ERROR_NUMBER() AS ErrorNumber,
            ERROR_MESSAGE() AS ErrorMessage,
            ERROR_SEVERITY() AS ErrorSeverity,
            ERROR_STATE() AS ErrorState,
            ERROR_LINE() AS ErrorLine,
            ERROR_PROCEDURE() AS ErrorProcedure;
    END CATCH
END
GO

-- SELECT: VISTA PARA LISTAR CANIONES

CREATE VIEW vListadoDeCanciones
AS
SELECT MC.idCancion AS IdCancion,MC.nombreCancion AS Cancion, MC.duracionCancion AS Duracion, MC.fechaLanzamientoCancion AS FechaDeLanzamiento,
MC.calidadAudio AS CalidadDeAudio, MC.estadoCancion AS Estado
FROM Musica.Cancion AS MC
GO			

-- UPDATE: PROCEDIMIENTO PARA ACTUALIZAR CANCIONES

CREATE PROCEDURE SP_ActualizarCancion
@IdCancion CHAR(4),
@nombre NVARCHAR(100) = NULL,
@duracion INT = NULL,
@fechaLanzamiento DATE = NULL,
@calidad NVARCHAR(100) = NULL,
@estado NVARCHAR(15) = NULL,
@Album NVARCHAR(100) = NULL
AS
BEGIN
    BEGIN TRY
        DECLARE @idAlbum CHAR(4)

        IF NOT EXISTS (
            SELECT 1 
            FROM Musica.Cancion
            WHERE idCancion = @IdCancion
        )
        BEGIN
            THROW 50035, 'La cancion no existe.', 1;
        END

        IF @duracion <= 0
        BEGIN
            THROW 50032, 'La duracion debe ser mayor a 0.', 1;
        END

       IF @calidad NOT IN ('Estándar', 'Alta')
        BEGIN
            THROW 50033, 'Calidad Inválida', 1;
        END

       IF @estado NOT IN ('Activo', 'Inactivo')
        BEGIN
            THROW 50034, 'Estado Inválido', 1;
        END

        IF @Album IS NOT NULL
        BEGIN
            IF NOT EXISTS (
                SELECT 1 
                FROM Musica.Album
                WHERE nombreAlbum = @Album
            )
            BEGIN
                THROW 50035, 'El Album no existe.', 1;
            END
        
            SELECT @idAlbum = MA.idAlbum
            FROM  Musica.Album AS MA
            WHERE MA.nombreAlbum = @Album;
        END

        UPDATE Musica.Cancion
        SET
            nombreCancion = ISNULL(@nombre, nombreCancion),
            duracionCancion = ISNULL(@duracion, duracionCancion),
            fechaLanzamientoCancion = ISNULL(@fechaLanzamiento, fechaLanzamientoCancion),
            calidadAudio = ISNULL(@calidad, calidadAudio),
            estadoCancion = ISNULL(@estado, estadoCancion),
            idAlbum = ISNULL(@idAlbum, idAlbum)

        WHERE idCancion = @IdCancion

    END TRY
    BEGIN CATCH
        SELECT 
            ERROR_NUMBER() AS ErrorNumber,
            ERROR_MESSAGE() AS ErrorMessage,
            ERROR_SEVERITY() AS ErrorSeverity,
            ERROR_STATE() AS ErrorState,
            ERROR_LINE() AS ErrorLine,
            ERROR_PROCEDURE() AS ErrorProcedure;
    END CATCH
END
GO

-- DELETE: PROCEDIMIENTO PARA ELIMINAR CANCIONES

CREATE PROCEDURE SP_EliminarCancion
@IdCancion CHAR(4)
AS
BEGIN
    BEGIN TRY
        IF NOT EXISTS (
            SELECT 1 
            FROM Musica.Cancion
            WHERE idCancion = @IdCancion
        )
        BEGIN
            THROW 50035, 'La cancion no existe.', 1;
        END

        DELETE FROM Musica.Cancion
        WHERE idCancion = @IdCancion

    END TRY
    BEGIN CATCH
        SELECT 
            ERROR_NUMBER() AS ErrorNumber,
            ERROR_MESSAGE() AS ErrorMessage,
            ERROR_SEVERITY() AS ErrorSeverity,
            ERROR_STATE() AS ErrorState,
            ERROR_LINE() AS ErrorLine,
            ERROR_PROCEDURE() AS ErrorProcedure;
    END CATCH
END
GO
-- OBJETOS PROGRAMABLES OPERACIONES CRUD EN LA TABLA ALBUM ===============================================================================================================

-- INSERT: PROCEDIMIENTO PARA CREAR ÁLBUM

CREATE PROCEDURE SP_InsertarAlbum
    @idAlbum CHAR(4),
    @nombreAlbum NVARCHAR(100),
    @fechaLanzamiento DATE,
    @nombreArtista NVARCHAR(100)
AS
BEGIN
    BEGIN TRY
        DECLARE @idArtista CHAR(4)

        IF EXISTS (SELECT 1 FROM Musica.Album WHERE idAlbum = @idAlbum)
        BEGIN
            THROW 51001, 'El ID del Álbum ya existe.', 1;
        END
        IF NOT EXISTS (SELECT 1 FROM Musica.Artista WHERE nombreArtista = @nombreArtista)
        BEGIN
            THROW 51002, 'El artista especificado no existe.', 1;
        END

        SELECT @idArtista = idArtista 
        FROM Musica.Artista 
        WHERE nombreArtista = @nombreArtista;

        INSERT INTO Musica.Album (idAlbum, nombreAlbum, fechaLanzamientoAlbum, idArtista)
        VALUES (@idAlbum, @nombreAlbum, @fechaLanzamiento, @idArtista);

    END TRY
    BEGIN CATCH
        SELECT 
            ERROR_NUMBER() AS ErrorNumber,
            ERROR_MESSAGE() AS ErrorMessage,
            ERROR_SEVERITY() AS ErrorSeverity,
            ERROR_STATE() AS ErrorState,
            ERROR_LINE() AS ErrorLine,
            ERROR_PROCEDURE() AS ErrorProcedure;
    END CATCH
END
GO

-- SELECT: VISTA PARA LISTAR ÁLBUMES

CREATE VIEW vListadoDeAlbumes
AS
SELECT 
    A.idAlbum, 
    A.nombreAlbum, 
    A.fechaLanzamientoAlbum,
    A.idArtista,
    Art.nombreArtista
FROM Musica.Album AS A
INNER JOIN Musica.Artista AS Art ON A.idArtista = Art.idArtista;
GO

-- UPDATE: PROCEDIMIENTO PARA ACTUALIZAR ÁLBUM

CREATE PROCEDURE SP_ActualizarAlbum
    @idAlbum CHAR(4),
    @nombreAlbum NVARCHAR(100) = NULL,
    @fechaLanzamiento DATE = NULL
AS
BEGIN
    BEGIN TRY

        IF NOT EXISTS (SELECT 1 FROM Musica.Album WHERE idAlbum = @idAlbum)
        BEGIN
            THROW 51003, 'El Álbum que intenta modificar no existe.', 1;
        END


        UPDATE Musica.Album
        SET
            nombreAlbum = ISNULL(@nombreAlbum, nombreAlbum),
            fechaLanzamientoAlbum = ISNULL(@fechaLanzamiento, fechaLanzamientoAlbum)
        WHERE idAlbum = @idAlbum;

    END TRY
    BEGIN CATCH
        SELECT 
            ERROR_NUMBER() AS ErrorNumber,
            ERROR_MESSAGE() AS ErrorMessage,
            ERROR_SEVERITY() AS ErrorSeverity,
            ERROR_STATE() AS ErrorState,
            ERROR_LINE() AS ErrorLine,
            ERROR_PROCEDURE() AS ErrorProcedure;
    END CATCH
END
GO

-- DELETE: PROCEDIMIENTO PARA ELIMINAR ÁLBUM

CREATE PROCEDURE SP_EliminarAlbum
    @idAlbum CHAR(4)
AS
BEGIN
    BEGIN TRY

        IF NOT EXISTS (SELECT 1 FROM Musica.Album WHERE idAlbum = @idAlbum)
        BEGIN
            THROW 51003, 'El Álbum que intenta eliminar no existe.', 1;
        END

        IF EXISTS (SELECT 1 FROM Musica.Cancion WHERE idAlbum = @idAlbum)
        BEGIN
            THROW 51004, 'No se puede eliminar el álbum porque contiene canciones vinculadas.', 1;
        END

        DELETE FROM Musica.Album 
        WHERE idAlbum = @idAlbum;

    END TRY
    BEGIN CATCH
        SELECT 
            ERROR_NUMBER() AS ErrorNumber,
            ERROR_MESSAGE() AS ErrorMessage,
            ERROR_SEVERITY() AS ErrorSeverity,
            ERROR_STATE() AS ErrorState,
            ERROR_LINE() AS ErrorLine,
            ERROR_PROCEDURE() AS ErrorProcedure;
    END CATCH
END
GO

--========================================================================================================================================================================
--                                                                     CONSULTAS SQL                                                                                    --
--========================================================================================================================================================================

-- REPORTES PARA USUARIOS ================================================================================================================================================

-- TOP CANCIONES MAS ESCUCHADAS POR EL USUARIO
CREATE PROCEDURE SP_TopCancionesMasEscuchadas
@IdUsuario CHAR(4)
AS
BEGIN
    BEGIN TRY

        IF NOT EXISTS (
            SELECT 1 
            FROM Usuarios.Usuario 
            WHERE IdUsuario = @IdUsuario
        )
        BEGIN
            THROW 50015, 'El usuario no existe.', 1;
        END


        SELECT TOP 3 MC.nombreCancion AS Cancion, COUNT(OC.idCancion) AS Reproduciones
        FROM Usuarios.Usuario AS UU
        INNER JOIN Operaciones.ReproduccionCancion AS OC
        ON UU.IdUsuario = OC.IdUsuario
        INNER JOIN Musica.Cancion AS MC
        ON OC.idCancion = MC.idCancion
        WHERE UU.IdUsuario = @IdUsuario
        GROUP BY UU.nombreUsuario, MC.nombreCancion
        ORDER BY COUNT(OC.idCancion) DESC
    END TRY
    BEGIN CATCH
        SELECT 
            ERROR_NUMBER() AS ErrorNumber,
            ERROR_MESSAGE() AS ErrorMessage,
            ERROR_SEVERITY() AS ErrorSeverity,
            ERROR_STATE() AS ErrorState,
            ERROR_LINE() AS ErrorLine,
            ERROR_PROCEDURE() AS ErrorProcedure;
    END CATCH 
END
GO

-- ARTISTAS MAS ESCUCHADOS DEL MES POR EL USUARIO
CREATE PROCEDURE SP_ArtistasMasEscuchadosDelMes
@IdUsuario CHAR(4)
AS
BEGIN
    BEGIN TRY
        IF NOT EXISTS (
            SELECT 1 
            FROM Usuarios.Usuario 
            WHERE IdUsuario = @IdUsuario
        )
        BEGIN
            THROW 50016, 'El usuario no existe.', 1;
        END

        SELECT MA.nombreArtista AS Artista, SUM(OC.duracionReproduccion) AS DuracionReproduccionesTotal 
        FROM Musica.Artista AS MA
        INNER JOIN Musica.Album AS MB
        ON MA.idArtista = MB.idArtista
        INNER JOIN Musica.Cancion AS MC
        ON MB.idAlbum = MC.idAlbum
        INNER JOIN Operaciones.ReproduccionCancion AS OC
        ON MC.idCancion = OC.idCancion
        INNER JOIN Usuarios.Usuario AS UU
        ON OC.IdUsuario = UU.IdUsuario
        WHERE UU.IdUsuario = @IdUsuario AND MONTH(OC.fechaReproduccion) = MONTH(GETDATE()) AND YEAR(OC.fechaReproduccion) = YEAR(GETDATE())
        GROUP BY MA.nombreArtista
        ORDER BY SUM(OC.duracionReproduccion) DESC
    END TRY
    BEGIN CATCH
            SELECT 
            ERROR_NUMBER() AS ErrorNumber,
            ERROR_MESSAGE() AS ErrorMessage,
            ERROR_SEVERITY() AS ErrorSeverity,
            ERROR_STATE() AS ErrorState,
            ERROR_LINE() AS ErrorLine,
            ERROR_PROCEDURE() AS ErrorProcedure;
    END CATCH 
END
GO

-- HISTORIAL DE REPRODUCCIONES DEL USUARIO
CREATE PROCEDURE SP_HistorialDeReproducciones 
@IdUsuario CHAR(4)
AS
BEGIN
    BEGIN TRY
        IF NOT EXISTS (
            SELECT 1 
            FROM Usuarios.Usuario 
            WHERE IdUsuario = @IdUsuario
        )
        BEGIN
            THROW 50017, 'El usuario no existe.', 1;
        END
        SELECT MC.nombreCancion AS Cancion, OC.duracionReproduccion AS Duracion, OC.fechaReproduccion AS FechaReproduccion
        FROM Usuarios.Usuario AS UU
        INNER JOIN Operaciones.ReproduccionCancion AS OC
        ON UU.IdUsuario = OC.IdUsuario
        INNER JOIN Musica.Cancion AS MC
        ON OC.idCancion = MC.idCancion
        WHERE UU.IdUsuario = @IdUsuario
        ORDER BY OC.fechaReproduccion ASC
    END TRY
    BEGIN CATCH
            SELECT 
            ERROR_NUMBER() AS ErrorNumber,
            ERROR_MESSAGE() AS ErrorMessage,
            ERROR_SEVERITY() AS ErrorSeverity,
            ERROR_STATE() AS ErrorState,
            ERROR_LINE() AS ErrorLine,
            ERROR_PROCEDURE() AS ErrorProcedure;
    END CATCH 
END
GO

-- PLAYLIST CREADAS POR EL USUARIO
CREATE PROCEDURE SP_PlaylistCreadasPorUsuario 
@IdUsuario CHAR(4)
AS
BEGIN
    BEGIN TRY
        IF NOT EXISTS (
            SELECT 1 
            FROM Usuarios.Usuario 
            WHERE IdUsuario = @IdUsuario
        )
        BEGIN
            THROW 50018, 'El usuario no existe.', 1;
        END
        SELECT UP.nombrePlaylist AS PlaylistCreadas
        FROM Usuarios.Usuario AS UU
        INNER JOIN Usuarios.Playlist AS UP
        ON UU.IdUsuario = @IdUsuario
    END TRY
    BEGIN CATCH
            SELECT 
            ERROR_NUMBER() AS ErrorNumber,
            ERROR_MESSAGE() AS ErrorMessage,
            ERROR_SEVERITY() AS ErrorSeverity,
            ERROR_STATE() AS ErrorState,
            ERROR_LINE() AS ErrorLine,
            ERROR_PROCEDURE() AS ErrorProcedure;
    END CATCH 
END
GO

-- CANCIONES QUE AL USUARIO HA DADO LIKE
CREATE PROCEDURE SP_CancionesConLike
@IdUsuario CHAR(4)
AS
BEGIN
    BEGIN TRY
        IF NOT EXISTS (
            SELECT 1 
            FROM Usuarios.Usuario 
            WHERE IdUsuario = @IdUsuario
        )
        BEGIN
            THROW 50019, 'El usuario no existe.', 1;
        END
        SELECT MC.nombreCancion AS CancionesConLike
        FROM Musica.Cancion AS MC
        INNER JOIN Usuarios.LikeCancion AS UK
        ON MC.idCancion = UK.idCancion
        INNER JOIN Usuarios.Usuario AS UU
        ON UK.IdUsuario = UU.IdUsuario
        WHERE UU.IdUsuario =@IdUsuario 
        GROUP BY MC.nombreCancion
    END TRY
    BEGIN CATCH
            SELECT 
            ERROR_NUMBER() AS ErrorNumber,
            ERROR_MESSAGE() AS ErrorMessage,
            ERROR_SEVERITY() AS ErrorSeverity,
            ERROR_STATE() AS ErrorState,
            ERROR_LINE() AS ErrorLine,
            ERROR_PROCEDURE() AS ErrorProcedure;
    END CATCH 
END
GO

-- ALBUMES GUARDADOS POR EL USUARIO
ALTER PROCEDURE SP_AlbumesGuardados
@IdUsuario CHAR(4)
AS
BEGIN
    BEGIN TRY
        IF NOT EXISTS (
            SELECT 1 
            FROM Usuarios.Usuario 
            WHERE IdUsuario = @IdUsuario
        )
        BEGIN
            THROW 50020, 'El usuario no existe.', 1;
        END
        SELECT MA.idAlbum, MA.nombreAlbum AS AlbumesGuardados, MAR.nombreArtista AS Artista
        FROM Musica.Album AS MA
        INNER JOIN Usuarios.AlbumGuardado AS UA
        ON MA.idAlbum = UA.idAlbum
        INNER JOIN Usuarios.Usuario AS UU
        ON UA.IdUsuario = UU.IdUsuario
        INNER JOIN Musica.Artista AS MAR
        ON MA.idArtista = MAR.idArtista
        WHERE UU.IdUsuario= @IdUsuario
        GROUP BY MA.idAlbum, MA.nombreAlbum, MAR.nombreArtista
    END TRY
    BEGIN CATCH
            SELECT 
            ERROR_NUMBER() AS ErrorNumber,
            ERROR_MESSAGE() AS ErrorMessage,
            ERROR_SEVERITY() AS ErrorSeverity,
            ERROR_STATE() AS ErrorState,
            ERROR_LINE() AS ErrorLine,
            ERROR_PROCEDURE() AS ErrorProcedure;
    END CATCH 
END
GO

-- ARTISTAS SEGUIDOS POR EL USUARIO
ALTER PROCEDURE SP_ArtistasSeguidos 
@IdUsuario CHAR(4)
AS
BEGIN
    BEGIN TRY
        IF NOT EXISTS (
            SELECT 1 
            FROM Usuarios.Usuario 
            WHERE IdUsuario = @IdUsuario
        )
        BEGIN
            THROW 50021, 'El usuario no existe.', 1;
        END
        SELECT MA.idArtista, MA.nombreArtista AS Artista
        FROM Musica.Artista AS MA
        INNER JOIN Usuarios.SeguimientoArtistas AS USA
        ON MA.idArtista = USA.idArtista
        INNER JOIN Usuarios.Usuario AS UU
        ON USA.IdUsuario = UU.IdUsuario
        WHERE UU.IdUsuario = @IdUsuario
        GROUP BY MA.idArtista, MA.nombreArtista
    END TRY
    BEGIN CATCH
            SELECT 
            ERROR_NUMBER() AS ErrorNumber,
            ERROR_MESSAGE() AS ErrorMessage,
            ERROR_SEVERITY() AS ErrorSeverity,
            ERROR_STATE() AS ErrorState,
            ERROR_LINE() AS ErrorLine,
            ERROR_PROCEDURE() AS ErrorProcedure;
    END CATCH 
END
GO

-- GENEROS MUSICALES FAVORITOS DEL USUARIO
CREATE PROCEDURE SP_GenerosMusicalesFavoritos
@IdUsuario CHAR(4)
AS
BEGIN
    BEGIN TRY
        IF NOT EXISTS (
            SELECT 1 
            FROM Usuarios.Usuario 
            WHERE IdUsuario = @IdUsuario
        )
        BEGIN
            THROW 50022, 'El usuario no existe.', 1;
        END
        SELECT MG.nombreGenero AS Genero, COUNT(OC.idCancion) AS CantidadCancionesEscuchadas
        FROM Usuarios.Usuario AS UU
        INNER JOIN Operaciones.ReproduccionCancion AS OC
        ON UU.IdUsuario = OC.IdUsuario
        INNER JOIN Musica.Cancion AS MC
        ON OC.idCancion = MC.idCancion
        INNER JOIN Musica.CancionGenero AS MCG
        ON MC.idCancion = MCG.idCancion
        INNER JOIN Musica.Genero AS MG
        ON MCG.idGenero = MG.idGenero
        where uu.IdUsuario = @IdUsuario
        GROUP BY MG.nombreGenero
        ORDER BY COUNT(OC.idCancion) DESC
    END TRY
    BEGIN CATCH
            SELECT 
            ERROR_NUMBER() AS ErrorNumber,
            ERROR_MESSAGE() AS ErrorMessage,
            ERROR_SEVERITY() AS ErrorSeverity,
            ERROR_STATE() AS ErrorState,
            ERROR_LINE() AS ErrorLine,
            ERROR_PROCEDURE() AS ErrorProcedure;
    END CATCH 
END
GO


-- RECOMENDACIONES BASADAS EN GENEROS FAVORITOS
CREATE PROCEDURE SP_Redomendaciones
@IdUsuario CHAR(4)
AS
BEGIN
    BEGIN TRY
        IF NOT EXISTS (
            SELECT 1 
            FROM Usuarios.Usuario 
            WHERE IdUsuario = @IdUsuario
        )
        BEGIN
            THROW 50023, 'El usuario no existe.', 1;
        END
        SELECT TOP 5 MC.nombreCancion AS Recomendacion, G.nombreGenero AS Genero, MAR.nombreArtista AS Artista
        FROM Musica.Cancion MC
        INNER JOIN Musica.CancionGenero CG 
        ON MC.idCancion = CG.idCancion
        INNER JOIN Musica.Genero G 
        ON CG.idGenero = G.idGenero
        INNER JOIN Musica.Album MA
        ON MC.idAlbum = MA.idAlbum
        INNER JOIN Musica.Artista MAR
        ON MA.idArtista = MAR.idArtista
        WHERE G.idGenero IN (
            SELECT TOP 3 MG.idGenero
            FROM Usuarios.Usuario UU
            INNER JOIN Operaciones.ReproduccionCancion OC 
            ON UU.IdUsuario = OC.IdUsuario
            INNER JOIN Musica.Cancion C 
            ON OC.idCancion = C.idCancion
            INNER JOIN Musica.CancionGenero CG2 
            ON C.idCancion = CG2.idCancion
            INNER JOIN Musica.Genero MG 
            ON CG2.idGenero = MG.idGenero
            WHERE UU.IdUsuario = @IdUsuario
            GROUP BY MG.idGenero
            ORDER BY COUNT(*) DESC
        )
        AND MC.idCancion NOT IN (
            SELECT idCancion
            FROM Operaciones.ReproduccionCancion OC
            INNER JOIN Usuarios.Usuario UU 
            ON OC.IdUsuario = UU.IdUsuario
            WHERE UU.IdUsuario = @IdUsuario
        )
    END TRY
    BEGIN CATCH
            SELECT 
            ERROR_NUMBER() AS ErrorNumber,
            ERROR_MESSAGE() AS ErrorMessage,
            ERROR_SEVERITY() AS ErrorSeverity,
            ERROR_STATE() AS ErrorState,
            ERROR_LINE() AS ErrorLine,
            ERROR_PROCEDURE() AS ErrorProcedure;
    END CATCH 
END
GO


-- TIEMPO TOTAL DE ESCUCHA POR SEMANA O MES

-- MES
CREATE PROCEDURE SP_TiempoEscuchaPorMes
@IdUsuario CHAR(4)
AS
BEGIN
    BEGIN TRY
        IF NOT EXISTS (
            SELECT 1 
            FROM Usuarios.Usuario 
            WHERE IdUsuario = @IdUsuario
        )
        BEGIN
            THROW 50024, 'El usuario no existe.', 1;
        END
        SELECT SUM(OC.duracionReproduccion) AS TiempoTotalporMes
        FROM Operaciones.ReproduccionCancion AS OC
        INNER JOIN Usuarios.Usuario AS UU
        ON OC.IdUsuario = UU.IdUsuario
        WHERE UU.IdUsuario = @IdUsuario AND MONTH(OC.fechaReproduccion) = MONTH(GETDATE()) AND YEAR(OC.fechaReproduccion) = YEAR(GETDATE())
   END TRY
    BEGIN CATCH
            SELECT 
            ERROR_NUMBER() AS ErrorNumber,
            ERROR_MESSAGE() AS ErrorMessage,
            ERROR_SEVERITY() AS ErrorSeverity,
            ERROR_STATE() AS ErrorState,
            ERROR_LINE() AS ErrorLine,
            ERROR_PROCEDURE() AS ErrorProcedure;
    END CATCH 
END
GO

-- SEMANA
CREATE PROCEDURE SP_TiempoEscuchaPorSemana
@IdUsuario CHAR(4)
AS
BEGIN
    BEGIN TRY
        IF NOT EXISTS (
            SELECT 1 
            FROM Usuarios.Usuario 
            WHERE IdUsuario = @IdUsuario
        )
        BEGIN
            THROW 50025, 'El usuario no existe.', 1;
        END
        SELECT ISNULL(SUM(OC.duracionReproduccion),0) AS TiempoTotalporSemana
        FROM Operaciones.ReproduccionCancion AS OC
        INNER JOIN Usuarios.Usuario AS UU
        ON OC.IdUsuario = UU.IdUsuario
        WHERE UU.IdUsuario = @IdUsuario  AND DATEPART(WEEK, OC.fechaReproduccion) = DATEPART(WEEK, GETDATE()) AND YEAR(OC.fechaReproduccion) = YEAR(GETDATE())
    END TRY
    BEGIN CATCH
            SELECT 
            ERROR_NUMBER() AS ErrorNumber,
            ERROR_MESSAGE() AS ErrorMessage,
            ERROR_SEVERITY() AS ErrorSeverity,
            ERROR_STATE() AS ErrorState,
            ERROR_LINE() AS ErrorLine,
            ERROR_PROCEDURE() AS ErrorProcedure;
    END CATCH 
END
GO

-- REPORTES PARA ARTISTAS =================================================================================================================================================

-- NUMERO DE REPRODUCCIONES POR CANCION
CREATE PROCEDURE SP_ReproduccionesPorCancion
@IdArtista CHAR(4)
AS
BEGIN
    BEGIN TRY
        IF NOT EXISTS (
            SELECT 1 
            FROM Musica.Artista 
            WHERE idArtista = @IdArtista
        )
        BEGIN
            THROW 50026, 'El artista no existe.', 1;
        END
        SELECT MC.nombreCancion AS Cancion, COUNT(OC.idCancion) AS NumeroReproducciones
        FROM Operaciones.ReproduccionCancion AS OC
        INNER JOIN Musica.Cancion AS MC
        ON OC.idCancion = MC.idCancion
        INNER JOIN Musica.Album AS MA
        ON MC.idAlbum = MA.idAlbum
        INNER JOIN Musica.Artista AS MAR
        ON MA.idArtista = MAR.idArtista
        WHERE MAR.idArtista = @IdArtista 
        GROUP BY MC.nombreCancion
    END TRY
    BEGIN CATCH
            SELECT 
            ERROR_NUMBER() AS ErrorNumber,
            ERROR_MESSAGE() AS ErrorMessage,
            ERROR_SEVERITY() AS ErrorSeverity,
            ERROR_STATE() AS ErrorState,
            ERROR_LINE() AS ErrorLine,
            ERROR_PROCEDURE() AS ErrorProcedure;
    END CATCH 
END

-- TOP CANCIONES DEL ARTISTA
CREATE PROCEDURE SP_TopCanciones
@IdArtista CHAR(4)
AS
BEGIN
    BEGIN TRY
        IF NOT EXISTS (
            SELECT 1 
            FROM Musica.Artista 
            WHERE idArtista = @IdArtista
        )
        BEGIN
            THROW 50027, 'El artista no existe.', 1;
        END
        SELECT TOP 3 MC.nombreCancion AS Cancion, COUNT(OC.idCancion) AS NumeroReproduccions
        FROM Operaciones.ReproduccionCancion AS OC
        INNER JOIN Musica.Cancion AS MC
        ON OC.idCancion = MC.idCancion
        INNER JOIN Musica.Album AS MA
        ON MC.idAlbum = MA.idAlbum
        INNER JOIN Musica.Artista AS MAR
        ON MA.idArtista = MAR.idArtista
        WHERE MAR.idArtista = @IdArtista
        GROUP BY MC.nombreCancion
    END TRY
    BEGIN CATCH
            SELECT 
            ERROR_NUMBER() AS ErrorNumber,
            ERROR_MESSAGE() AS ErrorMessage,
            ERROR_SEVERITY() AS ErrorSeverity,
            ERROR_STATE() AS ErrorState,
            ERROR_LINE() AS ErrorLine,
            ERROR_PROCEDURE() AS ErrorProcedure;
    END CATCH 
END

-- OYENTES MENSUALES DEL ARTISTA
CREATE PROCEDURE SP_OyentesMensuales
@IdArtista CHAR(4)
AS
BEGIN
    BEGIN TRY
        IF NOT EXISTS (
            SELECT 1 
            FROM Musica.Artista 
            WHERE idArtista = @IdArtista
        )
        BEGIN
            THROW 50028, 'El artista no existe.', 1;
        END
        SELECT COUNT(DISTINCT OC.IdUsuario) AS Oyentes
        FROM Operaciones.ReproduccionCancion AS OC
        INNER JOIN Musica.Cancion AS MC
        ON OC.idCancion = MC.idCancion
        INNER JOIN Musica.Album AS MA
        ON MC.idAlbum = MA.idAlbum
        INNER JOIN Musica.Artista AS MAR
        ON MA.idArtista = MAR.idArtista
        WHERE MAR.idArtista= @IdArtista
        AND MONTH(OC.fechaReproduccion) = MONTH(GETDATE()) AND YEAR(OC.fechaReproduccion) = YEAR(GETDATE())
        GROUP BY MAR.nombreArtista
        ORDER BY COUNT(OC.IdUsuario) DESC
    END TRY
    BEGIN CATCH
            SELECT 
            ERROR_NUMBER() AS ErrorNumber,
            ERROR_MESSAGE() AS ErrorMessage,
            ERROR_SEVERITY() AS ErrorSeverity,
            ERROR_STATE() AS ErrorState,
            ERROR_LINE() AS ErrorLine,
            ERROR_PROCEDURE() AS ErrorProcedure;
    END CATCH 
END

-- PAIS DONDE MAS SE ESCUCHA AL ARTISTA
CREATE PROCEDURE SP_PaisMasEscuchado
@IdArtista CHAR(4)
AS
BEGIN
    BEGIN TRY
        IF NOT EXISTS (
            SELECT 1 
            FROM Musica.Artista 
            WHERE idArtista = @IdArtista
        )
        BEGIN
            THROW 50029, 'El artista no existe.', 1;
        END

        SELECT TOP 1 OC.paisReproduccion AS PaisMasEscuchado, COUNT(DISTINCT OC.IdUsuario) AS Oyentes
        FROM Operaciones.ReproduccionCancion AS OC
        INNER JOIN Musica.Cancion AS MC
        ON OC.idCancion = MC.idCancion
        INNER JOIN Musica.Album AS MA
        ON MC.idAlbum = MA.idAlbum
        INNER JOIN Musica.Artista AS MAR
        ON MA.idArtista = MAR.idArtista
        WHERE MAR.idArtista = @IdArtista
        GROUP BY OC.paisReproduccion
        ORDER BY COUNT(DISTINCT OC.IdUsuario) DESC
   END TRY
    BEGIN CATCH
            SELECT 
            ERROR_NUMBER() AS ErrorNumber,
            ERROR_MESSAGE() AS ErrorMessage,
            ERROR_SEVERITY() AS ErrorSeverity,
            ERROR_STATE() AS ErrorState,
            ERROR_LINE() AS ErrorLine,
            ERROR_PROCEDURE() AS ErrorProcedure;
    END CATCH 
END
--========================================================================================================================================================================
--                                                                  PRUEBAS UNITARIAS                                                                                   --
--========================================================================================================================================================================

-- Pruebas aplicadas inicialmente sobre los Store procedures para verificar el correcto funcionamiento de las sentencias IF y TRY-CATCH:

-- Prueba con un usuario con suscripcion activa:
    EXEC SP_CrearSuscripcion 
    @idSuscripcion = 'S011',
    @idPago = 'P011',
    @idUsuario = 'U001' ,
    @tipoSuscripcion = 'Familiar' ,
    @monto = 14.99,
    @metodo = 'Tarjeta de Credito',
    @resultado = 'Aprobado' 

-- Prueba de inserción exitosa de un suscripcion con estado "Cancelada".
    EXEC SP_CrearSuscripcion 
    @idSuscripcion = 'S011',
    @idPago = 'P011',
    @idUsuario = 'U009' ,
    @tipoSuscripcion = 'Familiar' ,
    @monto = 14.99,
    @metodo = 'Tarjeta de Credito',
    @resultado = 'Aprobado'

-- Prueba de registro de resultado de pago "Fallido":
    EXEC SP_CrearSuscripcion 
    @idSuscripcion = 'S012',
    @idPago = 'P012',
    @idUsuario = 'U008' ,
    @tipoSuscripcion = 'Familiar' ,
    @monto = 14.99,
    @metodo = 'Tarjeta de Credito',
    @resultado = 'Fallido'

-- Prueba de inserción de una cancion con estado "Inactivo":
    EXEC SP_RegistrarReproduccion
    @idCancion ='C021',
    @IdUsuario = 'U001', 
    @paisReproduccion = 'Ecuador',
    @duracion = 100

-- Prueba de ingreso de regalia
EXEC SP_GenerarRegalias
    @IdRegalia = 'R006',
    @IdArtista = 'A003',
    @fechaInicio = '2026-04-27',
    @fechaFin = '2026-05-27'  

-- Prueba de ingreo de regalia en una fecha cruzada
    EXEC SP_GenerarRegalias
    @IdRegalia = 'R008',
    @IdArtista = 'A001',
    @fechaInicio = '2026-03-02',
    @fechaFin = '2026-03-30'  

-- Prueba de ingreso de un correo duplicado
    EXEC SP_CrearUsuario
    @IdUsuario = 'U011',
    @correo = 'diego.a@mail.ec',
    @contraseña = 'Hola12',
    @nombre = 'Diego Lopez'

-- priueba de ingreso de un nombre repetido
    EXEC SP_CrearUsuario
    @IdUsuario = 'U011',
    @correo = 'diegolopez.a@mail.ec',
    @contraseña = 'Hola12',
    @nombre = 'Diego Aguirre'

