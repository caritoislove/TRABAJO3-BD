
----------------------------------------------------------------------------
--TABLASSSSS 
----------------------------------------------------------------------------

--INICIALIZO EL VARRAY

SET SERVEROUTPUT ON;

CREATE OR REPLACE TYPE dbObj_vry IS VARRAY (5) OF NUMBER;

-- FIN INICIALIZACION

CREATE TABLE PRODUCTOS(
	IDFAB 			VARCHAR2(10) NOT NULL UNIQUE,
	IDPRODUCTO 		VARCHAR2(15) NOT NULL UNIQUE,
	DESCRIPCION 		VARCHAR2(20),
	PRECIO 			NUMBER(10),
	EXISTENCIAS 		NUMBER(5),
	DIA_ELAVORACION		VARCHAR2(25),
	FECHA_ELAVORACION 	dbObj_vry, -- LLAMADO AL VARRAY

	CONSTRAINT PK_IDFAB_IDPRODUCTO PRIMARY KEY (IDFAB, IDPRODUCTO)
	);

-- CREACION DEL ONJETO

SELECT
	tabl.DIA_ELAVORACION
	vry.column_value
FROM PRODUCTOS tabl, TABLE (tabl,DIA_ELAVORACION) vry;

-- FIN INCIALIZACION DEL OBJETO


CREATE TABLE SUCURSALES(
	SUCURSAL NUMBER(2) NOT NULL UNIQUE,
	CIUDAD VARCHAR2(15) ,
	REGION VARCHAR2(10),
	DIR VARCHAR2(50),
	OBJETIVO NUMBER(10),
	VENTAS NUMBER(10),
	CONSTRAINT PK_SUCURSAL PRIMARY KEY (SUCURSAL)
	);

CREATE TABLE TRABAJADORES(
	NUMEMP NUMBER(3) NOT NULL UNIQUE,
	NOMBRE VARCHAR2(20) ,
	EDAD NUMBER(2),
	SUCURSAL NUMBER(2),
	TITULO VARCHAR2(15),
	CONTRATO DATE,
	JEFE NUMBER(3),
	CUOTA NUMBER(10),
	VENTAS NUMBER(10),
	CONSTRAINT PK_NUMEMP PRIMARY KEY (NUMEMP),
	CONSTRAINT FK_SUCURSAL FOREIGN KEY (SUCURSAL) REFERENCES SUCURSALES ON
	DELETE CASCADE,
	CONSTRAINT MARGENEDAD CHECK (EDAD BETWEEN 18 AND 70)
	);

CREATE TABLE CLIENTES(
	NUMCLIE NUMBER(4) NOT NULL UNIQUE,
	NOMBRE VARCHAR2(20),
	NUMEMP NUMBER(3),
	LIMITECREDITO NUMBER(10),
	CONSTRAINT PK_NUMCLIE PRIMARY KEY (NUMCLIE),
	CONSTRAINT FK_NUMEMP1 FOREIGN KEY (NUMEMP) REFERENCES TRABAJADORES ON
	DELETE CASCADE
	);

CREATE TABLE PEDIDOS(
	CODIGO NUMBER(3) NOT NULL UNIQUE ,
	NUMPEDIDO NUMBER(9) NOT NULL,
	FECHAPEDIDO DATE,
	NUMCLIE NUMBER(4) NOT NULL,
	NUMEMP NUMBER(3) NOT NULL,
	IDFAB VARCHAR2(10) NOT NULL,
	IDPRODUCTO VARCHAR2(15) NOT NULL,
	CANT NUMBER(4),
	CONSTRAINT PK_CODIGO PRIMARY KEY (CODIGO),
	CONSTRAINT FK_NUMCLIE FOREIGN KEY (NUMCLIE) REFERENCES CLIENTES ON
	DELETE CASCADE,
	CONSTRAINT FK_NUMEMP2 FOREIGN KEY (NUMEMP) REFERENCES TRABAJADORES ON
	DELETE CASCADE,
	CONSTRAINT FK_IDFAB_IDPRODUCTO FOREIGN KEY (IDFAB, IDPRODUCTO)
	REFERENCES PRODUCTOS ON DELETE CASCADE
	);



CREATE PROCEDURE usp_report_error
AS
    SELECT   
        ERROR_NUMBER() AS ErrorNumber,  
        ERROR_SEVERITY() AS ErrorSeverity,  
        ERROR_STATE() AS ErrorState, 
        ERROR_LINE () AS ErrorLine,  
        ERROR_PROCEDURE() AS ErrorProcedure,  
        ERROR_MESSAGE() AS ErrorMessage;  
GO
----------------------------------------------------------------------------------------
--#INGRESO DE DATOS#
-----------------------------------------------------------------------------------------

---PRODUCTOS--------------------------------------------------------------- 
CREATE PROCEDURE spAgregaProductos
    @idfab AS VARCHAR2(10),
    @idpro AS VARCHAR2(15),
    @descrip AS VARCHAR2(20),
    @precio AS NUMBER(10),
    @stock AS NUMBER(5),
    @msg AS VARCHAR2(100) OUTPUT

AS 
BEGIN
	SET NOCOUNT ON; 
	BEGIN TRANSACTION Tadd

	BEGIN TRY
		INSERT INTO PRODUCTOS(IDFAB, IDPRODUCTO, DESCRIPCION, PRECIO, EXISTENCIAS) VALUES (@idfab, @idpro, @descrip, @precio, @stock);
		INSERT INTO PEDIDOS(IDFAB, IDPRODUCTO) VALUES (@idfab, @idpro);
		SET @msg = 'EL PRUCTO HA SIDO INGRESADO CORRECTAMENTE'
		COMMIT TRANSACTION Tadd
	END TRY
	
	BEGIN CATCH 
		SET @msg 'Ha ocurrido un Error: '+ ERROR_MESSAGE() + 'en la linea ' + CONVERT(NVARCHAR(255), ERROR_LINE() ) + '.'
		ROLLBACK TRANSACTION Tadd
	END CATCH

END 
GO

---SUCURSALES--------------------------------------------------------------- 
CREATE PROCEDURE spAgregaSucursales
	@sucursal as NUMBER(3)
	@ciudad as VARCHAR2(15)
	@region as VARCHAR2(10)
	@direc as VARCHAR2(50)
	@obj as VARCHAR2(100)
	@vent as NUMBER(10)
	@msg_err as VARCHAR2(100) OUTPUT

AS 
BEGIN
	SET NOCOUNT ON; 
	BEGIN TRANSACCTION Transacc

	BEGIN TRY
		INSERT INTO SUCURSALES(SUCURSAL, CIUDAD, REGION, DIR, OBJETIVO, VENTAS) VALUES (@sucursal, @ciudad, @region, @direc, @obj, @vent);
		INSERT INTO TRABAJADORES(SUCURSAL) VALUES (@sucursal);
		SET @msg_err = 'LA SUCURSAL HA SIDO INGRESADA CORRECTAMENTE'
		COMMIT TRANSACTION Transacc
	END TRY
	
	BEGIN CATCH 
		SET @msg_err 'Ha ocurrido un Error: '+ ERROR_MESSAGE() + 'en la linea ' + CONVERT(NVARCHAR(255), ERROR_LINE() ) + '.'
		ROLLBACK TRANSACTION Transacc
	END CATCH

