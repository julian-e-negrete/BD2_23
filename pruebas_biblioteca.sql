-- Pruebas - Sistema de Gestión de Biblioteca
USE Grupo23Biblioteca;
GO


-- ============================================================
PRINT 'SECCION 1: CONSULTAS';
-- ============================================================
GO

PRINT '-- sp_ObtenerRoles --';
EXEC sp_ObtenerRoles;
PRINT '';

PRINT '-- sp_ObtenerUsuarios --';
EXEC sp_ObtenerUsuarios;
PRINT '';

PRINT '-- sp_ObtenerEditoriales --';
EXEC sp_ObtenerEditoriales;
PRINT '';

PRINT '-- sp_ObtenerAutores --';
EXEC sp_ObtenerAutores;
PRINT '';

PRINT '-- sp_ObtenerCategorias --';
EXEC sp_ObtenerCategorias;
PRINT '';

PRINT '-- sp_ObtenerUsuarioPorID (IDUsuario = 2) --';
EXEC sp_ObtenerUsuarioPorID @IDUsuario = 2;
PRINT '';
GO


-- ============================================================
PRINT 'SECCION 2: INSERTS';
-- ============================================================
GO

PRINT '-- 2.1 Insertar ROL duplicado (debe fallar) --';
EXEC SP_InsertarRol @NombreRol = 'Lector';
PRINT '>> Error esperado: Ya existe un rol con ese nombre';
PRINT '';
GO

PRINT '-- 2.2 Insertar ROL nuevo OK --';
EXEC SP_InsertarRol @NombreRol = 'Investigador';
DECLARE @IDRolNuevo INT = IDENT_CURRENT('ROL');
PRINT 'OK - ROL creado, ID = ' + CAST(@IDRolNuevo AS VARCHAR(10));
PRINT '';
GO

PRINT '-- 2.3 Insertar USUARIO con email duplicado (debe fallar) --';
BEGIN TRY
    EXEC sp_InsertarUsuario
        @IDRol    = 3,
        @Nombre   = 'Test',
        @Apellido = 'Duplicado',
        @Email    = 'luis.perez@mail.com';
    PRINT '>> Sin error (inesperado)';
END TRY
BEGIN CATCH
    PRINT '>> Error capturado (50002): ' + ERROR_MESSAGE();
END CATCH
PRINT '';
GO

PRINT '-- 2.4 Insertar USUARIO OK --';
EXEC sp_InsertarUsuario
    @IDRol    = 3,
    @Nombre   = 'Test',
    @Apellido = 'Nuevo',
    @Email    = 'test.nuevo@mail.com',
    @Telefono = '+54 11 9999-0000';
DECLARE @IDUsrNuevo INT = IDENT_CURRENT('USUARIO');
PRINT 'OK - USUARIO creado, ID = ' + CAST(@IDUsrNuevo AS VARCHAR(10));
PRINT '';
GO

PRINT '-- 2.5 Insertar USUARIO con ROL inexistente (debe fallar) --';
BEGIN TRY
    EXEC sp_InsertarUsuario
        @IDRol    = 999,
        @Nombre   = 'X',
        @Apellido = 'Y',
        @Email    = 'noexiste.rol@mail.com';
    PRINT '>> Sin error (inesperado)';
END TRY
BEGIN CATCH
    PRINT '>> Error capturado (50001): ' + ERROR_MESSAGE();
END CATCH
PRINT '';
GO

PRINT '-- 2.6 Insertar EDITORIAL y AUTOR nuevos --';
EXEC sp_InsertarEditorial @NombreEditorial = 'Kapelusz', @Pais = 'Argentina';
DECLARE @IDEdNuevo INT = IDENT_CURRENT('EDITORIAL');
PRINT 'OK - EDITORIAL creada, ID = ' + CAST(@IDEdNuevo AS VARCHAR(10));

EXEC sp_InsertarAutor @Nombre = 'Gabriel', @Apellido = 'Celaya', @Nacionalidad = 'Espana';
DECLARE @IDAutNuevo INT = IDENT_CURRENT('AUTOR');
PRINT 'OK - AUTOR creado, ID = ' + CAST(@IDAutNuevo AS VARCHAR(10));
PRINT '';
GO


-- ============================================================
PRINT 'SECCION 3: UPDATES';
-- ============================================================
GO

PRINT '-- 3.1 Actualizar CATEGORIA --';
EXEC sp_ActualizarCategoria @IDCategoria = 6, @NombreCategoria = 'Computacion';
PRINT 'OK - Categoria 6 actualizada a Computacion';
PRINT '';
GO

