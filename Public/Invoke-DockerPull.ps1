#Requires -PSEdition Core -Version 6

function Invoke-DockerPull {
    [CmdletBinding()]
    param (
        [Parameter(mandatory=$true)]
        [String]
        $Image,
        [ValidateNotNullOrEmpty()]
        [String]
        $Tag = 'latest',
        [ValidateNotNullOrEmpty()]
        [String]
        $ID = ''
    )

    # It is possible to pull by digest / sha, ID. ID supersedes image:tag.
    #   So if ID is present, use ID. If not, pull image:tag
    if ( [string]::IsNullOrEmpty($ID) ) {
        $ID = "${Image}:${Tag}"
    }
    Invoke-Command "docker pull ${ID}"
}
