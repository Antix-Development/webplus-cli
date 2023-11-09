# cli for creating and packaging WebPlus (https://github.com/Antix-Development/WebPlus) apps.

$params = -Split $args # NPM concatenates the args, so reget them by splitting.

$command = $params[0]
$project = $params[1]
$template = $params[2]

$basedir = Split-Path $MyInvocation.MyCommand.Definition -Parent # App files contained in this directory.

$currentdir = Get-Location # Apps will be created in this directory.

function Show-Usage {
	Write-Host "Usage: webplus <option> file [template]"
	Write-Host ""
	Write-Host "Options:"
	Write-Host "  -c --create <name> [template]  Creates an app using the specified or default template."
	Write-Host "  -p --package <name>            Packages the app with the given name."
	Write-Host "  -h --help                      Output usage information."
	Write-Host ""
	Write-Host "Templates:"
	$directories = Get-ChildItem "$basedir\templates" -Directory
	foreach ($directory in $directories) {
		Write-Host " " $directory -ForegroundColor DarkBlue
	}
}

function Show-Error($e) {
	Write-Host $e -ForegroundColor Red
}

switch ($command) {
	
	default {Show-Usage} # No arguments.
	
	{($_ -eq "-h") -or ($_ -eq "-help") -or ($null -eq $_)} {Show-Usage} # Requested help.
	
	{($_ -eq "-c") -or ($_ -eq "-create")} { # Requested create.

		if ($null -ne $project) { # Was a project name given?

			if (!(Test-Path "$currentdir\$project")) { # Does a project with the given name NOT exist in the current directory?

				if ($null -eq $template) {$template = "default"} # Get default template name is nothing was passed.

				if ((Test-Path "$basedir\templates\$template")) { # Does a template with the given name exist?

					Copy-Item "$basedir\base\" -Destination "$currentdir\$project" -Recurse # Copy base files.
					Copy-Item "$basedir\templates\$template\*.*" -Destination "$currentdir\$project" -Recurse -Force # Superimpose template files.

					$project = $project.substring(0,1).toupper()+$project.substring(1).tolower() # Capitalize project name.
					Rename-Item -Path "$currentdir\$project\WebPlus.exe" -NewName "$project.exe" # Change binary name.

					Write-Host "New project ($project) created." -ForegroundColor Green
				
				} else {
					Show-Error "Template named $template was not found."
				}

			} else {
				Show-Error "Project named $project already exists."
			}

		} else {
		Show-Error "No project name provided."
		}
	}

	{($_ -eq "-p") -or ($_ -eq "-package")} { # Requested package.
	
		Compress-Archive -Path "$currentdir\$project" -DestinationPath "$project.zip" -Force # Package it.
	} 
}
