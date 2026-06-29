-- ============================================================
-- Sistema de Gestión de Biblioteca - Grupo 23
-- Setup completo: tablas, vistas, triggers, procedimientos
--                 almacenados y datos de prueba
-- Microsoft SQL Server
-- ============================================================


-- ============================================================
-- 1. BASE DE DATOS Y TABLAS
-- ============================================================

USE master;
GO

IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'Grupo23Biblioteca')
BEGIN
    CREATE DATABASE Grupo23Biblioteca;
END
GO

USE Grupo23Biblioteca;
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.ROL') AND type = 'U')
BEGIN
    CREATE TABLE ROL (
        IDRol        INT           IDENTITY(1,1) PRIMARY KEY,
        NombreRol    VARCHAR(50)   NOT NULL
    );
END
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.USUARIO') AND type = 'U')
BEGIN
    CREATE TABLE USUARIO (
        IDUsuario      INT           IDENTITY(1,1) PRIMARY KEY,
        IDRol          INT           NOT NULL,
        Nombre         VARCHAR(100)  NOT NULL,
        Apellido       VARCHAR(100)  NOT NULL,
        Email          VARCHAR(150)  NOT NULL UNIQUE,
        Telefono       VARCHAR(20)   NULL,
        FechaRegistro  DATE          NOT NULL DEFAULT CAST(GETDATE() AS DATE),
        CONSTRAINT FK_USUARIO_ROL FOREIGN KEY (IDRol) REFERENCES ROL(IDRol)
    );
END
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.CATEGORIA') AND type = 'U')
BEGIN
    CREATE TABLE CATEGORIA (
        IDCategoria      INT           IDENTITY(1,1) PRIMARY KEY,
        NombreCategoria  VARCHAR(100)  NOT NULL
    );
END
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.EDITORIAL') AND type = 'U')
BEGIN
    CREATE TABLE EDITORIAL (
        IDEditorial      INT           IDENTITY(1,1) PRIMARY KEY,
        NombreEditorial  VARCHAR(150)  NOT NULL,
        Pais             VARCHAR(100)  NULL
    );
END
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.AUTOR') AND type = 'U')
BEGIN
    CREATE TABLE AUTOR (
        IDAutor       INT           IDENTITY(1,1) PRIMARY KEY,
        Nombre        VARCHAR(100)  NOT NULL,
        Apellido      VARCHAR(100)  NOT NULL,
        Nacionalidad  VARCHAR(100)  NULL
    );
END
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.LIBRO') AND type = 'U')
BEGIN
    CREATE TABLE LIBRO (
        IDLibro           INT           IDENTITY(1,1) PRIMARY KEY,
        IDEditorial       INT           NOT NULL,
        IDCategoria       INT           NOT NULL,
        Titulo            VARCHAR(300)  NOT NULL,
        ISBN              VARCHAR(20)   NOT NULL UNIQUE,
        FechaLanzamiento  DATE          NULL,
        CONSTRAINT FK_LIBRO_EDITORIAL  FOREIGN KEY (IDEditorial) REFERENCES EDITORIAL(IDEditorial),
        CONSTRAINT FK_LIBRO_CATEGORIA  FOREIGN KEY (IDCategoria) REFERENCES CATEGORIA(IDCategoria)
    );
END
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.LIBRO_AUTOR') AND type = 'U')
BEGIN
    CREATE TABLE LIBRO_AUTOR (
        IDLibro  INT  NOT NULL,
        IDAutor  INT  NOT NULL,
        CONSTRAINT PK_LIBRO_AUTOR       PRIMARY KEY (IDLibro, IDAutor),
        CONSTRAINT FK_LIBROAUTOR_LIBRO  FOREIGN KEY (IDLibro) REFERENCES LIBRO(IDLibro),
        CONSTRAINT FK_LIBROAUTOR_AUTOR  FOREIGN KEY (IDAutor) REFERENCES AUTOR(IDAutor)
    );
END
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.ESTADO') AND type = 'U')
BEGIN
    CREATE TABLE ESTADO (
        IDEstado     INT          IDENTITY(1,1) PRIMARY KEY,
        NombreEstado VARCHAR(50)  NOT NULL UNIQUE
    );

    INSERT INTO ESTADO (NombreEstado) VALUES
        ('Disponible'),
        ('Prestado'),
        ('Dañado'),
        ('Baja');
