-- simple batch start

CREATE TABLE someTable(c1 int PRIMARY KEY)
GO
CREATE TABLE t142(id_c int, REFERENCES someTable(c1))
GO
DROP TABLE someTable
GO

begin transaction
GO
CREATE TABLE someTable(c1 int PRIMARY KEY)
GO
CREATE TABLE t142(id_c int, REFERENCES someTable(c1))
GO

-- Below output is only applicable if query is special case. for example, CREATE/ALTER TRIGGER, CREATE/ALTER FUNCTION, CREATE/ALTER PROC, CREATE/ALTER VIEW etc

if (@@trancount > 0) select cast('compile time error' as text) else select cast('runtime error' as text)
GO

if (@@trancount > 0) rollback tran
GO

DROP TABLE someTable
GO

-- simple batch end
GO

create schema error_mapping;
GO
-- Next portion is to check if error is being raised during parse analysis phase
GO

create table error_mapping.temp1 (a int)
GO

CREATE TABLE someTable(c1 int PRIMARY KEY)
GO
create procedure error_mapping.ErrorHandling1 as
begin
insert into error_mapping.temp1 values(1)
CREATE TABLE t142(id_c int, REFERENCES someTable(c1))
end
GO

DROP TABLE someTable
GO

create table error_mapping.temp2 (a int)
GO

CREATE TABLE someTable(c1 int PRIMARY KEY)
GO
insert into error_mapping.temp2 values(1)
CREATE TABLE t142(id_c int, REFERENCES someTable(c1))
GO

DROP TABLE someTable
GO

-- Here we are assuming that error_mapping.ErrorHandling1 is created with no error
GO

create table error_mapping.temp3 (a int)
GO

CREATE TABLE someTable(c1 int PRIMARY KEY)
GO
insert into error_mapping.temp3 values(1)
exec error_mapping.ErrorHandling1;
GO

DROP TABLE someTable
GO

if ((select count(*) from error_mapping.temp1) = 0 and (select count(*) from error_mapping.temp2) = 0 and (select count(*) from error_mapping.temp3) > 0) select cast('parse analysis phase error' as text)
GO

drop procedure error_mapping.ErrorHandling1;
GO
drop table error_mapping.temp1;
drop table error_mapping.temp2;
drop table error_mapping.temp3;
GO

-- Parse analysis phase end
GO

-- compile time error portion

-- Executing test error_mapping.ErrorHandling1
CREATE TABLE someTable(c1 int PRIMARY KEY)
GO

create procedure error_mapping.ErrorHandling1 as
begin
CREATE TABLE t142(id_c int, REFERENCES someTable(c1))
if @@error > 0 select cast('STATEMENT TERMINATING ERROR' as text);
select @@trancount;
end

GO

if @@error > 0 select cast('Compile time error' as text);
if @@trancount > 0 rollback transaction;
drop procedure error_mapping.ErrorHandling1;
set xact_abort OFF;
set implicit_transactions OFF;
GO
DROP TABLE someTable
GO


CREATE TABLE someTable(c1 int PRIMARY KEY)
GO
begin transaction
GO
-- Executing test error_mapping.ErrorHandling1
create procedure error_mapping.ErrorHandling1 as
begin
CREATE TABLE t142(id_c int, REFERENCES someTable(c1))
if @@error > 0 select cast('STATEMENT TERMINATING ERROR' as text);
end

GO

declare @err int = @@error; if (@err > 0 and @@trancount > 0) select cast('BATCH ONLY TERMINATING' as text) else if @err > 0 select cast('BATCH TERMINATING\ txn rolledback' as text);
if @@trancount > 0 rollback transaction;
drop procedure error_mapping.ErrorHandling1;
set xact_abort OFF;
set implicit_transactions OFF;
GO

GO
DROP TABLE someTable
GO


-- Checking xact_abort_flag for compile time error --
set xact_abort ON;
GO
CREATE TABLE someTable(c1 int PRIMARY KEY)
GO
begin transaction
GO
-- Executing test error_mapping.ErrorHandling1
create procedure error_mapping.ErrorHandling1 as
begin
CREATE TABLE t142(id_c int, REFERENCES someTable(c1))
if @@error > 0 select cast('STATEMENT TERMINATING ERROR' as text);
end

