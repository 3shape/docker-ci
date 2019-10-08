Import-Module -Verbose -Force -Name (Get-ChildItem $PSScriptRoot\..\*.psm1 | Select-Object -first 1).FullName
. "$PSScriptRoot\..\Private\Find-RepositoryName.ps1"

Describe 'Parse repos name from full git repository' {

    Context 'When full URL is specified' {

        It 'The repository name can be deduced' {
            $result = Find-RepositoryName -RepositoryPath "git@github.com:3shapeAS/jenkinsapi-powershell.git"
            $result | Should -BeExactly "jenkinsapi-powershell"
        }
    }
}