END
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.EJEMPLAR') AND type = 'U')
BEGIN
    CREATE TABLE EJEMPLAR (
        IDEjemplar      INT          IDENTITY(1,1) PRIMARY KEY,
        IDLibro         INT          NOT NULL,
        IDEstado        INT          NOT NULL,
        CodigoEjemplar  VARCHAR(50)  NOT NULL UNIQUE,
        CONSTRAINT FK_EJEMPLAR_LIBRO   FOREIGN KEY (IDLibro)  REFERENCES LIBRO(IDLibro),
        CONSTRAINT FK_EJEMPLAR_ESTADO  FOREIGN KEY (IDEstado) REFERENCES ESTADO(IDEstado)
    );
END
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.PRESTAMO') AND type = 'U')
BEGIN
    CREATE TABLE PRESTAMO (
        IDPrestamo              INT   IDENTITY(1,1) PRIMARY KEY,
        IDUsuario               INT   NOT NULL,
        IDEjemplar              INT   NOT NULL,
        FechaPrestamo           DATE  NOT NULL DEFAULT CAST(GETDATE() AS DATE),
        FechaDevolucionEstimada DATE  NOT NULL,
        CONSTRAINT FK_PRESTAMO_USUARIO   FOREIGN KEY (IDUsuario)  REFERENCES USUARIO(IDUsuario),
        CONSTRAINT FK_PRESTAMO_EJEMPLAR  FOREIGN KEY (IDEjemplar) REFERENCES EJEMPLAR(IDEjemplar)
    );
END
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.DEVOLUCION') AND type = 'U')
BEGIN
    CREATE TABLE DEVOLUCION (
        IDDevolucion    INT           IDENTITY(1,1) PRIMARY KEY,
        IDPrestamo      INT           NOT NULL UNIQUE,
        FechaDevolucion DATE          NOT NULL,
        Observaciones   VARCHAR(500)  NULL,
        CONSTRAINT FK_DEVOLUCION_PRESTAMO FOREIGN KEY (IDPrestamo) REFERENCES PRESTAMO(IDPrestamo)
    );
END
GO


-- ============================================================
-- 2. VISTAS
-- (deben existir antes que los SPs que las referencian)
-- ============================================================

CREATE OR ALTER VIEW vw_LibrosDisponibles AS
SELECT
    L.IDLibro,
    L.Titulo,
    L.ISBN,
    COUNT(E.IDEjemplar) AS Cantidad_Disponible
FROM LIBRO AS L
INNER JOIN EJEMPLAR AS E   ON L.IDLibro  = E.IDLibro
INNER JOIN ESTADO   AS EST ON E.IDEstado = EST.IDEstado
WHERE EST.NombreEstado = 'Disponible'
GROUP BY L.IDLibro, L.Titulo, L.ISBN;
GO

CREATE OR ALTER VIEW vw_PrestamosActivos AS
SELECT
    P.IDPrestamo,
    U.Nombre + ' ' + U.Apellido AS Usuario,
    U.Email,
    L.Titulo,
    E.CodigoEjemplar,
    P.FechaPrestamo,
    P.FechaDevolucionEstimada,
    DATEDIFF(DAY, GETDATE(), P.FechaDevolucionEstimada) AS DiasRestantes
FROM PRESTAMO P
INNER JOIN USUARIO     U ON P.IDUsuario  = U.IDUsuario
INNER JOIN EJEMPLAR    E ON P.IDEjemplar = E.IDEjemplar
INNER JOIN LIBRO       L ON E.IDLibro    = L.IDLibro
LEFT  JOIN DEVOLUCION  D ON P.IDPrestamo = D.IDPrestamo
WHERE D.IDPrestamo IS NULL;
GO

CREATE OR ALTER VIEW vw_PrestamosAtrasados AS
SELECT
    P.IDPrestamo,
    P.IDUsuario,
    U.Nombre + ' ' + U.Apellido AS Nombre_Completo,
    U.Email,
    P.IDEjemplar,
    E.CodigoEjemplar,
    P.FechaPrestamo,
    P.FechaDevolucionEstimada,
    DATEDIFF(DAY, P.FechaDevolucionEstimada, CAST(GETDATE() AS DATE)) AS Dias_Atraso
FROM PRESTAMO P
INNER JOIN  USUARIO    U ON P.IDUsuario  = U.IDUsuario
INNER JOIN  EJEMPLAR   E ON P.IDEjemplar = E.IDEjemplar
LEFT  JOIN  DEVOLUCION D ON P.IDPrestamo = D.IDPrestamo
WHERE  D.IDPrestamo IS NULL
AND  P.FechaDevolucionEstimada < CAST(GETDATE() AS DATE);
GO

