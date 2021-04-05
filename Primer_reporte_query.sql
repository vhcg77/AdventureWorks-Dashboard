-- BASE DE DATOS A CONECTARSE
USE AdventureWorks2019



-- CREACIÓN DE LA VISTA PRODUCTO
CREATE VIEW V_Producto (Id_producto, Producto, Subcategoria, Categoria)
AS
SELECT P.ProductID, P.name, S.Name,C.Name
FROM [Production].[Product] AS P
LEFT JOIN [Production].[ProductCategory] AS S
ON P.ProductSubcategoryID = S.ProductCategoryID
LEFT JOIN [Production].[ProductCategory] AS C
ON S.ProductCategoryID = C.ProductCategoryID

-- CREACIÓN DE LA VISTA PERSONA
CREATE VIEW V_Persona(Id_persona, Tipo_persona, Nombres, Email, Celular, Tipo_celular)
AS
SELECT P.BusinessEntityID, P.PersonType, CONCAT_WS(' ', P.FirstName, P.LastName), EA.EmailAddress, PP.PhoneNumber, PN.Name
FROM Person.Person as P
LEFT JOIN Person.EmailAddress as EA
ON P.BusinessEntityID = EA.BusinessEntityID
LEFT JOIN Person.PersonPhone as PP
ON P.BusinessEntityID = PP.BusinessEntityID
LEFT JOIN Person.PhoneNumberType as PN
ON PP.PhoneNumberTypeID = PN.PhoneNumberTypeID

-- CREACIÓN DE LA VISTA TERRITORIO
CREATE VIEW V_territorio (Id_territorio, Pais, Codigo_region, Grupo)
AS
SELECT a.TerritoryID, 
		 CASE WHEN a.CountryRegionCode = 'US' THEN 'United States' ELSE a.Name END AS Pais,
		 a.CountryRegionCode,
		 [Group] as Grupo
FROM [Sales].[SalesTerritory] AS A;

-- CREACIÓN DE LA VISTA VENDEDOR
CREATE VIEW V_vendedor(Id_Vendedor, Tipo_persona, Nombres, Email, Celular, Tipo_Celular)
AS
SELECT SP.BusinessEntityID, Tipo_persona, Nombres, Email, Celular, Tipo_celular
FROM Sales.SalesPerson AS SP
LEFT JOIN V_persona as P
on SP.BusinessEntityID = P.Id_persona

-- CREACIÓN DE LA VISTA PERSONA CLIENTE
CREATE VIEW V_cliente(Id_cliente, Tipo_persona, Nombres,  Email, Celular, Tipo_celular)
AS
SELECT C.PersonID, Tipo_persona, Nombres, Email, Celular, Tipo_celular
FROM Sales.Customer AS C
LEFT JOIN V_PERSONA AS P
ON C.PersonId = p.Id_persona;

-- CREACIÓN DE LA VISTA VENTAS
CREATE VIEW V_ventas (Id_orden, Fecha_pedido, Fecha_vencimiento, Fecha_envio, Id_territorio, Id_cliente, Id_vendedor, Id_producto, Unidades, Precio_unitario, Subtotal)
AS
SELECT H.SalesOrderID, CAST(H.OrderDate as date), CAST(H.DueDate AS date), CAST(H.ShipDate AS date), H.TerritoryID, H.CustomerID, H.SalesPersonID,
	   D.ProductID, D.OrderQty AS Unidades, D.UnitPrice, D.OrderQty*D.UnitPrice
FROM [Sales].[SalesOrderheader] AS H
LEFT JOIN [Sales].[SalesOrderDetail] AS D
ON H.SalesOrderID = D.SalesOrderID;

-- CREACIÓN DE LA TABLA CALENDARIO
CREATE TABLE Calendario
(
Fecha date,
Año INT,
Mes_numero INT,
Mes VARCHAR(3),
Mes_largo VARCHAR(20),
Dia INT
);

CREATE PROCEDURE Generar_fechas
AS
	TRUNCATE TABLE Calendario;
	DECLARE @fec_inicio date;
	DECLARE @fec_fin date;
	DECLARE @anio INT;
	DECLARE @mes_num INT;
	DECLARE @mes_corto VARCHAR(3);
	DECLARE @mes_largo VARCHAR(20);
	DECLARE @dia INT;

	set @fec_inicio = (SELECT CAST(MIN(OrderDate) as date) FROM [Sales].[SalesOrderHeader]);
	set @fec_fin = (SELECT CAST(MAX(ShipDate) as date) FROM [Sales].[SalesOrderHeader]);

	WHILE @fec_inicio <= @fec_fin
	BEGIN
		SET @anio = (SELECT YEAR( @fec_inicio));
		SET @mes_num = (SELECT MONTH( @fec_inicio));
		SET @mes_corto = (SELECT FORMAT(@fec_inicio, 'MMM', 'es-PE'));
		SET @mes_largo = (SELECT FORMAT(@fec_inicio, 'MMMM', 'es-PE'));
		SET @dia = (SELECT DAY(@fec_inicio));

		INSERT INTO Calendario(Fecha, Año, Mes_numero, Mes, Mes_largo, Dia)
		SELECT @fec_inicio, @anio, @mes_num, @mes_corto, @mes_largo, @dia;

		SET @fec_inicio = DATEADD(DAY, 1, @fec_inicio)
	END;


EXEC Generar_fechas;

DROP PROCEDURE Generar_fechas;

SELECT * FROM Calendario