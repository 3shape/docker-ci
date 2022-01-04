Import-Module -Force (Get-ChildItem -Path $PSScriptRoot/../Source -Recurse -Include *.psm1 -File).FullName
Import-Module -Global -Force $PSScriptRoot/Docker-CI.Tests.psm1

Describe 'Generate image changelog' {

    Context 'Docker chnagelog' {

        It 'correctly read from the test results' {
            $result = Read-ChangelogFromTestReport -TestReportPath "$global:StructureTestsDir/Changelog/report.json"

            $result.Replace("`n", "").Replace("`r", "") | Should -Be " git cli: git version 2.34.0.windows.1 dotnet: 5.0.100"
            $result | Should -Not -BeNullOrEmpty
        }

        It 'returns null on wrong file' {
            $result = Read-ChangelogFromTestReport -TestReportPath "testreport1.json"

            $result | Should -BeNullOrEmpty
        }
    }
}