CREATE OR ALTER VIEW vw_UsuariosConPrestamos AS
SELECT
    U.IDUsuario,
    U.Nombre,
    U.Apellido,
    U.Email,
    U.Telefono,
    COUNT(P.IDPrestamo) AS Cantidad_Prestamos
FROM USUARIO U
INNER JOIN  PRESTAMO   P ON U.IDUsuario  = P.IDUsuario
LEFT  JOIN  DEVOLUCION D ON P.IDPrestamo = D.IDPrestamo
WHERE D.IDPrestamo IS NULL
GROUP BY U.IDUsuario, U.Nombre, U.Apellido, U.Email, U.Telefono;
GO

CREATE OR ALTER VIEW vw_InformacionLibros AS
SELECT
    L.IDLibro,
    L.Titulo,
    L.ISBN,
    L.FechaLanzamiento,
    E.NombreEditorial,
    E.Pais AS PaisEditorial,
    C.NombreCategoria,
    A.Nombre + ' ' + A.Apellido AS Autor,
    (SELECT COUNT(*) FROM EJEMPLAR EJ WHERE EJ.IDLibro = L.IDLibro) AS Total_Ejemplares
FROM LIBRO L
INNER JOIN EDITORIAL   E  ON L.IDEditorial = E.IDEditorial
INNER JOIN CATEGORIA   C  ON L.IDCategoria = C.IDCategoria
INNER JOIN LIBRO_AUTOR LA ON L.IDLibro     = LA.IDLibro
INNER JOIN AUTOR       A  ON LA.IDAutor    = A.IDAutor;
GO


-- ============================================================
-- 3. TRIGGERS
-- ============================================================

CREATE TRIGGER trg_Prestamo_MarcarEjemplar
ON PRESTAMO
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE E
    SET    E.IDEstado = EST.IDEstado
    FROM   EJEMPLAR E
    INNER JOIN inserted    I   ON  E.IDEjemplar    = I.IDEjemplar
    INNER JOIN ESTADO      EST ON  EST.NombreEstado = 'Prestado';
END;
GO

CREATE TRIGGER trg_Devolucion_LiberarEjemplar
ON DEVOLUCION
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE E
    SET    E.IDEstado = EST.IDEstado
    FROM   EJEMPLAR  E
    INNER JOIN PRESTAMO    P   ON  E.IDEjemplar    = P.IDEjemplar
    INNER JOIN inserted    I   ON  P.IDPrestamo    = I.IDPrestamo
    INNER JOIN ESTADO      EST ON  EST.NombreEstado = 'Disponible';
END;
GO


-- ============================================================
-- 4. PROCEDIMIENTOS ALMACENADOS GENERALES
-- ============================================================

-- ROLES
CREATE PROCEDURE SP_InsertarRol
    @NombreRol VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (SELECT 1 FROM ROL WHERE NombreRol = @NombreRol)
    BEGIN
        RAISERROR('Ya existe un rol con ese nombre.', 16, 1);
        RETURN;
    END
    INSERT INTO ROL (NombreRol) VALUES (@NombreRol);
    SELECT SCOPE_IDENTITY() AS IDRol;
END
GO

CREATE PROCEDURE sp_ActualizarRol
    @IDRol     INT,
    @NombreRol VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS (SELECT 1 FROM ROL WHERE IDRol = @IDRol)
    BEGIN
        RAISERROR('El rol especificado no existe.', 16, 1);
        RETURN;
    END
    UPDATE ROL SET NombreRol = @NombreRol WHERE IDRol = @IDRol;
END
GO

CREATE PROCEDURE sp_EliminarRol
    @IDRol INT
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (SELECT 1 FROM USUARIO WHERE IDRol = @IDRol)
    BEGIN
        RAISERROR('No se puede eliminar el rol porque tiene usuarios asociados.', 16, 1);
        RETURN;
    END
    DELETE FROM ROL WHERE IDRol = @IDRol;
END
GO

CREATE PROCEDURE sp_ObtenerRoles
AS
BEGIN
    SET NOCOUNT ON;
    SELECT IDRol, NombreRol FROM ROL ORDER BY NombreRol;
END
GO