END 
GO

---TRABAJADORES--------------------------------------------------------------- 
CREATE PROCEDURE spAgregarTrabajadores
	@numemp as NUMBER(3)
	@nom as VARCHAR2(20)
	@edad as NUMBER(2)
	@sucursal as VARCHAR2(2)
	@tit as VARCHAR2(15)
	@contrato as DATE
	@jefe as NUMBER(3)
	@cuota as NUMBER (10)
	@ventas as NUMBER(10)
	@msg_err as VARCHAR2(100) OUTPUT

AS 
BEGIN
	SET NOCOUNT ON; 
	BEGIN TRANSACCTION Transacc

	BEGIN TRY
		INSERT INTO TRABAJADORES(NUMEMP, NOMBRE, EDAD, SUCURSAL, TITULO, CONTRATO, JEFE, CUOTA, VENTAS) VALUES (@numemp, @nom, @edad, @sucursal, @tit, @contrato, @jefe, @cuota, @ventas);
		INSERT INTO CLIENTES(NUMEMP) VALUES (@numemp);
		INSERT INTO PEDIDOS(NUMEMP) VALUES (@numemp);
		SET @msg_err = 'EL EMPLEADO HA SIDO INGRESADO CORRECTAMENTE'
		COMMIT TRANSACTION Transacc
	END TRY
	
	BEGIN CATCH 
		SET @msg_err 'Ha ocurrido un Error: '+ ERROR_MESSAGE() + 'en la linea ' + CONVERT(NVARCHAR(255), ERROR_LINE() ) + '.'
		ROLLBACK TRANSACTION Transacc
	END CATCH

END 
GO

---CLIENTES--------------------------------------------------------------- 
CREATE PROCEDURE spAgregarClientes
	@numclie as NUMBER(4)
	@nom as VARCHAR2(20)
	@numemp as NUMBER(2)
	@credito as VARCHAR2(2)
	@msg_err as VARCHAR2(100) OUTPUT

AS 
BEGIN
	SET NOCOUNT ON; 
	BEGIN TRANSACCTION Transacc

	BEGIN TRY
		INSERT INTO CLIENTES(NUMCLIE, NOMBRE, EDAD, NUMEMP, LIMITECREDITO) VALUES (@num, @nom, @numemp, @credito);
		INSERT INTO PEDIDOS(NUMCLIE) VALUES (@numclie);
		SET @msg_err = 'EL CLIENTE HA SIDO INGRESADO CORRECTAMENTE'
		COMMIT TRANSACTION Transacc
	END TRY
	
	BEGIN CATCH 
		SET @msg_err 'Ha ocurrido un Error: '+ ERROR_MESSAGE() + 'en la linea ' + CONVERT(NVARCHAR(255), ERROR_LINE() ) + '.'
		ROLLBACK TRANSACTION Transacc
	END CATCH

END 
GO

---PEDIDOS--------------------------------------------------------------- 
CREATE PROCEDURE spAgregarPedidos
	@cod as NUMBER(3)
	@num as NUMBER(9)
	@fecha as DATE
	@numclie as NUMBER(4)
	@numemp as NUMBER(3)
	@idfab as VARCHAR2(10)
	@idpro as VARCHAR2(15)
	@cant as NUMBER(4)
	@msg_err as VARCHAR2(100) OUTPUT

AS 
BEGIN
	SET NOCOUNT ON; 
	BEGIN TRANSACCTION Transacc

	BEGIN TRY
		INSERT INTO PEDIDOS(CODIGO, NUMPEDIDO, FECHAPEDIDO, NUMCLIE, NUMEMP, IDFAB, IDPRODUCTO, CANT) VALUES (@cod, @nun, @fecha, @numclie, @numemp, @idfab, @idpro, @cant);
		SET @msg_err = 'EL PEDIDO HA SIDO INGRESADO CORRECTAMENTE'
		COMMIT TRANSACTION Transacc
	END TRY
	
	BEGIN CATCH 
		SET @msg_err 'Ha ocurrido un Error: '+ ERROR_MESSAGE() + 'en la linea ' + CONVERT(NVARCHAR(255), ERROR_LINE() ) + '.'
		ROLLBACK TRANSACTION Transacc
	END CATCH

END 
GO
----------------------------------------------------------------------------------------------
--#ACTUALIZACION DE DATOS#
----------------------------------------------------------------------------------------------


---PRODUCTOS--------------------------------------------------------------- 

CREATE PROCEDURE spActualizaProductos
    @idfab AS VARCHAR2(10),
    @idpro AS VARCHAR2(15),
    @descrip AS VARCHAR2(20),
    @precio AS NUMBER(10),
    @stock AS NUMBER(5),
    @msg AS VARCHAR2(100) OUTPUT
    
-------------- o --------------
AS 
BEGIN
	SET NOCOUNT ON; 
	BEGIN TRANSACTION Tadd

	BEGIN TRY
		UPDATE PRODUCTOS
		SET  IDFAB = @idfab
		WHERE IDFAB = '';
		UPDATE PEDIDOS SET IDFAB = @idfab WHERE IDFAB = '';
		SET @msg = 'EL DATO HA SIDO ACTUALIZADO CORRECTAMENTE'
		COMMIT TRANSACTION Tadd
	END TRY
	
	BEGIN CATCH 
		SET @msg 'Ha ocurrido un Error: '+ ERROR_MESSAGE() + 'en la linea ' + CONVERT(NVARCHAR(255), ERROR_LINE() ) + '.'
		ROLLBACK TRANSACTION Tadd
	END CATCH

END 
GO
-------------- o --------------
AS 
BEGIN
	SET NOCOUNT ON; 
	BEGIN TRANSACTION Tadd

	BEGIN TRY
		UPDATE PRODUCTOS
		SET  IDPRODUCTO = @idpro
		WHERE IDPRODUCTO = '';
		UPDATE PEDIDOS(IDPRODUCTO) SET IDPRODUCTO = @idpro WHERE IDPRODUCTO = '';
		SET @msg = 'EL DATO HA SIDO ACTUALIZADO CORRECTAMENTE'
		COMMIT TRANSACTION Tadd
	END TRY
	
	BEGIN CATCH 
		SET @msg 'Ha ocurrido un Error: '+ ERROR_MESSAGE() + 'en la linea ' + CONVERT(NVARCHAR(255), ERROR_LINE() ) + '.'
		ROLLBACK TRANSACTION Tadd
	END CATCH

END 
GO
-------------- o --------------
AS 
BEGIN
	SET NOCOUNT ON; 
	BEGIN TRANSACTION Tadd

	BEGIN TRY
		UPDATE PRODUCTOS
		SET  DESCRIPCION = @descrip
		WHERE DESCRIPCION = '';
		SET @msg = 'EL DATO HA SIDO ACTUALIZADO CORRECTAMENTE'
		COMMIT TRANSACTION Tadd
	END TRY
	
	BEGIN CATCH 
		SET @msg 'Ha ocurrido un Error: '+ ERROR_MESSAGE() + 'en la linea ' + CONVERT(NVARCHAR(255), ERROR_LINE() ) + '.'
		ROLLBACK TRANSACTION Tadd
	END CATCH

