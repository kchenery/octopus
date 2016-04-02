SET NOCOUNT ON;

PRINT '[' + CONVERT(NVARCHAR(50), CONVERT(DATETIMEOFFSET(3), SYSDATETIMEOFFSET()), 127) + '] Populating the deployment.Version table';
GO

DECLARE @DeploymentVersion NVARCHAR(500);
SET @DeploymentVersion = '$(DeploymentVersion)';

/* Get the version number section out of the DeploymentVersion string which includes notes */
IF LEFT(@DeploymentVersion, 1) = '#'
BEGIN;
	SET @DeploymentVersion = '0.0.0 - Manual Deploy';
END;

DECLARE @VersionHierarchyStr NVARCHAR(50);
IF (CHARINDEX('-', @DeploymentVersion) > 0)
BEGIN;
	SELECT @VersionHierarchyStr = LEFT(@DeploymentVersion, CHARINDEX('-', @DeploymentVersion) - 1);
END;
ELSE
BEGIN;
	SELECT @VersionHierarchyStr = @DeploymentVersion;
END;

DECLARE @VersionHierarchyID HIERARCHYID;
SELECT @VersionHierarchyID = HIERARCHYID::Parse(REPLACE('/' + LTRIM(RTRIM(REPLACE(@VersionHierarchyStr, '.', '/'))) + '/', '//', '/'))
SELECT @VersionHierarchyStr = @VersionHierarchyID.ToString();

/* Get the major part */
DECLARE @Major	INT;
DECLARE @Start	INT = 2;
DECLARE @End	INT;
SELECT @End = CHARINDEX('/', @VersionHierarchyStr, @Start);

IF (@End > 0)
BEGIN;
	SELECT @Major = SUBSTRING(@VersionHierarchyStr, @Start, @End - @Start);
END;
ELSE
BEGIN;
	SELECT @Major = 0;
END;

/* Get the minor part */
DECLARE @Minor	INT;
SELECT @Start = @End + 1;
SELECT @End = CHARINDEX('/', @VersionHierarchyStr, @Start);

IF (@End > 0)
BEGIN;
	SELECT @Minor = SUBSTRING(@VersionHierarchyStr, @Start, @End - @Start);
END;
ELSE
BEGIN;
	SELECT @Minor = 0;
END;

/* Get the revision part */
DECLARE @Revision	INT;
SELECT @Start = @End + 1;
SELECT @End = CHARINDEX('/', @VersionHierarchyStr, @Start);

IF (@End > 0)
BEGIN;
	SELECT @Revision = SUBSTRING(@VersionHierarchyStr, @Start, @End - @Start);
END;
ELSE
BEGIN;
	SELECT @Revision = 0;
END;

/* Get the build part */
DECLARE @Build	INT;
SELECT @Start = @End + 1;
SELECT @End = CHARINDEX('/', @VersionHierarchyStr, @Start);

IF (@End > 0)
BEGIN;
	SELECT @Build = SUBSTRING(@VersionHierarchyStr, @Start, @End - @Start);
END;
ELSE
BEGIN;
	SELECT @Build = 0;
END;

/* Ensure the HierarchyID value is a 4 part value */
SELECT @VersionHierarchyStr = '/' + CAST(@Major AS NVARCHAR(20)) + '/' + CAST(@Minor AS NVARCHAR(20)) + '/' + CAST(@Revision AS NVARCHAR(20)) + '/' + CAST(@Build AS NVARCHAR(20)) + '/'
SELECT @VersionHierarchyID = HIERARCHYID::Parse(@VersionHierarchyStr);

/* And finally populate the deployment.Version table.  There was quite a bit of work to get to here! */
INSERT INTO deployment.[Version](VersionHierarchyID, Major, Minor, Revision, Build, DeploymentVersion)
VALUES(@VersionHierarchyID, @Major, @Minor, @Revision, @Build, @DeploymentVersion);

DECLARE @VersionID INT;
SELECT @VersionID = SCOPE_IDENTITY();

PRINT '[' + CONVERT(NVARCHAR(50), CONVERT(DATETIMEOFFSET(3), SYSDATETIMEOFFSET()), 127) + ']      deployment.Version.VersionID = ' + CAST(@VersionID AS NVARCHAR(10));

CREATE TABLE #SSDTDeploymentVersion(VersionID INT NOT NULL PRIMARY KEY CLUSTERED);
INSERT INTO #SSDTDeploymentVersion(VersionID) VALUES(@VersionID);
GO