-- USUARIOS
CREATE PROCEDURE sp_InsertarUsuario
    @IDRol     INT,
    @Nombre    VARCHAR(100),
    @Apellido  VARCHAR(100),
    @Email     VARCHAR(150),
    @Telefono  VARCHAR(20) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF NOT EXISTS (SELECT 1 FROM ROL WHERE IDRol = @IDRol)
            THROW 50001, 'El rol especificado no existe.', 1;

        IF EXISTS (SELECT 1 FROM USUARIO WHERE Email = @Email)
            THROW 50002, 'Ya existe un usuario registrado con ese email.', 1;

        INSERT INTO USUARIO (IDRol, Nombre, Apellido, Email, Telefono, FechaRegistro)
        VALUES (@IDRol, @Nombre, @Apellido, @Email, @Telefono, CAST(GETDATE() AS DATE));

        DECLARE @NuevoID INT = SCOPE_IDENTITY();
        COMMIT TRANSACTION;
        SELECT @NuevoID AS IDUsuario;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

CREATE PROCEDURE sp_ActualizarUsuario
    @IDUsuario INT,
    @IDRol     INT,
    @Nombre    VARCHAR(100),
    @Apellido  VARCHAR(100),
    @Email     VARCHAR(150),
    @Telefono  VARCHAR(20) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF NOT EXISTS (SELECT 1 FROM USUARIO WHERE IDUsuario = @IDUsuario)
            THROW 50003, 'El usuario especificado no existe.', 1;

        IF NOT EXISTS (SELECT 1 FROM ROL WHERE IDRol = @IDRol)
            THROW 50004, 'El rol especificado no existe.', 1;

        IF EXISTS (SELECT 1 FROM USUARIO WHERE Email = @Email AND IDUsuario <> @IDUsuario)
            THROW 50005, 'El email ya está en uso por otro usuario.', 1;

        UPDATE USUARIO
        SET IDRol = @IDRol, Nombre = @Nombre, Apellido = @Apellido,
            Email = @Email, Telefono = @Telefono
        WHERE IDUsuario = @IDUsuario;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

CREATE PROCEDURE sp_EliminarUsuario
    @IDUsuario INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF NOT EXISTS (SELECT 1 FROM USUARIO WHERE IDUsuario = @IDUsuario)
            THROW 50006, 'El usuario especificado no existe.', 1;

        IF EXISTS (SELECT 1 FROM PRESTAMO WHERE IDUsuario = @IDUsuario)
            THROW 50007, 'No se puede eliminar el usuario porque tiene préstamos asociados.', 1;

        DELETE FROM USUARIO WHERE IDUsuario = @IDUsuario;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

CREATE PROCEDURE sp_ObtenerUsuarios
AS
BEGIN
    SET NOCOUNT ON;
    SELECT U.IDUsuario, U.Nombre, U.Apellido, U.Email, U.Telefono, U.FechaRegistro, R.NombreRol
    FROM USUARIO U
    INNER JOIN ROL R ON U.IDRol = R.IDRol
    ORDER BY U.Apellido, U.Nombre;
END
GO

CREATE PROCEDURE sp_ObtenerUsuarioPorID
    @IDUsuario INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT U.IDUsuario, U.Nombre, U.Apellido, U.Email, U.Telefono, U.FechaRegistro,
           R.IDRol, R.NombreRol
    FROM USUARIO U
    INNER JOIN ROL R ON U.IDRol = R.IDRol
    WHERE U.IDUsuario = @IDUsuario;
END
GO

-- CATEGORIAS
CREATE PROCEDURE sp_InsertarCategoria
    @NombreCategoria VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (SELECT 1 FROM CATEGORIA WHERE NombreCategoria = @NombreCategoria)
    BEGIN
        RAISERROR('Ya existe una categoría con ese nombre.', 16, 1);
        RETURN;
    END
    INSERT INTO CATEGORIA (NombreCategoria) VALUES (@NombreCategoria);
    SELECT SCOPE_IDENTITY() AS IDCategoria;
END
GO

CREATE PROCEDURE sp_ActualizarCategoria
    @IDCategoria     INT,
    @NombreCategoria VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS (SELECT 1 FROM CATEGORIA WHERE IDCategoria = @IDCategoria)
    BEGIN
        RAISERROR('La categoría especificada no existe.', 16, 1);
        RETURN;
    END
    IF EXISTS (SELECT 1 FROM CATEGORIA WHERE NombreCategoria = @NombreCategoria AND IDCategoria <> @IDCategoria)
    BEGIN
        RAISERROR('Ya existe otra categoria con ese nombre.', 16, 1);
        RETURN;
    END
    UPDATE CATEGORIA SET NombreCategoria = @NombreCategoria WHERE IDCategoria = @IDCategoria;
