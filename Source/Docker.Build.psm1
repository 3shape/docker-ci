#Requires -Version 6

$Public = @( Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -ErrorAction SilentlyContinue )
$Private = @( Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -ErrorAction SilentlyContinue )

Foreach ($import in @($Public + $Private)) {
    Try {
        Write-Debug "Importing ${import}"
        . $import.fullname # Rewrite to bundle all in scriptblock so types do don't go out of scope.
    } Catch {
        Write-Error -Message "Failed to import function $($import.fullname): $_"
    }
}
Export-ModuleMember -Function $Public.Basename
