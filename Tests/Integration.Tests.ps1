Import-Module -Force $PSScriptRoot/../Docker.Build.psm1
. "$PSScriptRoot\..\Private\Invoke-Command.ps1"

Describe 'Use cases for this module' {

    Context 'With a local docker registry setup up and running' {

        BeforeAll {
            $testData = Join-Path (Split-Path -Parent $PSScriptRoot) "Test-Data"
            $dockerImages = Join-Path $testData 'DockerImage'
            $startRegistryCommand = 'docker run -d -p 5000:5000 --restart always --name registry registry:2'
            Invoke-Command  $startRegistryCommand
        }

        It 'can build and test my image' {
            $dockerFile = Join-Path $dockerImages 'Dockerfile'
            Invoke-DockerLint -DockerFile $dockerFile
            Invoke-DockerBuild -Image 'integrationtest' | Invoke-DockerTag | Invoke-DockerPush

        }
    }
}