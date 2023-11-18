$NumberOfVideos = 30

# if/else
if ($NumberOfVideos -ge 20) {
    "Greater than 20"
}
else {
    "Less than 20"
}

# while
$i = 1
while ($i -le 10) {
    $i
    ++$i
}

# for
for ($i = 0; $i -lt 10; $i++) {
    $i
}

# foreach
$PowerShellScripts = 'Script01', 'Script02', 'Script03'
foreach ($Script in $PowerShellScripts) {
    $Script
}

$CourseList = @(
    [PSCustomObject]@{
        Id     = 1
        Name   = 'PowerShell Master'
        Rating = 4.7
    },
    [PSCustomObject]@{
        Id     = 2
        Name   = 'Bash Master'
        Rating = 7.7
    },
    [PSCustomObject]@{
        Id     = 3
        Name   = 'Linux Master'
        Rating = 1.7
    }
)
foreach ($Course in $CourseList) {
    $Course.Id
    $Course.Name
    $Course.Rating
}