END 
GO
-------------- o --------------
AS 
BEGIN
	SET NOCOUNT ON; 
	BEGIN TRANSACTION Tadd

	BEGIN TRY
		UPDATE PRODUCTOS
		SET PRECIO = @precio
		WHERE PRECIO = '';
		SET @msg = 'EL DATO HA SIDO ACTUALIZADO CORRECTAMENTE'
		COMMIT TRANSACTION Tadd
	END TRY
	
	BEGIN CATCH 
		SET @msg 'Ha ocurrido un Error: '+ ERROR_MESSAGE() + 'en la linea ' + CONVERT(NVARCHAR(255), ERROR_LINE() ) + '.'
		ROLLBACK TRANSACTION Tadd
	END CATCH

END 
GO
-------------- o --------------
AS 
BEGIN
	SET NOCOUNT ON; 
	BEGIN TRANSACTION Tadd

	BEGIN TRY
		UPDATE PRODUCTOS
		SET EXISTENCIAS = @stock
		WHERE EXISTENCIAS = '';
		SET @msg = 'EL DATO HA SIDO ACTUALIZADO CORRECTAMENTE'
		COMMIT TRANSACTION Tadd
	END TRY
	
	BEGIN CATCH 
		SET @msg 'Ha ocurrido un Error: '+ ERROR_MESSAGE() + 'en la linea ' + CONVERT(NVARCHAR(255), ERROR_LINE() ) + '.'
		ROLLBACK TRANSACTION Tadd
	END CATCH

END 
GO

---SUCURSALES--------------------------------------------------------------- 

CREATE PROCEDURE spAgregaSucursales
	@sucursal as NUMBER(3)
	@ciudad as VARCHAR2(15)
	@region as VARCHAR2(10)
	@direc as VARCHAR2(50)
	@obj as VARCHAR2(100)
	@vent as NUMBER(10)
	@msg_err as VARCHAR2(100) OUTPUT
	
-------------- o --------------
AS 
BEGIN
	SET NOCOUNT ON; 
	BEGIN TRANSACCTION Transacc

	BEGIN TRY
		UPDATE SUCURSALES SET SUCURSAL = @sucursal WHERE SUCURSAL = '';
		UPDATE TRABAJADORES SET SUCURSAL = @sucursal WHERE SUCURSAL = '';
		SET @msg_err = 'EL DATO HA SIDO ACTUALIZADO CORRECTAMENTE'
		COMMIT TRANSACTION Transacc
	END TRY
	
	BEGIN CATCH 
		SET @msg_err 'Ha ocurrido un Error: '+ ERROR_MESAGE + 'en la linea ' + CONVERT(NVARCHAR(255), ERROR_LINE() ) + '.'
		ROLLBACK TRANSACTION Transacc
	END CATCH

END 
GO
-------------- o --------------
AS 
BEGIN
	SET NOCOUNT ON; 
	BEGIN TRANSACCTION Transacc

	BEGIN TRY
		UPDATE SUCURSALES SET CIUDAD = @ciudad WHERE CIUDAD = '';
		SET @msg_err = 'EL DATO HA SIDO ACTUALIZADO CORRECTAMENTE'
		COMMIT TRANSACTION Transacc
	END TRY
	
	BEGIN CATCH 
		SET @msg_err 'Ha ocurrido un Error: '+ ERROR_MESSAGE() + 'en la linea ' + CONVERT(NVARCHAR(255), ERROR_LINE() ) + '.'
		ROLLBACK TRANSACTION Transacc
	END CATCH

END 
GO
-------------- o --------------
AS 
BEGIN
	SET NOCOUNT ON; 
	BEGIN TRANSACCTION Transacc

	BEGIN TRY
		UPDATE SUCURSALES SET REGION = @region WHERE REGION= '';
		SET @msg_err = 'EL DATO HA SIDO ACTUALIZADO CORRECTAMENTE'
		COMMIT TRANSACTION Transacc
	END TRY
	
	BEGIN CATCH 
		SET @msg_err 'Ha ocurrido un Error: '+ ERROR_MESSAGE() + 'en la linea ' + CONVERT(NVARCHAR(255), ERROR_LINE() ) + '.'
		ROLLBACK TRANSACTION Transacc
	END CATCH

END 
GO
-------------- o --------------
AS 
BEGIN
	SET NOCOUNT ON; 
	BEGIN TRANSACCTION Transacc

	BEGIN TRY
		UPDATE SUCURSALES SET DIR = @direc WHERE DIR= '';
		SET @msg_err = 'EL DATO HA SIDO ACTUALIZADO CORRECTAMENTE'
		COMMIT TRANSACTION Transacc
	END TRY
	
	BEGIN CATCH 
		SET @msg_err 'Ha ocurrido un Error: '+ ERROR_MESSAGE() + 'en la linea ' + CONVERT(NVARCHAR(255), ERROR_LINE() ) + '.'
		ROLLBACK TRANSACTION Transacc
	END CATCH

END 
GO
-------------- o --------------
AS 
BEGIN
	SET NOCOUNT ON; 
	BEGIN TRANSACCTION Transacc

	BEGIN TRY
		UPDATE SUCURSALES SET OBJETIVO = @obj WHERE OBJETIVO = '';
		SET @msg_err = 'EL DATO HA SIDO ACTUALIZADO CORRECTAMENTE'
		COMMIT TRANSACTION Transacc
	END TRY
	
	BEGIN CATCH 
		SET @msg_err 'Ha ocurrido un Error: '+ ERROR_MESSAGE() + 'en la linea ' + CONVERT(NVARCHAR(255), ERROR_LINE() ) + '.'
		ROLLBACK TRANSACTION Transacc
	END CATCH

END 
GO
-------------- o --------------
AS 
BEGIN
	SET NOCOUNT ON; 
	BEGIN TRANSACCTION Transacc

	BEGIN TRY
		UPDATE SUCURSALES SET VENTAS = @vent WHERE VENTAS= '';
		SET @msg_err = 'EL DATO HA SIDO ACTUALIZADO CORRECTAMENTE'
		COMMIT TRANSACTION Transacc
	END TRY
	
	BEGIN CATCH 
		SET @msg_err 'Ha ocurrido un Error: '+ ERROR_MESSAGE() + 'en la linea ' + CONVERT(NVARCHAR(255), ERROR_LINE() ) + '.'
		ROLLBACK TRANSACTION Transacc
	END CATCH

END 
GO

---TRABAJADORES--------------------------------------------------------------- 

CREATE PROCEDURE spActualizarTrabajadores
	@numemp as NUMBER(3)
	@nom as VARCHAR2(20)
	@edad as NUMBER(2)
	@sucursal as VARCHAR2(2)
	@tit as VARCHAR2(15)
	@contrato as DATE
	@jefe as NUMBER(3)
	@cuota as NUMBER (10)
	@ventas as NUMBER(10)
	@msg_err as VARCHAR2(100) OUTPUT

