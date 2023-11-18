# Functions

function Get-Appversion {
    $PSVersionTable 
}

Get-Appversion

function Add-Integers([int]$x, [int]$y) {
    'The sum is: ' + ($x + $y)
}

Add-Integers 3 5


function Get-Course {
    param (
        [Object[]] $ScriptList
    )
    foreach ($Script in $ScriptList) {
        $Script
    }
    
}

$PowerShellScripts = 'Script01', 'Script02', 'Script03'

Get-Course $PowerShellScripts