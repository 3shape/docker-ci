function Assert-ExitCodeOk {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        $Result
    )
    if ($Result.ExitCode -ne 0) {
        $exception = [System.Exception]::new("The command $($Result.Command) failed. Exit code is: $($Result.ExitCode). The output from the command is $($Result.Output)")
        $exceptionId = '1000'
        $errorCategory = [System.Management.Automation.ErrorCategory]::InvalidResult
        $errorRecord = [System.Management.Automation.ErrorRecord]::new($exception, $exceptionId, $errorCategory, $PSItem)

        $PSCmdlet.ThrowTerminatingError($errorRecord)
    }
}