PRINT '-- 3.2 Actualizar AUTOR --';
EXEC sp_ActualizarAutor
    @IDAutor      = 12,
    @Nombre       = 'Dennis',
    @Apellido     = 'Ritchie',
    @Nacionalidad = 'EE.UU.';
PRINT 'OK - Autor 12 actualizado';
PRINT '';
GO

PRINT '-- 3.3 Actualizar EDITORIAL --';
EXEC sp_ActualizarEditorial
    @IDEditorial     = 1,
    @NombreEditorial = 'Alfaguara',
    @Pais            = 'Argentina';
PRINT 'OK - Editorial 1 actualizada';
PRINT '';
GO

PRINT '-- 3.4 Actualizar USUARIO valido --';
EXEC sp_ActualizarUsuario
    @IDUsuario = 8,
    @IDRol     = 3,
    @Nombre    = 'Martin',
    @Apellido  = 'Ortiz',
    @Email     = 'martin.ortiz@edu.com',
    @Telefono  = '+54 11 4000-0008';
PRINT 'OK - Usuario 8 actualizado';
PRINT '';
GO

PRINT '-- 3.5 Actualizar USUARIO con email en uso (debe fallar) --';
BEGIN TRY
    EXEC sp_ActualizarUsuario
        @IDUsuario = 1,
        @IDRol     = 2,
        @Nombre    = 'Ana',
        @Apellido  = 'Gomez',
        @Email     = 'sofia.fernandez@mail.com';
    PRINT '>> Sin error (inesperado)';
END TRY
BEGIN CATCH
    PRINT '>> Error capturado (50005): ' + ERROR_MESSAGE();
END CATCH
PRINT '';
GO


-- ============================================================
PRINT 'SECCION 4: DELETES';
-- ============================================================
GO

PRINT '-- 4.1 Eliminar ROL con usuarios asociados (debe fallar) --';
EXEC sp_EliminarRol @IDRol = 3;
PRINT '>> Error esperado: No se puede eliminar el rol porque tiene usuarios asociados';
PRINT '';
GO

PRINT '-- 4.2 Eliminar EDITORIAL con libros asociados (debe fallar) --';
EXEC sp_EliminarEditorial @IDEditorial = 1;
PRINT '>> Error esperado: No se puede eliminar la editorial porque tiene libros asociados';
PRINT '';
GO

PRINT '-- 4.3 Eliminar CATEGORIA con libros asociados (debe fallar) --';
EXEC sp_EliminarCategoria @IDCategoria = 1;
PRINT '>> Error esperado: No se puede eliminar la categoria porque tiene libros asociados';
PRINT '';
GO

PRINT '-- 4.4 Eliminar AUTOR con libros asociados (debe fallar) --';
EXEC sp_EliminarAutor @IDAutor = 1;
PRINT '>> Error esperado: No se puede eliminar el autor porque tiene libros asociados';
PRINT '';
GO

PRINT '-- 4.5 Eliminar EDITORIAL sin libros (caso feliz) --';
EXEC sp_InsertarEditorial @NombreEditorial = 'Temporal', @Pais = 'Test';
DECLARE @IDEdTmp INT = IDENT_CURRENT('EDITORIAL');
PRINT 'Editorial temporal creada, ID = ' + CAST(@IDEdTmp AS VARCHAR(10));
EXEC sp_EliminarEditorial @IDEditorial = @IDEdTmp;
PRINT 'OK - EDITORIAL temporal eliminada';
PRINT '';
GO


-- ============================================================
PRINT 'SECCION 5: TRIGGERS (PRESTAMO / DEVOLUCION)';
-- ============================================================
GO

PRINT '-- 5.0 Estado inicial del EJEMPLAR 5 (esperado IDEstado = 1 Disponible) --';
SELECT IDEjemplar, IDEstado, CodigoEjemplar FROM EJEMPLAR WHERE IDEjemplar = 5;
PRINT '';
GO

PRINT '-- 5.1 INSERT directo en PRESTAMO: trigger debe cambiar EJEMPLAR 5 a Prestado (2) --';
INSERT INTO PRESTAMO (IDUsuario, IDEjemplar, FechaPrestamo, FechaDevolucionEstimada)
VALUES (3, 5, CAST(GETDATE() AS DATE), DATEADD(DAY, 14, CAST(GETDATE() AS DATE)));
DECLARE @IDPrestamoTest INT = SCOPE_IDENTITY();
PRINT 'OK - Prestamo insertado, ID = ' + CAST(@IDPrestamoTest AS VARCHAR(10));
PRINT '';

