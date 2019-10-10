function Invoke-Command {
    [CmdletBinding()]
    param (
        [Parameter(mandatory=$true)]
        [string]
        $Command
    )

    $result = [CommandResult]::new()
    Write-Debug "Executing command: ${Command}"
    $outputs = Invoke-Expression "& $Command 2>&1"
    $result.Success = $?
    $result.ExitCode = $lastexitcode
    $result.Output = $outputs

    return $result
}