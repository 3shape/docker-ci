

function StoreMockValue {
    [CmdletBinding()]
    param (
        [Parameter()]
        [hashtable]
        $KeyValuePair
    )

    $script:KeyValuePair = $KeyValuePair
}

function GetMockValue {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]
        $Key
    )
    return $script:KeyValuePair[$Key]
}

Export-ModuleMember -Function StoreMockValue
Export-ModuleMember -Function GetMockValue
