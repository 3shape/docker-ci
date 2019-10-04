Import-Module -Force -Name (Get-ChildItem $PSScriptRoot\..\*.psm1 | Select-Object -first 1).FullName
. "$PSScriptRoot\..\Private\Get-RepositoryName.ps1"

Describe 'Parse repos name from full git repository' {

    Context 'When full URL is specified' {

        It 'The repository name can be deduced' {
            $result = Get-RepositoryName -FullRepositoryName "git@github.com:3shapeAS/jenkinsapi-powershell.git"
            $result | Should -BeExactly "jenkinsapi-powershell"
        }
    }
}
