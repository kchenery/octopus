CREATE VIEW [dbo].[ExampleAggregated]
WITH SCHEMABINDING
AS
SELECT
    e.[SomeData]
    ,COUNT_BIG(*)   AS [CountOfRows]
FROM
    [dbo].[Example] AS e
GROUP BY
    e.[SomeData]
;
GO

CREATE UNIQUE CLUSTERED INDEX [UCI_dbo_ExampleAggregated] ON [dbo].[ExampleAggregated]([SomeData]);
GO