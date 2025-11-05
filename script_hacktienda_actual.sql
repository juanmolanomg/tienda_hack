CREATE DATABASE IF NOT EXISTS retail_ropa;
USE retail_ropa;

-- ==============================
-- TABLA: Tipo de cliente
-- ==============================
CREATE TABLE cliente_tipo (
    id_cliente_tipo INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL
);

-- ==============================
-- TABLA: Tallas (ligadas al tipo de cliente)
-- ==============================
CREATE TABLE talla (
    id_talla INT AUTO_INCREMENT PRIMARY KEY,
    id_cliente_tipo INT NOT NULL,
    talla VARCHAR(10) NOT NULL,
    FOREIGN KEY (id_cliente_tipo) REFERENCES cliente_tipo(id_cliente_tipo)
);

-- ==============================
-- TABLA: Tipo de ropa (ligada al tipo de cliente)
-- ==============================
CREATE TABLE tipo_ropa (
    id_tipo_ropa INT AUTO_INCREMENT PRIMARY KEY,
    id_cliente_tipo INT NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    FOREIGN KEY (id_cliente_tipo) REFERENCES cliente_tipo(id_cliente_tipo)
);

-- ==============================
-- TABLA: Productos (inventario base)
-- ==============================
CREATE TABLE producto (
    id_producto INT AUTO_INCREMENT PRIMARY KEY,
    id_cliente_tipo INT NOT NULL,
    id_tipo_ropa INT NOT NULL,
    id_talla INT NOT NULL,
    nombre VARCHAR(150) NOT NULL,
    color VARCHAR(50),
    precio DECIMAL(10,2) NOT NULL,
    stock INT NOT NULL DEFAULT 0,
    FOREIGN KEY (id_cliente_tipo) REFERENCES cliente_tipo(id_cliente_tipo),
    FOREIGN KEY (id_tipo_ropa) REFERENCES tipo_ropa(id_tipo_ropa),
    FOREIGN KEY (id_talla) REFERENCES talla(id_talla)
);

-- ==============================
-- TABLA: Ventas
-- ==============================
CREATE TABLE venta (
    id_venta INT AUTO_INCREMENT PRIMARY KEY,
    fecha DATETIME DEFAULT CURRENT_TIMESTAMP,
    total DECIMAL(10,2) NOT NULL
);

-- ==============================
-- TABLA: Detalle de ventas
-- ==============================
CREATE TABLE detalle_venta (
    id_detalle INT AUTO_INCREMENT PRIMARY KEY,
    id_venta INT NOT NULL,
    id_producto INT NOT NULL,
    cantidad INT NOT NULL,
    subtotal DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (id_venta) REFERENCES venta(id_venta),
    FOREIGN KEY (id_producto) REFERENCES producto(id_producto)
);

-- ==============================
-- INSERTAR DATOS BÁSICOS
-- ==============================

-- Tipos de cliente
INSERT INTO cliente_tipo (nombre) VALUES
('Mujer'), ('Hombre'), ('Niño'), ('Niña');

-- Tallas por tipo de cliente
INSERT INTO talla (id_cliente_tipo, talla)
VALUES
(1, 'XXS'), (1, 'XS'), (1, 'S'), (1, 'M'), (1, 'L'), (1, 'XL'),
(2, 'XXS'), (2, 'XS'), (2, 'S'), (2, 'M'), (2, 'L'), (2, 'XL'),
(3, '4'), (3, '6'), (3, '8'), (3, '10'), (3, '12'), (3, '14'), (3, '16'),
(4, '4'), (4, '6'), (4, '8'), (4, '10'), (4, '12'), (4, '14'), (4, '16');

-- Tipos de ropa (por tipo de cliente)
INSERT INTO tipo_ropa (id_cliente_tipo, nombre)
VALUES
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
