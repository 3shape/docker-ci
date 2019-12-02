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
    $args = "login --username `"${Username}`" --password-stdin ${Registry}".TrimEnd()
    $maskedCommand = $args.Replace($plaintextPassword, "*********")

    [CommandResult] $commandResult = Invoke-Command 'docker' -CommandArgs $args -InputLines $plaintextPassword

    if (!$Quiet) {
        Write-CommandOuput $($commandResult.Output)
    }

    $commandResult.Command = $maskedCommand
    Assert-ExitCodeOK $commandResult
    return $commandResult
}
