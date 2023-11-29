# Base de datos de medicamentos e insumos de una droguería

Esta base de datos está diseñada para gestionar la información de una droguería, abordando aspectos como el inventario de productos farmacéuticos, la facturación de ventas, el control de caja diaria, la administración de usuarios y proveedores, entre otros. 

# Caracteristicas del sistema

## Gestión de Inventario:

La base de datos permite gestionar el inventario de una droguería, almacenando información detallada sobre los productos y ubicación en estantes.

## Ventas y Facturación:

Facilita el proceso de ventas y facturación al mantener un registro detallado de cada venta, incluyendo información sobre productos vendidos, detalles de pago, total de la venta, fecha de la transacción y usuario asociado.

## Caja Diaria:

Registra las operaciones diarias de la caja, incluyendo detalles de ingresos y egresos. Permite realizar arqueos diarios para evaluar las ventas totales, ingresos, egresos y el saldo final de la caja.

## Usuarios:

Gestiona usuarios con información como nombre, apellido, nombre de usuario y tipo de usuario. Establece relaciones con otras entidades para registrar la actividad de los usuarios en las transacciones.

## Proveedores:

Almacena información sobre los proveedores de los productos.

## Categorías de Productos:

Permite clasificar los productos en diferentes categorías para una mejor organización y búsqueda.

## Relaciones entre Entidades:

Establece relaciones entre las entidades para garantizar la coherencia y la integridad de los datos, como la relación entre el inventario y los proveedores.

## Registro Detallado de Ventas Diarias:

Mantiene un registro detallado de las ventas diarias, lo que facilita la generación de informes y análisis de rendimiento.

## Flexibilidad en la Gestión:

Proporciona la flexibilidad necesaria para gestionar cambios en el inventario, ventas y otros aspectos del negocio de la droguería.

## Normalización de Datos:

Sigue principios de normalización para reducir la redundancia y mejorar la eficiencia en el almacenamiento y gestión de datos.

# Modelo Conceptuale, Logico y Fisico

En este proyecto, se han desarrollado tres tipos de modelos para comprender y representar la estructura y funcionamiento del sistema: modelos conceptuales, modelos lógicos y modelos físicos.

## Modelo Conceputal

El Cliente nos ha pedido una base de datos que abarque los aspectos de una farmacia, necesita un sisema que maneje los productos en stock, ventas, los detalles de sus Clientes y Empleados, detalles de sus provedores y facturacion. Tambien necesita una estructura para el control de ingresos y egresos de la drogueria. El cliente quiere hacer un arqueo diario en el cual lo hace el empleado al que le corresponda el turno de la caja quiere tambien ver las ventas que se hiceron ese mismo dia o tambien dias anteriores y quiere tambien los ingresos y egresos diarios de su negocio.

## Modelo logico :

El cliente nos ha pedido una base de datos para su negocio que es una drogueria. se necesita el manejo de todos los datos de los productos, usuarios y caja

### Productos en Inventario:

Datos sobre los medicamentos almacenados, como el nombre, la cantidad, la fecha de vencimiento, etc.

### Caja:

Información sobre el dinero que entra y sale cada día, vinculado a las ventas y otros movimientos financieros.

### Detalles de Ventas Diarias:

Registra detalles específicos de las ventas realizadas cada día.
### Estantes:

Guarda información sobre los estantes en los que se almacenan los productos.

### Categorías de Productos:

Clasifica los productos en diferentes categorías.

### Facturación:

Registra la información relacionada con las facturas generadas en cada venta.

### Arqueo de Caja Diario:

Hace un seguimiento del estado financiero diario, incluyendo las ventas totales, ingresos, egresos y el saldo final.

### Usuarios:

Datos sobre las personas que utilizan el sistema, incluyendo su nombre, contraseña y tipo de usuario.

### Tipos de Pago:

Categoriza los diferentes métodos de pago utilizados en las transacciones.

### Detalles de Ventas:

Almacena información detallada sobre cada venta, como productos, cantidad, precio, etc.
Detalles de Ingresos y Egresos Diarios:

Registra los detalles de los ingresos y egresos diarios en la caja.

### Relaciones:

Vinculaciones entre las diferentes entidades para mostrar cómo interactúan entre sí.

### Ejemplos de Relaciones:

Los productos en el inventario están asociados con los proveedores.
Los productos pueden pertenecer a varias categorías.
La caja se relaciona con los detalles de ingresos y egresos diarios.
Los detalles de ingresos y egresos diarios están vinculados al arqueo de caja diario.
Las ventas están conectadas con los productos, las facturas y los detalles de ventas diarias.
Los productos en el inventario están ubicados en estantes específicos.
Objetivo:

