SELECT COUNT(*) FROM sys.all_columns WHERE object_id = object_id('sys.server_principals');
GO

SELECT name, type, type_desc, default_database_name, default_language_name
FROM sys.server_principals 
WHERE name =  'jdbc_user';
GO

CREATE LOGIN serv_principal_test WITH PASSWORD = 'test';
GO

SELECT name, type, type_desc, default_database_name, default_language_name
FROM sys.server_principals 
WHERE name in ('jdbc_user', 'serv_principal_test');
GO

DROP LOGIN serv_principal_test;
GO

SELECT name, type, type_desc, default_database_name, default_language_name
FROM sys.server_principals 
WHERE name in ('jdbc_user', 'serv_principal_test');
GO
