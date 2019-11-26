. "$PSScriptRoot\..\Private\Write-PassThruOutput.ps1"

function Invoke-DockerLogin {
    [CmdletBinding(PositionalBinding = $false)]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [String]
        $Username,

        [Parameter(Mandatory = $true, Position = 1)]
        [Securestring]
        $Password,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [String]
        $Registry,

        [Switch]
        $Quiet = [System.Convert]::ToBoolean($env:DOCKER_CI_QUIET_MODE)
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
