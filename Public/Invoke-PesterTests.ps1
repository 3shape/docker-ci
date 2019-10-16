function Invoke-PesterTests {
    [CmdletBinding()]
    param (
        [ValidateRange("NonNegative")]
        [Int32]
        $Depth = 0,

        [ValidateNotNullOrEmpty()]
        [String]
        $TestDirectory = '.'
    )
    $testDirectoryPath = Format-AsAbsolutePath (Add-PostFix  $TestDirectory)
    $testDirectoryExists = [System.IO.Directory]::Exists($testDirectoryPath)
    if (!$testDirectoryExists) {
        $mesage = "No such directory: ${testDirectoryPath}"
        throw [System.IO.DirectoryNotFoundException]::new($mesage)
    }
    $files = Get-ChildItem -Path "${testDirectoryPath}*.Tests.ps1" -Depth $Depth
    Invoke-Pester -Path $files -PassThru
}