END
GO

CREATE PROCEDURE sp_EliminarCategoria
    @IDCategoria INT
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (SELECT 1 FROM LIBRO WHERE IDCategoria = @IDCategoria)
    BEGIN
        RAISERROR('No se puede eliminar la categoría porque tiene libros asociados.', 16, 1);
        RETURN;
    END
    DELETE FROM CATEGORIA WHERE IDCategoria = @IDCategoria;
END
GO

CREATE PROCEDURE sp_ObtenerCategorias
AS
BEGIN
    SET NOCOUNT ON;
    SELECT IDCategoria, NombreCategoria FROM CATEGORIA ORDER BY NombreCategoria;
END
GO

-- EDITORIALES
CREATE PROCEDURE sp_InsertarEditorial
    @NombreEditorial VARCHAR(150),
    @Pais            VARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO EDITORIAL (NombreEditorial, Pais) VALUES (@NombreEditorial, @Pais);
    SELECT SCOPE_IDENTITY() AS IDEditorial;
END
GO

CREATE PROCEDURE sp_ActualizarEditorial
    @IDEditorial     INT,
    @NombreEditorial VARCHAR(150),
    @Pais            VARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS (SELECT 1 FROM EDITORIAL WHERE IDEditorial = @IDEditorial)
    BEGIN
        RAISERROR('La editorial especificada no existe.', 16, 1);
        RETURN;
    END
    UPDATE EDITORIAL SET NombreEditorial = @NombreEditorial, Pais = @Pais
    WHERE IDEditorial = @IDEditorial;
END
GO

CREATE PROCEDURE sp_EliminarEditorial
    @IDEditorial INT
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (SELECT 1 FROM LIBRO WHERE IDEditorial = @IDEditorial)
    BEGIN
        RAISERROR('No se puede eliminar la editorial porque tiene libros asociados.', 16, 1);
        RETURN;
    END
    DELETE FROM EDITORIAL WHERE IDEditorial = @IDEditorial;
END
GO

CREATE PROCEDURE sp_ObtenerEditoriales
AS
BEGIN
    SET NOCOUNT ON;
    SELECT IDEditorial, NombreEditorial, Pais FROM EDITORIAL ORDER BY NombreEditorial;
END
GO

-- AUTORES
CREATE PROCEDURE sp_InsertarAutor
    @Nombre       VARCHAR(100),
    @Apellido     VARCHAR(100),
    @Nacionalidad VARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO AUTOR (Nombre, Apellido, Nacionalidad) VALUES (@Nombre, @Apellido, @Nacionalidad);
    SELECT SCOPE_IDENTITY() AS IDAutor;
END
GO

CREATE PROCEDURE sp_ActualizarAutor
    @IDAutor      INT,
    @Nombre       VARCHAR(100),
    @Apellido     VARCHAR(100),
    @Nacionalidad VARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS (SELECT 1 FROM AUTOR WHERE IDAutor = @IDAutor)
    BEGIN
        RAISERROR('El autor especificado no existe.', 16, 1);
        RETURN;
    END
    UPDATE AUTOR SET Nombre = @Nombre, Apellido = @Apellido, Nacionalidad = @Nacionalidad
    WHERE IDAutor = @IDAutor;
END
GO

CREATE PROCEDURE sp_EliminarAutor
    @IDAutor INT
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (SELECT 1 FROM LIBRO_AUTOR WHERE IDAutor = @IDAutor)
    BEGIN
        RAISERROR('No se puede eliminar el autor porque tiene libros asociados.', 16, 1);
        RETURN;
    END
    DELETE FROM AUTOR WHERE IDAutor = @IDAutor;
END
GO

CREATE PROCEDURE sp_ObtenerAutores
AS
BEGIN
    SET NOCOUNT ON;
    SELECT IDAutor, Nombre, Apellido, Nacionalidad FROM AUTOR ORDER BY Apellido, Nombre;
END
GO


-- ============================================================
-- 5. PROCEDIMIENTOS DE PRÉSTAMO Y DEVOLUCIÓN
-- (referencian vw_PrestamosAtrasados, deben ir después de vistas)
-- ============================================================

