<#
 .SYNOPSIS
 Converts boolean values to boolean types

 .DESCRIPTION
 Converts boolean values to boolean types

 .PARAMETER Value
 The value to convert

 .EXAMPLE
 Format-OctopusArgument "true"
#>
Function Format-OctopusArgument {

	Param(
		[string]$Value
	)

	$Value = $Value.Trim()

	# There must be a better way to do this
	Switch -Wildcard ($Value){

		"True" { Return $True }
		"False" { Return $False }
		"#{*}" { Return $null }
		Default { Return $Value }
	}
}

<#
 .SYNOPSIS
 Finds the DAC File that you specify

 .DESCRIPTION
 Looks through the supplied PathList array and searches for the file you specify.  It will return the first one that it finds.

 .PARAMETER FileName
 Name of the file you are looking for

 .PARAMETER PathList
 Array of Paths to search through.

 .EXAMPLE
 Find-DacFile -FileName "Microsoft.SqlServer.TransactSql.ScriptDom.dll" -PathList @("${env:ProgramFiles}\Microsoft SQL Server", "${env:ProgramFiles(x86)}\Microsoft SQL Server")
#>
Function Find-DacFile {
	Param(
		[Parameter(Mandatory=$true)]
		[string]$FileName,
		[Parameter(Mandatory=$true)]
		[string[]]$PathList
	)

	$File = $null

	ForEach($Path in $PathList)
	{
		Write-Debug ("Searching: {0}" -f $Path)

		If (!($File))
		{
			$File = (
				Get-ChildItem $Path -ErrorAction SilentlyContinue -Filter $FileName -Recurse |
				Sort-Object FullName -Descending |
				Select -First 1
				)

			If ($File)
			{
				Write-Debug ("Found: {0}" -f $File.FullName)
			}
		}
	}

	Return $File
}

<#
 .SYNOPSIS
 Adds the required types so that they can be used

 .DESCRIPTION
 Adds the DacFX types that are required to do database deploys, scripts and deployment reports from SSDT

 .EXAMPLE
 Load-DACAssemblies
#>
Function Load-DACAssemblies {

	Write-Verbose "Loading the DacFX Assemblies"

	$SearchPathList = @("${env:ProgramFiles}\Microsoft SQL Server", "${env:ProgramFiles(x86)}\Microsoft SQL Server")

	Write-Debug "Searching for: Microsoft.SqlServer.TransactSql.ScriptDom.dll"
	$ScriptDomDLL = (Find-DacFile -FileName "Microsoft.SqlServer.TransactSql.ScriptDom.dll" -PathList $SearchPathList)

	Write-Debug "Searching for: Microsoft.SqlServer.Dac.dll"
	$DacDLL = (Find-DacFile -FileName "Microsoft.SqlServer.Dac.dll" -PathList $SearchPathList)

	If (!($ScriptDomDLL))
	{
		Throw "Could not find the file: Microsoft.SqlServer.TransactSql.ScriptDom.dll"
	}
	If (!($DacDLL))
	{
		Throw "Could not find the file: Microsoft.SqlServer.Dac.dll"
	}

	Write-Debug ("Adding the type: {0}" -f $ScriptDomDLL.FullName)
	Add-Type -Path $ScriptDomDLL.FullName

	Write-Debug ("Adding the type: {0}" -f $DacDLL.FullName)
	Add-Type -Path $DacDLL.FullName

	Write-Host "Loaded the DAC assemblies"
}


<#
 .SYNOPSIS
 Generates a connection string

 .DESCRIPTION
 Derive a connection string from the supplied variables

 .PARAMETER ServerName
 Name of the server to connect to

 .PARAMETER UseIntegratedSecurity
 Boolean value to indicate if Integrated Security should be used or not

 .PARAMETER UserName
 User name to use if we are not using integrated security

 .PASSWORD Password
 Password to use if we are not using integrated security

 .EXAMPLE
 Get-ConnectionString -ServerName localhost -UseIntegratedSecurity -Database OctopusDeploy

 .EXAMPLE
 Get-ConnectionString -ServerName localhost -UserName sa -Password ProbablyNotSecure -Database OctopusDeploy
