CREATE PROC babel_1299_proc (@a INT OUT, @b VARCHAR(10) OUTPUT) AS
BEGIN
	SET @a = @a + 1;
	SET @b = 'hi';
END
go

DECLARE @x INT = 10;
DECLARE @y VARCHAR(10) = 'hello';
EXEC babel_1299_proc @x OUT, @y OUT
SELECT @x AS x, @y AS y;
go

-- If an INOUT param is called without OUTPUT, 
-- it's treated like a regular input param
DECLARE @x INT = 10;
DECLARE @y VARCHAR(10) = 'hello';
EXEC babel_1299_proc @x OUT, @y
SELECT @x AS x, @y AS y;
go

DECLARE @x INT = 10;
DECLARE @y VARCHAR(10) = 'hello';
EXEC babel_1299_proc @x, @y OUT
SELECT @x AS x, @y AS y;
go

DROP PROC babel_1299_proc
go
