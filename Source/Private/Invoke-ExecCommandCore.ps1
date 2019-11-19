#   Borrowed from our friendly provider: https://github.com/dotnet/roslyn/blob/master/src/Setup/Installer/tools/utils.ps1

function Invoke-ExecCommandCore {
    param (
        [Parameter(mandatory = $true)]
        [string] $Command,
        [string] $CommandArgs,
        [switch] $PassThru = $true
    )

    $result = [CommandCoreResult]::new()
    $result.Command = $Command
    $result.CommandArgs = $CommandArgs
    $result.ExitCode = -1

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
            $result.Output += $outLine

            if ($PassThru) {
                Write-Information -InformationAction 'Continue' -MessageData $outLine
            }
        }
        $err = $process.StandardError
        while (-not $err.EndOfStream) {
            $errLine = $err.ReadLine()
            $result.Output += $errLine

            if ($PassThru) {
                Write-Information -InformationAction 'Continue' -MessageData $errLine
            }
        }

        while (-not $process.WaitForExit(100)) {
            # Non-blocking loop done to allow ctr-c interrupts
        }

        $finished = $true
    }
    finally {

        # If we didn't finish then an error occurred or the user hit ctrl-c.  Either
        # way kill the process
        if ((Get-Variable -Name 'finished' -ErrorAction 'Ignore') -and -not $finished) {
            #   Only kill when finish is $false and the process did not already exit.
            if (!$process.HasExited) {
                $process.Kill()
            }
        }
        $result.ExitCode = $process.ExitCode
    }
    return $result
}
