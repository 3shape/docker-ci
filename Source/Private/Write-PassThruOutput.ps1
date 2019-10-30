function Write-PassThruOuput {
    [CmdletBinding()]
    param (
        [String[]]
        $Message
    )
    foreach ($line in $($Message)) {
        Write-Information $line
    }
}
