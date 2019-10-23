. "$PSScriptRoot\..\Private\LintRemark.ps1"
. "$PSScriptRoot\..\Private\CommandResult.ps1"
. "$PSScriptRoot\..\Private\Format-AsAbsolutePath.ps1"

function Invoke-DockerLint {
    [CmdletBinding()]
    param (
        [ValidateNotNullOrEmpty()]
        [String]
        $DockerFile = 'Dockerfile',
        [bool]
        $TreatLintRemarksFoundAsException = $false
    )
    $pathToDockerFile = Format-AsAbsolutePath $DockerFile
    $dockerFileExists = [System.IO.File]::Exists($pathToDockerFile)
    if (!$dockerFileExists) {
        $mesage = "No such file: ${pathToDockerFile}"
        throw [System.IO.FileNotFoundException]::new($mesage)
    }
    $hadoLintImage = 'hadolint/hadolint:v1.17.2'
    [String[]] $code = Get-Content -Path $DockerFile
    if ($IsWindows) {
        $lintCommand = "cmd /c 'docker run -i ${hadoLintImage} < ${pathToDockerFile}'"
    }
    elseif ($IsLinux) {
        $lintCommand = "sh -c 'docker run -i ${hadoLintImage} < ${pathToDockerFile}'"
    }
    $commandResult = Invoke-Command $lintCommand
    if ($TreatLintRemarksFoundAsException) {
        Assert-ExitCodeOk $commandResult
    }
    [LintRemark[]] $lintRemarks = Find-LintRemarks $commandResult.Output
    $lintedDockerfile = Merge-CodeAndLintRemarks -CodeLines $code -LintRemarks $lintRemarks
    $result = [PSCustomObject]@{
        'Result'     = $commandResult
        'LintOutput' = $lintedDockerfile
    }
    return $result
}
