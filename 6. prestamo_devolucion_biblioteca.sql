-- Procedimientos de Prestamo y Devolucion

USE Grupo23Biblioteca;
GO

-- sp_InsertarPrestamo registra un préstamo y deja el ejemplar en estado 'Prestado'
-- (el trigger trg_Prestamo_MarcarEjemplar hace ese cambio).
-- Validaciones:
-- El usuario debe existir
-- El ejemplar debe existir
-- El ejemplar debe estar en estado 'Disponible' (= 1)
-- El usuario no debe tener préstamos atrasados
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

        -- 1. Usuario existe
        IF NOT EXISTS (SELECT 1 FROM USUARIO WHERE IDUsuario = @IDUsuario)
            THROW 50100, 'El usuario especificado no existe.', 1;

        -- 2. Ejemplar existe
        IF NOT EXISTS (SELECT 1 FROM EJEMPLAR WHERE IDEjemplar = @IDEjemplar)
            THROW 50101, 'El ejemplar especificado no existe.', 1;

        -- 3. Ejemplar debe estar Disponible
        IF NOT EXISTS (
            SELECT 1
            FROM EJEMPLAR E
            INNER JOIN ESTADO ES ON E.IDEstado = ES.IDEstado
            WHERE E.IDEjemplar = @IDEjemplar
              AND ES.NombreEstado = 'Disponible'
        )
            THROW 50102, 'El ejemplar no esta disponible para prestamo.', 1;

        -- 4. Usuario sin prestamos atrasados
        IF EXISTS (
            SELECT 1
            FROM vw_PrestamosAtrasados
            WHERE IDUsuario = @IDUsuario
        )
            THROW 50103, 'El usuario tiene prestamos atrasados. Regularice su situacion.', 1;

        -- 5. Insertar prestamo (el trigger pone el ejemplar en 'Prestado')
        INSERT INTO PRESTAMO (IDUsuario, IDEjemplar, FechaPrestamo, FechaDevolucionEstimada)
        VALUES (
            @IDUsuario,
            @IDEjemplar,
            CAST(GETDATE() AS DATE),
            @FechaDevolucionEstimada
        );

        DECLARE @NuevoID INT = SCOPE_IDENTITY();

        COMMIT TRANSACTION;
        SELECT @NuevoID AS IDPrestamo;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

-- sp_InsertarDevolucion registra la devolución de un préstamo y libera el ejemplar a estado 'Disponible'
-- (el trigger trg_Devolucion_LiberarEjemplar se encarga de ese cambio).
-- Validaciones:
-- El préstamo debe existir
-- El préstamo no debe tener una devolución ya registrada
-- La fecha de devolución no puede ser anterior a la fecha del préstamo

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

        -- 1. Prestamo existe
        IF NOT EXISTS (SELECT 1 FROM PRESTAMO WHERE IDPrestamo = @IDPrestamo)
            THROW 50200, 'El prestamo especificado no existe.', 1;

        -- 2. No debe tener devolucion previa
        IF EXISTS (SELECT 1 FROM DEVOLUCION WHERE IDPrestamo = @IDPrestamo)
            THROW 50201, 'Este prestamo ya tiene una devolucion registrada.', 1;

        -- 3. Fecha de devolucion >= fecha de prestamo
        IF @FechaDevolucion < (SELECT FechaPrestamo FROM PRESTAMO WHERE IDPrestamo = @IDPrestamo)
            THROW 50202, 'La fecha de devolucion no puede ser anterior a la fecha del prestamo.', 1;

        -- 4. Insertar devolucion (el trigger libera el ejemplar)
        INSERT INTO DEVOLUCION (IDPrestamo, FechaDevolucion, Observaciones)
        VALUES (@IDPrestamo, @FechaDevolucion, @Observaciones);

        DECLARE @NuevoID INT = SCOPE_IDENTITY();

        COMMIT TRANSACTION;
        SELECT @NuevoID AS IDDevolucion;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

-- sp_ObtenerPrestamosActivos
-- Lista los prestamos sin devolucion (puede ser reemplazado por SELECT * FROM vw_PrestamosActivos)

CREATE OR ALTER PROCEDURE sp_ObtenerPrestamosActivos
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        P.IDPrestamo,
        U.Nombre + ' ' + U.Apellido AS Usuario,
        U.Email,
        L.Titulo,
        E.CodigoEjemplar,
        P.FechaPrestamo,
        P.FechaDevolucionEstimada,
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

-- sp_ObtenerPrestamosAtrasados
-- Lista los prestamos cuya fecha estimada ya vencio y no
-- fueron devueltos.

CREATE OR ALTER PROCEDURE sp_ObtenerPrestamosAtrasados
AS
BEGIN
    SET NOCOUNT ON;
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
    FROM PRESTAMO    P
    INNER JOIN USUARIO  U ON P.IDUsuario  = U.IDUsuario
    INNER JOIN EJEMPLAR E ON P.IDEjemplar = E.IDEjemplar
    LEFT  JOIN DEVOLUCION D ON P.IDPrestamo = D.IDPrestamo
    WHERE D.IDPrestamo IS NULL
      AND P.FechaDevolucionEstimada < CAST(GETDATE() AS DATE)
    ORDER BY Dias_Atraso DESC;
END
GO
