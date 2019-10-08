Invoke-Psake -buildFile Build.ps1 -taskList build,test
exit ( [int]( -not $psake.build_success ) )
