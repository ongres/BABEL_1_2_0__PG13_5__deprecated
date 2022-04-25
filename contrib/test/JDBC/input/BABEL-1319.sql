CREATE TABLE [Item] (
    [_id] int NOT NULL IDENTITY,
    [Name] nvarchar(max) NULL,
    CONSTRAINT [PK_Item] PRIMARY KEY ([_id])
)
GO

CREATE TABLE [Tag] (  [_id] int NOT NULL IDENTITY,
    [Label] nvarchar(max) NULL,
    [Count] int NOT NULL,
    [Item_id] int NOT NULL,
    CONSTRAINT [PK_Tag] PRIMARY KEY ([_id]),
    CONSTRAINT [FK_Tag_Item_Item_id] FOREIGN KEY ([Item_id]) REFERENCES [Item] ([_id]) ON DELETE CASCADE
)
GO

CREATE INDEX [IX_Tag_Item_id] ON [Tag] ([Item_id])
GO

INSERT INTO [Item] ([Name])
VALUES ('ItemOne')
GO

DELETE FROM [Item] WHERE [Name] = 'ItemOne'
GO

DROP TABLE [Tag]
GO
DROP TABLE [Item]
GO