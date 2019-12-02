# Copied from here: https://github.com/dotnet/roslyn/blob/master/src/Setup/Installer/tools/utils.ps1

function Invoke-Command {
    [CmdletBinding(PositionalBinding = $false)]
    param (
        [Parameter(mandatory = $true, Position = 0)]
        [String] $Command,

        [Parameter(Position = 1)]
        [String]
        $CommandArgs = '',

        [String[]]
        $InputLines = '',

        [Switch]
        $Quiet = [System.Convert]::ToBoolean($env:DOCKER_CI_QUIET_MODE)
    )

    $result = [CommandResult]::new()
    $result.Command = $Command
    $result.CommandArgs = $CommandArgs
    $result.ExitCode = -1

    [System.Diagnostics.Process] $process = New-Process -Command $Command -Arguments $CommandArgs -WorkingDirectory (Get-Location) -RedirectStdIn

    try {
        $stdOutMessages = New-Object Collections.Generic.List[String]
        $stdErrMessages = New-Object Collections.Generic.List[String]

        $finished = $false

        $eventHandlerSource = 'if (! [String]::IsNullOrEmpty($EventArgs.Data)) {
                $Event.MessageData.Add($EventArgs.Data)
                if ($WriteLogging) {
                    Write-Information -InformationAction "Continue" -MessageData $EventArgs.Data
                }
            }'
        $eventHandlerSource = $eventHandlerSource.Replace("WriteLogging", !$Quiet)

        $eventHandler = [ScriptBlock]::Create($eventHandlerSource)

        $stdOutEventHandler = Register-ObjectEvent -InputObject $process `
            -Action $eventHandler -EventName 'OutputDataReceived' `
            -MessageData $stdOutMessages

        $stdErrEventHandler = Register-ObjectEvent -InputObject $process `
            -Action $eventHandler -EventName 'ErrorDataReceived' `
            -MessageData $stdErrMessages

        $process.Start() | Out-Null

        $process.BeginOutputReadLine()
        $process.BeginErrorReadLine()

        if ($InputLines) {
            $inputStream = $process.StandardInput
            $inputStream.AutoFlush = $true
            foreach ($line in $inputLines) {
                $inputStream.WriteLine($line)
            }
            $process.StandardInput.Close()
        }

        while (-not $process.WaitForExit(100)) {
            # Allow interrupts like CTRL + C
        }
        $finished = $true
    } finally {
        Unregister-Event -SourceIdentifier $stdOutEventHandler.Name
        Unregister-Event -SourceIdentifier $stdErrEventHandler.Name
        # If we didn't finish then an error occurred or the user hit ctrl-c.  Either
        # way kill the process
        try {
            if (-not $finished -and -not $process.HasExited) {
                Write-Debug "Cleanup, kill the process with id $($process.Id)"
                $process.Kill()
            }
        } catch {
            # This can happen if the process was never started in which case HasExited throws an exception.
        }
    }

    $result.StdOut = $stdOutMessages.ToArray()
    $result.StdErr = $stdErrMessages.ToArray()
    $result.Output = $stdOutMessages.ToArray() + $stdErrMessages.ToArray()
    $result.ExitCode = $process.ExitCode
    return $result
}
