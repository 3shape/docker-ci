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

function Add-RegistryPostfix {
    param (
        [String] $Registry,
        [ValidateNotNullOrEmpty()]
        [String] $Postfix = '/'
    )

    # Do nothing if $Data is empty / writespace
    if ([String]::IsNullOrWhiteSpace($Registry)) {
        return ''
    }

    $trimmedRegistry = $Registry.Trim()
    if ( -Not $trimmedRegistry.EndsWith($Postfix) ) {
            $trimmedRegistry += $Postfix
    }
    $trimmedRegistry
}

function Test-DockerDigest {
    param (
        [Parameter(Mandatory=$true)]
        [String] $Digest
    )

    $shaPrefix = 'sha256:'
    return $Digest.StartsWith($shaPrefix) -and $Digest.Length -eq ($shaPrefix.Length + 64)
}