-------------- o --------------
AS 
BEGIN
	SET NOCOUNT ON; 
	BEGIN TRANSACCTION Transacc

	BEGIN TRY
		UPDATE TRABAJADORES SET NUMEMP= @numemp WHERE NUMEMP = '';
		UPDATE CLIENTES SET NUMEMP= @numemp WHERE NUMEMP = '';
		update PEDIDOS SET NUMEMP = @numemp WHERE NUMEMP = '';
		SET @msg_err = 'EL DATO HA SIDO ACTUALIZADO CORRECTAMENTE'
		COMMIT TRANSACTION Transacc
	END TRY
	
	BEGIN CATCH 
		SET @msg_err 'Ha ocurrido un Error: '+ ERROR_MESSAGE() + 'en la linea ' + CONVERT(NVARCHAR(255), ERROR_LINE() ) + '.'
		ROLLBACK TRANSACTION Transacc
	END CATCH

END 
GO
-------------- o --------------
AS 
BEGIN
	SET NOCOUNT ON; 
	BEGIN TRANSACCTION Transacc

	BEGIN TRY
		UPDATE TRABAJADORES SET NOMBRE = @nom WHERE NOMBRE = '';
		SET @msg_err = 'EL DATO HA SIDO ACTUALIZADO CORRECTAMENTE'
		COMMIT TRANSACTION Transacc
	END TRY
	
	BEGIN CATCH 
		SET @msg_err 'Ha ocurrido un Error: '+ ERROR_MESSAGE() + 'en la linea ' + CONVERT(NVARCHAR(255), ERROR_LINE() ) + '.'
		ROLLBACK TRANSACTION Transacc
	END CATCH

END 
GO
-------------- o --------------
AS 
BEGIN
	SET NOCOUNT ON; 
	BEGIN TRANSACCTION Transacc

	BEGIN TRY
		UPDATE TRABAJADORES SET EDAD = @edad WHERE EDAD = '';
		SET @msg_err = 'EL DATO HA SIDO ACTUALIZADO CORRECTAMENTE'
		COMMIT TRANSACTION Transacc
	END TRY
	
	BEGIN CATCH 
		SET @msg_err 'Ha ocurrido un Error: '+ ERROR_MESSAGE() + 'en la linea ' + CONVERT(NVARCHAR(255), ERROR_LINE() ) + '.'
		ROLLBACK TRANSACTION Transacc
	END CATCH

END 
GO
-------------- o --------------
AS 
BEGIN
	SET NOCOUNT ON; 
	BEGIN TRANSACCTION Transacc

	BEGIN TRY
		UPDATE TRABAJADORES SET SUCURSAL = @sucursal WHERE SUCURSAL = '';
		SET @msg_err = 'EL DATO HA SIDO ACTUALIZADO CORRECTAMENTE'
		COMMIT TRANSACTION Transacc
	END TRY
	
	BEGIN CATCH 
		SET @msg_err 'Ha ocurrido un Error: '+ ERROR_MESSAGE() + 'en la linea ' + CONVERT(NVARCHAR(255), ERROR_LINE() ) + '.'
		ROLLBACK TRANSACTION Transacc
	END CATCH

END 
GO
-------------- o --------------
AS 
BEGIN
	SET NOCOUNT ON; 
	BEGIN TRANSACCTION Transacc

	BEGIN TRY
		UPDATE TRABAJADORES SET TITULO = @tit WHERE TITULO = '';
		SET @msg_err = 'EL DATO HA SIDO ACTUALIZADO CORRECTAMENTE'
		COMMIT TRANSACTION Transacc
	END TRY
	
	BEGIN CATCH 
		SET @msg_err 'Ha ocurrido un Error: '+ ERROR_MESSAGE() + 'en la linea ' + CONVERT(NVARCHAR(255), ERROR_LINE() ) + '.'
		ROLLBACK TRANSACTION Transacc
	END CATCH

END 
GO
-------------- o --------------
AS 
BEGIN
	SET NOCOUNT ON; 
	BEGIN TRANSACCTION Transacc

	BEGIN TRY
		UPDATE TRABAJADORES SET CONTRATO = @contrato WHERE CONTRATO = '';
		SET @msg_err = 'EL DATO HA SIDO ACTUALIZADO CORRECTAMENTE'
		COMMIT TRANSACTION Transacc
	END TRY
	
	BEGIN CATCH 
		SET @msg_err 'Ha ocurrido un Error: '+ ERROR_MESSAGE() + 'en la linea ' + CONVERT(NVARCHAR(255), ERROR_LINE() ) + '.'
		ROLLBACK TRANSACTION Transacc
	END CATCH

END 
GO
-------------- o --------------
AS 
BEGIN
	SET NOCOUNT ON; 
	BEGIN TRANSACCTION Transacc

	BEGIN TRY
		UPDATE TRABAJADORES SET JEFE = @jefe WHERE JEFE = '';
		SET @msg_err = 'EL DATO HA SIDO ACTUALIZADO CORRECTAMENTE'
		COMMIT TRANSACTION Transacc
	END TRY
	
	BEGIN CATCH 
		SET @msg_err 'Ha ocurrido un Error: '+ ERROR_MESSAGE() + 'en la linea ' + CONVERT(NVARCHAR(255), ERROR_LINE() ) + '.'
		ROLLBACK TRANSACTION Transacc
	END CATCH

END 
GO
-------------- o --------------
AS 
BEGIN
	SET NOCOUNT ON; 
	BEGIN TRANSACCTION Transacc

	BEGIN TRY
		UPDATE TRABAJADORES SET CUOTA = @cuota WHERE CUOTA = '';
		SET @msg_err = 'EL DATO HA SIDO ACTUALIZADO CORRECTAMENTE'
		COMMIT TRANSACTION Transacc
	END TRY
	
	BEGIN CATCH 
		SET @msg_err 'Ha ocurrido un Error: '+ ERROR_MESSAGE() + 'en la linea ' + CONVERT(NVARCHAR(255), ERROR_LINE() ) + '.'
		ROLLBACK TRANSACTION Transacc
	END CATCH

END 
GO
-------------- o --------------
AS 
BEGIN
	SET NOCOUNT ON; 
	BEGIN TRANSACCTION Transacc

	BEGIN TRY
		UPDATE TRABAJADORES SET VENTAS = @ventas WHERE VENTAS = '';
		SET @msg_err = 'EL DATO HA SIDO ACTUALIZADO CORRECTAMENTE'
		COMMIT TRANSACTION Transacc
	END TRY
	
	BEGIN CATCH 
		SET @msg_err 'Ha ocurrido un Error: '+ ERROR_MESSAGE() + 'en la linea ' + CONVERT(NVARCHAR(255), ERROR_LINE() ) + '.'
		ROLLBACK TRANSACTION Transacc
	END CATCH

