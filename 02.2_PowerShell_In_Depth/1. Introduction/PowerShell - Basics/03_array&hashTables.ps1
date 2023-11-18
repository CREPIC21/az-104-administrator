# Array
$PowerShellScripts = 'Script01', 'Script02', 'Script03'
$PowerShellScripts

$PowerShellScripts_1 = @('Script04', 'Script05', 'Script06')
$PowerShellScripts_1
$PowerShellScripts_1[0]

$PowerShellScripts_1[1] = 'Script07'
$PowerShellScripts_1

# Hash tables - Key/Values
$ServerNames = @{
    Development = 'Server01'
    Testing     = 'Server02'
    Production  = 'Server03'
}
$ServerNames['Development']
$ServerNames.Testing

$ServerNames.Add('QA', 'Server04')
$ServerNames