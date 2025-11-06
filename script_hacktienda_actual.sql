-- =======================================
-- BASE DE DATOS RETAIL MODA
-- =======================================
DROP DATABASE IF EXISTS retail_ropa;
CREATE DATABASE retail_ropa CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE retail_ropa;

-- =======================================
-- TABLA: Tipo de cliente
-- =======================================
CREATE TABLE cliente_tipo (
    id_cliente_tipo INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    descripcion VARCHAR(255)
) ENGINE=InnoDB;

-- =======================================
-- TABLA: Cliente
-- =======================================
CREATE TABLE cliente (
    id_cliente INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    fecha_nacimiento DATE,
    genero ENUM('Masculino', 'Femenino') DEFAULT 'Masculino',
    email VARCHAR(100),
    telefono VARCHAR(20),
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- =======================================
-- TABLA: Tallas (ligadas al tipo de cliente)
-- =======================================
CREATE TABLE talla (
    id_talla INT AUTO_INCREMENT PRIMARY KEY,
    id_cliente_tipo INT NOT NULL,
    talla VARCHAR(10) NOT NULL,
    FOREIGN KEY (id_cliente_tipo) REFERENCES cliente_tipo(id_cliente_tipo) ON DELETE CASCADE
) ENGINE=InnoDB;

-- =======================================
-- TABLA: Tipo de ropa (ligada al tipo de cliente)
-- =======================================
CREATE TABLE tipo_ropa (
    id_tipo_ropa INT AUTO_INCREMENT PRIMARY KEY,
    id_cliente_tipo INT NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT,
    FOREIGN KEY (id_cliente_tipo) REFERENCES cliente_tipo(id_cliente_tipo) ON DELETE CASCADE
) ENGINE=InnoDB;

-- =======================================
-- TABLA: Productos (inventario base)
-- =======================================
CREATE TABLE producto (
    id_producto INT AUTO_INCREMENT PRIMARY KEY,
    id_cliente_tipo INT NOT NULL,
    id_tipo_ropa INT NOT NULL,
    id_talla INT NOT NULL,
    nombre VARCHAR(150) NOT NULL,
    color VARCHAR(50),
    precio DECIMAL(10,2) NOT NULL,
    stock INT NOT NULL DEFAULT 0,
    fecha_ingreso TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_cliente_tipo) REFERENCES cliente_tipo(id_cliente_tipo),
    FOREIGN KEY (id_tipo_ropa) REFERENCES tipo_ropa(id_tipo_ropa),
    FOREIGN KEY (id_talla) REFERENCES talla(id_talla),
    INDEX idx_stock (stock),
    INDEX idx_tipo_ropa (id_tipo_ropa)
) ENGINE=InnoDB;

-- =======================================
-- TABLA: Ventas
-- =======================================
CREATE TABLE venta (
    id_venta INT AUTO_INCREMENT PRIMARY KEY,
    id_cliente INT,
    id_producto INT NOT NULL,
    fecha DATETIME DEFAULT CURRENT_TIMESTAMP,
    cantidad INT NOT NULL,
    subtotal DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente) ON DELETE SET NULL,
    FOREIGN KEY (id_producto) REFERENCES producto(id_producto) ON DELETE CASCADE,
    INDEX idx_fecha (fecha),
    INDEX idx_producto (id_producto)
) ENGINE=InnoDB;

-- =======================================
-- INSERTAR DATOS BÁSICOS
-- =======================================

-- Tipos de cliente
INSERT INTO cliente_tipo (nombre, descripcion) VALUES
('Mujer', 'Ropa y accesorios para mujer'),
('Hombre', 'Ropa y accesorios para hombre'),
('Niño', 'Ropa para niños de 4 a 16 años'),
('Niña', 'Ropa para niñas de 4 a 16 años');

-- Tallas por tipo de cliente
INSERT INTO talla (id_cliente_tipo, talla) VALUES
-- Mujer
(1, 'XXS'), (1, 'XS'), (1, 'S'), (1, 'M'), (1, 'L'), (1, 'XL'),
-- Hombre
(2, 'XXS'), (2, 'XS'), (2, 'S'), (2, 'M'), (2, 'L'), (2, 'XL'),
-- Niño
(3, '4'), (3, '6'), (3, '8'), (3, '10'), (3, '12'), (3, '14'), (3, '16'),
-- Niña
(4, '4'), (4, '6'), (4, '8'), (4, '10'), (4, '12'), (4, '14'), (4, '16');

