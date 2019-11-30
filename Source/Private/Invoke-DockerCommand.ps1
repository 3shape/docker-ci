function Invoke-DockerCommand {
    [CmdletBinding(PositionalBinding = $false)]
    param (
        [Parameter(Position = 0)]
        [String]
        $CommandArgs = '',

        [String[]]
        $InputLines,

        [Switch]
        $Quiet = [System.Convert]::ToBoolean($env:DOCKER_CI_QUIET_MODE)
    )
    return Invoke-Command -Command 'docker' -CommandArgs $CommandArgs -Quiet:$Quiet -InputLines $InputLines
}
