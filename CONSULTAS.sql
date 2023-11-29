-- Consultas para la tabla Producto

--Consultas CRUD:
--Create

   INSERT INTO Producto (NombreMedicamento, IDCategoriaProducto, NombreComercial, PrincipioActivo, FormaFarmaceutica, Concentracion, PresentacionComercial, NumeroLote, PrecioProducto, FechaFabricacion, FechaVencimiento, PrecioUnitario, FKIDProvedor, FKIDEstante)VALUES 
   ('NombreMedicamento', 1, 'NombreComercial', 'PrincipioActivo', 'FormaFarmaceutica', 'Concentracion', 'PresentacionComercial', 'NumeroLote', 10.50, '2023-01-01', '2023-12-31', 10.00, 1, 1);
   -- Recuerda cambiar los valores a como lo necesites agregar 

--Read

   SELECT * FROM Producto;

--Update

   UPDATE Producto
   SET NombreMedicamento = 'NuevoNombre', PrecioProducto = 15.00
   WHERE IDProducto = 1;

   -- Recuerda cambiar los valores a como lo necesites agregar 

--Delete

   DELETE FROM Producto WHERE IDProducto = 1;


--Cosultas con procedimientos de almacenado--  


--1. Encontrar productos con precio mayor al promedio
 
DELIMITER //
CREATE PROCEDURE ProductosPrecioMayorPromedio()
BEGIN
    SELECT NombreMedicamento, PrecioProducto
    FROM Producto
    WHERE PrecioProducto > (
        SELECT AVG(PrecioProducto)
        FROM Producto
    );
END //
DELIMITER ;

CALL ProductosPrecioMayorPromedio();

--2. Mostrar los productos más vendidos por tipo de pago

DELIMITER //
CREATE PROCEDURE ProductosMasVendidosPorTipoPago()
BEGIN
    SELECT  TP.TipoPago, P.NombreMedicamento, DV.Cantidad AS CantidadVendida 
    FROM TipoPago TP
    INNER JOIN DetallesVenta DV ON TP.IDTipoPago = DV.IDTipoPago
    INNER JOIN (
        SELECT DV.FKIDProducto, SUM(DV.Cantidad) AS TotalVendido
        FROM DetallesVenta DV
        GROUP BY DV.FKIDProducto
        ORDER BY TotalVendido DESC
    ) AS TopProductos ON DV.FKIDProducto = TopProductos.FKIDProducto
    INNER JOIN Producto P ON TopProductos.FKIDProducto = P.IDProducto;
END //
DELIMITER ;

CALL ProductosMasVendidosPorTipoPago();


--3. Encontrar los productos que nunca se han vendido

DELIMITER //
CREATE PROCEDURE ProductosNuncaVendidos()
BEGIN
    SELECT P.IDProducto, P.NombreMedicamento
    FROM Producto P
    LEFT JOIN DetallesVenta DV ON P.IDProducto = DV.FKIDProducto
    WHERE DV.FKIDProducto IS NULL;
END //
DELIMITER ;

CALL ProductosNuncaVendidos();


--4. Productos con menor stock en un estante específico
 sql 
DELIMITER //

CREATE PROCEDURE ProductosMenorStockEnEstante(IN idEstante INT)
BEGIN
    SELECT NombreMedicamento, Concentracion, PresentacionComercial, Concentracion, CantidadStock
    FROM Producto
    INNER JOIN (
        SELECT FKIDProducto, CantidadStock
        FROM Inventario
        WHERE FKProductoIDEstante = idEstante
        ORDER BY CantidadStock ASC
        LIMIT 5
    ) AS StockBajo ON Producto.IDProducto = StockBajo.FKIDProducto;
END //

DELIMITER ;

CALL ProductosMenorStockEnEstante(1);


--5. procedimiento almacenado que muestre los productos con una cantidad de stock específica y que tenga un precio menor al promedio de los precios de todos los productos en esa categoría

 DELIMITER //
CREATE PROCEDURE ProductosStockYPrecioPorDebajoPromedio(IN cantidadStock INT)
BEGIN
    SELECT P.NombreMedicamento, P.PrecioProducto, Inv.CantidadStock
    FROM Producto P
    INNER JOIN (
        SELECT PP.IDProducto, PP.PrecioProducto
        FROM Producto PP
        INNER JOIN (
            SELECT P.IDCategoriaProducto, AVG(P.PrecioProducto) AS PrecioPromedio
            FROM Producto P
            GROUP BY P.IDCategoriaProducto
        ) AS PromedioCategoria ON PP.IDCategoriaProducto = PromedioCategoria.IDCategoriaProducto
        WHERE PP.PrecioProducto < PromedioCategoria.PrecioPromedio
    ) AS PreciosPorDebajoPromedio ON P.IDProducto = PreciosPorDebajoPromedio.IDProducto
    INNER JOIN Inventario Inv ON P.IDProducto = Inv.FKIDProducto
    WHERE Inv.CantidadStock = cantidadStock;
END //

DELIMITER 
CALL ProductosStockYPrecioPorDebajoPromedio(453); 


--Consultas para la tabla Inventario

--Consultas CRUD--

--1. Create agregar un nuevo registro al inventario:

INSERT INTO Inventario (FKIDProducto, FKProductoIDEstante, CantidadStock)
VALUES (1, 1, 50); -- Agrega 50 unidades del producto con ID 1 al estante con ID 3


--2. Read  Mostrar productos con menos stock que la media:

SELECT P.NombreMedicamento, P.IDProducto, I.CantidadStock
FROM Producto P
INNER JOIN Inventario I ON P.IDProducto = I.FKIDProducto
WHERE I.CantidadStock < (SELECT AVG(CantidadStock) FROM Inventario);

--3. Update Aumentar el stock de un producto en un estante específico:

UPDATE Inventario
SET CantidadStock = CantidadStock + 20
WHERE FKIDProducto = 2 AND FKProductoIDEstante = 4; -- Aumentar en 20 unidades el producto con ID 2 en el estante con ID 4


