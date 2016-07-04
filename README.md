# UPDATE!
I submitted a pull request for a modified version of this that was accepted into the template directory in Octopus Deploy. You should use that instead!

 * [sql-deploy-dacpac template](https://github.com/OctopusDeploy/Library/blob/master/step-templates/sql-deploy-dacpac.json)
 * [pull request](https://github.com/OctopusDeploy/Library/pull/311)

# Octopus Deploy of SSDT projects
This repository contains PowerShell modules and step templates for Octopus Deploy.  Importing into Octopus Deploy will allow 
you to then define steps that work with SSDT packages.

With the modules and step it is possible to:
 * Create deploy reports
 * Create the deployment sql script
 * Deploy a dacpac to a target database

## Installation
 1. Create a new script module in the library of your OctopusDeploy server
 1. Paste the module code from [Octopus.PS.psm1](Octopus.PS/Modules/Octopus.PS.psm1) into the module Body.
 1. Under settings give the module a name and description
 1. Under the step templates libray, import a new template
 1. Use the JSON in [SSDT DacPac Command](Octopus.PS/Step%20Templates/SSDT%20DacPac%20Command.ps1)
 
## Using
 1. In your project create a new SSDT DacPac Command
 1. Define the values for the parameters
 1. Ensure you add the module to your project process
 
