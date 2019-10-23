. "$PSScriptRoot\LintRemark.ps1"

function Merge-CodeAndLintRemarks {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [String[]]
        $CodeLines,

        [LintRemark[]]
        $LintRemarks
    )
    [string[]] $result = @()

    $codeIndex = 0
    $lintIndex = 0
    while ($lintIndex -lt $LintRemarks.Length) {
        $codeLineRemarked = $LintRemarks[$lintIndex].LineNumber
        while ($codeIndex -lt ($codeLineRemarked - 1)) {
            $line = [string] ($codeIndex + 1) + ": " + $CodeLines[$codeIndex]
            $result += $line.TrimEnd()
            $codeIndex++
        }
        while ($lintIndex -lt $LintRemarks.Length -and $LintRemarks[$lintIndex].LineNumber -eq $codeLineRemarked) {
            $line = $LintRemarks[$lintIndex].LintRule + " " + $LintRemarks[$lintIndex].Explanation
            $result += $line.TrimEnd()
            $lintIndex++
        }
    }

    while ($codeIndex -lt $CodeLines.Length) {
        $line = [string] ($codeIndex + 1) + ": " + $CodeLines[$codeIndex]
        $result += $line.TrimEnd()
        $codeIndex++
    }
    return $result
}