-- Tipos de ropa
INSERT INTO tipo_ropa (id_cliente_tipo, nombre) VALUES
-- Mujer
(1, 'Abrigo'), (1, 'Bermuda'), (1, 'Buzo'), (1, 'Camisa'), (1, 'Falda'),
(1, 'Hogar'), (1, 'Jeans Terminados'), (1, 'Pantalones'), (1, 'Pijamas'),
(1, 'Ropa Interior'), (1, 'Terceras Piezas'), (1, 'Tshirt'), (1, 'Vestidos'),
-- Hombre
(2, 'Abrigo'), (2, 'Bermuda'), (2, 'Buzo'), (2, 'Camisa'), (2, 'Hogar'),
(2, 'Jeans Terminados'), (2, 'Pantalones'), (2, 'Polos'), (2, 'Ropa de Baño'),
(2, 'Ropa Interior'), (2, 'Tshirt Terminada'),
-- Niño
(3, 'Bermuda'), (3, 'Buzo'), (3, 'Camisa'), (3, 'Jeans Terminados'),
(3, 'Pantalones'), (3, 'Polos'), (3, 'Ropa de Baño'), (3, 'Tshirt Terminada'),
-- Niña
(4, 'Abrigo'), (4, 'Bermuda'), (4, 'Buzo'), (4, 'Camisa'), (4, 'Falda'),
(4, 'Jeans Terminados'), (4, 'Pantalones'), (4, 'Terceras Piezas'),
(4, 'Tshirt Terminada'), (4, 'Vestidos');

-- =======================================
-- CLIENTES DE PRUEBA (30 clientes variados)
-- =======================================
INSERT INTO cliente (nombre, fecha_nacimiento, genero, email, telefono) VALUES
('María González', '1990-03-15', 'Femenino', 'maria.g@email.com', '3001234567'),
('Juan Pérez', '1985-07-22', 'Masculino', 'juan.p@email.com', '3009876543'),
('Ana Martínez', '1995-11-08', 'Femenino', 'ana.m@email.com', '3005551234'),
('Carlos Rodríguez', '1978-04-30', 'Masculino', 'carlos.r@email.com', '3007778888'),
('Laura Sánchez', '2000-09-12', 'Femenino', 'laura.s@email.com', '3002223344'),
('Pedro Gómez', '1992-01-25', 'Masculino', 'pedro.g@email.com', '3004445566'),
('Sofía López', '2010-06-18', 'Femenino', 'sofia.l@email.com', '3006667788'),
('Diego Torres', '2012-08-05', 'Masculino', 'diego.t@email.com', '3008889999'),
('Valentina Ruiz', '1988-12-20', 'Femenino', 'valentina.r@email.com', '3001112233'),
('Andrés Díaz', '1975-03-10', 'Masculino', 'andres.d@email.com', '3003334455'),
('Camila Vargas', '2005-05-28', 'Femenino', 'camila.v@email.com', '3005556677'),
('Santiago Morales', '2008-10-15', 'Masculino', 'santiago.m@email.com', '3007778899'),
('Isabella Castro', '1998-02-14', 'Femenino', 'isabella.c@email.com', '3009990011'),
('Mateo Herrera', '1982-07-08', 'Masculino', 'mateo.h@email.com', '3001231234'),
('Lucía Jiménez', '2015-04-22', 'Femenino', 'lucia.j@email.com', '3003213210'),
('Sebastián Parra', '1993-11-30', 'Masculino', 'sebastian.p@email.com', '3005555555'),
('Gabriela Molina', '1987-09-05', 'Femenino', 'gabriela.m@email.com', '3007777777'),
('Nicolás Rojas', '2011-01-18', 'Masculino', 'nicolas.r@email.com', '3009999999'),
('Daniela Ortiz', '1996-06-25', 'Femenino', 'daniela.o@email.com', '3002468024'),
('Felipe Ramírez', '1980-08-12', 'Masculino', 'felipe.r@email.com', '3001357913'),
('Valentina Mendoza', '2013-12-03', 'Femenino', 'val.mendoza@email.com', '3008642086'),
('Miguel Ángel Silva', '1991-03-28', 'Masculino', 'miguel.silva@email.com', '3009753197'),
('Paula Gutiérrez', '2003-07-19', 'Femenino', 'paula.g@email.com', '3001593578'),
('Joaquín Navarro', '1984-10-07', 'Masculino', 'joaquin.n@email.com', '3007531598'),
('Emma Flores', '2009-02-16', 'Femenino', 'emma.f@email.com', '3008529637'),
('Lucas Aguilar', '1997-05-21', 'Masculino', 'lucas.a@email.com', '3006419527'),
('Martina Reyes', '2014-09-09', 'Femenino', 'martina.r@email.com', '3004826193'),
('Tomás Delgado', '1986-11-14', 'Masculino', 'tomas.d@email.com', '3002938475'),
('Victoria Paz', '1999-01-07', 'Femenino', 'victoria.p@email.com', '3005172849'),
('Emilio Cruz', '2007-04-26', 'Masculino', 'emilio.c@email.com', '3009384756');

