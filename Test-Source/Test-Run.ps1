$testRuns = 0
$failCount = 0

while ($failCount -eq 0) {
    $testRuns = $testRuns + 1
    $testResult = Invoke-Pester -Script './Invoke-Command.Tests.ps1' -TestName 'Runs only external tools' -PassThru
    $failCount = $($testResult.FailedCount)
}

Write-Output "Test runs before failure: $testRuns"
