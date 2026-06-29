-- Triggers - Sistema de Gestión de Biblioteca
USE Grupo23Biblioteca;
GO
-- Trigger 1: Al registrar un préstamo, marca el ejemplar como 'Prestado'
CREATE TRIGGER trg_Prestamo_MarcarEjemplar
ON PRESTAMO
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE E
    SET    E.IDEstado = EST.IDEstado
    FROM   EJEMPLAR E
    INNER JOIN inserted    I   ON  E.IDEjemplar   = I.IDEjemplar
    INNER JOIN ESTADO      EST ON  EST.NombreEstado = 'Prestado';
END;
GO

-- Trigger 2: Al registrar una devolución, marca el ejemplar como 'Disponible'
CREATE TRIGGER trg_Devolucion_LiberarEjemplar
ON DEVOLUCION
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE E
    SET    E.IDEstado = EST.IDEstado
    FROM   EJEMPLAR  E
    INNER JOIN PRESTAMO    P   ON  E.IDEjemplar   = P.IDEjemplar
    INNER JOIN inserted    I   ON  P.IDPrestamo   = I.IDPrestamo
    INNER JOIN ESTADO      EST ON  EST.NombreEstado = 'Disponible';
END;
GO
