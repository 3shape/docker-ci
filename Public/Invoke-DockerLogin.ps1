function Invoke-DockerLogin {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]
        $Username,

        [Parameter(Mandatory = $true)]
        [securestring]
        $Password,

        [ValidateNotNullOrEmpty()]
        [string]
        $Registry
    )
    [string] $plaintextPassword = [System.Net.NetworkCredential]::new("", $Password).Password
    $command = "Write-Output `"${plainTextPassword}`" | docker login --username `"${Username}`" --password-stdin ${Registry}".TrimEnd()
    Write-Debug ($command.Replace($plaintextPassword, "*********"))
    [CommandResult] $result = Invoke-Command $command
    $result
}
