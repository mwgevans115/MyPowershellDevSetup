<#PSScriptInfo
    .VERSION 0.1.0
    .GUID 2c25b8e5-ced3-4615-b4b6-395245f8097b
    .AUTHOR Mark Evans
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
Set-Variable -Name vscodeSettings -Option Constant -Description 'VS code settings file' `
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
Set-Variable -Name vsSettingsPath -Option Constant -Description 'VS Code Settigs file Path' `
    -Value = Join-Path $env:APPDATA "Code\User\settings.json"
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
Install-Module –Name PowerShellGet –Force -AllowClobber -Scope CurrentUser
Install-Script Install-Git, Install-VSCode, Install-Hub -Force -Scope CurrentUser
Install-Git
Install-Module -Name Posh-Git -Force -Scope CurrentUser
Add-PoshGitToProfile -AllHostsc
Install-Hub
# indicate that you prefer HTTPS to SSH git clone URLs
#git config --global hub.protocol https
& "c:\program files\git\cmd\git" config --global hub.protocol https
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
