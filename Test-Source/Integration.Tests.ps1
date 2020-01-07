
# Skip Integration tests as they require Linux docker containers to run the registry.
if ($IsWindows -and $env:TF_BUILD -ieq 'true') {
    return
}

Import-Module -Force (Get-ChildItem -Path $PSScriptRoot/../Source -Recurse -Include *.psm1 -File).FullName
Import-Module -Global -Force $PSScriptRoot/Docker-CI.Tests.psm1

. "$PSScriptRoot\..\Source\Private\Invoke-Command.ps1"
. "$PSScriptRoot\..\Source\Private\Utilities.ps1"

Describe 'Use cases for this module' {

    Context 'With a local docker registry with auth required' {

        $localRegistryName = 'localhost:5000'

        BeforeAll {
            $dockerImageDir = Join-Path $Global:ExampleReposDir "3.0/servercore/amd64"
            $testData = Join-Path (Split-Path -Parent $PSScriptRoot) "Test-Data"
            $htpasswdPath = Join-Path $testData 'DockerRegistry'
            $exampleRepos = Join-Path $testData 'ExampleRepos'
            $removeImageCommandArgs = 'image rm --force localhost:5000/integration-testcase-2:latest'
            $pruneImageCommandArgs = 'system prune --force'
            $startRegistryCommandArgs = "run -d -p 5000:5000 --name registry" + `
                " -v `"$($Global:LocalDockerRegistryDir):/auth`"" + `
                " -e `"REGISTRY_AUTH=htpasswd`"" + `
                " -e `"REGISTRY_AUTH_HTPASSWD_REALM=Registry Realm`"" + `
                " -e `"REGISTRY_AUTH_HTPASSWD_PATH=/auth/htpasswd`"" + `
                " registry:2"

            Invoke-DockerCommand $removeImageCommandArgs
            Invoke-DockerCommand $pruneImageCommandArgs
            Invoke-DockerCommand $startRegistryCommandArgs
        }

        AfterAll {
            Invoke-DockerCommand 'container stop registry'
            Invoke-DockerCommand 'container rm -v registry'
        }

        BeforeEach {
            $script:backupLocation = Get-Location
            New-FakeGitRepository $dockerImageDir
            Set-Location $dockerImageDir
        }

        AfterEach {
            Set-Location $script:backupLocation
        }

        It 'can build an image and tag it' {
            Invoke-DockerBuild . -ImageName 'integration-testcase-1'
            $findImageArgs = 'images integration-testcase-1'
            $result = Invoke-DockerCommand $findImageArgs
            ([regex]::Matches($result.Output, "integration-testcase-1" )).Count | Should -BeExactly 1
        }

        It "Use case #1: Can derive docker image name and tag in one go" {
            $result = Find-ImageName $dockerImageDir
            $result = Format-DockerTag | Invoke-DockerBuild -ImageName $result.ImageName

            $result.Dockerfile | Should -BeLike "*Dockerfile"
            $result.ImageName | Should -Be "dockerbuild-pwsh"
            $result.Tag | Should -Be  "3.0-servercore-amd64"
        }

        It "Use case #2: Can build and push in one go" {
            Invoke-DockerLogin -Username 'admin' -Password (ConvertTo-SecureString 'password' –asplaintext –force) -Registry 'localhost:5000'
            Invoke-DockerBuild -ImageName 'integration-testcase-2' -Registry 'localhost:5000' | Invoke-DockerPush -Registry 'localhost:5000'

            $result = Invoke-DockerPull -Registry 'localhost:5000' -ImageName 'integration-testcase-2' -Tag 'latest'
            $result.CommandResult.ExitCode | Should -Be 0
        }

        It "Use case #3: Can pull, tag and push in one go" {
            Invoke-DockerLogin -Username 'admin' -Password (ConvertTo-SecureString 'password' –asplaintext –force) -Registry $localRegistryName
            Invoke-DockerPull -ImageName 'ubuntu' | Invoke-DockerTag -NewImageName 'ubuntu' -NewTag 'v1.0.2' -NewRegistry $localRegistryName | Invoke-DockerPush
            $result = Invoke-DockerPull -Registry $localRegistryName -ImageName 'ubuntu' -Tag 'v1.0.2'
            $result.CommandResult.ExitCode | Should -Be 0
        }

        It 'Use case #4: Can produce an image from scratch' {
            $imageName = (Find-ImageName -RepositoryPath $dockerImageDir).ImageName

            # 1. Make sure we play by the rules: do linting and test
            Invoke-DockerLint
            Invoke-DockerTests -ImageName $imageName

            # 2. Build and push image to latest tag, then grab it and see it's ok
            $result = Invoke-DockerBuild -Registry $localRegistryName -ImageName $imageName | `
                Invoke-DockerPush | `
                Invoke-DockerPull

            $result.CommandResult.ExitCode | Should -Be 0
            $result.ImageName | Should -Be $imageName
            $result.Registry | Should -Be "${localRegistryName}/"
        }
    }
}