PRINT '-- Verificar EJEMPLAR 5 (esperado IDEstado = 2 Prestado) --';
SELECT IDEjemplar, IDEstado, CodigoEjemplar FROM EJEMPLAR WHERE IDEjemplar = 5;
PRINT '';

PRINT '-- 5.2 INSERT directo en DEVOLUCION: trigger debe liberar EJEMPLAR 5 a Disponible (1) --';
INSERT INTO DEVOLUCION (IDPrestamo, FechaDevolucion, Observaciones)
VALUES (@IDPrestamoTest, CAST(GETDATE() AS DATE), 'Prueba de trigger devolucion');
PRINT 'OK - Devolucion insertada';
PRINT '';

PRINT '-- Verificar EJEMPLAR 5 (esperado IDEstado = 1 Disponible) --';
SELECT IDEjemplar, IDEstado, CodigoEjemplar FROM EJEMPLAR WHERE IDEjemplar = 5;
PRINT '';
GO


-- ============================================================
PRINT 'SECCION 6: VISTAS';
-- ============================================================
GO

PRINT '-- 6.1 vw_LibrosDisponibles --';
SELECT * FROM vw_LibrosDisponibles ORDER BY Titulo;
PRINT '';
GO

PRINT '-- 6.2 vw_PrestamosActivos --';
SELECT * FROM vw_PrestamosActivos ORDER BY DiasRestantes;
PRINT '';
GO

PRINT '-- 6.3 vw_PrestamosAtrasados --';
SELECT * FROM vw_PrestamosAtrasados;
PRINT '';
GO

PRINT '-- 6.4 vw_UsuariosConPrestamos --';
SELECT * FROM vw_UsuariosConPrestamos ORDER BY Cantidad_Prestamos DESC;
PRINT '';
GO

PRINT '-- 6.5 vw_InformacionLibros (libro con co-autores: IDLibro = 11) --';
SELECT * FROM vw_InformacionLibros WHERE IDLibro = 11;
PRINT '';
GO


-- ============================================================
PRINT 'SECCION 7: TESTS NEGATIVOS ADICIONALES';
-- ============================================================
GO

PRINT '-- 7.1 Eliminar USUARIO con prestamos activos (debe fallar) --';
BEGIN TRY
    EXEC sp_EliminarUsuario @IDUsuario = 4;
    PRINT '>> Sin error (inesperado)';
END TRY
BEGIN CATCH
    PRINT '>> Error capturado (50007): ' + ERROR_MESSAGE();
END CATCH
PRINT '';
GO

PRINT '-- 7.2 Actualizar CATEGORIA con nombre duplicado (debe fallar) --';
EXEC sp_ActualizarCategoria @IDCategoria = 6, @NombreCategoria = 'Novela';
PRINT '>> Error esperado: Ya existe otra categoria con ese nombre';
PRINT '';
GO


-- ============================================================
PRINT 'SECCION 8: PRESTAMO Y DEVOLUCION (via SPs)';
-- ============================================================
GO

PRINT '-- 8.RESET: limpiar prestamos de prueba y dejar todos los ejemplares Disponibles --';
DELETE FROM DEVOLUCION WHERE IDPrestamo >= 7;
DELETE FROM PRESTAMO   WHERE IDPrestamo >= 7;
UPDATE EJEMPLAR SET IDEstado = 1;
PRINT 'OK - base reseteada';
PRINT '';
GO

PRINT '-- 8.0 Estado inicial del EJEMPLAR 1 (esperado IDEstado = 1 Disponible) --';
SELECT IDEjemplar, IDEstado, CodigoEjemplar FROM EJEMPLAR WHERE IDEjemplar = 1;
PRINT '';
GO

-- 8.1 a 8.6 en un solo batch para mantener @IDP entre tests
PRINT '-- 8.1 Insertar PRESTAMO valido (usuario 2, ejemplar 1) --';
EXEC sp_InsertarPrestamo
    @IDUsuario               = 2,
    @IDEjemplar              = 1,
    @FechaDevolucionEstimada = DATEADD(DAY, 21, CAST(GETDATE() AS DATE));
DECLARE @IDP INT = IDENT_CURRENT('PRESTAMO');
PRINT 'OK - Prestamo creado, ID = ' + CAST(@IDP AS VARCHAR(10));
PRINT '';

