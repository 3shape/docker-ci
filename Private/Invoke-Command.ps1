function Invoke-Command {
    [CmdletBinding()]
    param (
        [Parameter(mandatory=$true)]
        [string]
        $Command
    )

    try {
        $result = [CommandResult]::new()
        $output = Invoke-Expression "& $Command" 2> $null
        $result.ExitCode = $lastexitcode
        $result.Success = $?
        $result.Output = $output
    } catch {
        $PSCmdlet.ThrowTerminatingError($PSItem)
    }
    return $result
}
