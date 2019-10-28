function Invoke-DockerTests {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [String]
        $ImageName,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [String[]]
        $ConfigFiles = ((Get-ChildItem -Path . -Filter *.y*ml | Select-Object Name) | ForEach-Object { $_.Name }),

        [ValidateNotNullOrEmpty()]
        [String]
        $TestReportDir = $(New-RandomFolder),

        [ValidateNotNullOrEmpty()]
        [String]
        $TestReportName = 'testreport.json',

        [Switch]
        $TreatTestFailuresAsExceptions = $false
    )
    if ($null -eq $ConfigFiles -or $ConfigFiles.Length -eq 0) {
        throw [System.ArgumentException]::new('$ConfigFiles must contain one more test configuration file paths.')
    }

    $here = Format-AsAbsolutePath (Get-Location)
    $structureCommand = "docker run -i" + `
        " -v ${here}:/configs" + `
        " -v `"${TestReportDir}:/report`"" + `
        " -v /var/run/docker.sock:/var/run/docker.sock" + `
        " containerized-structure-test test -i ${ImageName} --test-report /report/${TestReportName}"

    $ConfigFiles.ForEach( {
            $configFile = Convert-ToUnixPath (Resolve-Path -Path $_  -Relative)
            $configName = Remove-Prefix -Value $configFile -Prefix './'
            $structureCommand = -join ($structureCommand, " -c /configs/${configName}")
        }
    )
    $commandResult = Invoke-Command $structureCommand
    if ($TreatTestFailuresAsExceptions) {
        Assert-ExitCodeOk $commandResult
    }

    $testReportPath = Join-Path $TestReportDir $TestReportName

    $result = [PSCustomObject]@{
        TestResult     = $(ConvertFrom-Json $(Get-Content $testReportPath))
        TestReportPath = $testReportPath
        Result         = $commandResult
        ImageName      = $ImageName
    }
    return $result
}