CREATE OR ALTER PROCEDURE sp_InsertarPrestamo
    @IDUsuario               INT,
    @IDEjemplar              INT,
    @FechaDevolucionEstimada DATE
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF NOT EXISTS (SELECT 1 FROM USUARIO WHERE IDUsuario = @IDUsuario)
            THROW 50100, 'El usuario especificado no existe.', 1;

        IF NOT EXISTS (SELECT 1 FROM EJEMPLAR WHERE IDEjemplar = @IDEjemplar)
            THROW 50101, 'El ejemplar especificado no existe.', 1;

        IF NOT EXISTS (
            SELECT 1
            FROM EJEMPLAR E
            INNER JOIN ESTADO ES ON E.IDEstado = ES.IDEstado
            WHERE E.IDEjemplar = @IDEjemplar AND ES.NombreEstado = 'Disponible'
        )
            THROW 50102, 'El ejemplar no esta disponible para prestamo.', 1;

        IF EXISTS (SELECT 1 FROM vw_PrestamosAtrasados WHERE IDUsuario = @IDUsuario)
            THROW 50103, 'El usuario tiene prestamos atrasados. Regularice su situacion.', 1;

        INSERT INTO PRESTAMO (IDUsuario, IDEjemplar, FechaPrestamo, FechaDevolucionEstimada)
        VALUES (@IDUsuario, @IDEjemplar, CAST(GETDATE() AS DATE), @FechaDevolucionEstimada);

        DECLARE @NuevoID INT = SCOPE_IDENTITY();
        COMMIT TRANSACTION;
        SELECT @NuevoID AS IDPrestamo;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE sp_InsertarDevolucion
    @IDPrestamo      INT,
    @FechaDevolucion DATE,
    @Observaciones   VARCHAR(500) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF NOT EXISTS (SELECT 1 FROM PRESTAMO WHERE IDPrestamo = @IDPrestamo)
            THROW 50200, 'El prestamo especificado no existe.', 1;

        IF EXISTS (SELECT 1 FROM DEVOLUCION WHERE IDPrestamo = @IDPrestamo)
            THROW 50201, 'Este prestamo ya tiene una devolucion registrada.', 1;

        IF @FechaDevolucion < (SELECT FechaPrestamo FROM PRESTAMO WHERE IDPrestamo = @IDPrestamo)
            THROW 50202, 'La fecha de devolucion no puede ser anterior a la fecha del prestamo.', 1;

        INSERT INTO DEVOLUCION (IDPrestamo, FechaDevolucion, Observaciones)
        VALUES (@IDPrestamo, @FechaDevolucion, @Observaciones);

        DECLARE @NuevoID INT = SCOPE_IDENTITY();
        COMMIT TRANSACTION;
        SELECT @NuevoID AS IDDevolucion;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE sp_ObtenerPrestamosActivos
AS
BEGIN
    SET NOCOUNT ON;
    SELECT P.IDPrestamo, U.Nombre + ' ' + U.Apellido AS Usuario, U.Email,
           L.Titulo, E.CodigoEjemplar, P.FechaPrestamo, P.FechaDevolucionEstimada,
           DATEDIFF(DAY, CAST(GETDATE() AS DATE), P.FechaDevolucionEstimada) AS DiasRestantes
    FROM PRESTAMO    P
    INNER JOIN USUARIO  U ON P.IDUsuario  = U.IDUsuario
    INNER JOIN EJEMPLAR E ON P.IDEjemplar = E.IDEjemplar
    INNER JOIN LIBRO    L ON E.IDLibro    = L.IDLibro
    LEFT  JOIN DEVOLUCION D ON P.IDPrestamo = D.IDPrestamo
    WHERE D.IDPrestamo IS NULL
    ORDER BY P.FechaDevolucionEstimada;
END
GO

CREATE OR ALTER PROCEDURE sp_ObtenerPrestamosAtrasados
AS
BEGIN
    SET NOCOUNT ON;
    SELECT P.IDPrestamo, P.IDUsuario, U.Nombre + ' ' + U.Apellido AS Nombre_Completo,
           U.Email, P.IDEjemplar, E.CodigoEjemplar, P.FechaPrestamo,
           P.FechaDevolucionEstimada,
           DATEDIFF(DAY, P.FechaDevolucionEstimada, CAST(GETDATE() AS DATE)) AS Dias_Atraso
    FROM PRESTAMO    P
    INNER JOIN USUARIO  U ON P.IDUsuario  = U.IDUsuario
    INNER JOIN EJEMPLAR E ON P.IDEjemplar = E.IDEjemplar
    LEFT  JOIN DEVOLUCION D ON P.IDPrestamo = D.IDPrestamo
    WHERE D.IDPrestamo IS NULL
      AND P.FechaDevolucionEstimada < CAST(GETDATE() AS DATE)
    ORDER BY Dias_Atraso DESC;