-- =======================================
-- PRODUCTOS DE PRUEBA (50 productos variados)
-- =======================================
INSERT INTO producto (id_cliente_tipo, id_tipo_ropa, id_talla, nombre, color, precio, stock) VALUES
-- MUJER (15 productos)
(1, 1, 4, 'Abrigo Invierno Premium', 'Negro', 250000, 15),
(1, 4, 4, 'Camisa Elegante Mujer', 'Blanca', 85000, 25),
(1, 7, 5, 'Jeans Skinny Mujer', 'Azul', 120000, 30),
(1, 13, 3, 'Vestido Casual Verano', 'Floral', 95000, 20),
(1, 5, 4, 'Falda Plisada', 'Negro', 75000, 18),
(1, 12, 4, 'Camiseta Básica Mujer', 'Blanca', 45000, 50),
(1, 3, 5, 'Buzo Deportivo Mujer', 'Gris', 110000, 22),
(1, 8, 4, 'Pantalón Formal Mujer', 'Negro', 135000, 12),
(1, 9, 4, 'Pijama Confort Mujer', 'Rosa', 68000, 35),
(1, 2, 3, 'Bermuda Deportiva Mujer', 'Azul Marino', 55000, 28),
(1, 13, 5, 'Vestido Elegante Noche', 'Rojo', 180000, 8),
(1, 11, 4, 'Chaqueta Casual Mujer', 'Beige', 145000, 14),
(1, 7, 6, 'Jeans Boyfriend Mujer', 'Azul Claro', 115000, 26),
(1, 4, 3, 'Blusa Estampada Mujer', 'Multicolor', 72000, 32),
(1, 10, 4, 'Ropa Interior Set Mujer', 'Negro', 48000, 45),

-- HOMBRE (15 productos)
(2, 14, 10, 'Abrigo Formal Hombre', 'Gris', 280000, 10),
(2, 17, 11, 'Camisa Ejecutiva Hombre', 'Azul', 92000, 28),
(2, 19, 11, 'Jeans Clásico Hombre', 'Índigo', 125000, 35),
(2, 22, 11, 'Polo Deportivo Hombre', 'Negro', 58000, 40),
(2, 20, 12, 'Pantalón Chino Hombre', 'Beige', 105000, 24),
(2, 24, 11, 'Camiseta Premium Hombre', 'Blanca', 52000, 48),
(2, 16, 10, 'Buzo Casual Hombre', 'Gris Oscuro', 98000, 30),
(2, 15, 11, 'Bermuda Playera Hombre', 'Azul', 62000, 22),
(2, 23, 11, 'Traje de Baño Hombre', 'Negro', 75000, 18),
(2, 21, 11, 'Ropa Interior Pack Hombre', 'Variado', 45000, 55),
(2, 17, 9, 'Camisa Casual Hombre', 'Cuadros', 85000, 26),
(2, 20, 11, 'Pantalón Jogger Hombre', 'Negro', 88000, 32),
(2, 22, 10, 'Polo Clásico Hombre', 'Blanco', 54000, 38),
(2, 14, 12, 'Chaqueta Impermeable Hombre', 'Azul Marino', 165000, 12),
(2, 24, 11, 'Camiseta Estampada Hombre', 'Gris', 48000, 42),