END 
GO
-------------- o --------------
AS 
BEGIN
	SET NOCOUNT ON; 
	BEGIN TRANSACCTION Transacc

	BEGIN TRY
		UPDATE TRABAJADORES SET CUOTA = @cuota WHERE CUOTA = '';
		SET @msg_err = 'EL DATO HA SIDO ACTUALIZADO CORRECTAMENTE'
		COMMIT TRANSACTION Transacc
	END TRY
	
	BEGIN CATCH 
		SET @msg_err 'Ha ocurrido un Error: '+ ERROR_MESSAGE() + 'en la linea ' + CONVERT(NVARCHAR(255), ERROR_LINE() ) + '.'
		ROLLBACK TRANSACTION Transacc
	END CATCH

END 
GO
-------------- o --------------
AS 
BEGIN
	SET NOCOUNT ON; 
	BEGIN TRANSACCTION Transacc

	BEGIN TRY
		UPDATE TRABAJADORES SET VENTAS = @ventas WHERE VENTAS = '';
		SET @msg_err = 'EL DATO HA SIDO ACTUALIZADO CORRECTAMENTE'
		COMMIT TRANSACTION Transacc
	END TRY
	
	BEGIN CATCH 
		SET @msg_err 'Ha ocurrido un Error: '+ ERROR_MESSAGE() + 'en la linea ' + CONVERT(NVARCHAR(255), ERROR_LINE() ) + '.'
		ROLLBACK TRANSACTION Transacc
	END CATCH

END 
GO

---CLIENTES--------------------------------------------------------------- 

CREATE PROCEDURE spActualizarClientes
	@numclie as NUMBER(4)
	@nom as VARCHAR2(20)
	@numemp as NUMBER(2)
	@credito as VARCHAR2(2)
	@msg_err as VARCHAR2(100) OUTPUT

-------------- o --------------
AS 
BEGIN
	SET NOCOUNT ON; 
	BEGIN TRANSACCTION Transacc

	BEGIN TRY
		UPDATE CLIENTES SET NUMCLIE = @numclie WHERE NUMCLIE = '';
		UPDATE PEDIDOS SET NUMCLIE = @numclie WHERE NUMCLIE = '';
		SET @msg_err = 'EL DATO HA SIDO ACTUALIZADO CORRECTAMENTE'
		COMMIT TRANSACTION Transacc
	END TRY
	
	BEGIN CATCH 
		SET @msg_err 'Ha ocurrido un Error: '+ ERROR_MESSAGE() + 'en la linea ' + CONVERT(NVARCHAR(255), ERROR_LINE() ) + '.'
		ROLLBACK TRANSACTION Transacc
	END CATCH

END 
GO
-------------- o --------------
AS 
BEGIN
	SET NOCOUNT ON; 
	BEGIN TRANSACCTION Transacc

	BEGIN TRY
		UPDATE CLIENTES SET NOMBRE = @nombre WHERE NOMBRE = '';
		SET @msg_err = 'EL DATO HA SIDO ACTUALIZADO CORRECTAMENTE'
		COMMIT TRANSACTION Transacc
	END TRY
	
	BEGIN CATCH 
		SET @msg_err 'Ha ocurrido un Error: '+ ERROR_MESSAGE() + 'en la linea ' + CONVERT(NVARCHAR(255), ERROR_LINE() ) + '.'
		ROLLBACK TRANSACTION Transacc
	END CATCH

END 
GO
-------------- o --------------
AS 
BEGIN
	SET NOCOUNT ON; 
	BEGIN TRANSACCTION Transacc

	BEGIN TRY
		UPDATE CLIENTES SET NUMEMP = @numemp WHERE NUMEMP = '';
		sET @msg_err = 'EL DATO HA SIDO ACTUALIZADO CORRECTAMENTE'
		COMMIT TRANSACTION Transacc
	END TRY
	
	BEGIN CATCH 
		SET @msg_err 'Ha ocurrido un Error: '+ ERROR_MESSAGE() + 'en la linea ' + CONVERT(NVARCHAR(255), ERROR_LINE() ) + '.'
		ROLLBACK TRANSACTION Transacc
	END CATCH

END 
GO
-------------- o --------------
AS 
BEGIN
	SET NOCOUNT ON; 
	BEGIN TRANSACCTION Transacc

	BEGIN TRY
		UPDATE CLIENTES SET LIMITECREDITO = @credito WHERE LIMITECREDITO = '';
		SET @msg_err = 'EL DATO HA SIDO ACTUALIZADO CORRECTAMENTE'
		COMMIT TRANSACTION Transacc
	END TRY
	
	BEGIN CATCH 
		SET @msg_err 'Ha ocurrido un Error: '+ ERROR_MESSAGE() + 'en la linea ' + CONVERT(NVARCHAR(255), ERROR_LINE() ) + '.'
		ROLLBACK TRANSACTION Transacc
	END CATCH

END 
GO

---PEDIDOS--------------------------------------------------------------- 

CREATE PROCEDURE spActualizarPedidos
	@cod as NUMBER(3)
	@num as NUMBER(9)
	@fecha as DATE
	@numclie as NUMBER(4)
	@numemp as NUMBER(3)
	@idfab as VARCHAR2(10)
	@idpro as VARCHAR2(15)
	@cant as NUMBER(4)
	@msg_err as VARCHAR2(100) OUTPUT

-------------- o --------------
AS 
BEGIN
	SET NOCOUNT ON; 
	BEGIN TRANSACCTION Transacc

	BEGIN TRY
		UPDATE PEDIDOS SET CODIGO = @cod WHERE CODIGO = '';
		SET @msg_err = 'EL PEDIDO HA SIDO INGRESADO CORRECTAMENTE'
		COMMIT TRANSACTION Transacc
	END TRY
	
	BEGIN CATCH 
		SET @msg_err 'Ha ocurrido un Error: '+ ERROR_MESSAGE() + 'en la linea ' + CONVERT(NVARCHAR(255), ERROR_LINE() ) + '.'
		ROLLBACK TRANSACTION Transacc
	END CATCH

END 
GO
-------------- o --------------
AS 
BEGIN
	SET NOCOUNT ON; 
	BEGIN TRANSACCTION Transacc

	BEGIN TRY
		UPDATE PEDIDOS SET NUMPEDIDO = @num WHERE NUMPEDIDO = '';
		SET @msg_err = 'EL PEDIDO HA SIDO INGRESADO CORRECTAMENTE'
		COMMIT TRANSACTION Transacc
	END TRY
	
	BEGIN CATCH 
		SET @msg_err 'Ha ocurrido un Error: '+ ERROR_MESSAGE() + 'en la linea ' + CONVERT(NVARCHAR(255), ERROR_LINE() ) + '.'
		ROLLBACK TRANSACTION Transacc
	END CATCH

END 
GO
-------------- o --------------
AS 
BEGIN
	SET NOCOUNT ON; 
	BEGIN TRANSACCTION Transacc

	BEGIN TRY
		UPDATE PEDIDOS SET NUMCLIE = @numclie WHERE NUMCLIE = '';
		SET @msg_err = 'EL PEDIDO HA SIDO INGRESADO CORRECTAMENTE'
		COMMIT TRANSACTION Transacc
	END TRY
	
	BEGIN CATCH 
		SET @msg_err 'Ha ocurrido un Error: '+ ERROR_MESSAGE() + 'en la linea ' + CONVERT(NVARCHAR(255), ERROR_LINE() ) + '.'
		ROLLBACK TRANSACTION Transacc
	END CATCH

