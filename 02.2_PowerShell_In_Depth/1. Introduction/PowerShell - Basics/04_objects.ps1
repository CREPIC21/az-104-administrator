# Objects - Custom Objects

$Course = [PSCustomObject]@{
    Id     = 1
    Name   = 'PowerShell Master'
    Rating = 4.7
}
$Course

'The course ID is ' + $Course.Id

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

$CourseList
$CourseList[1].Name