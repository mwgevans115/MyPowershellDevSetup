<#PSScriptInfo

.VERSION 1.1.0

.GUID 2c25b8e5-ced3-4615-b4b6-395245f8097b

.AUTHOR MarkEvans

.COMPANYNAME

.COPYRIGHT

.TAGS

.LICENSEURI

.PROJECTURI

.ICONURI

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES


.PRIVATEDATA

#> 



<#

.DESCRIPTION
Scipt for setting up powershell and vscode for development

#>

[cmdletbinding()]
param()

# --------------------------- User Defined Variables --------------------------
#                         Edit these variables as needed

#
# <- VARIABLES HERE ->
#

###############################################################################
#                       DO NOT MODIFY BEYOND THIS POINT!                      #
###############################################################################

# Track running time.
$StopWatch = [ordered]@{
    Total = [System.Diagnostics.Stopwatch]::StartNew()
}

# ------------------------------ Static Variables -----------------------------

#
# 'C:\Users\User\AppData\Local\Microsoft\Windows\PowerShell\PowerShellGet\'
# 'https://dist.nuget.org/win-x86-commandline/latest/nuget.exe'


Set-Variable -Name vscodeSettings -Option Constant -Description 'VS code settings file' -Scope Private `
    -Value @'
{
    // telemetry
    "telemetry.enableCrashReporter": false,
    "telemetry.enableTelemetry": false
    // editor
    "editor.quickSuggestionsDelay": 1,
    "editor.tabCompletion": "on",
    "files.defaultLanguage": "powershell",

    // default shell
    // Windows
        // PowerShell 7
        //    "terminal.integrated.shell.windows": "C:\\Program Files\\PowerShell\\7\\pwsh.exe",
        //    "powershell.powerShellExePath": "C:\\Program Files\\PowerShell\\7\\pwsh.exe",
        // PowerShell 6
            // "terminal.integrated.shell.windows": "C:\\Program Files\\PowerShell\\6\\pwsh.exe",
            // "powershell.powerShellExePath": "C:\\Program Files\\PowerShell\\6\\pwsh.exe",
        //PowerShell 5.1 and below
             "terminal.integrated.shell.windows": "C:\\WINDOWS\\System32\\WindowsPowerShell\\v1.0\\powershell.exe",
        //     "powershell.powerShellExePath": "C:\\WINDOWS\\System32\\WindowsPowerShell\\v1.0\\powershell.exe",
    // Linux
        // Ubuntu
            // PowerShell 7
                // "terminal.integrated.shell.linux": "/snap/powershell/current/opt/powershell/pwsh",
                // "powershell.powerShellExePath": "/snap/powershell/current/opt/powershell/pwsh",
            // PowerShell 6
                // "terminal.integrated.shell.linux": "/snap/powershell/36/opt/powershell/pwsh",
                // "powershell.powerShellExePath": "/snap/powershell/36/opt/powershell/pwsh",

    // powershell settings changes
    "powershell.codeFormatting.preset":"Stroustrup",
    "powershell.startAutomatically": true,
    "powershell.scriptAnalysis.enable": true,
    "powershell.integratedConsole.showOnStartup": false,
    "powershell.integratedConsole.focusConsoleOnExecute": true
}

'@
Set-Variable -Name 'vsSettingsPath' -Option Constant -Description 'VS Code Settigs file Path' -Scope Private `
    -Value (Join-Path -Path $env:APPDATA -ChildPath "Code\User\settings.json")
Set-Variable -Name 'GitPath' -Option Constant -Description 'Git file Path' -Scope Private `
    -Value (Join-Path -Path $env:ProgramFiles -ChildPath "git\cmd\git.exe")
Set-Variable -Name 'PowershellArgs' -Option Constant -Description 'Arguments to start powershell with' -Scope Private `
    -Value @('-NoExit', '-ExecutionPolicy Bypass', '-NoProfile')
Set-Variable -Name 'NugetPath' -Option Constant -Description 'Path to install NuGet.exe' -Scope Private `
    -Value (Join-Path ([Environment]::GetFolderPath([Environment+SpecialFolder]::LocalApplicationData)) 'Microsoft\Windows\PowerShell\PowerShellGet\Nuget.exe' )
Set-Variable -Name 'NugetURI' -Option Constant -Description 'Arguments to start powershell with' -Scope Private `
    -Value ([uri]'https://dist.nuget.org/win-x86-commandline/latest/nuget.exe')




#

# ------------------------------ Helper Functions -----------------------------

# Track step time.
$StopWatch.LoadFunctions = [System.Diagnostics.Stopwatch]::StartNew()

#
# <- FUNCTIONS HERE ->
#

# Stop step timer.
$StopWatch.LoadFunctions.Stop()

# ------------------------------- Script Logic --------------------------------

# Track step time.
$StopWatch.ScriptLogic = [System.Diagnostics.Stopwatch]::StartNew()

#
# <- LOGIC HERE ->
#

Install-PackageProvider -Name NuGet -Force -Scope CurrentUser
Install-Module -Name PowerShellGet -Force -AllowClobber -Scope CurrentUser
Invoke-WebRequest -UseBasicParsing -Uri $NugetURI -OutFile $NugetPath
Install-Script Install-Git, Install-VSCode, Install-Hub -Force -Scope CurrentUser
Start-Process powershell -ArgumentList ($PowershellArgs + '-Command Install-Git.ps1') -Verb RunAs
Install-Module -Name Posh-Git -Force -Scope CurrentUser
Add-PoshGitToProfile -AllHosts
Start-Process powershell -ArgumentList ($PowershellArgs + '-Command Install-Hub.ps1') -Verb RunAs
# indicate that you prefer HTTPS to SSH git clone URLs
& "$GitPath" config --global hub.protocol https

Install-VSCode -EnableContextMenus
New-Item $vsSettingsPath -ItemType File -Force
Set-Content -Path $vsSettingsPath -Value $vsCodeSettings

# Stop step timer.
$StopWatch.ScriptLogic.Stop()

# Compute and display elapsed run time (Verbose stream.)
$StopWatch.Total.Stop()
$StepTimes = @(
    $StopWatch.Keys | Where-Object { $_ -ne 'Total' } | ForEach-Object { [pscustomobject]@{ Step = $_ ; ElapsedTime = $StopWatch.Item($_).Elapsed.ToString() } }
)
$StepTimes | Out-String -Stream | Where-Object { $_ -ne "" } | Write-Verbose
Write-Verbose ""
Write-Verbose "TOTAL $($Stopwatch.Total.Elapsed.ToString())"
