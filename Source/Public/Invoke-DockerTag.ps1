function Invoke-DockerTag {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [String]
        $Registry = '',

        [Parameter(mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [String]
        $ImageName,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $Tag = 'latest',

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [String]
        $NewRegistry = '',

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [String]
        $NewImageName,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $NewTag = 'latest',

        [Switch]
        $Quiet = [System.Convert]::ToBoolean($env:DOCKER_POSH_QUIET_MODE)
    )

    $postfixedRegistry = Add-Postfix -Value $Registry
    $postfixedNewRegistry = Add-Postfix -Value $NewRegistry
    $source = "${postfixedRegistry}${ImageName}:${Tag}"
    $target = "${postfixedNewRegistry}${NewImageName}:${NewTag}"

    $commandResult = Invoke-Command "docker tag ${source} ${target}"
    Assert-ExitCodeOk $commandResult
    $result = [PSCustomObject]@{
        'Registry'      = $postfixedNewRegistry
        'ImageName'     = $NewImageName
        'Tag'           = $NewTag
        'CommandResult' = $commandResult
    }
    if (!$Quiet) {
        Write-CommandOuput $($commandResult.Output)
    }
    return $result
}
