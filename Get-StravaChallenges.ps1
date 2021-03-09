[CmdletBinding()]
param (
	# Starting number
	[Parameter(Mandatory = $false)]
	[int] $StartNumber = 2200,
	# End number
	[Parameter(Mandatory = $false)]
	[int] $EndNumber = 2800,
	# Credentials for Strava
	[Parameter(Mandatory = $false)]
	[System.Management.Automation.PSCredential]
	[System.Management.Automation.Credential()]
	$Credential = (Get-Credential -Message "Credentials for your Strava account"),
	# Activities is a filter string for the list of activities. Defaults to Ride
	[Parameter(Mandatory = $false)]
	[string] $Activity = "Ride"
)
$ErrorActionPreference = "Stop"

$numbers = $StartNumber..$EndNumber

# Login with account
$session = $null
$loginResp = Invoke-WebRequest -Uri "https://www.strava.com/login" -SessionVariable "session"
$loginSegments = [regex]::Match($loginResp.Content, 'name="authenticity_token" value="(.*?)"').Groups[1]
$loginBody = @{
	utf8               = "%E2%9C%93"
	authenticity_token = $loginSegments.Value
	plan               = ""
	email              = $Credential.UserName
	password           = $Credential.GetNetworkCredential().Password
}
$sessResp = Invoke-WebRequest -Method Post -Uri "https://www.strava.com/session" -Body $loginBody -WebSession $session

$numbers | ForEach-Object -Parallel {
	try {
		$resp = Invoke-WebRequest -Uri ("https://www.strava.com/challenges/{0}" -f $_) -WebSession $using:session -MaximumRedirection 0 -ErrorAction "Continue"
		$segments = [regex]::Match($resp.Content, ' data-react-props="({.*?})">')
		$data = [System.Web.HttpUtility]::HtmlDecode($segments.Groups[1]) | ConvertFrom-Json -Depth 20
	}
	catch {
		Continue
	}

	if (!$data.ended -and $resp.Content -like ("*Qualifying Activities:*{0}*" -f $Activity)) { 
		[PSCustomObject]@{
			ChallengeID = $_
			URL         = ("https://www.strava.com/challenges/{0}" -f $_)
			Cycling     = $resp.Content -like ("*Qualifying Activities:*{0}*" -f $Activity)
			Ended       = $data.ended
			Joined      = $data.joined
			Completed   = $data.completed
		}
	}
} -ThrottleLimit 20