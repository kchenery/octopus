CREATE TABLE [deployment].[Version]
(
	[VersionID]					INT NOT NULL IDENTITY(1, 1),
	[VersionHierarchyID]		HIERARCHYID	NOT NULL,
	[VersionNumber]				AS REPLACE(SUBSTRING([VersionHierarchyID].ToString(), 2, LEN([VersionHierarchyID].ToString()) - 2), '/', '.'),
	[Major]						INT NOT NULL,
	[Minor]						INT NOT NULL,
	[Revision]					INT NOT NULL,
	[Build]						INT NOT NULL,
	[DeploymentVersion]			NVARCHAR(500) NOT NULL,
	[IsSuccessfulDeployment]	AS (CONVERT(BIT, CASE WHEN [EndDateUTC] IS NULL THEN (0) ELSE (1) END)),
	[DeployedBy]				NVARCHAR(128) NOT NULL CONSTRAINT DF_deployment_Version_DeployedBy			DEFAULT SUSER_SNAME(),
	[StartDateUTC]				DATETIME2(3) NOT NULL CONSTRAINT DF_deployment_Version_DeploymentDateUtc	DEFAULT SYSUTCDATETIME(),
	[EndDateUTC]				DATETIME2(3) NULL,
	[DurationMS]				AS DATEDIFF(MS, [StartDateUTC], [EndDateUTC])
	CONSTRAINT PK_deployment_Version PRIMARY KEY CLUSTERED([VersionID]) WITH(FILLFACTOR = 100)
);
GO

CREATE INDEX [IX_deployment_Version_DeploymentStartDateUTC] ON [deployment].[Version]([StartDateUTC])
WITH(FILLFACTOR = 100);
GO

CREATE INDEX [IX_deployment_Version_Versions] ON [deployment].[Version]([Major], [Minor], [Build], [Revision])
WITH(FILLFACTOR = 100);