--4. Delete

DELETE FROM Inventario
WHERE FKIDProducto = 3 AND FKProductoIDEstante = 5; -- Eliminar el registro del producto con ID 3 en el estante con ID 5

--Procedimientos de almacena--

--1. Mostrar los productos con stock agotado en un estante específico

DELIMITER //
CREATE PROCEDURE ProductosStockAgotadoEnEstante(IN idEstante INT)
BEGIN
    SELECT P.NombreMedicamento, P.PresentacionComercial, P.Concentracion, I.CantidadStock
    FROM Producto P
    LEFT JOIN Inventario I ON P.IDProducto = I.FKIDProducto AND I.FKProductoIDEstante = idEstante
    WHERE I.CantidadStock = 0 OR I.CantidadStock IS NULL;
END //

DELIMITER ;

CALL ProductosStockAgotadoEnEstante(3);


--2. Actualizar el stock en el inventario de todos los productos en base a un aumento general

DELIMITER //

CREATE PROCEDURE AumentarStockGeneral(IN aumento INT)
BEGIN
    UPDATE Inventario
    SET CantidadStock = CantidadStock + aumento;

    SELECT * FROM Inventario;
END //

DELIMITER ;

CALL AumentarStockGeneral(3);

--3. Eliminar registros de inventario para productos que no se han vendido


DELIMITER //

CREATE PROCEDURE EliminarProductosNoVendidos()
BEGIN
    DELETE FROM Inventario
    WHERE FKIDProducto NOT IN (
        SELECT DV.FKIDProducto
        FROM DetallesVenta DV
    );
END //

DELIMITER ;

CALL EliminarProductosNoVendidos();

--4.  Mostrar el total de stock en cada estante

DELIMITER //

CREATE PROCEDURE TotalStockPorEstante()
BEGIN
    SELECT E.IDEstante, E.NombreEstante, SUM(I.CantidadStock) AS TotalStock
    FROM Estantes E
    LEFT JOIN Inventario I ON E.IDEstante = I.FKProductoIDEstante
    GROUP BY E.IDEstante, E.NombreEstante;
END //

DELIMITER ;

CALL TotalStockPorEstante();

--5. Mostrar productos con bajo stock en un estante específico

DELIMITER //

CREATE PROCEDURE ProductosBajoStockEnEstante(IN idEstante INT, IN minStock INT)
BEGIN
    SELECT P.NombreMedicamento, P.PresentacionComercial, P.Concentracion, I.CantidadStock
    FROM Producto P
    INNER JOIN Inventario I ON P.IDProducto = I.FKIDProducto
    WHERE I.FKProductoIDEstante = idEstante AND I.CantidadStock < minStock;
END //

DELIMITER ;

CALL ProductosBajoStockEnEstante(1, 200);

-- Consultas para la tabla Caja

--Consultas CRUD--

--1. Create -  Agregar un nuevo registro a la caja

INSERT INTO Caja (IDCaja, FKIDUsuario, BaseCaja, ingresoDiario, egresosDiaro, fechaCaja)
VALUES (12, 14, 500.00, 0.00, 0.00, '2023-11-30');


--2. Read -  Mostrar información de la caja para un usuario específico

SELECT * FROM Caja WHERE FKIDUsuario = 1;


--3. Update - Actualizar el registro de la caja para un usuario específico

DELETE FROM Caja WHERE IDCaja = 1 AND FKIDUsuario = 1;

--4. Delete - Eliminar un registro de la caja para un usuario específico:

DELETE FROM Caja WHERE FKIDUsuario = 14;

--Procedimientos de almacena--

--1. Mostrar el saldo máximo entre un rango de fechas


DELIMITER //

CREATE PROCEDURE SaldoMaximoEntreFechas(IN fechaInicio DATE, IN fechaFin DATE)
BEGIN
    SELECT MAX(SaldoTotal) AS SaldoMaximo
    FROM (
        SELECT SUM(BaseCaja + ingresoDiario - egresosDiaro) AS SaldoTotal
        FROM Caja
        WHERE fechaCaja BETWEEN fechaInicio AND fechaFin
        GROUP BY IDCaja
    ) AS Saldos;
END //

DELIMITER ;

CALL SaldoMaximoEntreFechas('2023-11-19', '2023-11-28');

--2. Mostrar el detalle de cajas con el promedio de ingresos y egresos por usuario

DELIMITER //

CREATE PROCEDURE DetalleCajasPromedioIngresosEgresos()
BEGIN
    SELECT C.IDCaja, C.FKIDUsuario, C.BaseCaja, C.ingresoDiario, C.egresosDiaro, C.fechaCaja, T.PromedioIngresos, T.PromedioEgresos
    FROM Caja C
    JOIN (
        SELECT FKIDUsuario, AVG(ingresoDiario) AS PromedioIngresos, AVG(egresosDiaro) AS PromedioEgresos
        FROM Caja
        GROUP BY FKIDUsuario
    ) T ON C.FKIDUsuario = T.FKIDUsuario;
END //

DELIMITER ;

CALL DetalleCajasPromedioIngresosEgresos();

--3. Mostrar empleados con el mayor número de cajas hechas y su saldo total

DELIMITER //

CREATE PROCEDURE EmpleadoConMasCajasYTotalSaldo()
BEGIN
    SELECT U.IDUsuario, U.NombreUsuario, COUNT(C.IDCaja) AS TotalCajas, SUM(C.BaseCaja + C.ingresoDiario - C.egresosDiaro) AS SaldoTotal
    FROM Usuarios U
    LEFT JOIN Caja C ON U.IDUsuario = C.FKIDUsuario
    GROUP BY U.IDUsuario
    ORDER BY TotalCajas DESC
    LIMIT 1;
END //

DELIMITER ;

CALL EmpleadoConMasCajasYTotalSaldo();

--4. Mostrar el detalle de cajas con el promedio de ingresos y egresos por mes

DELIMITER //