END 
GO
-------------- o --------------
AS 
BEGIN
	SET NOCOUNT ON; 
	BEGIN TRANSACCTION Transacc

	BEGIN TRY
		UPDATE PEDIDOS SET NUMEMPLE = @numemp WHERE NUMEMPLE = '';
		SET @msg_err = 'EL PEDIDO HA SIDO INGRESADO CORRECTAMENTE'
		COMMIT TRANSACTION Transacc
	END TRY
	
	BEGIN CATCH 
		SET @msg_err 'Ha ocurrido un Error: '+ ERROR_MESSAGE() + 'en la linea ' + CONVERT(NVARCHAR(255), ERROR_LINE() ) + '.'
		ROLLBACK TRANSACTION Transacc
	END CATCH

END 
GO
-------------- o --------------
AS 
BEGIN
	SET NOCOUNT ON; 
	BEGIN TRANSACCTION Transacc

	BEGIN TRY
		UPDATE PEDIDOS SET IDFAB = @idfab WHERE IDFAB = ''; 
		SET @msg_err = 'EL PEDIDO HA SIDO INGRESADO CORRECTAMENTE'
		COMMIT TRANSACTION Transacc
	END TRY
	
	BEGIN CATCH 
		SET @msg_err 'Ha ocurrido un Error: '+ ERROR_MESSAGE() + 'en la linea ' + CONVERT(NVARCHAR(255), ERROR_LINE() ) + '.'
		ROLLBACK TRANSACTION Transacc
	END CATCH

END 
GO
-------------- o --------------
AS 
BEGIN
	SET NOCOUNT ON; 
	BEGIN TRANSACCTION Transacc

	BEGIN TRY
		UPDATE PEDIDOS SET IDPRODUCTO = @idpro WHERE IDPRODUCTO = '';
		SET @msg_err = 'EL PEDIDO HA SIDO INGRESADO CORRECTAMENTE'
		COMMIT TRANSACTION Transacc
	END TRY
	
	BEGIN CATCH 
		SET @msg_err 'Ha ocurrido un Error: '+ ERROR_MESSAGE() + 'en la linea ' + CONVERT(NVARCHAR(255), ERROR_LINE() ) + '.'
		ROLLBACK TRANSACTION Transacc
	END CATCH

END 
GO
 
------------------------------------------------------------------------------------
--#BORRADO DE DATOS#
------------------------------------------------------------------------------------

--------PRODUCTOS--------------------------------------------------------------- 

----IDFAB--------------------
#no se puede borrar ya que es una llave primaria 
----IDPRODUCTO---------------
#no se puede borrar ya que es una llave primaria 
CREATE PROCEDURE spBorrarProductos
	@descrip AS VARCHAR2(20),
    @precio AS NUMBER(10),
    @stock AS NUMBER(5),
    @msg AS VARCHAR2(100) OUTPUT

----DESCRIPCION
AS
BEGIN
	BEGIN TRY
		BEGIN TRANSACTION;
		DELETE FROM PRODUCTOS WHERE DESCRIPCION = @descrip;
		COMMIT TRANSACTION; 
	END TRY

	BEGIN CATCH
		EXEC usp_report_error;
		IF (XACT_STATE()) = -1
		BEGIN 
			SET @msg = 'LA TRANSACTION SE ENCUENTRA EN UN ESTADO NO COMPROMETIDO.'
			ROLLBACK TRANSACTION;
		END;
		
		IF (XACT_STATE()) = 1
       	BEGIN
			SET @msg = 'LA TRANSACCION NO SE ENCUENTRA COMPROMETIDA'
			COMMIT TRANSACTION;
		END;
	END CATCH
END; 
GO 
----PRECIO
AS
BEGIN
	BEGIN TRY
		BEGIN TRANSACTION;
		DELETE FROM PRODUCTOS WHERE PRECIO = @precio;
		COMMIT TRANSACTION; 
	END TRY

	BEGIN CATCH
		EXEC usp_report_error;
		IF (XACT_STATE()) = -1
		BEGIN 
			SET @msg = 'LA TRANSACTION SE ENCUENTRA EN UN ESTADO NO COMPROMETIDO.'
			ROLLBACK TRANSACTION;
		END;
		
		IF (XACT_STATE()) = 1
       	BEGIN
			SET @msg = 'LA TRANSACCION NO SE ENCUENTRA COMPROMETIDA'
			COMMIT TRANSACTION;
		END;
	END CATCH
END; 
GO 

----EXISTENCIAS
AS
BEGIN
	BEGIN TRY
		BEGIN TRANSACTION;
		DELETE FROM PRODUCTOS WHERE EXISTENCIAS = @stock;
		COMMIT TRANSACTION; 
	END TRY

	BEGIN CATCH
		EXEC usp_report_error;
		IF (XACT_STATE()) = -1
		BEGIN 
			SET @msg = 'LA TRANSACTION SE ENCUENTRA EN UN ESTADO NO COMPROMETIDO.'
			ROLLBACK TRANSACTION;
		END;
		
		IF (XACT_STATE()) = 1
       	BEGIN
			SET @msg = 'LA TRANSACCION NO SE ENCUENTRA COMPROMETIDA'
			COMMIT TRANSACTION;
		END;
	END CATCH
END; 
GO 

---SUCURSALES---------------------------------------------------------------

CREATE PROCEDURE spBorrarSucursales
	@sucursal as NUMBER(3)
	@ciudad as VARCHAR2(15)
	@region as VARCHAR2(10)
	@direc as VARCHAR2(50)
	@obj as VARCHAR2(100)
	@vent as NUMBER(10)
	@msg_err as VARCHAR2(100) OUTPUT

----CIUDAD
AS 
BEGIN
	BEGIN TRY
		BEGIN TRANSACTION;
		DELETE FROM SUCURSALES WHERE CIUDAD = @ciudad;
		COMMIT TRANSACTION; 
	END TRY

	BEGIN CATCH
		EXEC usp_report_error;
		IF (XACT_STATE()) = -1
		BEGIN 
			SET @msg = 'LA TRANSACTION SE ENCUENTRA EN UN ESTADO NO COMPROMETIDO.'
			ROLLBACK TRANSACTION;
		END;
		
		IF (XACT_STATE()) = 1
       	BEGIN
			SET @msg = 'LA TRANSACCION NO SE ENCUENTRA COMPROMETIDA'
			COMMIT TRANSACTION;
		END;
	END CATCH
END; 
GO 

----REGION 
AS 
BEGIN
	BEGIN TRY
		BEGIN TRANSACTION;
		DELETE FROM SUCURSALES WHERE REGION = @region;
		COMMIT TRANSACTION; 
	END TRY

	BEGIN CATCH
		EXEC usp_report_error;
		IF (XACT_STATE()) = -1
		BEGIN 
			SET @msg = 'LA TRANSACTION SE ENCUENTRA EN UN ESTADO NO COMPROMETIDO.'
			ROLLBACK TRANSACTION;
		END;
		
		IF (XACT_STATE()) = 1
       	BEGIN
			SET @msg = 'LA TRANSACCION NO SE ENCUENTRA COMPROMETIDA'
			COMMIT TRANSACTION;
		END;
	END CATCH
