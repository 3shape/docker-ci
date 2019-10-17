pwsh -Command 'Invoke-ScriptAnalyzer -Recurse -EnableExit -Path ./Public'
$resultForPublicCode = $lastexitcode
pwsh -Command 'Invoke-ScriptAnalyzer -Recurse -EnableExit -Path ./Private'
$resultForPrivateCode = $lastexitcode
exit ($resultForPublicCode + $resultForPrivateCode)