la base de datos está diseñada para ayudar a gestionar la droguería. Permite realizar un seguimiento detallado de los productos en stock, las ventas diarias, las transacciones financieras, la facturación y más. Además, proporciona información sobre los usuarios que interactúan con el sistema y la relación entre diferentes entidades, lo que facilita la gestión eficiente de la droguería.



## Tablas de la base de datos

### Entidades y Atributos:

1. **Producto**
   - `IDProducto` (PK)
   - `NombreMedicamento`
   - `IDCategoriaProducto` (FK)
   - `NombreComercial`
   - `PrincipioActivo`
   - `FormaFarmaceutica`
   - `Concentracion`
   - `PresentacionComercial`
   - `NumeroLote`
   - `PrecioProducto`
   - `FechaFabricacion`
   - `FechaVencimiento`
   - `PrecioUnitario`
   - `FKIDProvedor` (FK)
   - `FKIDEstante` (FK)

2. **Inventario**
   - `IDInventario` (PK)
   - `FKIDProducto` (FK)
   - `FKProductoIDEstante` (FK)
   - `CantidadStock`

3. **Caja**
   - `IDCaja` (PK)
   - `FKIDUsuario` (FK)
   - `BaseCaja`
   - `ingresoDiario`
   - `egresosDiario`
   - `fechaCaja`

4. **Estantes**
   - `IDEstante` (PK)
   - `NombreEstante`

5. **CategoriasProductos**
   - `IDCategoriaProducto` (PK)
   - `NombreCategoria`

6. **Facturacion**
   - `IDFactura` (PK)
   - `IDUsuario` (FK)
   - `FechaFacturacion`
   - `TotalFactura`
   - `IDDetalle` (FK)

7. **Usuarios**
   - `IDUsuario` (PK)
   - `NombreUsuario`
   - `Nombre`
   - `Apellidos`
   - `Tipo`

8. **TipoPago**
   - `IDTipoPago` (PK)
   - `TipoPago`

9. **DetallesVenta**
   - `IDDetalle` (PK)
   - `FKIDUsuario` (FK)
   - `FKIDProducto` (FK)
   - `Cantidad`
   - `FKPrecioUnitario` (FK)
   - `Subtotal`
   - `IDTipoPago` (FK)

10. **Proveedores**
    - `IDProveedor` (PK)
    - `Empresa`
    - `NombreProveedor`
    - `ContactoProveedor`
    - `NumeroTelefonoProveedor`
    - `CorreoProveedor`

#### Relaciones:

- `Producto.IDCategoriaProducto` -> CategoriasProductos.IDCategoriaProducto
- `Producto.FKIDProvedor` -> Proveedores.IDProveedor
- `Producto.FKIDEstante` -> Estantes.IDEstante
- `Inventario.FKIDProducto` -> Producto.IDProducto
- `Inventario.FKProductoIDEstante` -> Producto.FKIDEstante
- `Caja.FKIDUsuario` -> Usuarios.IDUsuario
- `Facturacion.IDUsuario` -> Usuarios.IDUsuario
- `Facturacion.IDDetalle` -> DetallesVenta.IDDetalle
- `DetallesVenta.FKIDUsuario` -> Usuarios.IDUsuario
- `DetallesVenta.FKIDProducto` -> Producto.IDProducto
- `DetallesVenta.FKPrecioUnitario` -> Producto.PrecioUnitario
- `DetallesVenta.IDTipoPago` -> TipoPago.IDTipoPago
- `Proveedores.IDProveedor` -> Producto.FKIDProvedor
- `Estantes.IDEstante` -> Producto.FKIDEstante

![Imagen](/ModeloDrogueria.png)


# Modelo Fisico
- El modelado físico se ocupa de la conversión del modelo de datos lógico en un modelo de base de datos relacional.

## Creacion de tablas

El codigo para la creacion de las tablas se llama **DROGUERIA.sql** y lo puedes encontrar en los archivos del repositorio.
En este archivo tambien encontrara las creaciones de vistas 


## Inserciones

El codigo para la insercion de los datos se llama **INSERTS.sql** y lo puedes encontrar en los archivos del repositorio


## CONSULTAS :
el sql de las consultas lo encontraras en los archivos del repositorio como **CONSULTAS.sql**

### Consultas para la tabla Producto

**Consulta 1:**
```sql
.....
```

### Consultas para la tabla Inventario

### Consultas para la tabla Caja

### Consultas para la tabla Estantes

### Consultas para la tabla CategoriasProductos

### Consultas para la tabla Facturacion

### Consultas para la tabla Usuarios

### Consultas para la tabla TipoPago

### Consultas para la tabla DetallesVenta

### Consultas para la tabla Provedores

### Consultas para la tabla/Vista ArqueoCajaDiario

### Consultas para la tabla/Vista DetallesVentaDiarias

