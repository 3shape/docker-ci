. "$PSScriptRoot\New-RandomFolder.ps1"

Describe 'Creates a random folder for testing' {

    Context 'With the help of Pester TestDrive' {

        It 'can create random folder in TEMP folder' {
            $pathInTemp = New-RandomFolder
            Test-Path -Path $pathInTemp | Should -Be $true
            Remove-Item $pathInTemp -Recurse -Force
        }
    }
}