END
GO


-- ============================================================
-- 6. DATOS DE PRUEBA
-- ============================================================

SET IDENTITY_INSERT ROL ON;
INSERT INTO ROL (IDRol, NombreRol) VALUES
    (1, 'Administrador'),
    (2, 'Bibliotecario'),
    (3, 'Lector'),
    (4, 'Docente');
SET IDENTITY_INSERT ROL OFF;
GO

SET IDENTITY_INSERT EDITORIAL ON;
INSERT INTO EDITORIAL (IDEditorial, NombreEditorial, Pais) VALUES
    (1, 'Alfaguara',            'Argentina'),
    (2, 'Planeta',              'España'),
    (3, 'Anagrama',             'España'),
    (4, 'Penguin Random House', 'Estados Unidos'),
    (5, 'Sudamericana',         'Argentina');
SET IDENTITY_INSERT EDITORIAL OFF;
GO

SET IDENTITY_INSERT CATEGORIA ON;
INSERT INTO CATEGORIA (IDCategoria, NombreCategoria) VALUES
    (1, 'Novela'),
    (2, 'Ciencia Ficcion'),
    (3, 'Ensayo'),
    (4, 'Poesia'),
    (5, 'Historia'),
    (6, 'Informatica');
SET IDENTITY_INSERT CATEGORIA OFF;
GO

SET IDENTITY_INSERT AUTOR ON;
INSERT INTO AUTOR (IDAutor, Nombre, Apellido, Nacionalidad) VALUES
    (1,  'Jorge Luis', 'Borges',         'Argentina'),
    (2,  'Gabriel',    'Garcia Marquez', 'Colombia'),
    (3,  'Isabel',     'Allende',        'Chile'),
    (4,  'Julio',      'Cortazar',       'Argentina'),
    (5,  'Mario',      'Vargas Llosa',   'Peru'),
    (6,  'Stephen',    'King',           'Estados Unidos'),
    (7,  'George',     'Orwell',         'Reino Unido'),
    (8,  'Ray',        'Bradbury',       'Estados Unidos'),
    (9,  'Pablo',      'Neruda',         'Chile'),
    (10, 'Umberto',    'Eco',            'Italia'),
    (11, 'Brian',      'Kernighan',      'Estados Unidos'),
    (12, 'Dennis',     'Ritchie',        'Estados Unidos');
SET IDENTITY_INSERT AUTOR OFF;
GO

SET IDENTITY_INSERT LIBRO ON;
INSERT INTO LIBRO (IDLibro, IDEditorial, IDCategoria, Titulo, ISBN, FechaLanzamiento) VALUES
    (1,  5, 1, 'El Aleph',                                      '978-950-07-1234-5', '1949-06-01'),
    (2,  1, 1, 'Cien años de soledad',                          '978-84-376-0494-7', '1967-05-30'),
    (3,  1, 1, 'La casa de los espiritus',                      '978-84-01-37937-6', '1982-01-01'),
    (4,  2, 1, 'Rayuela',                                       '978-84-397-1781-3', '1963-06-28'),
    (5,  3, 1, 'La ciudad y los perros',                        '978-84-339-7162-0', '1963-01-01'),
    (6,  4, 2, 'It',                                            '978-1-501-14297-0', '1986-09-15'),
    (7,  4, 2, '1984',                                          '978-0-452-28423-4', '1949-06-08'),
    (8,  4, 2, 'Fahrenheit 451',                                '978-1-451-67331-9', '1953-10-19'),
    (9,  2, 4, 'Veinte poemas de amor y una cancion desesperada','978-84-376-0166-3', '1924-08-01'),
    (10, 5, 5, 'El nombre de la rosa',                          '978-84-397-1781-4', '1980-01-01'),
    (11, 4, 6, 'El lenguaje de programacion C',                 '978-0-13-110362-7', '1978-02-22'),
    (12, 2, 3, 'El Aleph (Borges, ensayo)',                     '978-84-376-0494-8', '1949-06-01');
SET IDENTITY_INSERT LIBRO OFF;
GO

