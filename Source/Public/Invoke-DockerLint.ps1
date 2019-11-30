. "$PSScriptRoot\..\Private\LintRemark.ps1"
. "$PSScriptRoot\..\Private\Format-AsAbsolutePath.ps1"
. "$PSScriptRoot\..\Private\Write-PassThruOutput.ps1"

function Invoke-DockerLint {
    [CmdletBinding(PositionalBinding = $false)]
    param (
        [ValidateNotNullOrEmpty()]
        [Parameter(Position = 0)]
        [String]
        $DockerFile = 'Dockerfile',

        [ValidateNotNullOrEmpty()]
        [String]
        $HadolintTag = 'v1.17.3',

        [Switch]
        $TreatLintRemarksFoundAsException,

        [Switch]
        $Quiet = [System.Convert]::ToBoolean($env:DOCKER_CI_QUIET_MODE)
    )
    $pathToDockerFile = Format-AsAbsolutePath $DockerFile
    $dockerFileExists = Test-Path -Path $pathToDockerFile -PathType Leaf
    if (!$dockerFileExists) {
        $mesage = "No such file: ${pathToDockerFile}"
        throw [System.IO.FileNotFoundException]::new($mesage)
    }
    $hadoLintImage = "hadolint/hadolint:${HadolintTag}"
    [String[]] $code = Get-Content -Path $DockerFile
    Invoke-DockerCommand "pull ${hadoLintImage}"
    [String[]] $dockerFileContents = Get-Content -Path $pathToDockerFile
    $lintCommandArgs = "run -i ${hadoLintImage}"
    $commandResult = Invoke-DockerCommand $lintCommandArgs -InputLines $dockerFileContents

    if ($TreatLintRemarksFoundAsException) {
        Assert-ExitCodeOk $commandResult
    }
    [LintRemark[]] $lintRemarks = Find-LintRemarks $commandResult.Output
    $lintedDockerfile = Merge-CodeAndLintRemarks -CodeLines $code -LintRemarks $lintRemarks
    $result = [PSCustomObject]@{
        'CommandResult' = $commandResult
        'LintRemarks'   = $lintRemarks
        'LintOutput'    = $lintedDockerfile
    }
    if (!$Quiet) {
        Write-CommandOuput $($result.LintOutput)
    }
    return $result
}
