-- 📌 Crea un gatillo (after_insert_pedidos) que se activa después de cada inserción en la tabla de pedidos. Este gatillo actualiza el precio total en los pedidos según la cantidad y el precio del producto.

-- Creación de la tabla productos
CREATE TABLE productos (
    producto_id SERIAL PRIMARY KEY,
    nombre_producto VARCHAR(100) NOT NULL,
    precio DECIMAL(10, 2) NOT NULL
);

-- Inserción de algunos datos iniciales en la tabla productos
INSERT INTO productos (nombre_producto, precio) VALUES
('Producto A', 50.00),
('Producto B', 75.00),
('Producto C', 100.00);

-- Creación de la tabla pedidos
CREATE TABLE pedidos (
    pedido_id SERIAL PRIMARY KEY,
    fecha_pedido DATE NOT NULL,
    producto_id INT REFERENCES productos(producto_id),
    cantidad INT NOT NULL
	precio_total DECIMAL(10,2)
);

-- Inserción de algunos datos iniciales en la tabla pedidos
INSERT INTO pedidos (fecha_pedido, producto_id, cantidad) VALUES
('2023-01-15', 1, 2),
('2023-01-16', 2, 1),
('2023-01-17', 3, 3);

--  Crea un gatillo (after_insert_pedidos) que se activa después de cada inserción en la tabla de pedidos. Este gatillo actualiza el precio total en los pedidos según la cantidad y el precio del producto.

CREATE OR REPLACE FUNCTION actualizar_precio_total() RETURNS TRIGGER $after_insert_pedidos$
	BEGIN
		UPDATE pedidos
		SET precio_total = p.precio * NEW.cantidad
		FROM productos p
		WHERE p.productos_id = NEW.producto_id AND pedidos.pedido_id = NEW.pedido_id
		RETURN NEW
	END;

$after_insert_pedidos$ LANGUAGE plpgsql

CREATE TRIGGER after_insert_pedido
AFTER INSERT ON pedidos
	FOR EACH ROW EXECUTE FUNCTION actualizar_precio_total();

-- 📌 Utiliza una subselección para mostrar los pedidos con un precio total mayor a 100.

SELECT * FROM pedidos WHERE (SELECT precio FROM productos WHERE producto_id = pedidos.producto_id) * cantidad > 100

-- 📌 Crea una vista (productos_con_cantidad) que muestra los productos con las cantidades pedidas.

CREATE VIEW productos_con_cantidad AS 
	SELECT p.producto_id, p.nombre_producto, SUM(cantidad) AS cantidad_pedida
	FROM productos p
	LEFT JOIN pedidos ON p.producto_id = pedidos.producto_id
	GROUP BY p.producto_id, p.nombre_producto;

-- 📌 Crea un índice en la columna nombre_producto de la tabla productos para acelerar las búsquedas por nombre.

CREATE INDEX idx_nombre_producto ON productos(nombre_producto);