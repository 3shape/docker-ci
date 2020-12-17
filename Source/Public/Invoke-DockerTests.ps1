function Invoke-DockerTests {
    [CmdletBinding(PositionalBinding = $false)]
    param (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 0)]
        [String]
        $ImageName,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [String[]]
        $ConfigPath = (Format-AsAbsolutePath (Get-Location)),

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
    $allYamlFiles = '*.y*ml'
    $configFiles = (Get-ChildItem -Recurse -Path $ConfigPath -Filter $allYamlFiles | Select-Object FullName | ForEach-Object { $_.FullNAme })

    if (0 -eq $configFiles.Length) {
        throw [System.ArgumentException]::new("No yaml files found at ${ConfigPath}, did you point to a directory with config files?")
    }

    $here = Format-AsAbsolutePath (Get-Location)
    $hereOnDockerHost = Convert-ToDockerHostPath $here
    $absoluteTestReportDir = Format-AsAbsolutePath ($TestReportDir)
    if (!(Test-Path $absoluteTestReportDir -PathType Container)) {
        New-Item $absoluteTestReportDir -ItemType Directory -Force | Out-Null
    }
    $absoluteTestReportDirOnDockerHost = Convert-ToDockerHostPath $absoluteTestReportDir
    $osType = Find-DockerOSType
    $dockerSocket = Find-DockerSocket -OsType $osType
    if ($osType -ieq 'windows') {
        $configs = 'C:/configs'
        $report = 'C:/report'
    } else {
        $configs = '/configs'
        $report = '/report'
    }
    $structureCommand = "run -i" + `
        " -v `"${hereOnDockerHost}:${configs}`"" + `
        " -v `"${absoluteTestReportDirOnDockerHost}:${report}`"" + `
        " -v `"${dockerSocket}:${dockerSocket}`"" + `
        " 3shape/containerized-structure-test:latest test -i ${ImageName} --test-report ${report}/${TestReportName}"

    $configFiles.ForEach( {
            $relativePath = Resolve-Path -Path $_ -Relative
            $configFile = Convert-ToUnixPath ($relativePath)
            $configName = Remove-Prefix -Value $configFile -Prefix './'
            $structureCommand = -join ($structureCommand, " -c ${configs}/${configName}")
        }
    )

    $commandResult = Invoke-DockerCommand $structureCommand
    if ($TreatTestFailuresAsExceptions) {
        Assert-ExitCodeOk $commandResult
    }

    $testReportPath = Join-Path $absoluteTestReportDir $TestReportName
    $testReportExists = Test-Path -Path $testReportPath -PathType Leaf
    if ($testReportExists) {
        $testResult = $(ConvertFrom-Json $(Get-Content $testReportPath))
    }

    $result = [PSCustomObject]@{
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
