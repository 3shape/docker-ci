function Read-ChangelogFromTestReport {
    param(
        [ValidateNotNullOrEmpty()]
        [String[]]
        $TestReportPath
    )

    if (Test-Path -Path $testReportPath -PathType Leaf) {
        $result = $(ConvertFrom-Json $(Get-Content $testReportPath -Raw))
        
        $changelog = $result.Results | where { $_.Name -match "Command Test" } | `
            foreach { "$($_.Name.Split(':')[1]): $($_.Stdout)".Replace("`n", "").Replace("`r", "") } | `
            Out-String 

        Write-CommandOuput $changelog
        Write-Output $changelog
    } else {
        Write-CommandOuput "Provided report path does not exists: $testReportPath"
    }
}