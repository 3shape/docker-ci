. "$PSScriptRoot\..\Private\Write-PassThruOutput.ps1"

function Invoke-DockerLogin {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [String]
        $Username,

        [Parameter(Mandatory = $true)]
        [Securestring]
        $Password,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [String]
        $Registry,

        [Switch]
        $Quiet = [System.Convert]::ToBoolean($env:DOCKER_POSH_QUIET_MODE)
    )
    [String] $plaintextPassword = [System.Net.NetworkCredential]::new("", $Password).Password
    $command = "Write-Output `"${plainTextPassword}`" | docker login --username `"${Username}`" --password-stdin ${Registry}".TrimEnd()
    $maskedCommand = $command.Replace($plaintextPassword, "*********")
    Write-Debug ($maskedCommand)
    [CommandResult] $commandResult = Invoke-Command $command
    if (!$Quiet) {
        Write-CommandOuput $($commandResult.Output)
    }
    # Mask password from being shown
    $commandResult.Command = $maskedCommand
    Assert-ExitCodeOK $commandResult
    return $commandResult
}