GO

declare @err int = @@error; if (@err > 0 and @@trancount > 0) select cast('BATCH ONLY TERMINATING' as text) else if @err > 0 select cast('BATCH TERMINATING\ txn rolledback' as text);
if @@trancount > 0 rollback transaction;
drop procedure error_mapping.ErrorHandling1;
set xact_abort OFF;
set implicit_transactions OFF;
GO

GO
DROP TABLE someTable
GO
set xact_abort OFF;
GO

---- comiple time error portion end --
---- Next portion is for runtime error --
--
---- Executing test error_mapping.ErrorHandling10000000
--CREATE TABLE someTable(c1 int PRIMARY KEY)
--GO
--
--create procedure error_mapping.ErrorHandling1 as
--begin
--CREATE TABLE t142(id_c int, REFERENCES someTable(c1))
--if @@error > 0 select cast('STATEMENT TERMINATING ERROR' as text);
--select @@trancount;
--end
--
--GO
--
--if @@error > 0 select cast('CURRENT BATCH TERMINATING ERROR' as text);
--GO
--create procedure error_mapping.ErrorHandling2 as
--begin
--exec error_mapping.ErrorHandling1;
--if @@error > 0 select cast('CURRENT BATCH TERMINATING ERROR' as text);
--end
--
--GO
--
--begin transaction;
--GO
--exec error_mapping.ErrorHandling2;
--GO
--declare @err int = @@error; if (@err > 0 and @@trancount > 0) select cast('BATCH ONLY TERMINATING' as text) else if @err > 0 select cast('BATCH TERMINATING\ txn rolledback' as text);
--if @@trancount > 0 rollback transaction;
--drop procedure error_mapping.ErrorHandling1;
--drop procedure error_mapping.ErrorHandling2;
--set xact_abort OFF;
--set implicit_transactions OFF;
--GO
--DROP TABLE someTable
--GO
--
--
--set xact_abort ON;
--GO
---- Executing test error_mapping.ErrorHandling10000000
--CREATE TABLE someTable(c1 int PRIMARY KEY)
--GO
--
--create procedure error_mapping.ErrorHandling1 as
--begin
--CREATE TABLE t142(id_c int, REFERENCES someTable(c1))
--if @@error > 0 select cast('STATEMENT TERMINATING ERROR' as text);
--select @@trancount;
--end
--
--GO
--
--if @@error > 0 select cast('CURRENT BATCH TERMINATING ERROR' as text);
--GO
--create procedure error_mapping.ErrorHandling2 as
--begin
--exec error_mapping.ErrorHandling1;
--if @@error > 0 select cast('CURRENT BATCH TERMINATING ERROR' as text);
--end
--
--GO
--
--begin transaction;
--GO
--exec error_mapping.ErrorHandling2;
--GO
--declare @err int = @@error; if (@err > 0 and @@trancount > 0) select cast('BATCH ONLY TERMINATING' as text) else if @err > 0 select cast('BATCH TERMINATING\ txn rolledback' as text);
--if @@trancount > 0 rollback transaction;
--drop procedure error_mapping.ErrorHandling1;
--drop procedure error_mapping.ErrorHandling2;
--set xact_abort OFF;
--set implicit_transactions OFF;
--GO
--DROP TABLE someTable
--GO
--
--
--
--set xact_abort OFF;
--GO
--
---- Error classification is done --

-- Executing test error_mapping.ErrorHandling10000000
CREATE TABLE someTable(c1 int PRIMARY KEY)
GO

begin try
select 1
CREATE TABLE t142(id_c int, REFERENCES someTable(c1))
end try
begin catch
	select xact_state();
end catch

if @@trancount > 0 rollback transaction;
--drop procedure error_mapping.ErrorHandling1;
--drop procedure error_mapping.ErrorHandling2;
--set xact_abort OFF;
--set implicit_transactions OFF;
--GO
--DROP TABLE someTable
--GO
--
--
--
GO
drop table sometable
go
drop schema error_mapping;
GO
