. "$PSScriptRoot\..\Private\LintRemark.ps1"
. "$PSScriptRoot\..\Private\CommandResult.ps1"
. "$PSScriptRoot\..\Private\Format-AsAbsolutePath.ps1"
. "$PSScriptRoot\..\Private\Write-PassThruOutput.ps1"

function Invoke-DockerLint {
    [CmdletBinding()]
    param (
        [ValidateNotNullOrEmpty()]
        [String]
        $DockerFile = 'Dockerfile',

        [Switch]
        $TreatLintRemarksFoundAsException,

        [Switch]
        $Quiet = [System.Convert]::ToBoolean($env:DOCKER_POSH_QUIET_MODE)
    )
    $pathToDockerFile = Format-AsAbsolutePath $DockerFile
    $dockerFileExists = Test-Path -Path $pathToDockerFile -PathType Leaf
    if (!$dockerFileExists) {
        $mesage = "No such file: ${pathToDockerFile}"
        throw [System.IO.FileNotFoundException]::new($mesage)
    }
    $hadoLintImage = 'hadolint/hadolint:v1.17.2'
    [String[]] $code = Get-Content -Path $DockerFile

    $lintCommand = "Get-Content `"${pathToDockerFile}`" | docker run -i ${hadoLintImage}"
    $commandResult = Invoke-Command $lintCommand
    if ($TreatLintRemarksFoundAsException) {
        Assert-ExitCodeOk $commandResult
    }
    [LintRemark[]] $lintRemarks = Find-LintRemarks $commandResult.Output
    $lintedDockerfile = Merge-CodeAndLintRemarks -CodeLines $code -LintRemarks $lintRemarks
    $result = [PSCustomObject]@{
        'CommandResult' = $commandResult
        'LintOutput'    = $lintedDockerfile
    }
    if (!$Quiet) {
        Write-CommandOuput $($result.LintOutput)
    }
    return $result
}
