. "$PSScriptRoot\..\Private\LintRemark.ps1"
. "$PSScriptRoot\..\Private\CommandResult.ps1"
. "$PSScriptRoot\..\Private\Format-AsAbsolutePath.ps1"

function Invoke-DockerLinting {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]
        $DockerFile
    )
    $pathToDockerFile = Format-AsAbsolutePath $DockerFile
    $dockerFileExists = [System.IO.File]::Exists($pathToDockerFile)
    if (!$dockerFileExists) {
        throw [System.IO.FileNotFoundException]::new("No such file: $pathToDockerFile")
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
