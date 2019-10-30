
function StoreMockValue {
    [CmdletBinding()]
    param (
        $Key,
        $Value
    )
    Write-Debug "Asked to store this key, value: ${Key}, ${Value}"
    if ($script:KeyValuePair[$Key]) {
        return
    }

    $script:KeyValuePair.Add($Key, $Value)
}

function Initialize-MockReg {
    Write-Debug "Clear store of values"
    $script:KeyValuePair = @{}
}

function GetMockValue {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]
        $Key
    )
    Write-Debug "Getting this key: '$Key' and value $script:KeyValuePair[$Key]"
    Write-Debug $script:KeyValuePair.Length

    return $script:KeyValuePair[$Key]
}

Export-ModuleMember -Function StoreMockValue
Export-ModuleMember -Function GetMockValue
Export-ModuleMember -Function Initialize-MockReg
