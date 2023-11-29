
DROP DATABASE IF EXISTS drogueria;


CREATE DATABASE drogueria;

USE drogueria;

CREATE TABLE `Producto`(
    `IDProducto` INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `NombreMedicamento` VARCHAR(100) NOT NULL,
    `IDCategoriaProducto` INT NOT NULL,
    `NombreComercial` VARCHAR(100) NOT NULL,
    `PrincipioActivo` VARCHAR(100) NOT NULL,
    `FormaFarmaceutica` VARCHAR(100) NOT NULL,
    `Concentracion` VARCHAR(50) NOT NULL,
    `PresentacionComercial` VARCHAR(100) NOT NULL,
    `NumeroLote` VARCHAR(50) NOT NULL,
    `PrecioProducto` DECIMAL(10, 2) NOT NULL,
    `FechaFabricacion` DATE NOT NULL,
    `FechaVencimiento` DATE NOT NULL,
    `PrecioUnitario` DECIMAL(10, 2) NOT NULL,
    `FKIDProvedor` INT NOT NULL,
    `FKIDEstante` INT NOT NULL
);
CREATE TABLE `Inventario`(
    `IDInventario` INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `FKIDProducto` INT NOT NULL,
    `FKProductoIDEstante` INT NOT NULL,
    `CantidadStock` INT NOT NULL
);
CREATE TABLE `Caja`(
    `IDCaja` INT NOT NULL PRIMARY KEY,
    `FKIDUsuario` INT NOT NULL,
    `BaseCaja` DECIMAL(10, 2) NOT NULL,
    `ingresoDiario` DECIMAL(10, 2) NOT NULL,
    `egresosDiaro` DECIMAL(10, 2) NOT NULL,
    `fechaCaja` DATE NOT NULL
);
CREATE TABLE `Estantes`(
    `IDEstante` INT NOT NULL PRIMARY KEY,
    `NombreEstante` VARCHAR(50) NOT NULL
);
CREATE TABLE `CategoriasProductos`(
    `IDCategoriaProducto` INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `NombreCategoria` VARCHAR(50) NOT NULL
);
CREATE TABLE `Facturacion`(
    `IDFactura` INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `IDUsuario` INT NOT NULL,
    `FechaFacturacion` DATE NOT NULL,
    `TotalFactura` DECIMAL(10, 2) NOT NULL,
    `IDDetalle` INT NOT NULL
);
CREATE TABLE `Usuarios` (
    `IDUsuario` INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `NombreUsuario` VARCHAR(50) NOT NULL,
    `Nombre` VARCHAR(100) NOT NULL,
    `Apellidos` VARCHAR(100) NOT NULL,
    `Tipo` ENUM('Administrador', 'Empleado', 'Cliente') NOT NULL
);

CREATE TABLE `TipoPago`(
    `IDTipoPago` INT NOT NULL PRIMARY KEY,
    `TipoPago` VARCHAR(50) NOT NULL
);
CREATE TABLE `DetallesVenta`(
    `IDDetalle` INT NOT NULL AUTO_INCREMENT PRIMARY KEY,   
    `FKIDUsuario` INT NOT NULL,
    `FKIDProducto` INT NOT NULL,
    `Cantidad` INT NOT NULL,
    `FKPrecioUnitario` DECIMAL(10, 2) NOT NULL,
    `Subtotal` DECIMAL(10, 2) NOT NULL,
    `IDTipoPago` INT NOT NULL
);
CREATE TABLE `Proveedores`(
    `IDProveedor` INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `Empresa` VARCHAR(100) NOT NULL,
    `NombreProveedor` VARCHAR(100) NOT NULL,
    `ContactoProveedor` VARCHAR(100) NOT NULL,
    `NumeroTelefonoProveedor` VARCHAR(15) NOT NULL,
    `CorreoProveedor` VARCHAR(100) NOT NULL
);

ALTER TABLE 
    `Producto` ADD INDEX `idx_fk_id_proveedor` (`FKIDProvedor`);
ALTER TABLE
    `Proveedores` ADD CONSTRAINT `proveedores_idproveedor_foreign` FOREIGN KEY(`IDProveedor`) REFERENCES `Producto`(`FKIDProvedor`);
ALTER TABLE
    `Inventario` ADD CONSTRAINT `inventario_fkidproducto_foreign` FOREIGN KEY(`FKIDProducto`) REFERENCES `Producto`(`IDProducto`);
ALTER TABLE 
    `TipoPago` ADD INDEX `idx_id_tipo_pago` (`IDTipoPago`);
