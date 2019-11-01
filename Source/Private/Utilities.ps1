function New-FakeGitRepository {
    param (
        [Parameter(mandatory = $true)]
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
        [String] $Value = '',

        [ValidateNotNullOrEmpty()]
        [String] $Postfix = '/'
    )

    # Docker registry, images, nor tag allow white spaces, so let's trim it clean
    $trimmedValue = $Value.Trim()
    if ([String]::IsNullOrEmpty($trimmedValue)) {
        return $trimmedValue
    }

    if ( -Not $trimmedValue.EndsWith($Postfix) ) {
        $trimmedValue += $Postfix
    }
    return $trimmedValue
}
