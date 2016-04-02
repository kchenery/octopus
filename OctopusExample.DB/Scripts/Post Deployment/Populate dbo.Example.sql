PRINT '[' + CONVERT(NVARCHAR(50), CONVERT(DATETIMEOFFSET(3), SYSDATETIMEOFFSET()), 127) + '] Populating dbo.Example';
GO
WITH SourceData(ExampleID, SomeData) AS (

	SELECT 1, 'Hello'		UNION ALL
	SELECT 2, 'World'

)
MERGE INTO dbo.Example AS tgt
USING SourceData AS src
ON tgt.ExampleID = src.ExampleID

WHEN NOT MATCHED THEN INSERT(ExampleID, SomeData)
VALUES(src.ExampleID, src.SomeData)

WHEN MATCHED THEN UPDATE
SET SomeData = src.SomeData
;
GO