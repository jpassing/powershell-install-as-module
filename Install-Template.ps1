#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.
#

[CmdletBinding()]
    Param(
        [Parameter(Mandatory=$false)][ValidateSet("LocalMachine", "CurrentUser")][string] $Install,
        [Parameter(Mandatory=$false)][ValidateSet("LocalMachine", "CurrentUser")][string] $Uninstall
    )

###############################################################################
###= JP.TemplateModule\JP.TemplateModule.psm1
###############################################################################

#Requires -version 4

Set-StrictMode -Version Latest

# Stop script on error
$ErrorActionPreference ="stop"

function Invoke-TemplateTest {
    [CmdletBinding()]
    Param()

    Write-Host "This is a test function"
}

###############################################################################
###= JP.TemplateModule\JP.TemplateModule.psd1
###############################################################################

@{
    ModuleVersion = '1.0'
    RootModule = 'JP.TemplateModule.psm1'
    FunctionsToExport = @(
        'Invoke-TemplateTest')
}

###############################################################################
###=
###############################################################################


function Install-ScriptAsModule {
    <#
        .SYNOPSIS
            Generate a Powershell module from this script and install it.
    #>
    Param(
        [Parameter(Mandatory=$True)][string]$ModulePath,
        [Parameter(Mandatory=$false)][string]$Prefix = "###="
    )

    $OutputFile = $Null
    $FullOutputPath = $Null
    Get-Content $script:MyInvocation.MyCommand.Path | Foreach-Object {
        if ($_.StartsWith($Prefix)) {
            # Start a new file
            $OutputFile = $_.Substring($Prefix.Length).Trim()

            if ($OutputFile) {
                $FullOutputPath = (Join-Path -Path $ModulePath -ChildPath $OutputFile)

                New-Item `
                    -ItemType Directory `
                    -Force -Path ([System.IO.Path]::GetDirectoryName($FullOutputPath)) | Out-Null

                # Truncate file
                "" | Out-File  $FullOutputPath
            }
        }
        elseif ($OutputFile) {
            # Keep appending to file
            $_ | Out-File  $FullOutputPath -Append
        }
    }
}

function Uninstall-ScriptAsModule {
    <#
        .SYNOPSIS
            Renove Powershell module that has been generated from this script.
    #>
    Param(
        [Parameter(Mandatory=$True)][string]$ModulePath,
        [Parameter(Mandatory=$false)][string]$Prefix = "###="
    )

    Get-Content $script:MyInvocation.MyCommand.Path | Where-Object { $_.StartsWith($Prefix) } | Foreach-Object {
        $OutputFile = $_.Substring($Prefix.Length).Trim()

        if ($OutputFile) {
            $FullOutputPath = (Join-Path -Path $ModulePath -ChildPath $OutputFile)

            if (Test-Path $FullOutputPath) {
                Remove-Item -Force $FullOutputPath
            }
        }
    }
}

$_PowerShellModuleFolders = @{
    LocalMachine = (Join-Path -Path $Env:ProgramFiles -ChildPath "WindowsPowerShell\Modules\");
    CurrentUser = (Join-Path -Path ([environment]::getfolderpath("mydocuments")) -ChildPath "WindowsPowerShell\Modules\")
}

Write-Host ""
Write-Host "Advanced functions added to current session."

if ($Uninstall) {
    Uninstall-ScriptAsModule -ModulePath $_PowerShellModuleFolders[$Uninstall]
    Write-Host "Advanced functions removed from $($_PowerShellModuleFolders[$Uninstall])"
}
elseif ($Install) {
    Install-ScriptAsModule -ModulePath $_PowerShellModuleFolders[$Install]
    Write-Host "Advanced functions installed to $($_PowerShellModuleFolders[$Install])"
}
else {
    Write-Host "Use -Install to add functions permanenently."
}