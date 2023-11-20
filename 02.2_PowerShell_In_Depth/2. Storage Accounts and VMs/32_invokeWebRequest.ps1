# The URI you want to send a web request to
$uri = "https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/invoke-webrequest?view=powershell-7.3"

# Sending a web request to the specified URI and storing the response object in the $request variable
$request = Invoke-WebRequest -Uri $uri

# Outputting the entire web request response object to the console or output
$request

# Retrieving and outputting only the status code from the web request response
$request.StatusCode
