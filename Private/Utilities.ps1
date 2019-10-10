#Requires -PSEdition Core -Version 6

function Get-TempPath {
    if ($IsWindows) {
        [system.io.path]::GetTempPath()
    } elseif ($IsLinux) {
        '/tmp'
    }
}

function New-RandomFolder {
    do {
        $randomString = New-Guid
        $randomPath = Join-Path $(Get-TempPath) $randomString
    } while (Test-Path -Path $randomPath -PathType Container)
    New-Item -Path $randomPath -ItemType Directory | Out-Null
    return $randomPath
}

function New-FakeGitRepository {
    param (
        [Parameter(mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [String]$Path
    )

    $dotGitPath = Join-Path $Path ".git"
    if (Test-Path $dotGitPath -PathType Container) {
        Remove-Item $dotGitPath -Recurse -Force | Out-Null
    }
    New-Item $dotGitPath -ItemType Directory

    $configData = @"
[remote "origin"]
url = https://github.com/3shapeAS/dockerbuild-pwsh.git
"@

    $configData | Out-File -FilePath "$dotGitPath/config" -Encoding ascii
}
