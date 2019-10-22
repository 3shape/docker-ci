Import-Module -Force $PSScriptRoot/../Docker.Build.psm1
. "$PSScriptRoot\..\Private\Invoke-Command.ps1"
. "$PSScriptRoot\..\Private\Utilities.ps1"

Describe 'Use cases for this module' {

    Context 'With a local docker registry with auth required' {

        $localRegistryName = 'localhost:5000'
        $dockerImageNamePrefix = 'integration-testcase'

        BeforeAll {
            $testData = Join-Path (Split-Path -Parent $PSScriptRoot) "Test-Data"
            $htpasswdPath = Join-Path $testData 'DockerRegistry'
            $dockerImages = Join-Path $testData 'DockerImage'
            $exampleRepos = Join-Path $testData 'ExampleRepos'
            $removeImageCommand = 'docker image rm --force localhost:5000/integration-testcase-2:latest'
            $pruneImageCommand = 'docker system prune --force'
            $startRegistryCommand = "docker run -d -p 5000:5000 --name registry -v ${htpasswdPath}:/auth -e 'REGISTRY_AUTH=htpasswd' -e 'REGISTRY_AUTH_HTPASSWD_REALM=Registry Realm' -e REGISTRY_AUTH_HTPASSWD_PATH=/auth/htpasswd registry:2"
            Invoke-Command $removeImageCommand
            Invoke-Command $pruneImageCommand
            Invoke-Command $startRegistryCommand
        }

        AfterAll {
            Invoke-Command 'docker container stop registry'
            Invoke-Command 'docker container rm -v registry'
        }

        BeforeEach {
            $script:backupLocation = Get-Location
        }

        AfterEach {
            Set-Location $script:backupLocation
        }

        It "Use case #1: Can derive docker image name and tag in one go" {
            $exampleReposPath = Join-Path $testData "ExampleRepos"
            $location = Join-Path $exampleReposPath "3.0/servercore/amd64"
            Set-Location $location
            New-FakeGitRepository $location

            $result = Find-ImageName $location

            $result = Format-DockerTag | Invoke-DockerBuild -ImageName $result.ImageName

            $result.Dockerfile | Should -BeLike "*Dockerfile"
            $result.ImageName | Should -Be "dockerbuild-pwsh"
            $result.Tag | Should -Be  "3.0-servercore-amd64"
        }

        It "Use case #2: Can build and push in one go" {
            $exampleReposPath = Join-Path $testData "ExampleRepos"
            $location = Join-Path $exampleReposPath "3.0/servercore/amd64"
            Set-Location $location
            New-FakeGitRepository $location

            Invoke-DockerLogin -Username 'admin' -Password (ConvertTo-SecureString 'password' –asplaintext –force) -Registry 'localhost:5000'

            Invoke-DockerBuild -ImageName 'integration-testcase-2' -Registry 'localhost:5000' | Invoke-DockerPush -Registry 'localhost:5000'

            $result = Invoke-DockerPull -Registry 'localhost:5000' -ImageName 'integration-testcase-2' -Tag 'latest'
            $result.Result.ExitCode | Should -Be 0
        }

        It "Use case #3: Can pull, tag and push in one go" {
            Invoke-DockerLogin -Username 'admin' -Password (ConvertTo-SecureString 'password' –asplaintext –force) -Registry $localRegistryName

            Invoke-DockerPull -ImageName 'ubuntu' | Invoke-DockerTag -NewImageName 'ubuntu' -NewTag 'v1.0.2' -NewRegistry $localRegistryName | Invoke-DockerPush
            $result = Invoke-DockerPull -Registry $localRegistryName -ImageName 'ubuntu' -Tag 'v1.0.2'

            $result.Result.ExitCode | Should -Be 0
        }

        It 'Use case #4: Can produce an image from scratch' {
            $dockerFileDirectory = Join-Path  $exampleRepos '3.0/servercore/amd64'
            Set-Location $dockerFileDirectory
            New-FakeGitRepository $dockerFileDirectory
            $imageName = (Find-ImageName -RepositoryPath $dockerFileDirectory).ImageName

            # 1. Make sure we play by the rules
            Invoke-DockerLint
            Invoke-DockerTests

            # 2. Build and push image to latest tag, then grab it and see it's ok
            $result = Invoke-DockerBuild -Registry $localRegistryName -ImageName $imageName |
                        Invoke-DockerPush |
                            Invoke-DockerPull

            $result.Result.ExitCode | Should -Be 0
            $result.ImageName | Should -Be $imageName
            $result.Registry | Should -Be "${localRegistryName}/"
        }

    }
}
