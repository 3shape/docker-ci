function Invoke-DockerLogin {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [String]
        $Username,

        [Parameter(Mandatory = $true)]
        [Securestring]
        $Password,

        [ValidateNotNullOrEmpty()]
        [String]
        $Registry
    )
    [String] $plaintextPassword = [System.Net.NetworkCredential]::new("", $Password).Password
    $command = "Write-Output `"${plainTextPassword}`" | docker login --username `"${Username}`" --password-stdin ${Registry}".TrimEnd()
    Write-Debug ($command.Replace($plaintextPassword, "*********"))
    [CommandResult] $commandResult = Invoke-Command $command
    Assert-ExitCodeOK $commandResult
    return $commandResult
}
