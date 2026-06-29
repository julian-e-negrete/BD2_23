-- Procedimientos Almacenados - Sistema de Gestión de Biblioteca
USE Grupo23Biblioteca;
GO

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

        INSERT INTO USUARIO
        (
            IDRol,
            Nombre,
            Apellido,
            Email,
            Telefono,
            FechaRegistro
        )
        VALUES
        (
            @IDRol,
            @Nombre,
            @Apellido,
            @Email,
            @Telefono,
            CAST(GETDATE() AS DATE)
        );

        DECLARE @NuevoID INT = SCOPE_IDENTITY();

        COMMIT TRANSACTION;

        SELECT @NuevoID AS IDUsuario;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

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

        IF EXISTS (
            SELECT 1
            FROM USUARIO
            WHERE Email = @Email
              AND IDUsuario <> @IDUsuario
        )
            THROW 50005, 'El email ya está en uso por otro usuario.', 1;

        UPDATE USUARIO
        SET IDRol = @IDRol,
            Nombre = @Nombre,
            Apellido = @Apellido,
            Email = @Email,
            Telefono = @Telefono
        WHERE IDUsuario = @IDUsuario;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

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

        DELETE FROM USUARIO
        WHERE IDUsuario = @IDUsuario;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH
END
GO

CREATE PROCEDURE sp_ObtenerUsuarios
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        U.IDUsuario,
        U.Nombre,
        U.Apellido,
        U.Email,
        U.Telefono,
        U.FechaRegistro,
        R.NombreRol
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

    SELECT
        U.IDUsuario,
        U.Nombre,
        U.Apellido,
        U.Email,
        U.Telefono,
        U.FechaRegistro,
        R.IDRol,
        R.NombreRol
    FROM USUARIO U
    INNER JOIN ROL R ON U.IDRol = R.IDRol
    WHERE U.IDUsuario = @IDUsuario;
END
GO

-- CATEGORÍAS

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
    
    IF EXISTS(SELECT 1 FROM CATEGORIA WHERE NombreCategoria = @NombreCategoria AND IDCategoria <> @IDCategoria)
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
    UPDATE EDITORIAL
    SET NombreEditorial = @NombreEditorial,
        Pais            = @Pais
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
    INSERT INTO AUTOR (Nombre, Apellido, Nacionalidad)
    VALUES (@Nombre, @Apellido, @Nacionalidad);
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
    UPDATE AUTOR
    SET Nombre       = @Nombre,
        Apellido     = @Apellido,
        Nacionalidad = @Nacionalidad
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