PRINT '-- Verificar EJEMPLAR 1 (esperado IDEstado = 2 Prestado) --';
SELECT IDEjemplar, IDEstado, CodigoEjemplar FROM EJEMPLAR WHERE IDEjemplar = 1;
PRINT '';

PRINT '-- 8.2 Insertar PRESTAMO sobre ejemplar ya prestado (debe fallar) --';
BEGIN TRY
    EXEC sp_InsertarPrestamo
        @IDUsuario               = 3,
        @IDEjemplar              = 1,
        @FechaDevolucionEstimada = DATEADD(DAY, 21, CAST(GETDATE() AS DATE));
    PRINT '>> Sin error (inesperado)';
END TRY
BEGIN CATCH
    PRINT '>> Error capturado (50102): ' + ERROR_MESSAGE();
END CATCH
PRINT '';

PRINT '-- 8.3 Insertar PRESTAMO con usuario inexistente (debe fallar) --';
BEGIN TRY
    EXEC sp_InsertarPrestamo
        @IDUsuario               = 999,
        @IDEjemplar              = 2,
        @FechaDevolucionEstimada = DATEADD(DAY, 21, CAST(GETDATE() AS DATE));
    PRINT '>> Sin error (inesperado)';
END TRY
BEGIN CATCH
    PRINT '>> Error capturado (50100): ' + ERROR_MESSAGE();
END CATCH
PRINT '';

PRINT '-- 8.4 Insertar PRESTAMO con ejemplar inexistente (debe fallar) --';
BEGIN TRY
    EXEC sp_InsertarPrestamo
        @IDUsuario               = 2,
        @IDEjemplar              = 999,
        @FechaDevolucionEstimada = DATEADD(DAY, 21, CAST(GETDATE() AS DATE));
    PRINT '>> Sin error (inesperado)';
END TRY
BEGIN CATCH
    PRINT '>> Error capturado (50101): ' + ERROR_MESSAGE();
END CATCH
PRINT '';

PRINT '-- 8.5 Devolver el prestamo correctamente --';
EXEC sp_InsertarDevolucion
    @IDPrestamo      = @IDP,
    @FechaDevolucion = CAST(GETDATE() AS DATE),
    @Observaciones   = 'Devuelto en buen estado';
PRINT 'OK - Devolucion registrada';
PRINT '';

PRINT '-- Verificar EJEMPLAR 1 (esperado IDEstado = 1 Disponible) --';
SELECT IDEjemplar, IDEstado, CodigoEjemplar FROM EJEMPLAR WHERE IDEjemplar = 1;
PRINT '';

PRINT '-- 8.6 Intentar devolver el mismo prestamo dos veces (debe fallar) --';
BEGIN TRY
    EXEC sp_InsertarDevolucion
        @IDPrestamo      = @IDP,
        @FechaDevolucion = CAST(GETDATE() AS DATE),
        @Observaciones   = 'Doble devolucion';
    PRINT '>> Sin error (inesperado)';
END TRY
BEGIN CATCH
    PRINT '>> Error capturado (50201): ' + ERROR_MESSAGE();
END CATCH
PRINT '';
GO

PRINT '-- 8.7 Devolucion con fecha anterior a la fecha del prestamo (debe fallar) --';
EXEC sp_InsertarPrestamo
    @IDUsuario               = 3,
    @IDEjemplar              = 4,
    @FechaDevolucionEstimada = DATEADD(DAY, 21, CAST(GETDATE() AS DATE));
DECLARE @IDP2 INT = IDENT_CURRENT('PRESTAMO');
PRINT 'Prestamo auxiliar creado, ID = ' + CAST(@IDP2 AS VARCHAR(10));

BEGIN TRY
    EXEC sp_InsertarDevolucion
        @IDPrestamo      = @IDP2,
        @FechaDevolucion = '2020-01-01',
        @Observaciones   = 'Fecha invalida';
    PRINT '>> Sin error (inesperado)';
END TRY
BEGIN CATCH
    PRINT '>> Error capturado (50202): ' + ERROR_MESSAGE();
END CATCH
PRINT '';
GO

PRINT '-- 8.8 sp_ObtenerPrestamosActivos --';
EXEC sp_ObtenerPrestamosActivos;
PRINT '';
GO

PRINT '-- 8.9 sp_ObtenerPrestamosAtrasados --';
EXEC sp_ObtenerPrestamosAtrasados;
PRINT '';
GO


PRINT '== FIN DE PRUEBAS ==';
GO
