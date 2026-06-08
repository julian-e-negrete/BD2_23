-- ============================================================
-- Sistema de Gestión de Biblioteca
-- Microsoft SQL Server
-- ============================================================

CREATE TABLE ROL (
    IDRol        INT           IDENTITY(1,1) PRIMARY KEY,
    NombreRol    VARCHAR(50)   NOT NULL
);

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

CREATE TABLE CATEGORIA (
    IDCategoria      INT           IDENTITY(1,1) PRIMARY KEY,
    NombreCategoria  VARCHAR(100)  NOT NULL
);

CREATE TABLE EDITORIAL (
    IDEditorial      INT           IDENTITY(1,1) PRIMARY KEY,
    NombreEditorial  VARCHAR(150)  NOT NULL,
    Pais             VARCHAR(100)  NULL
);

CREATE TABLE AUTOR (
    IDAutor       INT           IDENTITY(1,1) PRIMARY KEY,
    Nombre        VARCHAR(100)  NOT NULL,
    Apellido      VARCHAR(100)  NOT NULL,
    Nacionalidad  VARCHAR(100)  NULL
);

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

CREATE TABLE LIBRO_AUTOR (
    IDLibro  INT  NOT NULL,
    IDAutor  INT  NOT NULL,
    CONSTRAINT PK_LIBRO_AUTOR       PRIMARY KEY (IDLibro, IDAutor),
    CONSTRAINT FK_LIBROAUTOR_LIBRO  FOREIGN KEY (IDLibro) REFERENCES LIBRO(IDLibro),
    CONSTRAINT FK_LIBROAUTOR_AUTOR  FOREIGN KEY (IDAutor) REFERENCES AUTOR(IDAutor)
);

CREATE TABLE ESTADO (
    IDEstado     INT          IDENTITY(1,1) PRIMARY KEY,
    NombreEstado VARCHAR(50)  NOT NULL UNIQUE
);

INSERT INTO ESTADO (NombreEstado) VALUES
    ('Disponible'),
    ('Prestado'),
    ('Dañado'),
    ('Baja');

CREATE TABLE EJEMPLAR (
    IDEjemplar      INT          IDENTITY(1,1) PRIMARY KEY,
    IDLibro         INT          NOT NULL,
    IDEstado        INT          NOT NULL,
    CodigoEjemplar  VARCHAR(50)  NOT NULL UNIQUE,
    CONSTRAINT FK_EJEMPLAR_LIBRO   FOREIGN KEY (IDLibro)  REFERENCES LIBRO(IDLibro),
    CONSTRAINT FK_EJEMPLAR_ESTADO  FOREIGN KEY (IDEstado) REFERENCES ESTADO(IDEstado)
);

CREATE TABLE PRESTAMO (
    IDPrestamo              INT   IDENTITY(1,1) PRIMARY KEY,
    IDUsuario               INT   NOT NULL,
    IDEjemplar              INT   NOT NULL,
    FechaPrestamo           DATE  NOT NULL DEFAULT CAST(GETDATE() AS DATE),
    FechaDevolucionEstimada DATE  NOT NULL,
    CONSTRAINT FK_PRESTAMO_USUARIO   FOREIGN KEY (IDUsuario)  REFERENCES USUARIO(IDUsuario),
    CONSTRAINT FK_PRESTAMO_EJEMPLAR  FOREIGN KEY (IDEjemplar) REFERENCES EJEMPLAR(IDEjemplar)
);

CREATE TABLE DEVOLUCION (
    IDDevolucion    INT           IDENTITY(1,1) PRIMARY KEY,
    IDPrestamo      INT           NOT NULL UNIQUE,
    FechaDevolucion DATE          NOT NULL,
    Observaciones   VARCHAR(500)  NULL,
    CONSTRAINT FK_DEVOLUCION_PRESTAMO FOREIGN KEY (IDPrestamo) REFERENCES PRESTAMO(IDPrestamo)
);
