function Write-CommandOuput {
    [CmdletBinding()]
    param (
        [String[]]
        $Message
    )
    foreach ($line in $($Message)) {
        Write-Information -InformationAction 'Continue' -MessageData $line
    }
}
