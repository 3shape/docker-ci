function Write-TestResults {
    param(
        [ValidateNotNullOrEmpty()]
        [String]
        $TestReportPath,
    
        [ValidateNotNullOrEmpty()]
        $CommandResult,
    
        [Switch]
        $TreatTestFailuresAsExceptions = $false,
    
        [Switch]
        $Quiet = $false
    )

    if ((Test-Path -Path $testReportPath -PathType Leaf) -and !$Quiet) {
        $result = $(ConvertFrom-Json $(Get-Content $testReportPath))
    
        Write-CommandOuput $($result)
        Write-CommandOuput $($result.Results | where { !$_.Pass } | select Name, @{Label = "Error"; Expression = { $_.Errors -join "`r`n" } })
    }
    
    if ($TreatTestFailuresAsExceptions) {
        Assert-ExitCodeOk $commandResult
    }
}