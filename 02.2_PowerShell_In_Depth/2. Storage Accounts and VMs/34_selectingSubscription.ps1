# Define the subscription name
$subscriptionName = "Staging Subscription"

# Retrieve the subscription object matching the specified subscription name
$subscription = Get-AzSubscription -SubscriptionName $subscriptionName

# Set the context of the current session to the retrieved subscription object
Set-AzContext -SubscriptionObject $subscription

# we also gave Contributor role to our App Object using Azure UI
# - https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#contributor

# Start deploying resources in selected subscription
# ..................................................