##################################################################################################################
## Azure Cognitive Services - Voice Recognition 
## This is a simple test of Azure Cognitive Services rest apis
##
## Inputs for this file are:
##      - $cogSubscriptionKey - This is an access key from your Azure cognitive services subscription
##      - $cogWavFile - The path and name of a wave file containing the verification phrase
##      - $cogLocale - The language locale for your verification phrase
##################################################################################################################


param (
[string] $cogSubscriptionKey = $(throw "Provide your Azure Cognitive Services subscription services access key."),
[string] $cogWavFile =$(throw "Provide path and name to a WAV file containing the verification phrase."),
[string] $cogLocale=$(throw "Provide the locale of the verification phrase (en-us or ")
)


# define the base URI for cognitive services speaker recognition and verification apis
$cogUrl="https://westus.api.cognitive.microsoft.com/spid/v1.0"

##########################################################################################################
## Create a profile
##########################################################################################################

# Build the verificationProfiles end point
$cogProfileUrl = $cogUrl + "/verificationProfiles"


# Define the header for creating the profile
$cprofileHeader = @{}
$cprofileHeader.Add( "Content-Type","application/json")
$cprofileHeader.Add( "Ocp-Apim-Subscription-Key",$cogSubscriptionKey)

# Define the body for the message
$cprofileBody = "{'locale':'$cogLocale'}"


# Call the rest method, which returns the profile ID
$cogProfileID = Invoke-RestMethod $cogProfileUrl -Headers $cprofileHeader -Body $cprofileBody -Method Post

if ($cogProfileID.verificationProfileId -eq '')
{
write-host $Error
exit
}

#########################################################################################################
## Create enrollment
#########################################################################################################

# Build the endpoint URL for enrollment
$cogEnrollUrl = $cogProfileUrl + "/" + $cogProfileID.verificationProfileId +"/enroll"

# Update the content-type for the header (use the same header)
$cprofileHeader.'Content-Type'="multipart/form-data"

# Create the Enrollment by uploading the wav file
# The service requires 3 enrollments so uploading the same file 3 times for this test
$cogEnrollID = Invoke-RestMethod $cogEnrollUrl -Headers $cprofileHeader -Infile $cogWavFile -Method Post
$cogEnrollID = Invoke-RestMethod $cogEnrollUrl -Headers $cprofileHeader -Infile $cogWavFile -Method Post
$cogEnrollID = Invoke-RestMethod $cogEnrollUrl -Headers $cprofileHeader -Infile $cogWavFile -Method Post

########################################################################################################
## Verify a speaker
########################################################################################################


# Build the endpoint URL for verification
$cogVerifyUrl = $cogUrl + "/verify?verificationProfileId=" + $cogProfileID.verificationProfileId

# Call the rest endpoint, returning the verification results
$cogVerifyResults = Invoke-RestMethod $cogVerifyUrl -Headers $cprofileHeader -Infile .\Houston2.wav -Method Post

# Return the verification results, confidence level, and the actual verification phrase

$cogVerifyResults.result
$cogVerifyResults.confidence
$cogVerifyResults.phrase
