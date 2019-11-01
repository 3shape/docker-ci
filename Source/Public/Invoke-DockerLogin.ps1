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
        $PassThru
    )
    [String] $plaintextPassword = [System.Net.NetworkCredential]::new("", $Password).Password
    $command = "Write-Output `"${plainTextPassword}`" | docker login --username `"${Username}`" --password-stdin ${Registry}".TrimEnd()
    $maskedCommand = $command.Replace($plaintextPassword, "*********")
    Write-Debug ($maskedCommand)
    [CommandResult] $commandResult = Invoke-Command $command
    if ($PassThru) {
        Write-PassThruOuput $($commandResult.Output)
    }
    # Mask password from being shown
    $maskedCommandResult = $commandResult
    $maskedCommandResult.Command = $maskedCommand
    Assert-ExitCodeOK $maskedCommandResult
    return $commandResult
}