-- NIÑO (10 productos)
(3, 26, 15, 'Buzo Deportivo Niño', 'Azul', 65000, 20),
(3, 27, 16, 'Camisa Escolar Niño', 'Blanca', 48000, 35),
(3, 28, 17, 'Jeans Resistente Niño', 'Azul', 75000, 28),
(3, 30, 16, 'Pantalón Casual Niño', 'Beige', 55000, 24),
(3, 31, 15, 'Polo Sport Niño', 'Rojo', 38000, 40),
(3, 32, 16, 'Traje de Baño Niño', 'Azul', 42000, 22),
(3, 33, 17, 'Camiseta Niño', 'Verde', 32000, 45),
(3, 25, 16, 'Bermuda Verano Niño', 'Naranja', 38000, 30),
(3, 28, 18, 'Jeans Cómodo Niño', 'Azul Oscuro', 72000, 26),
(3, 26, 19, 'Buzo Abrigado Niño', 'Gris', 68000, 18),

-- NIÑA (10 productos)
(4, 34, 22, 'Abrigo Tierno Niña', 'Rosa', 95000, 16),
(4, 37, 23, 'Camisa Escolar Niña', 'Blanca', 48000, 32),
(4, 43, 24, 'Vestido Casual Niña', 'Floral', 72000, 25),
(4, 38, 22, 'Falda Plisada Niña', 'Azul', 45000, 28),
(4, 39, 23, 'Jeans Skinny Niña', 'Azul', 68000, 30),
(4, 40, 24, 'Pantalón Casual Niña', 'Negro', 52000, 24),
(4, 42, 23, 'Camiseta Básica Niña', 'Rosa', 32000, 42),
(4, 35, 22, 'Bermuda Verano Niña', 'Amarillo', 38000, 26),
(4, 43, 25, 'Vestido Elegante Niña', 'Rojo', 88000, 12),
(4, 36, 23, 'Buzo Deportivo Niña', 'Morado', 62000, 22);
-- Producto nuevo para Mujer
INSERT INTO producto (id_cliente_tipo, id_tipo_ropa, id_talla, nombre, color, precio, stock)
VALUES
(1, 1, 4, 'Abrigo de Lana Mujer', 'Negro', 200000, 10);
INSERT INTO producto (id_cliente_tipo, id_tipo_ropa, id_talla, nombre, color, precio, stock) VALUES
(3, 26, 15, 'Buzo Deportivo Niño', 'Azul', 65000, 20),
(3, 27, 16, 'Camisa Escolar Niño', 'Blanca', 48000, 35),
(3, 28, 17, 'Jeans Resistente Niño', 'Azul', 75000, 28),
(3, 30, 16, 'Pantalón Casual Niño', 'Beige', 55000, 24),
(3, 31, 15, 'Polo Sport Niño', 'Rojo', 38000, 40),
(3, 32, 16, 'Traje de Baño Niño', 'Azul', 42000, 22),
(3, 33, 17, 'Camiseta Niño', 'Verde', 32000, 45),
(3, 25, 16, 'Bermuda Verano Niño', 'Naranja', 38000, 30),
(3, 28, 18, 'Jeans Cómodo Niño', 'Azul Oscuro', 72000, 26),
(3, 26, 19, 'Buzo Abrigado Niño', 'Gris', 68000, 18);

-- =======================================
-- VENTAS DE PRUEBA (100 ventas distribuidas)
-- =======================================
INSERT INTO venta (id_cliente, id_producto, fecha, cantidad, subtotal) VALUES
-- Octubre 2025
(1, 3, '2025-10-01 10:30:00', 2, 240000),
(2, 17, '2025-10-01 14:15:00', 1, 92000),
(3, 27, '2025-10-02 09:45:00', 3, 144000),
(4, 12, '2025-10-02 16:20:00', 1, 45000),
(5, 21, '2025-10-03 11:00:00', 2, 90000),
(6, 8, '2025-10-03 13:30:00', 1, 135000),
(7, 43, '2025-10-04 10:15:00', 2, 144000),
(8, 32, '2025-10-04 15:45:00', 1, 42000),
(9, 4, '2025-10-05 12:00:00', 1, 95000),
(10, 19, '2025-10-05 14:30:00', 3, 375000),
(11, 38, '2025-10-06 09:30:00', 2, 90000),
(12, 26, '2025-10-06 16:00:00', 1, 65000),
(13, 6, '2025-10-07 11:45:00', 4, 180000),
(14, 22, '2025-10-07 13:15:00', 2, 108000),
(15, 49, '2025-10-08 10:00:00', 1, 88000),
(16, 13, '2025-10-08 15:30:00', 2, 230000),
(17, 1, '2025-10-09 12:30:00', 1, 250000),
(18, 28, '2025-10-09 14:00:00', 2, 150000),
(19, 7, '2025-10-10 09:00:00', 1, 110000),
(20, 35, '2025-10-10 16:45:00', 3, 114000),

