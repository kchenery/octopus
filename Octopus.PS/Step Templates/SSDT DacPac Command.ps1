# Get the supplied parameters
$DACPACPackageStep = $OctopusParameters["DACPACPackageStep"]
$DACPACPackageName = $OctopusParameters["DACPACPackageName"]
$PublishProfile = $OctopusParameters["DACPACPublishProfile"]
$Report = Format-OctopusArgument -Value $OctopusParameters["Report"]
$Script = Format-OctopusArgument -Value $OctopusParameters["Script"]
$Deploy = Format-OctopusArgument -Value $OctopusParameters["Deploy"]
$TargetServer = $OctopusParameters["TargetServer"]
$TargetDatabase = $OctopusParameters["TargetDatabase"]
$UseIntegratedSecurity = Format-OctopusArgument -Value $OctopusParameters["UseIntegratedSecurity"]
$Username = $OctopusParameters["SQLUsername"]
$Password = $OctopusParameters["SQLPassword"]
$AdditionalDeploymentContributors = $OctopusParameters["AdditionalContributors"]
$AdditionalDeploymentContributorArguments = $OctopusParameters["AdditionalContributorArguments"]

$InstallPathKey = ("Octopus.Action[{0}].Output.Package.InstallationDirectoryPath" -f $DACPACPackageStep)
$InstallPath = $OctopusParameters[$InstallPathKey]

# Expand the publish dacpac filename
$DACPACPackageName = ($InstallPath + "\" + $DACPACPackageName)

# Expand the publish profile filename
$PublishProfile = ($InstallPath + "\" + $PublishProfile)

# Invoke the DacPac utility
Invoke-DacPacUtility -Report $Report -Script $Script -Deploy $Deploy -DacPacFilename $DACPACPackageName -TargetServer $TargetServer -TargetDatabase $TargetDatabase -UseIntegratedSecurity $UseIntegratedSecurity -Username $Username -Password $Password -PublishProfile $PublishProfile -AdditionalDeploymentContributors $AdditionalDeploymentContributors -AdditionalDeploymentContributorArguements $AdditionalDeploymentContributorArguements