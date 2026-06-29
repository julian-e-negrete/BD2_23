-- Pruebas - Sistema de Gestión de Biblioteca

USE Grupo23Biblioteca;
GO


PRINT 'SECCION 1: SMOKE TESTS DE CONSULTAS';

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


PRINT 'SECCION 2: INSERTS';

GO

PRINT '-- 2.1 Insertar ROL duplicado (debe fallar) --';
EXEC sp_InsertarRol @NombreRol = 'Lector';
PRINT '>> Esperado: Msg 50000 (Ya existe un rol con ese nombre)';
PRINT '';

GO

PRINT '-- 2.2 Insertar ROL nuevo OK --';
DECLARE @IDRolNuevo INT;
EXEC @IDRolNuevo = sp_InsertarRol @NombreRol = 'Investigador';
PRINT 'OK - ROL creado, ID = ' + CAST(@IDRolNuevo AS VARCHAR(10));
PRINT '';

GO

PRINT '-- 2.3 Insertar USUARIO con email duplicado (debe fallar) --';
EXEC sp_InsertarUsuario
    @IDRol = 3,
    @Nombre = 'Test',
    @Apellido = 'Duplicado',
    @Email = 'luis.perez@mail.com';
PRINT '>> Esperado: Msg 50002 (Ya existe un usuario con ese email)';
PRINT '';

GO

PRINT '-- 2.4 Insertar USUARIO OK --';
DECLARE @IDUsrNuevo INT;
EXEC @IDUsrNuevo = sp_InsertarUsuario
    @IDRol = 3,
    @Nombre = 'Test',
    @Apellido = 'Nuevo',
    @Email = 'test.nuevo@mail.com',
    @Telefono = '+54 11 9999-0000';
PRINT 'OK - USUARIO creado, ID = ' + CAST(@IDUsrNuevo AS VARCHAR(10));
PRINT '';

GO

PRINT '-- 2.5 Insertar USUARIO con ROL inexistente (debe fallar) --';
EXEC sp_InsertarUsuario
    @IDRol = 999,
    @Nombre = 'X',
    @Apellido = 'Y',
    @Email = 'noexiste.rol@mail.com';
PRINT '>> Esperado: Msg 50001 (El rol especificado no existe)';
PRINT '';

GO

PRINT '-- 2.6 Insertar EDITORIAL y AUTOR nuevos --';
DECLARE @IDEdNuevo INT, @IDAutNuevo INT;
EXEC @IDEdNuevo = sp_InsertarEditorial
    @NombreEditorial = 'Kapelusz',
    @Pais = 'Argentina';
PRINT 'OK - EDITORIAL creada, ID = ' + CAST(@IDEdNuevo AS VARCHAR(10));

EXEC @IDAutNuevo = sp_InsertarAutor
    @Nombre = 'Gabriel',
    @Apellido = 'Celaya',
    @Nacionalidad = 'Espana';
PRINT 'OK - AUTOR creado, ID = ' + CAST(@IDAutNuevo AS VARCHAR(10));
PRINT '';

GO


PRINT 'SECCION 3: UPDATES';

GO

PRINT '-- 3.1 Actualizar CATEGORIA --';
EXEC sp_ActualizarCategoria @IDCategoria = 6, @NombreCategoria = 'Computacion';
PRINT 'OK';
PRINT '';

GO

PRINT '-- 3.2 Actualizar AUTOR --';
EXEC sp_ActualizarAutor
    @IDAutor = 12,
    @Nombre = 'Dennis',
    @Apellido = 'Ritchie',
    @Nacionalidad = 'EE.UU.';
PRINT 'OK';
PRINT '';

GO

PRINT '-- 3.3 Actualizar EDITORIAL --';
EXEC sp_ActualizarEditorial
    @IDEditorial = 1,
    @NombreEditorial = 'Alfaguara',
    @Pais = 'Argentina';
PRINT 'OK';
PRINT '';

GO

PRINT '-- 3.4 Actualizar USUARIO valido --';
EXEC sp_ActualizarUsuario
    @IDUsuario = 8,
    @IDRol = 3,
    @Nombre = 'Martin',
    @Apellido = 'Ortiz',
    @Email = 'martin.ortiz@edu.com',
    @Telefono = '+54 11 4000-0008';
PRINT 'OK';
PRINT '';

GO

PRINT '-- 3.5 Actualizar USUARIO con email en uso (debe fallar) --';
EXEC sp_ActualizarUsuario
    @IDUsuario = 1,
    @IDRol = 2,
    @Nombre = 'Ana',
    @Apellido = 'Gomez',
    @Email = 'sofia.fernandez@mail.com';
