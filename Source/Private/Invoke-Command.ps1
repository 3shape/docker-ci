# Copied from here: https://github.com/dotnet/roslyn/blob/master/src/Setup/Installer/tools/utils.ps1

function Invoke-Command {
    [CmdletBinding(PositionalBinding = $false)]
    param (
        [Parameter(mandatory = $true, Position = 0)]
        [String] $Command,

        [Parameter(Position = 1)]
        [String]
        $CommandArgs = '',

        [Switch]
        $Quiet = [System.Convert]::ToBoolean($env:DOCKER_CI_QUIET_MODE)
    )

    $result = [CommandCoreResult]::new()
    $result.Command = $Command
    $result.CommandArgs = $CommandArgs
    $result.ExitCode = -1

    [System.Diagnostics.Process] $process = New-Process -Command $Command -Arguments $CommandArgs -WorkingDirectory (Get-Location)

    try {
        $oStdOutBuilder = [System.Text.StringBuilder]::new()
        $oStdErrBuilder = [System.Text.StringBuilder]::new()

        $finished = $false

        $eventHandlerSource = 'if (! [String]::IsNullOrEmpty($EventArgs.Data)) {
                $Event.MessageData.AppendLine($EventArgs.Data)
                if ($WriteLogging) {
                    Write-Information -InformationAction "Continue" -MessageData $EventArgs.Data
                }
            }'
        $eventHandlerSource = $eventHandlerSource.Replace("WriteLogging", !$Quiet)

        [scriptblock] $eventHandler = [scriptblock]::Create($eventHandlerSource)
        $sScripBlock = {
            if (! [String]::IsNullOrEmpty($EventArgs.Data)) {
                $Event.MessageData.AppendLine($EventArgs.Data)
                Write-Information -InformationAction 'Continue' -MessageData $EventArgs.Data
            }
        }


        $stdOutEventHandler = Register-ObjectEvent -InputObject $process `
            -Action $eventHandler -EventName 'OutputDataReceived' `
            -MessageData $oStdOutBuilder

        $stdErrEventHandler = Register-ObjectEvent -InputObject $process `
            -Action $eventHandler -EventName 'ErrorDataReceived' `
            -MessageData $oStdErrBuilder

        $process.Start() | Out-Null
        $process.BeginOutputReadLine()
        $process.BeginErrorReadLine()


        while (-not $process.WaitForExit(100)) {
            # Allow interrupts like CTRL + C
        }
        $finished = $true
    } catch {
        Write-Debug 'bad'
    } finally {
        Unregister-Event -SourceIdentifier $stdOutEventHandler.Name
        Unregister-Event -SourceIdentifier $stdErrEventHandler.Name
        # If we didn't finish then an error occurred or the user hit ctrl-c.  Either
        # way kill the process
        if (-not $finished -and -not $process.HasExited) {
            Write-Debug "Cleanup, kill the process with id $($process.Id)"
            $process.Kill()
        }
    }
    $result.Output = $oStdOutBuilder.ToString().Trim()
    $errors = $oStdErrBuilder.ToString().Trim()
    $result.ExitCode = $process.ExitCode
    return $result
}
