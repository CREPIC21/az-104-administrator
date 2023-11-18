$Cars = @(
    [PSCustomObject]@{
        Brand = "BMW"
        Model = "X5"
        Color = @("Red", "Blue", "Yellow")
        Seats = @(
            @{
                Amount = 5
                Color  = "Black"
            },
            @{
                Amount = 7
                Color  = "Green"
            }
        )
    },
    [PSCustomObject]@{
        Brand = "Opel"
        Model = "Corsa"
        Color = @("Pink", "Blue")
        Seats = @(
            @{
                Amount = 2
                Color  = "Black"
            },
            @{
                Amount = 1
                Color  = "Green"
            }
        )
    }
)
$Cars
$Cars[0].Seats

$Cars | Where-Object { $_.Model -eq "X5" } | Select-Object -Property Model

$Cars[0].Seats.Item(0)

foreach ($Seat in $Cars[0].Seats) {
    $Seat.Color
}