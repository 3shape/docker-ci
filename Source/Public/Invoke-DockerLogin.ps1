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
    Write-Debug ($command.Replace($plaintextPassword, "*********"))
    [CommandResult] $commandResult = Invoke-Command $command
    if ($PassThru) {
        Write-PassThruOuput $($commandResult.Output)
    }
    Assert-ExitCodeOK $commandResult
    return $commandResult
}
