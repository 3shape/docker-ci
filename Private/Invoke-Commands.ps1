function Invoke-Commands {
    param (
        [ValidateNotNullOrEmpty()]
        [Array] $Commands = @()
    )
    foreach ($command in $Commands.GetEnumerator())
    {
        try {
            $commandWithArgs = $ExecutionContext.InvokeCommand.ExpandString($command)
            $result += (Invoke-Expression "& $command" 2> $null)
        }
        catch {
            $catchedException = $PSItem.Exception
            throw [System.Exception]::new("Could not execute command $commandWithArgs", $catchedException)
        }
        if ((-not $?) -or ($lastexitcode -ne 0)) {
            throw "Error raised while executing: '$commandWithArgs', exit code was $lastexitcode"
        }
    }
    $result
}
