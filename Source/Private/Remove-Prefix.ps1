function Remove-Prefix {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [String]
        $Value,

        [Parameter(Mandatory = $true)]
        [String]
        $Prefix
    )

    If ($Value.StartsWith($Prefix)) {
        $result = $Value.Substring($Prefix.Length)
        return $result
    }
    else {
        return $Value
    }
}


