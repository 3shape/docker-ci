Import-Module -Force $PSScriptRoot/../Docker.Build.psm1
. "$PSScriptRoot\..\Private\Invoke-Command.ps1"

Describe 'Use cases for this module' {

    Context 'With a local docker registry setup up and running' {

        BeforeAll {
            $testData = Join-Path (Split-Path -Parent $PSScriptRoot) "Test-Data"
            $htpasswdPath = Join-Path $testData 'DockerRegistry'
            $dockerImages = Join-Path $testData 'DockerImage'
            $startRegistryCommand = "docker run -d -p 5000:5000 --name registry -v ${htpasswdPath}:/auth -e 'REGISTRY_AUTH=htpasswd' -e 'REGISTRY_AUTH_HTPASSWD_REALM=Registry Realm' -e REGISTRY_AUTH_HTPASSWD_PATH=/auth/htpasswd registry:2"
            Invoke-Command  $startRegistryCommand
        }

        AfterAll {
            Invoke-Command 'docker container stop registry'
            Invoke-Command 'docker container rm -v registry'
        }

        It 'can login' {
            $result = Invoke-DockerLogin    -Registry 'localhost:5000' `
                                            -Username 'admin' `
                                            -Password (ConvertTo-SecureString 'password' –asplaintext –force)

            $result | Should -Not -BeNullOrEmpty
            $result.ExitCode | Should -Be 0
        }

        It "can build and push my image with 'latest' tag" {
            $dockerFile = Join-Path $dockerImages 'Dockerfile'
            # Invoke-DockerBuild -Image 'integrationtest'
            # 1. Login
            # 2. Pull the image
            # 3. Lint
            # 4. Build
            # 5. Test
            # 6. Tag
            # 7. Push
        }

    }
}
