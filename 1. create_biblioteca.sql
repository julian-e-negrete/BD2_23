--Script listo para ejecutar
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