CREATE PROCEDURE DetalleCajasPromedioMes()
BEGIN
SELECT C.IDCaja, C.FKIDUsuario, C.BaseCaja, C.ingresoDiario, C.egresosDiaro, C.fechaCaja, PromediosPorMes.PromedioIngresosPorMes, PromediosPorMes.PromedioEgresosPorMes
FROM Caja C
JOIN (
    SELECT MONTH(fechaCaja) AS Mes, FKIDUsuario,
           AVG(ingresoDiario) AS PromedioIngresosPorMes,
           AVG(egresosDiaro) AS PromedioEgresosPorMes
    FROM Caja
    GROUP BY Mes, FKIDUsuario
) AS PromediosPorMes ON MONTH(C.fechaCaja) = PromediosPorMes.Mes AND C.FKIDUsuario = PromediosPorMes.FKIDUsuario;

END //

DELIMITER ;

CALL DetalleCajasPromedioMes();

--5.  calcular el saldo acumulado por empleado 

DELIMITER //

CREATE PROCEDURE SaldoAcumuladoPorUsuario()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE userID INT;
    DECLARE saldo DECIMAL(10, 2);
    DECLARE saldoAcumulado DECIMAL(10, 2) DEFAULT 0;
    DECLARE prevUserID INT DEFAULT NULL;

    DECLARE cur CURSOR FOR
        SELECT FKIDUsuario, BaseCaja + ingresoDiario - egresosDiaro AS Saldo
        FROM Caja
        ORDER BY FKIDUsuario, fechaCaja;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO userID, saldo;

        IF done THEN
            LEAVE read_loop;
        END IF;

        IF prevUserID IS NULL THEN
            SET prevUserID = userID;
        END IF;

        IF prevUserID != userID THEN
            SELECT prevUserID, saldoAcumulado;
            SET saldoAcumulado = 0;
        END IF;

        SET saldoAcumulado = saldoAcumulado + saldo;
        SET prevUserID = userID;
    END LOOP;

    CLOSE cur;

    IF saldoAcumulado != 0 THEN
        SELECT userID, saldoAcumulado;
    END IF;
END //

DELIMITER ;

CALL SaldoAcumuladoPorUsuario();

-- Consultas para la tabla Estantes

--Consultas CRUD--

--1. Create

INSERT INTO Estantes (IDEstante, NombreEstante)
VALUES (11, 'Estante K');


--2. Read

SELECT e.IDEstante, e.NombreEstante, COALESCE(SUM(i.CantidadStock), 0) AS CantidadTotalProductos
FROM Estantes e
LEFT JOIN Inventario i ON e.IDEstante = i.FKProductoIDEstante
GROUP BY e.IDEstante, e.NombreEstante;


--3. Update

UPDATE Estantes
SET NombreEstante = 'NuevoNombre'
WHERE IDEstante = 1;


--4. Delete

DELETE FROM Estantes
WHERE IDEstante = 1;

-- Eliminar los productos asociados al estante eliminado
DELETE FROM Inventario
WHERE FKProductoIDEstante = 1;


--Procedimientos de almacena--

--1. busca los estantes con menor stock promedio de productos y los elimina si están por debajo de 450.

DELIMITER //

CREATE PROCEDURE EliminarEstantesBajoStockPromedio(IN cantidad_limite INT)
BEGIN
    DECLARE stock_promedio INT;

    SELECT AVG(CantidadStock) INTO stock_promedio
    FROM (
        SELECT AVG(CantidadStock) AS CantidadStock
        FROM Inventario
        GROUP BY FKProductoIDEstante
    ) AS StockPromedioPorEstante;

    DELETE FROM Estantes
    WHERE IDEstante IN (
        SELECT I.FKProductoIDEstante
        FROM Inventario I
        INNER JOIN (
            SELECT FKProductoIDEstante, AVG(CantidadStock) AS StockPromedio
            FROM Inventario
            GROUP BY FKProductoIDEstante
        ) AS StockPromedioPorEstante ON I.FKProductoIDEstante = StockPromedioPorEstante.FKProductoIDEstante
        WHERE StockPromedio < stock_promedio AND StockPromedio < cantidad_limite
    );
END //

DELIMITER ;

CALL EliminarEstantesBajoStockPromedio(450);

--2. obtener los estantes con un stock promedio inferior al global, eliminando aquellos que coincidan con ese criterio:

DELIMITER //

CREATE PROCEDURE EliminarEstantesBajoStockGlobal()
BEGIN
    DECLARE stock_promedio_global DECIMAL(10, 2);
    
    SELECT AVG(CantidadStock) INTO stock_promedio_global
    FROM Inventario;
    
    DELETE FROM Estantes
    WHERE IDEstante IN (
        SELECT I.FKProductoIDEstante
        FROM Inventario I
        GROUP BY I.FKProductoIDEstante
        HAVING AVG(I.CantidadStock) < stock_promedio_global
    );
END //

DELIMITER ;

CALL EliminarEstantesBajoStockGlobal();

--3.  busca aquellos estantes con una cantidad de stock acumulado inferior al promedio global de stock en todos los estantes:

DELIMITER //

CREATE PROCEDURE EstantesBajoPromedioGlobal()
BEGIN
    DECLARE stock_promedio_global DECIMAL(10, 2);
    
    SELECT AVG(CantidadStock) INTO stock_promedio_global
    FROM Inventario;
    
    SELECT E.IDEstante, E.NombreEstante, SUM(I.CantidadStock) AS StockAcumulado
    FROM Estantes E
    LEFT JOIN Inventario I ON E.IDEstante = I.FKProductoIDEstante
    GROUP BY E.IDEstante, E.NombreEstante
    HAVING StockAcumulado < stock_promedio_global;
END //

DELIMITER ;

CALL EstantesBajoPromedioGlobal();

--4.  estantes con el stock más bajo en comparación con otros estantes del mismo tipo

DELIMITER //