END; 
GO 

----DIRECCION 
AS 
BEGIN
	BEGIN TRY
		BEGIN TRANSACTION;
		DELETE FROM SUCURSALES WHERE DIR = @direc;
		COMMIT TRANSACTION; 
	END TRY

	BEGIN CATCH
		EXEC usp_report_error;
		IF (XACT_STATE()) = -1
		BEGIN 
			SET @msg = 'LA TRANSACTION SE ENCUENTRA EN UN ESTADO NO COMPROMETIDO.'
			ROLLBACK TRANSACTION;
		END;
		
		IF (XACT_STATE()) = 1
       	BEGIN
			SET @msg = 'LA TRANSACCION NO SE ENCUENTRA COMPROMETIDA'
			COMMIT TRANSACTION;
		END;
	END CATCH
END; 
GO 

----OBJETIVO
AS 
BEGIN
	BEGIN TRY
		BEGIN TRANSACTION;
		DELETE FROM SUCURSALES WHERE OBJETIVO = @obj;
		COMMIT TRANSACTION; 
	END TRY

	BEGIN CATCH
		EXEC usp_report_error;
		IF (XACT_STATE()) = -1
		BEGIN 
			SET @msg = 'LA TRANSACTION SE ENCUENTRA EN UN ESTADO NO COMPROMETIDO.'
			ROLLBACK TRANSACTION;
		END;
		
		IF (XACT_STATE()) = 1
       	BEGIN
			SET @msg = 'LA TRANSACCION NO SE ENCUENTRA COMPROMETIDA'
			COMMIT TRANSACTION;
		END;
	END CATCH
END; 
GO 

----VENTAS
AS 
BEGIN
	BEGIN TRY
		BEGIN TRANSACTION;
		DELETE FROM SUCURSALES WHERE VENTAS = @vent;
		COMMIT TRANSACTION; 
	END TRY

	BEGIN CATCH
		EXEC usp_report_error;
		IF (XACT_STATE()) = -1
		BEGIN 
			SET @msg = 'LA TRANSACTION SE ENCUENTRA EN UN ESTADO NO COMPROMETIDO.'
			ROLLBACK TRANSACTION;
		END;
		
		IF (XACT_STATE()) = 1
       	BEGIN
			SET @msg = 'LA TRANSACCION NO SE ENCUENTRA COMPROMETIDA'
			COMMIT TRANSACTION;
		END;
	END CATCH
END; 
GO 

---TRABAJADORES--------------------------------------------------------------- 
CREATE PROCEDURE spBorrarTrabajadores
	@nom as VARCHAR2(20)
	@edad as NUMBER(2)
	@tit as VARCHAR2(15)
	@contrato as DATE
	@jefe as NUMBER(3)
	@cuota as NUMBER (10)
	@ventas as NUMBER(10)
	@msg_err as VARCHAR2(100) OUTPUT

----NUMERO EMPLEADO 
#ES una clave primaría por lo que no la puedo borrar

----SUCURSAL
#Es una clave foraneas por lo que no la puedo borrar

----NOMBRE
AS
BEGIN
	BEGIN TRY
		BEGIN TRANSACTION;
		DELETE FROM TRABAJADORES WHERE NOMBRE = @nom;
		COMMIT TRANSACTION; 
	END TRY

	BEGIN CATCH
		EXEC usp_report_error;
		IF (XACT_STATE()) = -1
		BEGIN 
			SET @msg = 'LA TRANSACTION SE ENCUENTRA EN UN ESTADO NO COMPROMETIDO.'
			ROLLBACK TRANSACTION;
		END;
		
		IF (XACT_STATE()) = 1
       	BEGIN
			SET @msg = 'LA TRANSACCION NO SE ENCUENTRA COMPROMETIDA'
			COMMIT TRANSACTION;
		END;
	END CATCH
END; 
GO 

----EDAD
AS
BEGIN
	BEGIN TRY
		BEGIN TRANSACTION;
		DELETE FROM TRABAJADORES WHERE EDAD = @edad; 
		COMMIT TRANSACTION; 
	END TRY

	BEGIN CATCH
		EXEC usp_report_error;
		IF (XACT_STATE()) = -1
		BEGIN 
			SET @msg = 'LA TRANSACTION SE ENCUENTRA EN UN ESTADO NO COMPROMETIDO.'
			ROLLBACK TRANSACTION;
		END;
		
		IF (XACT_STATE()) = 1
       	BEGIN
			SET @msg = 'LA TRANSACCION NO SE ENCUENTRA COMPROMETIDA'
			COMMIT TRANSACTION;
		END;
	END CATCH
END; 
GO 

----TITULO
AS
BEGIN
	BEGIN TRY
		BEGIN TRANSACTION;
		DELETE FROM TRABAJADORES WHERE TITULO = @tit; 
		COMMIT TRANSACTION; 
	END TRY

	BEGIN CATCH
		EXEC usp_report_error;
		IF (XACT_STATE()) = -1
		BEGIN 
			SET @msg = 'LA TRANSACTION SE ENCUENTRA EN UN ESTADO NO COMPROMETIDO.'
			ROLLBACK TRANSACTION;
		END;
		
		IF (XACT_STATE()) = 1
       	BEGIN
			SET @msg = 'LA TRANSACCION NO SE ENCUENTRA COMPROMETIDA'
			COMMIT TRANSACTION;
		END;
	END CATCH
END; 
GO 

----CONTRATO
AS
BEGIN
	BEGIN TRY
		BEGIN TRANSACTION;
		DELETE FROM TRABAJADORES WHERE CONTRATO = @contrato; 
		COMMIT TRANSACTION; 
	END TRY

	BEGIN CATCH
		EXEC usp_report_error;
		IF (XACT_STATE()) = -1
		BEGIN 
			SET @msg = 'LA TRANSACTION SE ENCUENTRA EN UN ESTADO NO COMPROMETIDO.'
			ROLLBACK TRANSACTION;
		END;
		
		IF (XACT_STATE()) = 1
       	BEGIN
			SET @msg = 'LA TRANSACCION NO SE ENCUENTRA COMPROMETIDA'
			COMMIT TRANSACTION;
		END;
	END CATCH
END; 
GO

----JEFE
AS
BEGIN
	BEGIN TRY
		BEGIN TRANSACTION;
		DELETE FROM TRABAJADORES WHERE JEFE = @jefe; 
		COMMIT TRANSACTION; 
	END TRY

	BEGIN CATCH
		EXEC usp_report_error;
		IF (XACT_STATE()) = -1
		BEGIN 
			SET @msg = 'LA TRANSACTION SE ENCUENTRA EN UN ESTADO NO COMPROMETIDO.'
			ROLLBACK TRANSACTION;
		END;
		
		IF (XACT_STATE()) = 1
       	BEGIN
			SET @msg = 'LA TRANSACCION NO SE ENCUENTRA COMPROMETIDA'
			COMMIT TRANSACTION;
		END;
	END CATCH
