#!/usr/bin/env pwsh

<#
.SYNOPSIS
    Converts appsettings.json to environment variable format.

.DESCRIPTION
    Flattens JSON configuration into ASP.NET Core environment 
    variable format using double underscore (__) separators.

.PARAMETER Path
    Path to the appsettings.json file. Defaults to 
    appsettings.json in current directory.

.PARAMETER Format
    Output format: Table, List, Kubernetes, or Raw. Default: Table

.EXAMPLE
    ./convert-appsettings.ps1
    ./convert-appsettings.ps1 -Path ./config/appsettings.json
    ./convert-appsettings.ps1 -Format Kubernetes
#>

param(
    [Parameter(Position = 0)]
    [string]$Path = "appsettings.json",
    
    [Parameter()]
    [ValidateSet("Table", "List", "Kubernetes", "Raw")]
    [string]$Format = "Table"
)

if (-not (Test-Path $Path)) {
    Write-Error "File not found: $Path"
    exit 1
}

try {
    $json = Get-Content $Path -Raw | ConvertFrom-Json
}
catch {
    Write-Error "Failed to parse JSON: $_"
    exit 1
}

function Convert-ToEnvVars {
    param(
        [object]$obj,
        [string]$prefix = ""
    )
    
    foreach ($property in $obj.PSObject.Properties) {
        $key = if ($prefix) { 
            "$prefix`__$($property.Name)" 
        } else { 
            $property.Name 
        }
        $value = $property.Value
        
        if ($value -is [System.Management.Automation.PSCustomObject]) {
            Convert-ToEnvVars -obj $value -prefix $key
        }
        elseif ($value -is [array]) {
            for ($i = 0; $i -lt $value.Count; $i++) {
                if ($value[$i] -is [System.Management.Automation.PSCustomObject]) {
                    Convert-ToEnvVars -obj $value[$i] -prefix "$key`__$i"
                }
                else {
                    [PSCustomObject]@{
                        Name  = $key + "__$i"
                        Value = $value[$i]
                    }
                }
            }
        }
        else {
            [PSCustomObject]@{
                Name  = $key
                Value = $value
            }
        }
    }
}

$envVars = Convert-ToEnvVars -obj $json

switch ($Format) {
    "Table" {
        $envVars | Format-Table -AutoSize
    }
    "List" {
        $envVars | Format-List
    }
    "Kubernetes" {
        foreach ($var in $envVars) {
            $name = $var.Name -replace ':', '-'
            Write-Output "  - name: $($var.Name)"
            Write-Output "    value: `"$($var.Value)`""
        }
    }
    "Raw" {
        foreach ($var in $envVars) {
            Write-Output "$($var.Name)=$($var.Value)"
        }
    }
}
