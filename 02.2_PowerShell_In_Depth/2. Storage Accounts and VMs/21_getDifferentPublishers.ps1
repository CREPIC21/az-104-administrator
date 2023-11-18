$location = "North Europe"

Get-AzVMImagePublisher -Location $location

$PublisherName = "Canonical"
Get-AzVMImagePublisher -Location $location | Where-Object { $_.PublisherName -eq $PublisherName }

Get-AzVMImageOffer -Location $location -PublisherName $PublisherName

$Offer = "UbuntuServer"

Get-AzVMImageSku -Location $location -PublisherName $PublisherName -Offer $Offer