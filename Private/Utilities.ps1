function Get-TempPath {
    if ($IsWindows) {
        [system.io.path]::GetTempPath()
    } elseif ($IsLinux) {
        '/tmp'
    }
}

function New-RandomFolder {
    do {
        $randomPath = Join-Path $(Get-TempPath) $(New-Guid)
    } while (Test-Path -Path $randomPath -PathType Container)
    New-Item -Path $randomPath -ItemType Directory | Out-Null
    return $randomPath
}

function New-FakeGitRepository {
    param (
        [Parameter(mandatory=$true)]
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

function Add-Postfix {
    param (
        [String] $Value,

        [ValidateNotNullOrEmpty()]
        [String] $Postfix = '/'
    )

    if ([String]::IsNullOrWhiteSpace($Value)) {
        return $Value
    }

    $trimmedValue = $Value.Trim()
    if ( -Not $trimmedValue.EndsWith($Postfix) ) {
            $trimmedValue += $Postfix
    }
    $trimmedValue
}