END; 
GO 

----CUOTA
AS
BEGIN
	BEGIN TRY
		BEGIN TRANSACTION;
		DELETE FROM TRABAJADORES WHERE CUOTA = @cuota; 
		COMMIT TRANSACTION; 
	END TRY

	BEGIN CATCH
		EXEC usp_report_error;
		IF (XACT_STATE()) = -1
		BEGIN 
			SET @msg = 'LA TRANSACTION SE ENCUENTRA EN UN ESTADO NO COMPROMETIDO.'
			ROLLBACK TRANSACTION;
		END;
		
		IF (XACT_STATE()) = 1
       	BEGIN
			SET @msg = 'LA TRANSACCION NO SE ENCUENTRA COMPROMETIDA'
			COMMIT TRANSACTION;
		END;
	END CATCH
END; 
GO 

----VENTAS
AS
BEGIN
	BEGIN TRY
		BEGIN TRANSACTION;
		DELETE FROM TRABAJADORES WHERE VENTAS = @ventas; 
		COMMIT TRANSACTION; 
	END TRY

	BEGIN CATCH
		EXEC usp_report_error;
		IF (XACT_STATE()) = -1
		BEGIN 
			SET @msg = 'LA TRANSACTION SE ENCUENTRA EN UN ESTADO NO COMPROMETIDO.'
			ROLLBACK TRANSACTION;
		END;
		
		IF (XACT_STATE()) = 1
       	BEGIN
			SET @msg = 'LA TRANSACCION NO SE ENCUENTRA COMPROMETIDA'
			COMMIT TRANSACTION;
		END;
	END CATCH
END; 
GO 

---CLIENTES--------------------------------------------------------------- 
CREATE PROCEDURE spBorrarClientes
	@nom as VARCHAR2(20)
	@credito as VARCHAR2(2)
	@msg_err as VARCHAR2(100) OUTPUT
----NUMERO CLIENTES
#No se puede eliminar ya que es una clave primaria 

----NUMERO EMPLEADO
#No se puede borrar ya que es una clave foranea

----NOMBRE
AS
BEGIN
	BEGIN TRY
		BEGIN TRANSACTION;
		DELETE FROM CLIENTES WHERE NOMBRE = @nom; 
		COMMIT TRANSACTION; 
	END TRY

	BEGIN CATCH
		EXEC usp_report_error;
		IF (XACT_STATE()) = -1
		BEGIN 
			SET @msg = 'LA TRANSACTION SE ENCUENTRA EN UN ESTADO NO COMPROMETIDO.'
			ROLLBACK TRANSACTION;
		END;
		
		IF (XACT_STATE()) = 1
       	BEGIN
			SET @msg = 'LA TRANSACCION NO SE ENCUENTRA COMPROMETIDA'
			COMMIT TRANSACTION;
		END;
	END CATCH
END; 
GO 

----LIMITE CREDITO 
AS
BEGIN
	BEGIN TRY
		BEGIN TRANSACTION;
		DELETE FROM CLIENTES WHERE NUMEMPLE = @; 
		COMMIT TRANSACTION; 
	END TRY

	BEGIN CATCH
		EXEC usp_report_error;
		IF (XACT_STATE()) = -1
		BEGIN 
			SET @msg = 'LA TRANSACTION SE ENCUENTRA EN UN ESTADO NO COMPROMETIDO.'
			ROLLBACK TRANSACTION;
		END;
		
		IF (XACT_STATE()) = 1
       	BEGIN
			SET @msg = 'LA TRANSACCION NO SE ENCUENTRA COMPROMETIDA'
			COMMIT TRANSACTION;
		END;
	END CATCH
END; 
GO 


---PEDIDOS--------------------------------------------------------------- 
CREATE PROCEDURE spBorrarPedidos
	@num as NUMBER(9)
	@fecha as DATE
	@cant as NUMBER(4)
	@msg_err as VARCHAR2(100) OUTPUT

----CODIGO
#Este dato es clave primaria de la tabla PEDIDOS, por lo que no se puede borrar

----NUMERO CLIENTE 
#Corresponde auna clave foranea, esto impide que se puede eliminar 

----NUMERO EMPLEADO 
#Corresponde auna clave foranea, esto impide que se puede eliminar 

----ID FABRICA
#Corresponde auna clave foranea, esto impide que se puede eliminar 

----ID PRODUCTO 
#Corresponde auna clave foranea, esto impide que se puede eliminar 

----NUMERO DEL PEDIDO
AS
BEGIN
	BEGIN TRY
		BEGIN TRANSACTION;
		DELETE FROM PEDIDOS WHERE NUMPEDIDO = @num; 
		COMMIT TRANSACTION; 
	END TRY

	BEGIN CATCH
		EXEC usp_report_error;
		IF (XACT_STATE()) = -1
		BEGIN 
			SET @msg = 'LA TRANSACTION SE ENCUENTRA EN UN ESTADO NO COMPROMETIDO.'
			ROLLBACK TRANSACTION;
		END;
		
		IF (XACT_STATE()) = 1
       	BEGIN
			SET @msg = 'LA TRANSACCION NO SE ENCUENTRA COMPROMETIDA'
			COMMIT TRANSACTION;
		END;
	END CATCH
END; 
GO 

----FECHA EN QUE FUE CURSADO EL PEDIDO
AS
BEGIN
	BEGIN TRY
		BEGIN TRANSACTION;
		DELETE FROM PEDIDOS WHERE FECHAPEDIDO = @fecha; 
		COMMIT TRANSACTION; 
	END TRY

	BEGIN CATCH
		EXEC usp_report_error;
		IF (XACT_STATE()) = -1
		BEGIN 
			SET @msg = 'LA TRANSACTION SE ENCUENTRA EN UN ESTADO NO COMPROMETIDO.'
			ROLLBACK TRANSACTION;
		END;
		
		IF (XACT_STATE()) = 1
       	BEGIN
			SET @msg = 'LA TRANSACCION NO SE ENCUENTRA COMPROMETIDA'
			COMMIT TRANSACTION;
		END;
	END CATCH
END; 
GO 


----CANTIDAD DE PRODUCTOS SOLICITADOS
AS
BEGIN
	BEGIN TRY
		BEGIN TRANSACTION;
		DELETE FROM PEDIDOS WHERE CANT = @cant; 
		COMMIT TRANSACTION; 
	END TRY

	BEGIN CATCH
		EXEC usp_report_error;
		IF (XACT_STATE()) = -1
		BEGIN 
			SET @msg = 'LA TRANSACTION SE ENCUENTRA EN UN ESTADO NO COMPROMETIDO.'
			ROLLBACK TRANSACTION;
		END;
		
		IF (XACT_STATE()) = 1
       	BEGIN
			SET @msg = 'LA TRANSACCION NO SE ENCUENTRA COMPROMETIDA'
			COMMIT TRANSACTION;
		END;
	END CATCH
END; 
GO
