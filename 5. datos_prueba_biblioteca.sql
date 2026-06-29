-- Datos de prueba
-- Orden: ROL, EDITORIAL, CATEGORIA, AUTOR, LIBRO, LIBRO_AUTOR, EJEMPLAR
USE Grupo23Biblioteca;
GO
-- ROL
SET IDENTITY_INSERT ROL ON;
INSERT INTO ROL (IDRol, NombreRol) VALUES
    (1, 'Administrador'),
    (2, 'Bibliotecario'),
    (3, 'Lector'),
    (4, 'Docente');
SET IDENTITY_INSERT ROL OFF;
GO

-- EDITORIAL
SET IDENTITY_INSERT EDITORIAL ON;
INSERT INTO EDITORIAL (IDEditorial, NombreEditorial, Pais) VALUES
    (1, 'Alfaguara',           'Argentina'),
    (2, 'Planeta',             'España'),
    (3, 'Anagrama',            'España'),
    (4, 'Penguin Random House','Estados Unidos'),
    (5, 'Sudamericana',        'Argentina');
SET IDENTITY_INSERT EDITORIAL OFF;
GO

-- CATEGORIA
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

-- AUTOR
SET IDENTITY_INSERT AUTOR ON;
INSERT INTO AUTOR (IDAutor, Nombre, Apellido, Nacionalidad) VALUES
    (1,  'Jorge Luis',  'Borges',         'Argentina'),
    (2,  'Gabriel',     'Garcia Marquez', 'Colombia'),
    (3,  'Isabel',      'Allende',        'Chile'),
    (4,  'Julio',       'Cortazar',       'Argentina'),
    (5,  'Mario',       'Vargas Llosa',   'Peru'),
    (6,  'Stephen',     'King',           'Estados Unidos'),
    (7,  'George',      'Orwell',         'Reino Unido'),
    (8,  'Ray',         'Bradbury',       'Estados Unidos'),
    (9,  'Pablo',       'Neruda',         'Chile'),
    (10, 'Umberto',     'Eco',            'Italia'),
    (11, 'Brian',       'Kernighan',      'Estados Unidos'),
    (12, 'Dennis',      'Ritchie',        'Estados Unidos');
SET IDENTITY_INSERT AUTOR OFF;
GO

-- LIBRO
SET IDENTITY_INSERT LIBRO ON;
INSERT INTO LIBRO (IDLibro, IDEditorial, IDCategoria, Titulo, ISBN, FechaLanzamiento) VALUES
    (1, 5, 1, 'El Aleph',                         '978-950-07-1234-5', '1949-06-01'),
    (2, 1, 1, 'Cien años de soledad',             '978-84-376-0494-7', '1967-05-30'),
    (3, 1, 1, 'La casa de los espiritus',         '978-84-01-37937-6', '1982-01-01'),
    (4, 2, 1, 'Rayuela',                          '978-84-397-1781-3', '1963-06-28'),
    (5, 3, 1, 'La ciudad y los perros',           '978-84-339-7162-0', '1963-01-01'),
    (6, 4, 2, 'It',                               '978-1-501-14297-0', '1986-09-15'),
    (7, 4, 2, '1984',                             '978-0-452-28423-4', '1949-06-08'),
    (8, 4, 2, 'Fahrenheit 451',                   '978-1-451-67331-9', '1953-10-19'),
    (9, 2, 4, 'Veinte poemas de amor y una cancion desesperada','978-84-376-0166-3', '1924-08-01'),
    (10,5, 5, 'El nombre de la rosa',             '978-84-397-1781-4', '1980-01-01'),
    (11,4, 6, 'El lenguaje de programacion C',    '978-0-13-110362-7', '1978-02-22'),
    (12,2, 3, 'El Aleph (Borges, ensayo)',        '978-84-376-0494-8', '1949-06-01');
SET IDENTITY_INSERT LIBRO OFF;
GO

