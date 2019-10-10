Import-Module -Force $PSScriptRoot/../Docker.Build.psm1

function Get-TempPath {
    if ($IsWindows) {
        [system.io.path]::GetTempPath()
    } elseif ($IsLinux) {
        '/tmp'
    }
}

function New-RandomFolder {
    param (
        [int]$FolderLength = 8
    )
    do {
        $randomString = ( -join ((0x30..0x39) + ( 0x41..0x5A) + ( 0x61..0x7A) | Get-Random -Count $FolderLength | % {[char]$_}) )
        $randomPath = Join-Path $(Get-TempPath) $randomString
    } while (Test-Path -Path $randomPath -PathType Container)
    New-Item -Path $randomPath -ItemType Directory | Out-Null
    return $randomPath
}

function Fake-GitRepository {
    param (
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

Describe 'Parse context from git repository' {

    Context 'Validating support functions for - When git is installed' {

        It 'can get TEMP path' {
            $tempPath = Get-TempPath

            if ($IsWindows) {
                $tempPath.IndexOf($Env:TEMP) | Should -Be 0
            } elseif ($IsLinux) {
                $tempPath.IndexOf('/tmp') | Should -Be 0
            }
        }

        It 'can create random folder in TEMP folder' {
            $pathInTemp = New-RandomFolder

            Test-Path -Path $pathInTemp | Should -Be $true

            Remove-Item $pathInTemp -Recurse -Force | Out-Null
        }

        It 'can create fake git repository for testing' {
            $pathInTemp = New-RandomFolder
            Fake-GitRepository -Path $pathInTemp

            Test-Path -Path (Join-Path $pathInTemp ".git") -PathType Container | Should -Be $true
            Test-Path -Path (Join-Path $pathInTemp ".git/config") -PathType Leaf | Should -Be $true

            Remove-Item $pathInTemp -Recurse -Force | Out-Null
        }

    }

    Context 'When git is installed' {

        It 'can find a repository origin' {
            $tempFolder = New-RandomFolder

            $gitRepoPath1 = Join-Path $tempFolder "NoSpace"
            Fake-GitRepository -Path $gitRepoPath1
            $result = Find-ImageName -RepositoryPath $gitRepoPath1
            $result | Should -BeExactly "dockerbuild-pwsh"

            Remove-Item $tempFolder -Recurse -Force | Out-Null
        }

        It 'can find a repository origin with folder with space' {
            $tempFolder = New-RandomFolder

            $gitRepoPath2 = Join-Path $tempFolder "With Space"
            Fake-GitRepository -Path $gitRepoPath2
            $result = Find-ImageName -RepositoryPath $gitRepoPath2
            $result | Should -BeExactly "dockerbuild-pwsh"

            Remove-Item $tempFolder -Recurse -Force | Out-Null
        }
    }
}