CREATE PROCEDURE EstantesStockMasBajo()
BEGIN
    SELECT E1.IDEstante, E1.NombreEstante, I1.CantidadStock AS Stock
    FROM Estantes E1
    INNER JOIN Inventario I1 ON E1.IDEstante = I1.FKProductoIDEstante
    WHERE I1.CantidadStock = (
        SELECT MIN(I2.CantidadStock)
        FROM Inventario I2
        WHERE I2.FKProductoIDEstante = E1.IDEstante
    );
END //

DELIMITER ;

CALL EstantesStockMasBajo();

--5.  obten el promedio de stock por tipo de estante y muestra aquellos estantes cuyo stock está por debajo de este promedio

DELIMITER //

CREATE PROCEDURE EstantesBajoStockPromedio()
BEGIN
    CREATE TEMPORARY TABLE IF NOT EXISTS PromedioStockPorEstante AS
    SELECT I.FKProductoIDEstante, AVG(I.CantidadStock) AS PromedioStock
    FROM Inventario I
    GROUP BY I.FKProductoIDEstante;

    
    SELECT E.IDEstante, E.NombreEstante, I.CantidadStock
    FROM Estantes E
    INNER JOIN Inventario I ON E.IDEstante = I.FKProductoIDEstante
    INNER JOIN PromedioStockPorEstante P ON E.IDEstante = P.FKProductoIDEstante
    WHERE I.CantidadStock < P.PromedioStock;
    
    DROP TEMPORARY TABLE IF EXISTS PromedioStockPorEstante;
END //

DELIMITER ;

CALL EstantesBajoStockPromedio();

-- Consultas para la tabla CategoriasProductos

--Consultas CRUD--

--1. Create

   INSERT INTO CategoriasProductos (NombreCategoria)
   VALUES ('NombreNuevaCategoria');


--2. Read

   SELECT * FROM CategoriasProductos;

--3. Update

   UPDATE CategoriasProductos
   SET NombreCategoria = 'NuevoNombreCategoria'
   WHERE IDCategoriaProducto = 1;


--4. Delete

   DELETE FROM CategoriasProductos
   WHERE IDCategoriaProducto = 1;

--Procedimientos de almacena--

--1. muestra la categoría con la mayor cantidad de productos con un precio por encima del promedio genera

DELIMITER //

CREATE PROCEDURE CategoriaPrecioSuperiorPromedio()
BEGIN
    SELECT cp.IDCategoriaProducto, cp.NombreCategoria, COUNT(p.IDProducto) AS CantidadProductos
    FROM CategoriasProductos cp
    JOIN Producto p ON cp.IDCategoriaProducto = p.IDCategoriaProducto
    WHERE p.PrecioProducto > (
        SELECT AVG(PrecioProducto)
        FROM Producto
    )
    GROUP BY cp.IDCategoriaProducto, cp.NombreCategoria
    ORDER BY COUNT(p.IDProducto) DESC
    LIMIT 1;
END //

DELIMITER ;
CALL CategoriaPrecioSuperiorPromedio();

--2. muestra la cantidad de productos por categoría que están almacenados en estantes específicos:

DELIMITER //

CREATE PROCEDURE ProductosPorCategoriaEnEstantes(IN estante_id INT)
BEGIN
    SELECT cp.IDCategoriaProducto, cp.NombreCategoria, COUNT(p.IDProducto) AS CantidadProductos
    FROM CategoriasProductos cp
    JOIN Producto p ON cp.IDCategoriaProducto = p.IDCategoriaProducto
    JOIN Inventario i ON p.IDProducto = i.FKIDProducto
    WHERE i.FKProductoIDEstante = estante_id
    GROUP BY cp.IDCategoriaProducto, cp.NombreCategoria;
END //

DELIMITER ;

CALL ProductosPorCategoriaEnEstantes(3);

--3. muestra la cantidad promedio de productos por categoría en un rango de precios específico:

DELIMITER //

CREATE PROCEDURE PromedioProductosPorCategoriaEnRangoPrecio(IN precio_min DECIMAL(10, 2), IN precio_max DECIMAL(10, 2))
BEGIN
    SELECT cp.IDCategoriaProducto, cp.NombreCategoria, AVG(i.CantidadStock) AS PromedioStock
    FROM CategoriasProductos cp
    JOIN Producto p ON cp.IDCategoriaProducto = p.IDCategoriaProducto
    JOIN Inventario i ON p.IDProducto = i.FKIDProducto
    WHERE p.PrecioProducto BETWEEN precio_min AND precio_max
    GROUP BY cp.IDCategoriaProducto, cp.NombreCategoria;
END //
DELIMITER ;
CALL PromedioProductosPorCategoriaEnRangoPrecio(1.00 , 7.00);

--4.  muestra la cantidad de productos por categoría con un stock mínimo especificado

DELIMITER //

CREATE PROCEDURE ProductosPorCategoriaConStockMinimo(IN stock_min INT)
BEGIN
    SELECT cp.NombreCategoria, COUNT(p.IDProducto) AS CantidadProductos
    FROM CategoriasProductos cp
    JOIN Producto p ON cp.IDCategoriaProducto = p.IDCategoriaProducto
    JOIN Inventario i ON p.IDProducto = i.FKIDProducto
    WHERE i.CantidadStock >= stock_min
    GROUP BY cp.NombreCategoria;
END //

DELIMITER ;
CALL ProductosPorCategoriaConStockMinimo(400);

--5.  muestra las categorías de productos que tienen un precio promedio por encima del promedio general de precios de todos los productos

DELIMITER //

CREATE PROCEDURE CategoriasPrecioPromedioSuperior()
BEGIN
    SELECT cp.NombreCategoria
    FROM CategoriasProductos cp
    JOIN Producto p ON cp.IDCategoriaProducto = p.IDCategoriaProducto
    WHERE p.PrecioProducto > (
        SELECT AVG(PrecioProducto)
        FROM Producto
    )
    GROUP BY cp.NombreCategoria;
END //

delimiter ;
CALL CategoriasPrecioPromedioSuperior();

-- Consultas para la tabla Facturacion