PRINT '>> Esperado: Msg 50005 (El email ya esta en uso)';
PRINT '';

GO


PRINT 'SECCION 4: DELETES';

GO

PRINT '-- 4.1 Eliminar ROL con usuarios (debe fallar) --';
EXEC sp_EliminarRol @IDRol = 3;
PRINT '>> Esperado: Msg 50000 (No se puede eliminar el rol)';
PRINT '';

GO

PRINT '-- 4.2 Eliminar EDITORIAL con libros (debe fallar) --';
EXEC sp_EliminarEditorial @IDEditorial = 1;
PRINT '>> Esperado: Msg 50000 (No se puede eliminar la editorial)';
PRINT '';

GO

PRINT '-- 4.3 Eliminar CATEGORIA con libros (debe fallar) --';
EXEC sp_EliminarCategoria @IDCategoria = 1;
PRINT '>> Esperado: Msg 50000 (No se puede eliminar la categoria)';
PRINT '';

GO

PRINT '-- 4.4 Eliminar AUTOR con libros (debe fallar) --';
EXEC sp_EliminarAutor @IDAutor = 1;
PRINT '>> Esperado: Msg 50000 (No se puede eliminar el autor)';
PRINT '';

GO

PRINT '-- 4.5 Eliminar EDITORIAL sin libros (caso feliz) --';
DECLARE @IDEdTmp INT;
EXEC @IDEdTmp = sp_InsertarEditorial @NombreEditorial = 'Temporal', @Pais = 'Test';
EXEC sp_EliminarEditorial @IDEditorial = @IDEdTmp;
PRINT 'OK - EDITORIAL temporal eliminada';
PRINT '';

GO


PRINT 'SECCION 5: TRIGGERS (PRESTAMO / DEVOLUCION)';

GO

PRINT '-- 5.0 Estado inicial del EJEMPLAR 5 --';
SELECT IDEjemplar, IDEstado, CodigoEjemplar FROM EJEMPLAR WHERE IDEjemplar = 5;
PRINT '';

GO

PRINT '-- 5.1 INSERT PRESTAMO: trigger cambia a "Prestado" (2) --';
DECLARE @IDPrestamoTest INT;
INSERT INTO PRESTAMO (IDUsuario, IDEjemplar, FechaPrestamo, FechaDevolucionEstimada)
VALUES (3, 5, '2026-06-29', '2026-07-13');
SET @IDPrestamoTest = SCOPE_IDENTITY();
PRINT 'OK - Prestamo insertado, ID = ' + CAST(@IDPrestamoTest AS VARCHAR(10));
PRINT '';

PRINT '-- Verificar cambio de estado del EJEMPLAR 5 (esperado IDEstado = 2) --';
SELECT IDEjemplar, IDEstado, CodigoEjemplar FROM EJEMPLAR WHERE IDEjemplar = 5;
PRINT '';

PRINT '-- 5.2 INSERT DEVOLUCION: trigger libera a "Disponible" (1) --';
INSERT INTO DEVOLUCION (IDPrestamo, FechaDevolucion, Observaciones)
VALUES (@IDPrestamoTest, '2026-06-29', 'Prueba de trigger devolucion');
PRINT 'OK - Devolucion insertada';
PRINT '';

PRINT '-- Verificar liberacion del EJEMPLAR 5 (esperado IDEstado = 1) --';
SELECT IDEjemplar, IDEstado, CodigoEjemplar FROM EJEMPLAR WHERE IDEjemplar = 5;
PRINT '';

GO


PRINT 'SECCION 6: VISTAS';

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


PRINT 'SECCION 7: TESTS NEGATIVOS ADICIONALES';

GO

PRINT '-- 7.1 Eliminar USUARIO con prestamos (debe fallar) --';
EXEC sp_EliminarUsuario @IDUsuario = 4;
PRINT '>> Esperado: Msg 50007 (No se puede eliminar el usuario)';
PRINT '';

GO

PRINT '-- 7.2 Actualizar CATEGORIA con nombre duplicado (debe fallar) --';
EXEC sp_ActualizarCategoria @IDCategoria = 6, @NombreCategoria = 'Novela';
PRINT '>> Esperado: Msg 50000 (Ya existe otra categoria)';
PRINT '';

GO


PRINT 'SECCION 8: PRESTAMO Y DEVOLUCION (SPs nuevos)';

