-- Eliminar base de datos si es que ya existe.
DROP DATABASE biblioteca;
-- Crear base de datos.
CREATE DATABASE biblioteca;

-- Cambiar a esa base de datos.
\c biblioteca

-- Crear las tablas indicadas de acuerdo al modelo de datos.
CREATE TABLE socios(
    rut VARCHAR(20) PRIMARY KEY,
    nombre VARCHAR(100),
    apellido VARCHAR(100),
    calle VARCHAR(100),
    número VARCHAR(20),
    comuna VARCHAR(50),
    teléfono VARCHAR(20)
);

CREATE TABLE libros(
    isbn VARCHAR PRIMARY KEY,
    título VARCHAR(100),
    pág INT,
    días_préstamo INT
);

CREATE TABLE autores(
    id_autor INT PRIMARY KEY,
    nombre VARCHAR(100),
    apellido VARCHAR(100),
    tipo_autor VARCHAR(20),
    nacimiento VARCHAR(50),
    defunción VARCHAR(50)
);

CREATE TABLE libros_autores(
    isbn VARCHAR,
    id_autor INT,
    FOREIGN KEY(isbn) REFERENCES libros(isbn),
    FOREIGN KEY(id_autor) REFERENCES autores(id_autor)
);

CREATE TABLE historial(
    id_historial SERIAL PRIMARY KEY,
    rut VARCHAR(20),
    isbn VARCHAR,
    fecha_préstamo DATE,
    fecha_devolución DATE,
    FOREIGN KEY(rut) REFERENCES socios(rut),
    FOREIGN KEY(isbn) REFERENCES libros(isbn)
);

-- Insertar los siguientes registros.
\copy socios FROM 'socios.csv' csv header;
\copy libros FROM 'libros.csv' csv header;
\copy autores FROM 'autores.csv' csv header;
\copy libros_autores FROM 'libros_autores.csv' csv header;
\copy historial FROM 'historial.csv' csv header;

--a. Mostrar todos los libros que posean menos de 300 páginas.
SELECT *
FROM libros
WHERE pág < 300;

-- b. Mostrar todos los autores que hayan nacido después del 01-01-1970.
--Nota: Solo aparece el año de nacimiento en los registros.
SELECT *
FROM autores
WHERE nacimiento >= '1970';

-- c. ¿Cuál es el libro más solicitado?
SELECT DISTINCT título AS "Libro más solicitado"
FROM libros AS A 
JOIN historial AS B 
ON A.isbn=B.isbn
WHERE B.isbn=(SELECT MAX(isbn) FROM historial);

-- d. Si se cobrara una multa de $100 por cada día de atraso, mostrar cuánto debería pagar cada usuario que entregue el préstamo después de 7 días.
SELECT A.rut, B.título, A.fecha_préstamo, A.fecha_devolución, B.días_préstamo, (A.fecha_devolución - A.fecha_préstamo) AS "Días prestado", ((A.fecha_devolución - A.fecha_préstamo) - B.días_préstamo) AS "Días de atraso", ((A.fecha_devolución - A.fecha_préstamo) - B.días_préstamo) * 100 AS "Multa en $"
FROM historial AS A
JOIN libros AS B
ON A.isbn=B.isbn
WHERE ((A.fecha_devolución - A.fecha_préstamo) - B.días_préstamo) * 100 > 7;