ALTER TABLE
    `DetallesVenta` ADD CONSTRAINT `detallesventa_idtipopago_foreign` FOREIGN KEY(`IDTipoPago`) REFERENCES `TipoPago`(`IDTipoPago`);
ALTER TABLE
    `Producto` ADD CONSTRAINT `producto_idcategoriaproducto_foreign` FOREIGN KEY(`IDCategoriaProducto`) REFERENCES `CategoriasProductos`(`IDCategoriaProducto`);
ALTER TABLE
    `DetallesVenta` ADD CONSTRAINT `detallesventa_fkidproducto_foreign` FOREIGN KEY(`FKIDProducto`) REFERENCES `Producto`(`IDProducto`);
ALTER TABLE 
    `DetallesVenta` ADD INDEX `idx_fk_precio_unitario` (`FKPrecioUnitario`);
ALTER TABLE
    `Producto` ADD INDEX `idx_fk_precio_unitario` (`PrecioUnitario`);
ALTER TABLE
    `DetallesVenta` ADD CONSTRAINT `detallesventa_preciounitario_foreign` FOREIGN KEY(`FKPrecioUnitario`) REFERENCES `Producto`(`PrecioUnitario`);
ALTER TABLE 
    `Usuarios` ADD INDEX `idx_idusuario` (`IDUsuario`);
ALTER TABLE
    `Facturacion` ADD CONSTRAINT `facturacion_idusuario_foreign` FOREIGN KEY(`IDUsuario`) REFERENCES `Usuarios`(`IDUsuario`);
ALTER TABLE
    `Caja` ADD CONSTRAINT `caja_fkidusuario_foreign` FOREIGN KEY(`FKIDUsuario`) REFERENCES `Usuarios`(`IDUsuario`);
ALTER TABLE
    `DetallesVenta` ADD CONSTRAINT `detallesventa_fkidusuario_foreign` FOREIGN KEY(`FKIDUsuario`) REFERENCES `Usuarios`(`IDUsuario`);
ALTER TABLE 
    `Producto` ADD INDEX `idx_fkidestante` (`FKIDEstante`);
ALTER TABLE
    `Estantes` ADD CONSTRAINT `estantes_idestante_foreign` FOREIGN KEY(`IDEstante`) REFERENCES `Producto`(`FKIDEstante`);
ALTER TABLE
    `Inventario` ADD CONSTRAINT `inventario_fkproductoidestante_foreign` FOREIGN KEY(`FKProductoIDEstante`) REFERENCES `Producto`(`FKIDEstante`);
ALTER TABLE 
    `DetallesVenta` ADD INDEX `idx_iddetalle` (`IDDetalle`);
ALTER TABLE
    `Facturacion` ADD CONSTRAINT `facturacion_iddetalle_foreign` FOREIGN KEY(`IDDetalle`) REFERENCES `DetallesVenta`(`IDDetalle`);

-- vista para visulizar el arqueo de la caja:

CREATE VIEW ArqueoCajaDiario AS 
    SELECT  u.NombreUsuario AS Usuario_que_realizo_el_arqueo , c.IDCaja, c.FKIDUsuario, c.BaseCaja, c.ingresoDiario, c.egresosDiaro, c.BaseCaja + c.ingresoDiario - c.egresosDiaro as Total_en_caja, c.fechaCaja , COUNT(f.IDFactura) AS Ventas_Realizadas
    FROM Caja c
    JOIN Usuarios u ON c.FKIDUsuario = u.IDUsuario  
    JOIN Facturacion f ON u.IDUsuario = f.IDUsuario
    WHERE fechaCaja = CURDATE()
    GROUP BY Usuario_que_realizo_el_arqueo , c.IDCaja, c.FKIDUsuario, c.BaseCaja, c.ingresoDiario, c.egresosDiaro, c.fechaCaja;

-- vista para visualizar las ventas del dia
CREATE VIEW DetallesVentaDiarias AS
    SELECT f.IDFactura, f.IDUsuario, f.FechaFacturacion, f.TotalFactura , dv.FKIDProducto, dv.Cantidad , dv.Subtotal, tp.TipoPago, p.NombreMedicamento
    FROM Facturacion f
    JOIN DetallesVenta dv ON f.IDDetalle = dv.IDDetalle  
    JOIN TipoPago tp ON dv.IDTipoPago = tp.IDTipoPago
    JOIN Producto p ON dv.FKIDProducto = p.IDProducto
    WHERE f.FechaFacturacion = CURDATE();
    