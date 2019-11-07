
function Invoke-DockerCommand {
    param (
        [Parameter(mandatory = $true)]
        [string] $CommandArgs,
        [switch] $ShowInProgressOutput = $true
    )
    $result = Invoke-ExecCommandCore -Command 'docker' -CommandArgs $CommandArgs -ShowInProgressOutput:$ShowInProgressOutput
    return $result
}

#   Borrowed from our friendly provider: https://github.com/dotnet/roslyn/blob/master/src/Setup/Installer/tools/utils.ps1

function Invoke-ExecCommandCore {
    param (
        [Parameter(mandatory = $true)]
        [string] $Command,
        [string] $CommandArgs,
        [switch] $ShowInProgressOutput = $true
    )

    $result = [CommandCoreResult]::new()
    $result.Command = $Command
    $result.CommandArgs = $CommandArgs

    $startInfo = New-Object System.Diagnostics.ProcessStartInfo
    $startInfo.FileName = $Command
    $startInfo.Arguments = $CommandArgs

    $startInfo.UseShellExecute = $false
    $startInfo.WorkingDirectory = Get-Location

    #   Always redirect output
    $startInfo.RedirectStandardOutput = $true
    $startInfo.RedirectStandardError = $true
    $startInfo.CreateNoWindow = $true

    $process = New-Object System.Diagnostics.Process
    $process.StartInfo = $startInfo

    try {
        $process.Start() | Out-Null

        $finished = $false
        # The OutputDataReceived event doesn't fire as events are sent by the
        # process in powershell.  Possibly due to subtleties of how Powershell
        # manages the thread pool that I'm not aware of.  Using blocking
        # reading here as an alternative which is fine since this blocks
        # on completion already.
        $out = $process.StandardOutput
        while (-not $out.EndOfStream) {
            $outLine = $out.ReadLine()
            $result.StdOut += $outLine

            if ($ShowInProgressOutput) {
                Write-Information -InformationAction 'Continue' -MessageData $outLine
            }
        }
        $err = $process.StandardError
        while (-not $err.EndOfStream) {
            $errLine = $err.ReadLine()
            $result.StdErr += $errLine

            if ($ShowInProgressOutput) {
                Write-Information -InformationAction 'Continue' -MessageData $errLine
            }
        }

        while (-not $process.WaitForExit(100)) {
            # Non-blocking loop done to allow ctr-c interrupts
        }

        $finished = $true
        $result.ExitCode = $process.ExitCode

        #   Dont' bail on failure
        # if ($process.ExitCode -ne 0) {
        #     throw "Command failed to execute: $Command $CommandArgs"
        # }
    }
    #   Catch the exception and process the output
    # catch [System.Management.Automation.MethodInvocationException] {
    #     $finished = $true
    #     $exception = $_.Exception
    #     if ($null -ne $_.Exception.InnerException) {
    #         $exception = $_.Exception.InnerException
    #     }
    #     if ($ShowInProgressOutput) {
    #         Write-Error -InformationAction 'SilentlyContinue' -Exception $exception
    #     }
    #     if ($null -eq $result.StdErr) {
    #         $result.StdErr += $exception.Message
    #     }
    #     if ($result.ExitCode -eq 0) {
    #         $result.ExitCode = $exception.ErrorCode
    #     }
    # }
    finally {
        # If we didn't finish then an error occurred or the user hit ctrl-c.  Either
        # way kill the process
        if ((Get-Variable -Name 'finished' -ErrorAction 'SilentlyContinue') -and -not $finished) {
            $process.Kill()
        }
    }
    return $result
}