INSERT INTO LIBRO_AUTOR (IDLibro, IDAutor) VALUES
    (1,  1), (2,  2), (3,  3), (4,  4), (5,  5),
    (6,  6), (7,  7), (8,  8), (9,  9), (10, 10),
    (11, 11), (11, 12), (12, 1);
GO

SET IDENTITY_INSERT EJEMPLAR ON;
INSERT INTO EJEMPLAR (IDEjemplar, IDLibro, IDEstado, CodigoEjemplar) VALUES
    (1,  1,  1, 'EJ-0001'), (2,  1,  1, 'EJ-0002'),
    (3,  2,  1, 'EJ-0003'), (4,  2,  1, 'EJ-0004'),
    (5,  3,  1, 'EJ-0005'), (6,  4,  1, 'EJ-0006'),
    (7,  4,  1, 'EJ-0007'), (8,  5,  1, 'EJ-0008'),
    (9,  6,  1, 'EJ-0009'), (10, 6,  1, 'EJ-0010'),
    (11, 7,  1, 'EJ-0011'), (12, 7,  1, 'EJ-0012'),
    (13, 8,  1, 'EJ-0013'), (14, 9,  1, 'EJ-0014'),
    (15, 9,  1, 'EJ-0015'), (16, 10, 1, 'EJ-0016'),
    (17, 10, 1, 'EJ-0017'), (18, 11, 1, 'EJ-0018'),
    (19, 11, 1, 'EJ-0019'), (20, 12, 1, 'EJ-0020');
SET IDENTITY_INSERT EJEMPLAR OFF;
GO

SET IDENTITY_INSERT USUARIO ON;
INSERT INTO USUARIO (IDUsuario, IDRol, Nombre, Apellido, Email, Telefono, FechaRegistro) VALUES
    (1, 2, 'Ana',     'Gomez',     'ana.gomez@bib.com',        '+54 11 4000-0001', '2025-01-15'),
    (2, 3, 'Luis',    'Perez',     'luis.perez@mail.com',      '+54 11 4000-0002', '2025-02-10'),
    (3, 3, 'Maria',   'Lopez',     'maria.lopez@mail.com',     '+54 11 4000-0003', '2025-03-05'),
    (4, 4, 'Carlos',  'Ramirez',   'carlos.ramirez@edu.com',   '+54 11 4000-0004', '2025-03-20'),
    (5, 3, 'Sofia',   'Fernandez', 'sofia.fernandez@mail.com', '+54 11 4000-0005', '2025-04-12'),
    (6, 1, 'Diego',   'Suarez',    'diego.suarez@bib.com',     '+54 11 4000-0006', '2025-04-18'),
    (7, 3, 'Julieta', 'Castro',    'julieta.castro@mail.com',  '+54 11 4000-0007', '2025-05-02'),
    (8, 4, 'Martin',  'Ortiz',     'martin.ortiz@edu.com',     '+54 11 4000-0008', '2025-05-22');
SET IDENTITY_INSERT USUARIO OFF;
GO

-- Los triggers cambian IDEstado del EJEMPLAR a 'Prestado' al insertar
-- Prestamo 6: vencido y sin devolucion, sirve para probar vw_PrestamosAtrasados
SET IDENTITY_INSERT PRESTAMO ON;
INSERT INTO PRESTAMO (IDPrestamo, IDUsuario, IDEjemplar, FechaPrestamo, FechaDevolucionEstimada) VALUES
    (1, 2, 3,  '2026-06-01', '2026-06-15'),
    (2, 3, 6,  '2026-06-10', '2026-06-24'),
    (3, 4, 11, '2026-06-20', '2026-07-04'),
    (4, 5, 14, '2026-06-25', '2026-07-09'),
    (5, 7, 18, '2026-06-27', '2026-07-11'),
    (6, 8, 2,  '2026-05-01', '2026-05-15');
SET IDENTITY_INSERT PRESTAMO OFF;
GO

-- Los triggers liberan el EJEMPLAR a 'Disponible' al insertar
SET IDENTITY_INSERT DEVOLUCION ON;
INSERT INTO DEVOLUCION (IDDevolucion, IDPrestamo, FechaDevolucion, Observaciones) VALUES
    (1, 1, '2026-06-14', 'Devuelto en buen estado'),
    (2, 2, '2026-06-25', 'Devuelto con 1 dia de atraso');
SET IDENTITY_INSERT DEVOLUCION OFF;
GO
