PRINT '[' + CONVERT(NVARCHAR(50), CONVERT(DATETIMEOFFSET(3), SYSDATETIMEOFFSET()), 127) + '] Updating the deployment.Version table with end date';
GO
DECLARE @VersionID	INT;

SELECT
	@VersionID = VersionID
FROM
	#SSDTDeploymentVersion
;

UPDATE	deployment.[Version]
SET		[EndDateUTC] = SYSUTCDATETIME()
WHERE	VersionID = @VersionID;