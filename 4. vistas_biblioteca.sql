-- Vistas - Sistema de Gestión de Biblioteca
USE Grupo23Biblioteca;
GO
-- Vista 1: Muestra todos los libros que tienen al menos un ejemplar disponible
-- y la cantidad de ejemplares disponibles.
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

-- Vista 2: Muestra todos los préstamos que todavía no hayan sido devueltos.
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

-- Vista 3: Muestra los préstamos cuya fecha estimada de devolución ya pasó
-- y que todavía no han sido devueltos.
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

-- Vista 4: Muestra todos los usuarios que tienen al menos un préstamo activo
-- y la cantidad de préstamos activos.
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

-- Vista 5: Muestra los libros con la información relevante sobre los mismos.
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