--Consultas CRUD--

--1. Create

INSERT INTO Facturacion (IDUsuario, FechaFacturacion, TotalFactura, IDDetalle)
VALUES (18, '2023-11-28', 150.50, 1);


--2. Read

SELECT * FROM Facturacion WHERE IDFactura = 5;

--3. Update

UPDATE Facturacion SET TotalFactura = 180.25 WHERE IDFactura = 5;

--4. Delete

DELETE FROM Facturacion WHERE IDFactura = 5;

--Procedimientos de almacena--

--1. devuelve detalles de facturación completos, incluyendo el número total de detalles por factura, la cantidad total de productos por factura y el subtotal total por factura.

DELIMITER //

CREATE PROCEDURE DetallesFacturacionCompleta()
BEGIN
    SELECT 
        f.IDFactura,
        u.NombreUsuario AS Usuario,
        f.FechaFacturacion,
        f.TotalFactura,
        (
            SELECT COUNT(IDDetalle)
            FROM DetallesVenta
            WHERE IDFactura = f.IDFactura
        ) AS TotalDetalles,
        (
            SELECT SUM(Cantidad)
            FROM DetallesVenta
            WHERE IDFactura = f.IDFactura
        ) AS TotalProductos,
        (
            SELECT SUM(Subtotal)
            FROM DetallesVenta
            WHERE IDFactura = f.IDFactura
        ) AS TotalSubtotal
    FROM Facturacion f
    JOIN Usuarios u ON f.IDUsuario = u.IDUsuario;
END //

DELIMITER ;
CALL DetallesFacturacionCompleta();

--2. 

DELIMITER //

CREATE PROCEDURE DetallesFacturaPorUsuario(IN userID INT)
BEGIN
    SELECT 
        f.IDFactura,
        f.FechaFacturacion,
        f.TotalFactura,
        dv.FKIDProducto,
        dv.Cantidad,
        dv.Subtotal,
        tp.TipoPago
    FROM Facturacion f
    JOIN DetallesVenta dv ON f.IDDetalle = dv.IDDetalle
    JOIN TipoPago tp ON dv.IDTipoPago = tp.IDTipoPago
    WHERE f.IDUsuario = userID
    AND f.IDFactura IN (
        SELECT IDFactura 
        FROM Facturacion 
        WHERE IDUsuario = userID
    );
END //

DELIMITER ;

CALL DetallesFacturaPorUsuario(4);

--3. calcular el total de facturación por usuario

DELIMITER //

CREATE PROCEDURE TotalFacturacionPorUsuario()
BEGIN
    SELECT u.NombreUsuario, SUM(f.TotalFactura) AS TotalFacturacion
    FROM Facturacion f
    INNER JOIN Usuarios u ON f.IDUsuario = u.IDUsuario
    GROUP BY u.NombreUsuario;
END //

DELIMITER ;

CALL TotalFacturacionPorUsuario();

--4. obtener el detalle de facturación por usuario

DELIMITER //

CREATE PROCEDURE DetalleFacturacionPorUsuario(IN userID INT)
BEGIN
    SELECT f.IDFactura, f.FechaFacturacion, f.TotalFactura, dv.Cantidad, p.NombreMedicamento, tp.TipoPago
    FROM Facturacion f
    JOIN DetallesVenta dv ON f.IDDetalle = dv.IDDetalle
    JOIN Producto p ON dv.FKIDProducto = p.IDProducto
    JOIN TipoPago tp ON dv.IDTipoPago = tp.IDTipoPago
    WHERE f.IDUsuario = userID;
END //

DELIMITER ;

CALL DetalleFacturacionPorUsuario(5);

--5.  calcular el total de ventas por usuario y rango de fechas

DELIMITER //

CREATE PROCEDURE TotalVentasPorUsuarioEnFecha(IN userID INT, IN fecha_inicio DATE, IN fecha_fin DATE)
BEGIN
    SELECT u.NombreUsuario, SUM(f.TotalFactura) AS TotalVentas
    FROM Usuarios u
    JOIN Facturacion f ON u.IDUsuario = f.IDUsuario
    WHERE u.IDUsuario = userID AND f.FechaFacturacion BETWEEN fecha_inicio AND fecha_fin
    GROUP BY u.NombreUsuario;
END //

DELIMITER ;

CALL TotalVentasPorUsuarioEnFecha(4, '2023-11-19', '2023-11-28');

-- Consultas para la tabla Usuarios
    
--Consultas CRUD--

--1. Create

INSERT INTO Usuarios (NombreUsuario, Nombre, Apellidos, Tipo)
VALUES ('nombre_usuario', 'nombre', 'apellidos', 'Tipo_Usuario');

--2. Read

SELECT * FROM Usuarios;

--3. Update

UPDATE Usuarios
SET Nombre = 'nuevo_nombre', Apellidos = 'nuevos_apellidos'
WHERE IDUsuario = id_usuario_a_actualizar;

--4. Delete

DELETE FROM Usuarios WHERE IDUsuario = id_usuario_a_eliminar;

--Procedimientos de almacena--
--1. Encontrar los usuarios que han realizado compras todos los días durante un período

DELIMITER //
CREATE PROCEDURE UsuariosQueCompraronTodosLosDias(IN fechaInicio DATE, IN fechaFin DATE)
BEGIN
    SELECT U.NombreUsuario, COUNT(DISTINCT DATE(FechaFacturacion)) AS DiasComprados
    FROM Usuarios U
    INNER JOIN Facturacion F ON U.IDUsuario = F.IDUsuario
    WHERE F.FechaFacturacion BETWEEN fechaInicio AND fechaFin
    GROUP BY U.NombreUsuario
    HAVING DiasComprados = DATEDIFF(fechaFin, fechaInicio) + 1;
END //
DELIMITER ;

CALL UsuariosQueCompraronTodosLosDias('2023-11-25','2023-11-28');

--2. recupera información de la tabla Usuarios, contando el total de facturas, el total de detalles de venta y el total de detalles de venta relacionados por usuario.

