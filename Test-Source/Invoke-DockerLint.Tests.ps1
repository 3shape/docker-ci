
# Need hadolint windows docker container (doable as they release windows executable)
if ($IsWindows) {
    return
}

Import-Module -Force (Get-ChildItem -Path $PSScriptRoot/../Source -Recurse -Include *.psm1 -File).FullName
Import-Module -Global -Force $PSScriptRoot/Docker-CI.Tests.psm1

Describe 'Execute linting on a given docker image' {

    Context 'When full path to a docker image is specified' {

        It 'can find 0 rule violations' {
            $dockerFile = Join-Path $Global:DockerImagesDir 'Windows.Dockerfile'
            $lintedDockerFile = Get-Content -Path (Join-Path $Global:DockerImagesDir 'Windows.Dockerfile.Linted')
            $result = Invoke-DockerLint -DockerFile $dockerFile
            $lintedDockerFile | Should -Be $result.LintOutput
        }

        It 'can find 0 rule violations, on folder with space' {
            $folderWithSpace = Join-Path $Global:DockerImagesDir 'Folder with space'
            $dockerFile = Join-Path $folderWithSpace 'Windows.Dockerfile'
            $lintedDockerFile = Get-Content -Path (Join-Path $Global:DockerImagesDir 'Windows.Dockerfile.Linted')
            $result = Invoke-DockerLint -DockerFile $dockerFile
            $lintedDockerFile | Should -Be $result.LintOutput
        }

        It 'can find 1 rule violation' {
            $dockerFile = Join-Path $Global:DockerImagesDir 'Linux.Dockerfile'
            $lintedDockerFile = Get-Content -Path (Join-Path $Global:DockerImagesDir 'Linux.Dockerfile.Linted')
            $result = Invoke-DockerLint -DockerFile $dockerFile
            $result.LintOutput | Should -Be $lintedDockerFile
            $result.LintRemarks.Length | Should -Be 1
        }

        It 'can find multiple rule violations' {
            $dockerFile = Join-Path $Global:DockerImagesDir 'Poorly.Written.Dockerfile'
            [string[]] $lintedDockerFile = Get-Content -Path (Join-Path $Global:DockerImagesDir 'Poorly.Written.Dockerfile.Linted')
            [string[]] $result = (Invoke-DockerLint -DockerFile $dockerFile).LintOutput

            for ($i = 0; $i -lt $lintedDockerFile.Length; $i++) {
                $lintedDockerFile[$i] | Should -Be $result[$i]
            }
        }

        It 'throws exception if docker image does not exist' {
            $code = {
                Invoke-DockerLint -DockerFile "not/here"
            }
            $code | Should -Throw -ExceptionType ([System.IO.FileNotFoundException]) -PassThru
        }

        It 'throws correct exception message if docker image does not exist' {
            try {
                Invoke-DockerLint -DockerFile "not.here"
            } catch {
                $exception = $_.Exception

            }
            $exception.Message | Should -BeLike "*not.here*"
        }

        It 'throws exception if lint remarks are found if required' {
            $dockerFile = Join-Path $Global:DockerImagesDir 'Linux.Dockerfile'

            $code = {
                Invoke-DockerLint -DockerFile $dockerFile -TreatLintRemarksFoundAsException
            }

            $code | Should -Throw -ExceptionType ([System.Exception]) -PassThru
        }
    }

    Context 'Pipeline execution' {
        It 'returns the expected pscustomobject' {
            $dockerFile = Join-Path $Global:DockerImagesDir 'Windows.Dockerfile'

            $result = Invoke-DockerLint -DockerFile $dockerFile

            $result.LintOutput | Should -Not -BeNullOrEmpty
            $result.LintRemarks.Length | Should -Be 0
            $result.CommandResult.ExitCode | Should -Be 0
            $result.CommandResult | Should -Not -BeNullOrEmpty
        }
    }

    Context 'Verbosity of execution' {

        BeforeAll {
            Initialize-MockReg
        }

        It 'outputs the result if Quiet is disabled' {
            Mock -CommandName "Invoke-Command" $Global:CodeThatReturnsExitCodeZero -Verifiable -ModuleName $Global:ModuleName
            $tempFile = New-TemporaryFile
            $dockerFile = Join-Path $Global:DockerImagesDir 'Linux.Dockerfile'

            Invoke-DockerLint -DockerFile $dockerFile -Quiet:$false 6> $tempFile

            $result = Get-Content $tempFile

            $result | Should -Be @('1: FROM ubuntu:latest')
        }

        It 'suppresses the output of the command invoked if Quiet is enabled' {
            Mock -CommandName "Invoke-Command" $Global:CodeThatReturnsExitCodeZero -Verifiable -ModuleName $Global:ModuleName
            $tempFile = New-TemporaryFile
            $dockerFile = Join-Path $Global:DockerImagesDir 'Linux.Dockerfile'

            Invoke-DockerLint -DockerFile $dockerFile -Quiet:$true 6> $tempFile

            $result = Get-Content $tempFile

            $result | Should -BeNullOrEmpty
        }
    }
}