-- Noviembre 2025 (más reciente - más ventas)
(21, 3, '2025-11-01 10:00:00', 3, 360000),
(22, 17, '2025-11-01 11:30:00', 2, 184000),
(23, 6, '2025-11-01 14:00:00', 5, 225000),
(24, 22, '2025-11-01 16:15:00', 3, 162000),
(25, 39, '2025-11-02 09:30:00', 2, 136000),
(26, 12, '2025-11-02 11:00:00', 4, 180000),
(27, 31, '2025-11-02 13:45:00', 3, 114000),
(28, 7, '2025-11-02 15:30:00', 2, 220000),
(29, 19, '2025-11-03 10:15:00', 4, 500000),
(30, 43, '2025-11-03 12:00:00', 1, 72000),
(1, 24, '2025-11-03 14:30:00', 3, 144000),
(2, 8, '2025-11-03 16:00:00', 1, 135000),
(3, 32, '2025-11-04 09:00:00', 2, 84000),
(4, 15, '2025-11-04 11:30:00', 3, 186000),
(5, 4, '2025-11-04 13:00:00', 2, 190000),
(6, 27, '2025-11-04 15:45:00', 4, 192000),
(7, 46, '2025-11-05 10:30:00', 2, 104000),
(8, 13, '2025-11-05 12:15:00', 1, 115000),
(9, 21, '2025-11-05 14:00:00', 2, 90000),
(10, 38, '2025-11-05 16:30:00', 3, 135000),
(11, 6, '2025-11-06 09:45:00', 6, 270000),
(12, 17, '2025-11-06 11:15:00', 2, 184000),
(13, 28, '2025-11-06 13:30:00', 2, 150000),
(14, 3, '2025-11-06 15:00:00', 4, 480000),
(15, 42, '2025-11-06 16:45:00', 5, 160000),

-- Ventas adicionales para crear más datos
(16, 22, '2025-10-15 10:00:00', 2, 108000),
(17, 19, '2025-10-16 11:30:00', 3, 375000),
(18, 6, '2025-10-17 13:00:00', 4, 180000),
(19, 12, '2025-10-18 14:30:00', 3, 135000),
(20, 27, '2025-10-19 09:15:00', 2, 96000),
(21, 31, '2025-10-20 10:45:00', 3, 114000),
(22, 7, '2025-10-21 12:00:00', 1, 110000),
(23, 17, '2025-10-22 13:30:00', 2, 184000),
(24, 24, '2025-10-23 15:00:00', 4, 192000),
(25, 38, '2025-10-24 16:15:00', 2, 90000),
(26, 3, '2025-10-25 09:30:00', 3, 360000),
(27, 43, '2025-10-26 11:00:00', 1, 72000),
(28, 32, '2025-10-27 12:30:00', 2, 84000),
(29, 8, '2025-10-28 14:00:00', 1, 135000),
(30, 19, '2025-10-29 15:30:00', 5, 625000),
(1, 15, '2025-10-30 10:00:00', 2, 124000),
(2, 4, '2025-10-31 11:30:00', 1, 95000),
(3, 28, '2025-10-31 13:00:00', 3, 225000),
(4, 46, '2025-10-31 14:30:00', 2, 104000),
(5, 21, '2025-10-31 16:00:00', 1, 45000),