#>
Function Get-ConnectionString {
	Param(
		[Parameter(Mandatory=$True)]
		[string]$ServerName,
		[bool]$UseIntegratedSecurity,
		[string]$UserName,
		[string]$Password,
		[string]$Database
	)

	$ApplicationName = "OctopusDeploy"
	$connectionString = ("Application Name={0};Server={1}" -f $ApplicationName, $ServerName)

	If ($UseIntegratedSecurity)
	{
		Write-Verbose "Using integrated security"
		$connectionString += ";Trusted_Connection=True"
	}
	Else{
		Write-Verbose "Using standard security"
		$connectionString += (";Uid={0};Pwd={1}" -f $UserName, $Password)
	}

	If ($Database)
	{
		$connectionString += (";Initial Catalog={0}" -f $Database)
	}

	Return $connectionString
}


<#
 .SYNOPSIS
 Invokes the DacPac utility

 .DESCRIPTION
 Used to invoke the actions against the DacFx library.  This utility can generate deployment reports, deployment scripts and execute a deploy

 .PARAMETER Report
 Boolean flag as to whether a deploy report should be generated

 .PARAMETER Script
 Boolean flag as to whether a deployment script should be generated

 .PARAMETER Deploy
 Boolean flag as to whether a deployment should occur

 .PARAMETER DacPacFilename
 Full path as to where we can find the DacPac to use

 .PARAMETER TargetServer
 Name of the server to run the DacPac against

 .PARAMETER TargetDatabase
 Name of the database to run the DacPac against

 .PARAMETER UseIntegratedSecurity
 Flag as to whether we should use integrate security or not

 .PARAMETER UserName
 If we are not using integrated security, we should use this user name to connect to the server

 .PARAMETER Password
 If we are not using integrated security, we should use this password to connect to the server

 .PARAMETER PublishProfile
 Full path to the publish profile we should use

 .EXAMPLE
 Invoke-DacPacUtility

