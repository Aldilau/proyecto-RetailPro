-- =====================================================================
-- RETAILPRO - M5: CONSULTAS CON JOINS PARA EL PROYECTO
-- =====================================================================
-- Base sobre el modelo relacional de retailpro_modelo.sql:
--   territorios(id_territorio, ciudad, region, pais, zona)
--   clientes(id_cliente, nombre, email, id_territorio, segmento, fecha_registro)
--   productos(id_producto, nombre_producto, categoria, subcategoria, precio, costo)
--   ventas(id_venta, fecha_venta, id_cliente, id_producto, cantidad,
--          precio_unitario, total_venta, canal)
-- =====================================================================

USE RetailPro;


-- ---------------------------------------------------------------------
-- CONSULTA 1 - Vista base del proyecto (INNER JOIN)
-- ---------------------------------------------------------------------
-- Cruza ventas + clientes + productos + territorios en una sola fila.

SELECT
    v.fecha_venta                  AS fecha,
    c.nombre                       AS nombre_cliente,
    c.segmento                     AS segmento,
    t.region                       AS region,
    p.nombre_producto              AS nombre_producto,
    p.categoria                    AS categoria,
    v.cantidad                     AS cantidad,
    v.precio_unitario              AS precio_unitario,
    v.total_venta                  AS total_venta,
    v.canal                        AS canal
FROM ventas v
INNER JOIN clientes c
    ON v.id_cliente = c.id_cliente
INNER JOIN productos p
    ON v.id_producto = p.id_producto
INNER JOIN territorios t
    ON c.id_territorio = t.id_territorio
ORDER BY v.fecha_venta;


-- ---------------------------------------------------------------------
-- CONSULTA 2 - Clientes sin ventas (LEFT JOIN)
-- ---------------------------------------------------------------------
-- Clientes registrados que nunca compraron. Se parte de clientes
--y se hace LEFT JOIN contra ventas: los clientes sin ninguna
-- venta asociada quedan con id_venta = NULL.
SELECT
    c.nombre            AS nombre_cliente,
    c.email              AS email,
    c.fecha_registro     AS fecha_registro
FROM clientes c
LEFT JOIN ventas v
    ON c.id_cliente = v.id_cliente
WHERE v.id_venta IS NULL;


-- ---------------------------------------------------------------------
-- CONSULTA 3 - Productos sin ventas (LEFT JOIN)
-- ---------------------------------------------------------------------
-- Mismo criterio que la consulta anterior, ahora partiendo de productos.
SELECT
    p.nombre_producto   AS nombre_producto,
    p.categoria         AS categoria,
    p.precio            AS precio
FROM productos p
LEFT JOIN ventas v
    ON p.id_producto = v.id_producto
WHERE v.id_venta IS NULL;


-- ---------------------------------------------------------------------
-- CONSULTA 4 - Consolidado por canal (UNION ALL)
-- ---------------------------------------------------------------------
-- El modelo no tiene tablas separadas por canal: todas las ventas viven
-- en "ventas" y la columna canal trae 'Online', 'Tienda' o 'Mayorista'.
-- Para respetar la consigna (Online vs. Presencial), se arman dos
-- subconsultas sobre la misma tabla -cada una con su propio filtro y su
-- columna canal "reescrita" a mano- y se combinan con UNION ALL:
--   - Online     -> canal = 'Online'
--   - Presencial -> canal IN ('Tienda', 'Mayorista')  (venta con
--                   atención física, sin canal de e-commerce)
-- Sobre ese consolidado se calcula el total por canal con GROUP BY.
SELECT
    canal,
    SUM(total_venta) AS total_por_canal
FROM (
    SELECT
        'Online'        AS canal,
        v.id_venta,
        v.fecha_venta,
        v.total_venta
    FROM ventas v
    WHERE v.canal = 'Online'

    UNION ALL

    SELECT
        'Presencial'    AS canal,
        v.id_venta,
        v.fecha_venta,
        v.total_venta
    FROM ventas v
    WHERE v.canal IN ('Tienda', 'Mayorista')
) AS ventas_consolidadas
GROUP BY canal;
