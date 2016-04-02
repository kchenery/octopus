CREATE VIEW [deployment].[LatestVersion]
AS
/*
 * Description:	Get the most recent and last successful deployments. These are determined by the IsSuccessfulDeployment
 *				flag and the VersionID values.
 */
WITH MostRecentDeployments AS (
	SELECT
		'Most Recent' AS DeploymentType
		,[VersionID], [VersionHierarchyID], [VersionNumber], [Major], [Minor], [Revision], [Build], 
		[DeploymentVersion], [IsSuccessfulDeployment], [DeployedBy], [StartDateUTC], [EndDateUTC], [DurationMS]
	FROM
		deployment.[Version]
	WHERE
		VersionID = (SELECT MAX(VersionID) FROM deployment.Version)

	UNION ALL 

	SELECT
		'Last Successful' AS DeploymentType
		,[VersionID], [VersionHierarchyID], [VersionNumber], [Major], [Minor], [Revision], [Build], 
		[DeploymentVersion], [IsSuccessfulDeployment], [DeployedBy], [StartDateUTC], [EndDateUTC], [DurationMS]
	FROM
		deployment.[Version]
	WHERE
		VersionID = (SELECT MAX(VersionID) FROM deployment.Version WHERE IsSuccessfulDeployment = 1)

)
SELECT
	[DeploymentType], [VersionID], [VersionHierarchyID], [VersionNumber], [Major], [Minor], [Revision], [Build], 
	[DeploymentVersion], [IsSuccessfulDeployment], [DeployedBy], [StartDateUTC], [EndDateUTC], [DurationMS]
FROM
	MostRecentDeployments
;