DELIMITER //

CREATE PROCEDURE UsuariosComplejo()
BEGIN
    SELECT u.IDUsuario, u.NombreUsuario, COUNT(f.IDFactura) AS TotalFacturas,
        (
            SELECT COUNT(DISTINCT f2.IDDetalle)
            FROM Facturacion f2
            WHERE f2.IDUsuario = u.IDUsuario
        ) AS TotalDetallesVenta,
        (
            SELECT COUNT(DISTINCT d.IDDetalle)
            FROM DetallesVenta d
            JOIN Facturacion f3 ON d.IDDetalle = f3.IDDetalle
            WHERE f3.IDUsuario = u.IDUsuario
        ) AS TotalDetallesVentaRelacionados
    FROM Usuarios u
    LEFT JOIN Facturacion f ON u.IDUsuario = f.IDUsuario
    GROUP BY u.IDUsuario, u.NombreUsuario;
END //

DELIMITER ;

CALL UsuariosComplejo();

--3. Procedimiento para obtener usuarios con el mayor total en caja

DELIMITER //

CREATE PROCEDURE UsuarioMayorTotalCaja()
BEGIN
    SELECT u.NombreUsuario, c.BaseCaja + c.ingresoDiario - c.egresosDiaro AS TotalCaja
    FROM Usuarios u
    JOIN Caja c ON u.IDUsuario = c.FKIDUsuario
    WHERE c.BaseCaja + c.ingresoDiario - c.egresosDiaro = (
        SELECT MAX(c2.BaseCaja + c2.ingresoDiario - c2.egresosDiaro)
        FROM Caja c2
        WHERE c2.FKIDUsuario = u.IDUsuario
    );
END //

DELIMITER ;
CALL UsuarioMayorTotalCaja();

--4.  proporciona información detallada sobre la facturación para cada usuario, incluyendo el total de facturas, el número total de detalles de facturación y el número de detalles de venta relacionados

DELIMITER //

CREATE PROCEDURE DetallesFacturacionUsuarios()
BEGIN
    SELECT u.NombreUsuario, COUNT(f.IDFactura) AS TotalFacturas,
        (
            SELECT COUNT(DISTINCT f2.IDDetalle)
            FROM Facturacion f2
            WHERE f2.IDUsuario = u.IDUsuario
        ) AS TotalDetallesFacturacion,
        (
            SELECT COUNT(DISTINCT dv.IDDetalle)
            FROM DetallesVenta dv
            JOIN Facturacion f3 ON dv.IDDetalle = f3.IDDetalle
            WHERE f3.IDUsuario = u.IDUsuario
        ) AS TotalDetallesVentaRelacionados
    FROM Usuarios u
    LEFT JOIN Facturacion f ON u.IDUsuario = f.IDUsuario
    GROUP BY u.IDUsuario;
END //

DELIMITER ;
CALL DetallesFacturacionUsuarios();

--5. obtener información sobre las ventas diarias por usuario, incluyendo tanto el total de productos vendidos como el usuario que realizó el gasto máximo en ese día en particular.

DELIMITER //

CREATE PROCEDURE VentasYUsuarioMasGasto()
BEGIN
    SELECT u.NombreUsuario, SUM(dv.Cantidad) AS TotalVentas, MAX(ventas.TotalGasto) AS MaxGastoDiario
    FROM Usuarios u
    JOIN Facturacion f ON u.IDUsuario = f.IDUsuario
    JOIN DetallesVenta dv ON f.IDDetalle = dv.IDDetalle
    JOIN (
        SELECT f2.IDUsuario, SUM(dv2.Subtotal) AS TotalGasto
        FROM Facturacion f2
        JOIN DetallesVenta dv2 ON f2.IDDetalle = dv2.IDDetalle
        WHERE f2.FechaFacturacion = CURDATE()
        GROUP BY f2.IDUsuario
    ) AS ventas ON u.IDUsuario = ventas.IDUsuario
    GROUP BY u.IDUsuario;
END //
DELIMITER ;
CALL VentasYUsuarioMasGasto();


-- Consultas para la tabla TipoPago

--Consultas CRUD--

--1. Create

INSERT INTO TipoPago (IDTipoPago, TipoPago)
VALUES (11, 'NuevoTipoPago');


--2. Read

SELECT * FROM TipoPago;

--3. Update

UPDATE TipoPago
SET TipoPago = 'Tarjeta de crédito'
WHERE IDTipoPago = 2;


--4. Delete

DELETE FROM TipoPago
WHERE IDTipoPago = 3;


--Procedimientos de almacena--

--1.  muestra el número total de detalles de venta asociados a ese tipo de pago

DELIMITER //

CREATE PROCEDURE ObtenerInfoTipoPago(IN p_ID INT)
BEGIN
    SELECT tp.IDTipoPago, tp.TipoPago, COUNT(dv.IDDetalle) AS TotalDetalles
    FROM TipoPago tp
    LEFT JOIN DetallesVenta dv ON tp.IDTipoPago = dv.IDTipoPago
    WHERE tp.IDTipoPago = p_ID
    GROUP BY tp.IDTipoPago;
END //

DELIMITER ;
CALL ObtenerInfoTipoPago(1);

--2. calcular el total de detalles de venta asociados a cada tipo de pago. Si no hay detalles de venta para un tipo de pago específico, el resultado será cero

DELIMITER //

CREATE PROCEDURE DetallesTipoPago(IN p_ID INT)
BEGIN
    SELECT tp.IDTipoPago, tp.TipoPago, IFNULL(TotalDetalles.Total, 0) AS TotalDetallesVenta
    FROM TipoPago tp
    LEFT JOIN (
        SELECT IDTipoPago, COUNT(*) AS Total
        FROM DetallesVenta
        GROUP BY IDTipoPago
    ) AS TotalDetalles ON tp.IDTipoPago = TotalDetalles.IDTipoPago
    WHERE tp.IDTipoPago = p_ID;
END //

