. "$PSScriptRoot\..\Private\LintRemark.ps1"
. "$PSScriptRoot\..\Private\CommandResult.ps1"
. "$PSScriptRoot\..\Private\Format-AsAbsolutePath.ps1"

function Invoke-DockerLint {
    [CmdletBinding()]
    param (
        [ValidateNotNullOrEmpty()]
        [string]
        $DockerFile = 'Dockerfile'
    )
    $pathToDockerFile = Format-AsAbsolutePath $DockerFile
    $dockerFileExists = [System.IO.File]::Exists($pathToDockerFile)
    if (!$dockerFileExists) {
        $mesage = "No such file: ${pathToDockerFile}"
        throw [System.IO.FileNotFoundException]::new($mesage)
    }
    $hadoLintImage = 'hadolint/hadolint:v1.17.2'
    [string[]] $code = Get-Content -Path $DockerFile
    if ($IsWindows) {
        $lintCommand = "cmd /c 'docker run -i ${hadoLintImage} < ${pathToDockerFile}'"
    }
    elseif ($IsLinux) {
        $lintCommand = "sh -c 'docker run -i ${hadoLintImage} < ${pathToDockerFile}'"
    }
    [CommandResult] $result = Invoke-Command $lintCommand
    [LintRemark[]] $lintRemarks = Find-LintRemarks $result.Output
    return Merge-CodeAndLintRemarks -CodeLines $code -LintRemarks $lintRemarks
}
