CREATE TABLE [dbo].[Example]
(
	[ExampleId] INT NOT NULL,
	[SomeData]	NVARCHAR(100) NOT NULL,
	CONSTRAINT PK_dbo_Example PRIMARY KEY CLUSTERED(ExampleId)
);
GO

CREATE INDEX [IX_SomeData] ON [dbo].[Example]([SomeData]);
GO