DELIMITER ;
CALL DetallesTipoPago(1);

--3. muestra la cantidad máxima de detalles de venta asociados a un tipo de pago



--4.

DELIMITER //

CREATE PROCEDURE DetallesTipoPagoComplejos()
BEGIN
    SELECT tp.IDTipoPago, tp.TipoPago, IFNULL(SUM(CASE WHEN dv.Cantidad > 0 THEN 1 ELSE 0 END), 0) AS TotalVentas,
    (
        SELECT COUNT(*) 
        FROM DetallesVenta 
        WHERE DetallesVenta.IDTipoPago = tp.IDTipoPago
        GROUP BY DetallesVenta.IDTipoPago
        ORDER BY COUNT(*) DESC
        LIMIT 1
    ) AS MaxDetallesPorTipoPago
    FROM TipoPago tp
    LEFT JOIN DetallesVenta dv ON tp.IDTipoPago = dv.IDTipoPago
    GROUP BY tp.IDTipoPago, tp.TipoPago;
END //

DELIMITER ;
CALL DetallesTipoPagoComplejos();

--5.  Muestra el total de detalles de venta y la suma total de ventas para cada tipo de pago

DELIMITER //

CREATE PROCEDURE TipoPagoDetallesComplejos()
BEGIN
    SELECT 
        tp.IDTipoPago, 
        tp.TipoPago,
        (SELECT COUNT(*) FROM DetallesVenta WHERE DetallesVenta.IDTipoPago = tp.IDTipoPago) AS TotalDetallesVenta,
        (SELECT SUM(Subtotal) FROM DetallesVenta WHERE DetallesVenta.IDTipoPago = tp.IDTipoPago) AS TotalVentas
    FROM TipoPago tp;
END //

DELIMITER ;
CALL TipoPagoDetallesComplejos();

-- Consultas para la tabla DetallesVenta

--Consultas CRUD--

--1. Create

-- Agregar un nuevo detalle de venta
INSERT INTO DetallesVenta (FKIDUsuario, FKIDProducto, Cantidad, FKPrecioUnitario, Subtotal, IDTipoPago)
VALUES (valor_IDUsuario, valor_IDProducto, valor_cantidad, valor_precio_unitario, valor_subtotal, valor_IDTipoPago);

--2. Read

-- Mostrar detalles de venta por ID
SELECT * FROM DetallesVenta WHERE IDDetalle = valor_IDDetalle;

-- Mostrar todos los detalles de venta
SELECT * FROM DetallesVenta;

--3. Update

-- Actualizar cantidad y subtotal de un detalle de venta específico
UPDATE DetallesVenta
SET Cantidad = nuevo_valor_cantidad, Subtotal = nuevo_valor_subtotal
WHERE IDDetalle = valor_IDDetalle;

--4. Delete

-- Eliminar un detalle de venta por ID
DELETE FROM DetallesVenta WHERE IDDetalle = valor_IDDetalle;

--Procedimientos de almacena--

--1.  filtra las ventas cuya cantidad total sea mayor a 5

DELIMITER //

CREATE PROCEDURE DetallesVentaDetallado()
BEGIN
    SELECT 
        dv.IDDetalle,
        dv.FKIDUsuario,
        u.NombreUsuario,
        dv.FKIDProducto,
        p.NombreMedicamento,
        dv.Cantidad,
        dv.Subtotal,
        tp.TipoPago
    FROM DetallesVenta dv
    JOIN Usuarios u ON dv.FKIDUsuario = u.IDUsuario
    JOIN Producto p ON dv.FKIDProducto = p.IDProducto
    JOIN TipoPago tp ON dv.IDTipoPago = tp.IDTipoPago
    WHERE dv.IDDetalle IN (
        SELECT IDDetalle
        FROM DetallesVenta
        GROUP BY IDDetalle
        HAVING SUM(Cantidad) > 5
    );
END //

DELIMITER ;
CALL DetallesVentaDetallado();

--2. devuelve detalles de ventas asociados con ese producto específico.

DELIMITER //

CREATE PROCEDURE DetallesVentaEspecificos(IN producto_id INT)
BEGIN
    SELECT 
        dv.IDDetalle,
        dv.FKIDUsuario,
        u.NombreUsuario,
        dv.FKIDProducto,
        p.NombreMedicamento,
        dv.Cantidad,
        dv.Subtotal,
        tp.TipoPago
    FROM DetallesVenta dv
    JOIN Usuarios u ON dv.FKIDUsuario = u.IDUsuario
    JOIN Producto p ON dv.FKIDProducto = p.IDProducto
    JOIN TipoPago tp ON dv.IDTipoPago = tp.IDTipoPago
    WHERE dv.FKIDProducto = producto_id
    ORDER BY dv.Subtotal DESC;
END //

DELIMITER ;
CALL DetallesVentaEspecificos(1);

--3. recupera los detalles de ventas para una fecha específica 

DELIMITER //

CREATE PROCEDURE DetallesVentaPorFecha(IN fecha_consulta DATE)
BEGIN
    SELECT 
        dv.IDDetalle,
        u.NombreUsuario,
        p.NombreMedicamento,
        dv.Cantidad,
        dv.Subtotal,
        tp.TipoPago
    FROM DetallesVenta dv
    JOIN Usuarios u ON dv.FKIDUsuario = u.IDUsuario
    JOIN Producto p ON dv.FKIDProducto = p.IDProducto
    JOIN TipoPago tp ON dv.IDTipoPago = tp.IDTipoPago
    JOIN Facturacion f ON dv.IDDetalle = f.IDDetalle
    WHERE f.FechaFacturacion = fecha_consulta
    ORDER BY dv.Cantidad DESC;
END //

DELIMITER ;
CALL DetallesVentaPorFecha('2023-11-25');

--4. recupera los detalles de ventas para un usuario específico, mostrando el nombre del medicamento, la cantidad vendida, el subtotal y el tipo de pago asociado a cada detalle de venta.

DELIMITER //

