# Define the location for the Azure resources
$location = "North Europe"

# Retrieve available VM image publishers in the specified location
Get-AzVMImagePublisher -Location $location

# Define the publisher name for the VM image
$PublisherName = "Canonical"

# Retrieve VM image publishers filtered by the specified publisher name and location
Get-AzVMImagePublisher -Location $location | Where-Object { $_.PublisherName -eq $PublisherName }

# Retrieve available VM image offers from the specified publisher and location
Get-AzVMImageOffer -Location $location -PublisherName $PublisherName

# Define the offer for the VM image
$Offer = "UbuntuServer"

# Retrieve available VM image SKUs from the specified publisher, offer, and location
Get-AzVMImageSku -Location $location -PublisherName $PublisherName -Offer $Offer
