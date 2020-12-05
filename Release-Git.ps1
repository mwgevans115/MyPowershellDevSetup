[CmdletBinding()]
param (
    [Parameter()]
    [string]
    $Release
)
$Release = "v$((Test-ScriptFileInfo -Path .\Release\MyPowerShellDevSetup\MyPowerShellDevSetup.ps1).Version)"
git tag $Release
git push origin --tags
Get-ChildItem -Directory .\Release | % {Compress-Archive -Path $_.FullName -DestinationPath ($_.FullName + ".zip") -Force}
hub release create -m "Version $Release" $Release
Get-ChildItem .\Release\* -Include '*.zip' | % {hub release edit -m "Version $Release" -a $_.FullName $Release}
