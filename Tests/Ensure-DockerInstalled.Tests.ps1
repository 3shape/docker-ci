. "$PSScriptRoot\..\Private\Ensure-DockerInstalled.ps1"
. "$PSScriptRoot\..\Private\Run-Commands.ps1"

Describe 'Verify docker tool installed' {

    Context 'When docker is installed' {

        It 'It is detected as installed' {
            $result = Ensure-DockerInstalled -DockerBinaryName "docker"
            $result | Should -Match "Docker"
        }
    }


}