CREATE PROCEDURE DetallesVentasPorUsuario(IN usuario_id INT)
BEGIN
    SELECT 
        dv.IDDetalle,
        p.NombreMedicamento,
        dv.Cantidad,
        dv.Subtotal,
        tp.TipoPago
    FROM DetallesVenta dv
    JOIN Producto p ON dv.FKIDProducto = p.IDProducto
    JOIN TipoPago tp ON dv.IDTipoPago = tp.IDTipoPago
    WHERE dv.FKIDUsuario = usuario_id
    ORDER BY dv.Subtotal DESC;
END //

DELIMITER ;
CALL DetallesVentasPorUsuario(3);

--5.

DELIMITER //

CREATE PROCEDURE VentasPorProductoEnFecha(IN fecha_consulta DATE)
BEGIN
    SELECT 
        p.NombreMedicamento,
        COUNT(dv.FKIDProducto) AS CantidadVentas
    FROM DetallesVenta dv
    JOIN Producto p ON dv.FKIDProducto = p.IDProducto
    JOIN Facturacion f ON dv.IDDetalle = f.IDDetalle
    WHERE f.FechaFacturacion = fecha_consulta
    GROUP BY p.NombreMedicamento
    ORDER BY CantidadVentas DESC;
END //

DELIMITER ;
CALL VentasPorProductoEnFecha('2023-11-25');

-- Consultas para la tabla Provedores

--Consultas CRUD--

--1. Create

-- Agregar un nuevo proveedor
INSERT INTO Proveedores (Empresa, NombreProveedor, ContactoProveedor, NumeroTelefonoProveedor, CorreoProveedor)
VALUES ('Nombre de la empresa', 'Nombre del proveedor', 'Contacto', 'Número de teléfono', 'Correo electrónico');


--2. Read

-- Mostrar todos los proveedores
SELECT * FROM Proveedores;

-- Mostrar proveedores por ID
SELECT * FROM Proveedores WHERE IDProveedor = valor_IDProveedor;


--3. Update

-- Actualizar información de un proveedor específico
UPDATE Proveedores
SET Empresa = 'Nueva empresa', NombreProveedor = 'Nuevo nombre', ContactoProveedor = 'Nuevo contacto'
WHERE IDProveedor = valor_IDProveedor;


--4. Delete

-- Eliminar un proveedor por ID
DELETE FROM Proveedores WHERE IDProveedor = valor_IDProveedor;


--Procedimientos de almacena--

--1. muestra el ID del proveedor, la empresa y el nombre del proveedor, además de la cantidad de productos asociados al proveedor y la cantidad de esos productos que están en el inventario.

DELIMITER //

CREATE PROCEDURE ObtenerInfoProveedoresDetallada()
BEGIN
    SELECT p.IDProveedor, p.Empresa, p.NombreProveedor,
           (SELECT COUNT(*) FROM Producto WHERE FKIDProvedor = p.IDProveedor) AS CantidadProductos,
           (SELECT COUNT(*) FROM Inventario WHERE FKIDProducto IN 
               (SELECT IDProducto FROM Producto WHERE FKIDProvedor = p.IDProveedor)) AS CantidadEnInventario
    FROM Proveedores p;
END //

DELIMITER ;
CALL ObtenerInfoProveedoresDetallada();

--2.  muestra el ID del proveedor, la empresa y el nombre del proveedor, junto con la cantidad de productos que tiene asociados en el inventario

DELIMITER //

CREATE PROCEDURE DetallesInventarioProveedores()
BEGIN
    SELECT p.IDProveedor, p.Empresa, p.NombreProveedor, COUNT(pr.IDProducto) AS CantidadProductosEnInventario
    FROM Proveedores p
    LEFT JOIN Producto pr ON p.IDProveedor = pr.FKIDProvedor
    LEFT JOIN Inventario i ON pr.IDProducto = i.FKIDProducto
    GROUP BY p.IDProveedor;
END //

DELIMITER ;
CALL DetallesInventarioProveedores();

--3.  muestra el ID del proveedor, la empresa y el nombre del proveedor, junto con el total de compras realizadas a cada uno

DELIMITER //

CREATE PROCEDURE ComprasPorProveedor()
BEGIN
    SELECT p.IDProveedor, p.Empresa, p.NombreProveedor, COUNT(f.IDFactura) AS TotalCompras
    FROM Proveedores p
    LEFT JOIN Producto pr ON p.IDProveedor = pr.FKIDProvedor
    LEFT JOIN DetallesVenta dv ON pr.IDProducto = dv.FKIDProducto
    LEFT JOIN Facturacion f ON dv.IDDetalle = f.IDDetalle
    GROUP BY p.IDProveedor;
END //

DELIMITER ;
CALL ComprasPorProveedor();

--4. presenta el ID del proveedor, el nombre de la empresa y del proveedor, y los detalles de los productos que suministra cada proveedor, incluyendo el ID del producto, su nombre, forma farmacéutica y precio.

DELIMITER //

CREATE PROCEDURE DetallesProductosPorProveedor()
BEGIN
    SELECT p.IDProveedor, p.Empresa, p.NombreProveedor, pr.IDProducto, pr.NombreMedicamento, pr.FormaFarmaceutica, pr.PrecioProducto
    FROM Proveedores p
    LEFT JOIN Producto pr ON p.IDProveedor = pr.FKIDProvedor;
END //

DELIMITER ;
CALL DetallesProductosPorProveedor();

--5. devuelve el ID y el nombre del proveedor junto con la cantidad total de productos que suministra cada uno.

DELIMITER //

CREATE PROCEDURE CantidadProductosPorProveedor()
BEGIN
    SELECT p.IDProveedor, p.NombreProveedor, COUNT(pr.IDProducto) AS Cantidad_Productos
    FROM Proveedores p
    LEFT JOIN Producto pr ON p.IDProveedor = pr.FKIDProvedor
    GROUP BY p.IDProveedor, p.NombreProveedor;
END //

DELIMITER ;
CALL CantidadProductosPorProveedor();