# Get 0365 Credentials
$credential=Get-Credential

# Connect to 0365
Connect-MsolService -Credential $credential


# Install SFBO module (if not importanted)
if ((Get-Module | where Name -eq 'SkypeOnlineconnector').Name -eq 'SkypeOnlineConnector') {
    Import-Module SkypeOnlineConnector
    }

# connect to SFBO
# Create a remote session
$sfboSession = New-CsOnlineSession -Credential $credential

# Import the remote session
Import-PSSession $sfboSession

# Get the supported languages and voices
Get-CsOrganizationalAutoAttendantsupportedlanguage 

# Get the supported voices for a language
$language = Get-CsOrganizationalAutoAttendantsupportedlanguage -Identity "en-US"

# Get a specific voice

$myVoice = $language.Voices | Where Name -eq 'Benjamin'

# Get your autoattendants
Get-CsOrganizationalAutoAttendant

pause

# Get a specific autoattendant
$oaa=Get-CsOrganizationalAutoAttendant -PrimaryUri "sip:oaa_uri@mycompany.com"

# Set the voice for your autoattendant
$oaa.VoiceId = $myVoice


$oaa.VoiceId 
 