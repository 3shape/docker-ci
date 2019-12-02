function Invoke-DockerTag {
    [CmdletBinding(PositionalBinding = $false)]
    param (
        [Parameter(mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 0)]
        [String]
        $ImageName,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [String]
        $Registry = '',

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
        $Quiet = [System.Convert]::ToBoolean($env:DOCKER_CI_QUIET_MODE)
    )

    $postfixedRegistry = Add-Postfix -Value $Registry
    $postfixedNewRegistry = Add-Postfix -Value $NewRegistry
    $source = "${postfixedRegistry}${ImageName}:${Tag}"
    $target = "${postfixedNewRegistry}${NewImageName}:${NewTag}"

    $commandResult = Invoke-DockerCommand "tag ${source} ${target}"
    Assert-ExitCodeOk $commandResult
    $result = [PSCustomObject]@{
        'Registry'      = $postfixedNewRegistry
        'ImageName'     = $NewImageName
        'Tag'           = $NewTag
        'CommandResult' = $commandResult
    }
    if (!$Quiet) {
        Write-CommandOuput ("tagged ${source} as ${target}")
    }
    return $result
}
