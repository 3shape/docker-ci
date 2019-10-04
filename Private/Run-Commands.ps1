function Run-Commands {
    param (
        [ValidateNotNullOrEmpty()]
        [Array] $Commands = @()
    )
    $result = $null
    foreach ($command in $Commands.GetEnumerator())
    {
        $result += (Invoke-Expression "& $command" 2> $null)
        if ((-not $?) -or ($lastexitcode -ne 0)) {
            $commandName = $ExecutionContext.InvokeCommand.ExpandString($command)
            throw "Error raised while executing: $commandName, exit code was $lastexitcode"
        }
    }
    $result
}