GO

PRINT '-- 8.RESET: limpiar prestamos previos de prueba y dejar todos los ejemplares Disponibles --';
DELETE FROM DEVOLUCION WHERE IDPrestamo >= 6;
DELETE FROM PRESTAMO   WHERE IDPrestamo >= 6;
UPDATE EJEMPLAR SET IDEstado = 1;
PRINT 'OK - base reseteada';
PRINT '';

GO

PRINT '-- 8.0 Estado inicial del EJEMPLAR 1 (esperado IDEstado = 1) --';

PRINT '-- 8.0 Estado inicial del EJEMPLAR 1 (esperado IDEstado = 1) --';
SELECT IDEjemplar, IDEstado, CodigoEjemplar FROM EJEMPLAR WHERE IDEjemplar = 1;
PRINT '';

GO

PRINT '-- 8.1 Insertar PRESTAMO valido (usuario 2, ejemplar 1) --';
DECLARE @IDP INT;
EXEC @IDP = sp_InsertarPrestamo
    @IDUsuario = 2,
    @IDEjemplar = 1,
    @FechaDevolucionEstimada = '2026-07-20';
PRINT 'OK - Prestamo creado, ID = ' + CAST(@IDP AS VARCHAR(10));
PRINT '';

PRINT '-- Verificar cambio de estado del EJEMPLAR 1 (esperado IDEstado = 2) --';
SELECT IDEjemplar, IDEstado, CodigoEjemplar FROM EJEMPLAR WHERE IDEjemplar = 1;
PRINT '';

PRINT '-- 8.2 Insertar PRESTAMO sobre ejemplar ya prestado (debe fallar) --';
EXEC sp_InsertarPrestamo
    @IDUsuario = 3,
    @IDEjemplar = 1,
    @FechaDevolucionEstimada = '2026-07-20';
PRINT '>> Esperado: Msg 50102 (El ejemplar no esta disponible)';
PRINT '';

PRINT '-- 8.3 Insertar PRESTAMO con usuario inexistente (debe fallar) --';
EXEC sp_InsertarPrestamo
    @IDUsuario = 999,
    @IDEjemplar = 2,
    @FechaDevolucionEstimada = '2026-07-20';
PRINT '>> Esperado: Msg 50100 (El usuario no existe)';
PRINT '';

PRINT '-- 8.4 Insertar PRESTAMO con ejemplar inexistente (debe fallar) --';
EXEC sp_InsertarPrestamo
    @IDUsuario = 2,
    @IDEjemplar = 999,
    @FechaDevolucionEstimada = '2026-07-20';
PRINT '>> Esperado: Msg 50101 (El ejemplar no existe)';
PRINT '';

PRINT '-- 8.5 Devolver el prestamo @IDP --';
EXEC sp_InsertarDevolucion
    @IDPrestamo = @IDP,
    @FechaDevolucion = '2026-07-15',
    @Observaciones = 'Devuelto en buen estado';
PRINT 'OK - Devolucion registrada';
PRINT '';

PRINT '-- Verificar liberacion del EJEMPLAR 1 (esperado IDEstado = 1) --';
SELECT IDEjemplar, IDEstado, CodigoEjemplar FROM EJEMPLAR WHERE IDEjemplar = 1;
PRINT '';

PRINT '-- 8.6 Intentar devolver el mismo prestamo dos veces (debe fallar) --';
EXEC sp_InsertarDevolucion
    @IDPrestamo = @IDP,
    @FechaDevolucion = '2026-07-15',
    @Observaciones = 'Doble devolucion';
PRINT '>> Esperado: Msg 50201 (Ya tiene una devolucion registrada)';
PRINT '';

GO

PRINT '-- 8.7 Devolucion con fecha anterior al prestamo (debe fallar) --';
DECLARE @IDP2 INT;
EXEC @IDP2 = sp_InsertarPrestamo
    @IDUsuario = 3,
    @IDEjemplar = 2,
    @FechaDevolucionEstimada = '2026-07-25';
PRINT 'Prestamo auxiliar creado, ID = ' + CAST(@IDP2 AS VARCHAR(10));

EXEC sp_InsertarDevolucion
    @IDPrestamo = @IDP2,
    @FechaDevolucion = '2020-01-01',
    @Observaciones = 'Fecha invalida';
PRINT '>> Esperado: Msg 50202 (Fecha de devolucion anterior al prestamo)';
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


PRINT 'FIN DE PRUEBAS';

GO