#>
Function Invoke-DacPacUtility {

	Param(
		[bool]$Report,
		[bool]$Script,
		[bool]$Deploy,
		[string]$DacPacFilename,
		[string]$TargetServer,
		[string]$TargetDatabase,
		[bool]$UseIntegratedSecurity,
		[string]$UserName,
		[string]$Password,
		[string]$PublishProfile,
		[string]$AdditionalDeploymentContributors,
		[string]$AdditionalDeploymentContributorArguments
	)

	# We output the parameters (excluding password) so that we can see what was supplied for debuging if required.  Useful for variable scoping problems
	Write-Debug ("Invoke-DacPacUtility called.  Parameter values supplied:")
	Write-Debug ("    Dacpac Filename:                  {0}" -f $DacPacFilename)
	Write-Debug ("    Dacpac Profile:                   {0}" -f $PublishProfile)
	Write-Debug ("    Target server:                    {0}" -f $TargetServer)
	Write-Debug ("    Target database:                  {0}" -f $TargetDatabase)
	Write-Debug ("    Using integrated security:        {0}" -f $UseIntegratedSecurity)
	Write-Debug ("    Username:                         {0}" -f $UserName)
	Write-Debug ("    Report:                           {0}" -f $Report)
	Write-Debug ("    Script:                           {0}" -f $Script)
	Write-Debug ("    Deploy:                           {0}" -f $Deploy)
	Write-Debug ("    Deployment contributors:          {0}" -f $AdditionalDeploymentContributors)
	Write-Debug ("    Deployment contributor arguments: {0}" -f $AdditionalDeploymentContributorArguments)

	$DateTime = ((Get-Date).ToUniversalTime().ToString("yyyyMMddHHmmss"))

	Load-DACAssemblies

	Try {
		$dacPac = [Microsoft.SqlServer.Dac.DacPackage]::Load($DacPacFilename)
		$connectionString = (Get-ConnectionString -ServerName $TargetServer -Database $TargetDatabase -UseIntegratedSecurity $UseIntegratedSecurity -UserName $UserName -Password $Password)

		# Load the publish profile if supplied
		If ($PublishProfile)
		{
			Write-Verbose ("Attempting to load the publish profile: {0}" -f $PublishProfile)

			#Load the publish profile
			$dacProfile = [Microsoft.SqlServer.Dac.DacProfile]::Load($PublishProfile)
			Write-Verbose ("Loaded publish profile: {0}" -f $PublishProfile)

			#Load the artifact back into Octopus Deploy
			$profileArtifact = ("{0}.{1}.{2}.{3}" -f $TargetServer, $TargetDatabase, $DateTime, ($PublishProfile.Remove(0, $PublishProfile.LastIndexOf("\") + 1)))
			New-OctopusArtifact -Path $PublishProfile -Name $profileArtifact
			Write-Verbose ("Loaded publish profile as an Octopus Deploy artifact")
		}
		Else {
			$dacProfile = New-Object Microsoft.SqlServer.Dac.DacProfile
			Write-Verbose ("Created blank publish profile")
		}

		# Specify additional deployment contributors:
		$dacProfile.DeployOptions.AdditionalDeploymentContributors = $AdditionalDeploymentContributors
		$dacProfile.DeployOptions.AdditionalDeploymentContributorArguments = $AdditionalDeploymentContributorArguments

		$dacServices = New-Object Microsoft.SqlServer.Dac.DacServices -ArgumentList $connectionString

		# Register the object events and output them to the verbose stream
		Register-ObjectEvent -InputObject $dacServices -EventName "ProgressChanged" -SourceIdentifier "ProgressChanged" -Action { Write-Verbose ("DacServices: {0}" -f $EventArgs.Message) } | Out-Null
		Register-ObjectEvent -InputObject $dacServices -EventName "Message" -SourceIdentifier "Message" -Action { Write-Host ($EventArgs.Message.Message) } | Out-Null

	
		If ($Report -or $Script -or $ExtractDacpac)
		{
			# Extract a DACPAC so we can do reports and scripting faster (if both are done)
			# dbDacPac
			$dbDacPacFilename = ("{0}.{1}.{2}.dacpac" -f $TargetServer, $TargetDatabase, $DateTime)
			$dacVersion = New-Object System.Version(1, 0, 0, 0)
			Write-Debug "Extracting target server dacpac"
			$dacServices.Extract($dbDacPacFilename, $TargetDatabase, $TargetDatabase, $dacVersion)

			Write-Debug ("Loading the target server dacpac for report and scripting. Filename: {0}" -f $dbDacPacFilename)
			$dbDacPac = [Microsoft.SqlServer.Dac.DacPackage]::Load($dbDacPacFilename)

			If ($ExtractDacpac)
			{
				New-OctopusArtifact -Path $dbDacPacFilename -Name $dbDacPacFilename
			}

			# Generate a Deploy Report if one is asked for
			If ($Report)
			{
				Write-Host ("Generating deploy report against server: {0}, database: {1}" -f $TargetServer, $TargetDatabase)
				$deployReport = [Microsoft.SqlServer.Dac.DacServices]::GenerateDeployReport($dacPac, $dbDacPac, $TargetDatabase, $dacProfile.DeployOptions)
				$reportArtifact = ("{0}.{1}.{2}.{3}" -f $TargetServer, $TargetDatabase, $DateTime, "DeployReport.xml")
		
				Set-Content $reportArtifact $deployReport

				Write-Host ("Loading the deploy report to OctopusDeploy: {0}" -f $reportArtifact)
				New-OctopusArtifact -Path $reportArtifact -Name $reportArtifact
			}

			# Generate a Deploy Script if one is asked for
			If ($Script)
			{
				Write-Host ("Generating deploy script against server: {0}, database: {1}" -f $TargetServer, $TargetDatabase)
				$deployScript = [Microsoft.SqlServer.Dac.DacServices]::GenerateDeployScript($dacPac, $dbDacPac, $TargetDatabase, $dacProfile.DeployOptions)
				$scriptArtifact = ("{0}.{1}.{2}.{3}" -f $TargetServer, $TargetDatabase, $DateTime, "DeployScript.sql")
		
				Set-Content $scriptArtifact $deployScript
		
				Write-Host ("Loading the deploy script to OctopusDeploy: {0}" -f $scriptArtifact)
				New-OctopusArtifact -Path $scriptArtifact -Name $scriptArtifact
			}
		}

		# Deploy the dacpac if asked for
		If ($Deploy)
		{
			Write-Host ("Starting deployment of dacpac against server: {0}, database: {1}" -f $TargetServer, $TargetDatabase)
			$dacServices.Deploy($dacPac, $TargetDatabase, $true, $dacProfile.DeployOptions, $null)
		
			Write-Host ("Dacpac deployment complete")
		}

		Unregister-Event -SourceIdentifier "ProgressChanged"
		Unregister-Event -SourceIdentifier "Message"
	}
	Catch {
		Throw ("Deployment failed: {0} `r`nReason: {1}" -f $_.Exception.Message, $_.Exception.InnerException.Message)
	}
}

# Export the Invoke-DacPacUtility function
Export-ModuleMember -Function Format-OctopusArgument
Export-ModuleMember -Function Invoke-DacPacUtility