-- LIBRO_AUTOR
INSERT INTO LIBRO_AUTOR (IDLibro, IDAutor) VALUES
    (1,  1),
    (2,  2),
    (3,  3),
    (4,  4),
    (5,  5),
    (6,  6),
    (7,  7),
    (8,  8),
    (9,  9),
    (10, 10),
    (11, 11),
    (11, 12),
    (12, 1);
GO

-- EJEMPLAR (todos arrancan en estado 'Disponible' = 1)
SET IDENTITY_INSERT EJEMPLAR ON;
INSERT INTO EJEMPLAR (IDEjemplar, IDLibro, IDEstado, CodigoEjemplar) VALUES
    (1,  1,  1, 'EJ-0001'),
    (2,  1,  1, 'EJ-0002'),
    (3,  2,  1, 'EJ-0003'),
    (4,  2,  1, 'EJ-0004'),
    (5,  3,  1, 'EJ-0005'),
    (6,  4,  1, 'EJ-0006'),
    (7,  4,  1, 'EJ-0007'),
    (8,  5,  1, 'EJ-0008'),
    (9,  6,  1, 'EJ-0009'),
    (10, 6,  1, 'EJ-0010'),
    (11, 7,  1, 'EJ-0011'),
    (12, 7,  1, 'EJ-0012'),
    (13, 8,  1, 'EJ-0013'),
    (14, 9,  1, 'EJ-0014'),
    (15, 9,  1, 'EJ-0015'),
    (16, 10, 1, 'EJ-0016'),
    (17, 10, 1, 'EJ-0017'),
    (18, 11, 1, 'EJ-0018'),
    (19, 11, 1, 'EJ-0019'),
    (20, 12, 1, 'EJ-0020');
SET IDENTITY_INSERT EJEMPLAR OFF;
GO

-- USUARIO
SET IDENTITY_INSERT USUARIO ON;
INSERT INTO USUARIO (IDUsuario, IDRol, Nombre, Apellido, Email, Telefono, FechaRegistro) VALUES
    (1, 2, 'Ana',      'Gomez',     'ana.gomez@bib.com',     '+54 11 4000-0001', '2025-01-15'),
    (2, 3, 'Luis',     'Perez',     'luis.perez@mail.com',   '+54 11 4000-0002', '2025-02-10'),
    (3, 3, 'Maria',    'Lopez',     'maria.lopez@mail.com',  '+54 11 4000-0003', '2025-03-05'),
    (4, 4, 'Carlos',   'Ramirez',   'carlos.ramirez@edu.com','+54 11 4000-0004', '2025-03-20'),
    (5, 3, 'Sofia',    'Fernandez', 'sofia.fernandez@mail.com','+54 11 4000-0005', '2025-04-12'),
    (6, 1, 'Diego',    'Suarez',    'diego.suarez@bib.com',  '+54 11 4000-0006', '2025-04-18'),
    (7, 3, 'Julieta',  'Castro',    'julieta.castro@mail.com','+54 11 4000-0007', '2025-05-02'),
    (8, 4, 'Martin',   'Ortiz',     'martin.ortiz@edu.com',  '+54 11 4000-0008', '2025-05-22');
SET IDENTITY_INSERT USUARIO OFF;
GO

-- PRESTAMO (los triggers cambian el estado del ejemplar a 'Prestado' = 2)
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

-- DEVOLUCION (los triggers liberan el ejemplar a 'Disponible' = 1)
SET IDENTITY_INSERT DEVOLUCION ON;
INSERT INTO DEVOLUCION (IDDevolucion, IDPrestamo, FechaDevolucion, Observaciones) VALUES
    (1, 1, '2026-06-14', 'Devuelto en buen estado'),
    (2, 2, '2026-06-25', 'Devuelto con 1 dia de atraso');
SET IDENTITY_INSERT DEVOLUCION OFF;
GO
