function Invoke-DockerTag {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $Registry,

        [Parameter(mandatory=$true, ValueFromPipelineByPropertyName = $true)]
        [String]
        $ImageName,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $Tag = 'latest',

        [ValidateNotNullOrEmpty()]
        [String]
        $NewRegistry = $global:DockerPublicRegistry,

        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName = $true)]
        [String]
        $NewImageName,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $NewTag = 'latest'
    )

    $postfixedRegistry = Add-Postfix -Value $Registry
    $postfixedNewRegistry = Add-Postfix -Value $NewRegistry
    $source = "${postfixedRegistry}${ImageName}:${Tag}"
    $target = "${postfixedNewRegistry}${NewImageName}:${NewTag}"

    $commandResult = Invoke-Command "docker tag ${source} ${target}"
    if ($commandResult.Exitcode -ne 0) {
        $message = "An error occured during docker tag. The error message was: ${result.Output}, the exit code was: ${result.Exitcode}"
        Write-Debug "${message}"
        throw "${message}"
    }

    $result = [PSCustomObject]@{
        'Tag' = $NewTag
        'ImageName' = $NewImageName
        'Registry' = $postfixedNewRegistry
        'Result' = $commandResult
    }
    return $result
}
