# Copied from here: https://github.com/dotnet/roslyn/blob/master/src/Setup/Installer/tools/utils.ps1
. "$PSScriptRoot\Write-PassThruOutput.ps1"
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
        $eventHandlerSource = $eventHandlerSource.Replace("WriteLogging", !$Quiet.IsPresent)

        $stdOutHandlerSource = [ScriptBlock]::Create($eventHandlerSource)
        $stdErrHandlerSource = [ScriptBlock]::Create($eventHandlerSource)

        $stdOutEventHandler = Register-ObjectEvent -InputObject $process `
            -Action $stdOutHandlerSource -EventName 'OutputDataReceived' `
            -MessageData $stdOutMessages

        $stdErrEventHandler = Register-ObjectEvent -InputObject $process `
            -Action $stdErrHandlerSource -EventName 'ErrorDataReceived' `
            -MessageData $stdErrMessages

        $process.Start() | Out-Null

        $process.BeginOutputReadLine()
        $process.BeginErrorReadLine()

        if ($InputLines) {
            try {
                $inputStream = $process.StandardInput
                $inputStream.AutoFlush = $true
                foreach ($line in $inputLines) {
                    $inputStream.WriteLine($line)
                }
            } finally {
                $process.StandardInput.Close()
            }
        }

        while (-not $process.WaitForExit(100)) {
            # Allow interrupts like CTRL + C by doing a non-blocking wait
        }
        # Allow all async event handlers to finish up by doing a blocking wait, then free up the resources
        # associated with that process on OS level.
        $process.WaitForExit()
        $processId = $process.Id
        $result.ExitCode = $process.ExitCode
        $process.Close()

        $finished = $true
    } finally {
        Unregister-Event -SourceIdentifier $stdOutEventHandler.Name
        Unregister-Event -SourceIdentifier $stdErrEventHandler.Name
        # If we didn't finish then an error occurred or the user hit ctrl-c. Either
        # way kill the process
        try {
            if (-not $finished -or -not ($process.HasExited -ne $false -and $process.HasExited -ne $true)) {
                if (!$Quiet.IsPresent) {
                    Write-CommandOuput $message
                }
                if ($null -ne $process) {
                    $message = "Cleanup, kill the process with id $processId"
                    Write-Debug $message
                    $process.Kill()
                }
            }
        } catch {
            # This can happen if the process was never started in which case WaitForExit or HasExited throws an exception.
            $message = "Exception caught while trying to kill process id $processId, exception: $_"
            Write-Debug $message
            if (!$Quiet.IsPresent) {
                Write-CommandOuput $message
            }
        }
    }
    $result.StdOut = $stdOutMessages.ToArray()
    $result.StdErr = $stdErrMessages.ToArray()
    $result.Output = $stdOutMessages.ToArray() + $stdErrMessages.ToArray()
    return $result
}