-- Más ventas de noviembre para tendencias
(6, 6, '2025-11-07 09:00:00', 7, 315000),
(7, 17, '2025-11-07 10:30:00', 3, 276000),
(8, 22, '2025-11-07 12:00:00', 4, 216000),
(9, 3, '2025-11-07 13:30:00', 2, 240000),
(10, 12, '2025-11-07 15:00:00', 5, 225000),
(11, 27, '2025-11-08 09:30:00', 3, 144000),
(12, 19, '2025-11-08 11:00:00', 6, 750000),
(13, 31, '2025-11-08 12:30:00', 4, 152000),
(14, 7, '2025-11-08 14:00:00', 2, 220000),
(15, 38, '2025-11-08 15:30:00', 3, 135000),
(16, 24, '2025-11-09 10:00:00', 5, 240000),
(17, 43, '2025-11-09 11:30:00', 2, 144000),
(18, 8, '2025-11-09 13:00:00', 1, 135000),
(19, 32, '2025-11-09 14:30:00', 3, 126000),
(20, 15, '2025-11-09 16:00:00', 2, 124000),
(21, 4, '2025-11-10 09:00:00', 2, 190000),
(22, 28, '2025-11-10 10:30:00', 4, 300000),
(23, 46, '2025-11-10 12:00:00', 2, 104000),
(24, 21, '2025-11-10 13:30:00', 3, 135000),
(25, 13, '2025-11-10 15:00:00', 1, 115000);
SELECT id_producto, nombre FROM producto ORDER BY id_producto;
INSERT INTO venta (id_cliente, id_producto, fecha, cantidad, subtotal) VALUES
(1, 251, '2025-10-01 10:30:00', 2, 240000),
(2, 252, '2025-10-01 14:15:00', 1, 92000),
(3, 253, '2025-10-02 09:45:00', 3, 144000),
(4, 254, '2025-10-02 16:20:00', 1, 45000),
(5, 255, '2025-10-03 11:00:00', 2, 90000),
(6, 256, '2025-10-03 13:30:00', 1, 135000),
(7, 257, '2025-10-04 10:15:00', 2, 144000),
(8, 258, '2025-10-04 15:45:00', 1, 42000),
(9, 259, '2025-10-05 12:00:00', 1, 95000),
(10, 260, '2025-10-05 14:30:00', 3, 375000);

-- =======================================
-- PRODUCTOS CON STOCK CRÍTICO Y ALTA ROTACIÓN
-- =======================================

-- Productos nuevos con stock bajo (crítico ≤5)
INSERT INTO producto (id_cliente_tipo, id_tipo_ropa, id_talla, nombre, color, precio, stock) VALUES
(1, 4, 4, 'Blusa Edición Limitada', 'Roja', 95000, 3),   -- Stock crítico
(2, 20, 12, 'Pantalón Premium Hombre', 'Negro', 150000, 2), -- Stock crítico
(3, 28, 17, 'Jeans Niño Resistente', 'Azul', 75000, 5), -- Stock crítico

-- Productos con stock normal pero con muchas ventas (alta rotación)
(1, 13, 3, 'Vestido Fiesta Mujer', 'Negro', 120000, 20),
(2, 22, 11, 'Polo Deportivo Hombre', 'Azul', 60000, 15),
(4, 43, 24, 'Vestido Casual Niña', 'Floral', 72000, 18);

-- =======================================
-- VENTAS PARA GENERAR ALTA ROTACIÓN
-- =======================================
INSERT INTO venta (id_cliente, id_producto, fecha, cantidad, subtotal) VALUES
-- Alta rotación Mujer
(1, 251, '2025-11-01 10:00:00', 10, 1200000),
(2, 251, '2025-11-02 12:00:00', 5, 600000),
(3, 254, '2025-11-03 14:00:00', 7, 840000),

-- Alta rotación Hombre
(4, 252, '2025-11-04 10:30:00', 8, 480000),
(5, 252, '2025-11-05 11:15:00', 6, 360000),

-- Alta rotación Niña
(6, 255, '2025-11-06 09:45:00', 9, 648000),
(7, 255, '2025-11-06 15:00:00', 4, 288000);

-- =======================================
-- CONSULTAS ÚTILES PARA VERIFICAR
-- =======================================
-- Ver total de ventas por mes
-- SELECT DATE_FORMAT(fecha, '%Y-%m') AS mes, SUM(subtotal) AS total FROM venta GROUP BY mes;

-- Ver productos con stock crítico
-- SELECT * FROM producto WHERE stock <= 5;

-- Ver productos más vendidos
-- SELECT p.nombre, SUM(v.cantidad) AS total_ventas FROM venta v JOIN producto p ON v.id_producto = p.id_producto GROUP BY p.id_producto ORDER BY total_ventas DESC LIMIT 10;

-- Ver rotación de productos
-- SELECT p.nombre, SUM(v.cantidad)/p.stock AS rotacion FROM venta v JOIN producto p ON v.id_producto = p.id_producto GROUP BY p.id_producto ORDER BY rotacion DESC;