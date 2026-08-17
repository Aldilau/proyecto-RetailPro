-- =====================================================================
-- Pre-entrega: Consultas SQL de negocio
-- Título: Extrayendo métricas clave con SQL
-- Base de datos: Ventas_Tech_DB
-- Tabla utilizada: ventas (id_cliente, id_producto, cantidad, precio_unitario, fecha_venta)
-- =====================================================================

USE Ventas_Tech_DB;

-- =====================================================================
-- Consulta 1 — Resumen ejecutivo mensual
-- Total facturado, cantidad de pedidos y ticket promedio, por mes
-- =====================================================================
SELECT
    MONTH(fecha_venta)                       AS mes,
    SUM(cantidad * precio_unitario)          AS total_facturado,
    COUNT(*)                                 AS cantidad_pedidos,
    ROUND(
        SUM(cantidad * precio_unitario) / COUNT(*),
        2
    )                                        AS ticket_promedio
FROM ventas
GROUP BY MONTH(fecha_venta)
ORDER BY mes;
 
 
-- =====================================================================
-- Consulta 2 — Ranking de productos
-- Top 5 de id_producto por total facturado
-- =====================================================================
SELECT TOP 5
    id_producto,
    SUM(cantidad)                            AS unidades_vendidas,
    SUM(cantidad * precio_unitario)          AS total_facturado
FROM ventas
GROUP BY id_producto
ORDER BY total_facturado DESC;
 
 
-- =====================================================================
-- Consulta 3 — Clientes recurrentes
-- Clientes con más de un pedido, cantidad de pedidos y total gastado
-- =====================================================================
SELECT
    id_cliente,
    COUNT(*)                                 AS cantidad_pedidos,
    SUM(cantidad * precio_unitario)          AS total_gastado
FROM ventas
GROUP BY id_cliente
HAVING COUNT(*) > 1
ORDER BY total_gastado DESC;
 
 
-- =====================================================================
-- Consulta 4 — Meses por encima/por debajo del promedio
-- Total facturado por mes, comparado contra el promedio mensual general
-- =====================================================================
SELECT
    MONTH(fecha_venta)                       AS mes,
    SUM(cantidad * precio_unitario)          AS total_facturado,
    CASE
        WHEN SUM(cantidad * precio_unitario) > (
            SELECT AVG(total_mes)
            FROM (
                SELECT SUM(cantidad * precio_unitario) AS total_mes
                FROM ventas
                GROUP BY MONTH(fecha_venta)
            ) AS totales_por_mes
        ) THEN 'Por encima'
        ELSE 'Por debajo'
    END                                       AS comparacion_promedio
FROM ventas
GROUP BY MONTH(fecha_venta)
ORDER BY mes;
 
 
-- =====================================================================
-- Hallazgos
-- =====================================================================
-- 1. El producto 1 (Laptop Pro15) concentra el 55,9% de la facturación
--    total ($3.600 de $6.444), a pesar de haberse vendido en solo 3
--    unidades. Es el caso opuesto al Mouse Inalámbrico (id_producto 2),
--    que vendió 13 unidades pero generó apenas el 5,6% del total ($364):
--    unidades vendidas no es lo mismo que impacto en la facturación.
--
-- 2. Los 5 clientes de la base son recurrentes: todos realizaron
--    exactamente 2 pedidos cada uno. El cliente 1 (María López) es el
--    que más gastó en total ($2.640), seguido por el cliente 5
--    (Laura Torres, $2.100); entre ambos explican el 73,5% del total
--    facturado.
--
-- 3. Todas las ventas registradas corresponden a marzo de 2024 (un único
--    mes), por lo que la Consulta 4 no aporta información útil todavía:
--    al no haber otros meses para comparar, el único mes disponible
--    queda técnicamente "Por debajo" del promedio (no supera su propio
--    valor). Este análisis va a ser relevante recién cuando se carguen
--    ventas de más meses.