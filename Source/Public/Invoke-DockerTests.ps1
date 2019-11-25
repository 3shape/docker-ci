function Invoke-DockerTests {
    [CmdletBinding(PositionalBinding = $false)]
    param (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 0)]
        [String]
        $ImageName,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [String[]]
        $ConfigFiles = ((Get-ChildItem -Path . -Filter *.y*ml | Select-Object Name) | ForEach-Object { $_.Name }),

        [ValidateNotNullOrEmpty()]
        [String]
        $TestReportDir = '.',

        [ValidateNotNullOrEmpty()]
        [String]
        $TestReportName = 'testreport.json',

        [Switch]
        $TreatTestFailuresAsExceptions = $false,

        [Switch]
        $Quiet = [System.Convert]::ToBoolean($env:DOCKER_CI_QUIET_MODE)
    )
    if ($null -eq $ConfigFiles -or $ConfigFiles.Length -eq 0) {
        throw [System.ArgumentException]::new('$ConfigFiles must contain one more test configuration file paths.')
    }

    $here = Format-AsAbsolutePath (Get-Location)
    $absoluteTestReportDir = Format-AsAbsolutePath ($TestReportDir)
    if (!(Test-Path $absoluteTestReportDir -PathType Container)) {
        New-Item $absoluteTestReportDir -ItemType Directory -Force | Out-Null
    }
    $osType = Find-DockerOSType
    $dockerSocket = Find-DockerSocket -OsType $osType
    if ($osType -ieq 'windows') {
        $configs = 'C:/configs'
        $report = 'C:/report'
    } else {
        $configs = '/configs'
        $report = '/report'
    }
    $structureCommand = "docker run -i" + `
        " -v `"${here}:${configs}`"" + `
        " -v `"${absoluteTestReportDir}:${report}`"" + `
        " -v `"${dockerSocket}:${dockerSocket}`"" + `
        " 3shape/containerized-structure-test:latest test -i ${ImageName} --test-report ${report}/${TestReportName}"

    $ConfigFiles.ForEach( {
            $configFile = Convert-ToUnixPath (Resolve-Path -Path $_  -Relative)
            $configName = Remove-Prefix -Value $configFile -Prefix './'
            $structureCommand = -join ($structureCommand, " -c ${configs}/${configName}")
        }
    )
    $commandResult = Invoke-Command $structureCommand
    if ($TreatTestFailuresAsExceptions) {
        Assert-ExitCodeOk $commandResult
    }

    $testReportPath = Join-Path $absoluteTestReportDir $TestReportName
    $testReportExists = Test-Path -Path $testReportPath -PathType Leaf
    if ($testReportExists) {
        $testResult = $(ConvertFrom-Json $(Get-Content $testReportPath))
    }

    $result = [PSCustomObject]@{
        # Todo: Need to check if the test report folder is missing.
        # It should not crash when folder is not there, but should simply return nothing
        'TestResult'     = $testResult
        'TestReportPath' = $testReportPath
        'CommandResult'  = $commandResult
        'ImageName'      = $ImageName
    }
    if (!$Quiet) {
        Write-CommandOuput $($result.TestResult)
    }
    return $result
}
