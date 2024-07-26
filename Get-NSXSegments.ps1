# NSX-T Manager details
$nsxManager = "https://nsx-manager-ip"  # Replace with your NSX Manager IP or hostname
$username = "your-username"  # Replace with your NSX username
$password = "your-password"  # Replace with your NSX password

# Disable SSL verification (not recommended for production)
[System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}

# Function to get NSX segments
function Get-NsxSegments {
    $url = "$nsxManager/api/v1/segments"
    
    # Create the HTTP request
    $request = [System.Net.HttpWebRequest]::Create($url)
    $request.Credentials = New-Object System.Net.NetworkCredential($username, $password)
    $request.Method = "GET"
    
    try {
        # Get the response
        $response = $request.GetResponse()
        $responseStream = $response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($responseStream)
        $responseBody = $reader.ReadToEnd()
        $reader.Close()
        $responseStream.Close()
        $response.Close()
        
        # Convert JSON response to PowerShell object
        $segments = $responseBody | ConvertFrom-Json
        return $segments
    } catch {
        Write-Error "Failed to retrieve segments: $_"
        return $null
    }
}

# Function to save segments to a JSON file
function Save-SegmentsToFile {
    param (
        [Parameter(Mandatory=$true)]
        [PSObject]$segments,
        
        [Parameter(Mandatory=$true)]
        [string]$filePath
    )
    
    $segments | ConvertTo-Json -Depth 10 | Out-File -FilePath $filePath -Encoding utf8
    Write-Output "Segments have been saved to $filePath"
}

# Main script execution
$segments = Get-NsxSegments
if ($segments) {
    Save-SegmentsToFile -segments $segments -filePath "segments.json"
}
