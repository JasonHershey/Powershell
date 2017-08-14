##################################################################################################################
## Azure Cognitive Services - Facial Recognition 
## This is a simple test of Azure Cognitive Services rest apis for Facial recognition
##
## Inputs for this file are:
##      - $cogSubscriptionKey - This is an access key from your Azure cognitive services subscription
##      - $cogPersonGroupID - ID for people group used to store images to verify against
##      - $cogPersonGroupName - The name of the people group
##      - $cogPerson - The name of the person whose face will be verified
##
## Assumes subfolders containing images required to verify against, and an image to verify
##################################################################################################################


param (
[string] $cogSubscriptionKey = $(throw "Provide your Azure Cognitive Services subscription services access key."),
[string] $cogPersonGroupID=$(throw "Provide an ID for the person group"),
[string] $cogPersonGroupName=$(throw "Provide a name for the person group"),
[string] $cogPerson=$(throw "Provide a name of the person whose image will be verified")

)

## Verify required folders and files exist
if (!(Test-Path ('PersonGroups\' + $cogPersonGroupID.tolower() + '\*.jpg')) -and !(Test-Path 'TestFaces\*.jpg'))
{
write-host 'Required folders or files are missing.'
exit
}


# define the base URI for cognitive services facial recognition apis
$cogUrl="https://westus.api.cognitive.microsoft.com/face/v1.0"

##########################################################################################################
## Create a person group
##########################################################################################################

# Build the person group end point
$cogPGUrl = $cogUrl + "/persongroups/" + $cogPersonGroupID.tolower()


# Define the message header for creating the persongroup
$cogPGHeader = @{}
$cogPGHeader.Add( "Content-Type","application/json")
$cogPGHeader.Add( "Ocp-Apim-Subscription-Key",$cogSubscriptionKey)

# Define the body for the message
$cogPGBody = "{'name':'$cogPersonGroupName'}"

# Create the person group , which returns an empty body
# Common error is that the person group already exists
try
{
$cogPGID = Invoke-RestMethod $cogPGUrl -Headers $cogPGHeader -Body $cogPGBody -Method Put
}
catch
{
    write-host $Error[0]
}
#########################################################################################################
## Add faces to the group
#########################################################################################################


# Build the New Face URI end point
$cogNewFaceUrl = $cogPGUrl + "/persons"

# Define the body for the New Face message
$cogPGBody = "{'name':'$cogPerson'}"

# Create the person returning their personId
$cogPersonID = Invoke-RestMethod $cogNewFaceUrl -Headers $cogPGHeader -body  $cogPGBody -Method Post


# Build the endpoint URI for uploading images of the person
$cogAddFaceUrl = $cogNewFaceUrl + "/" + $cogPersonID.personId + "/persistedFaces"

# Define the content type for uploading the facial images
$cogPGHeader.'Content-Type'="application/octet-stream"

# Load the facial images
foreach ($cogImagefile in (Get-childItem -path ('PeopleGroups\' + $cogPersonGroupID + '\' + $cogPerson) -filter *.jpg))
{
$cogFaceID = Invoke-RestMethod $cogAddFaceUrl -Headers $cogPGHeader -Infile $cogImagefile.FullName  -Method Post
}

########################################################################################################
## Train the group
########################################################################################################

#Build the persongroup URI end point
$cogTrainUrl = $cogPGUrl + "/train"

# Train the gorup
$cogTrainBody = Invoke-RestMethod $cogTrainUrl -Headers $cogPGHeader -Method Post

########################################################################################################
## Detect and verify a face
########################################################################################################

# Build the URI end point for detecting a face
$cogDetFaceUrl = $cogUrl + "/detect?returnFaceId=true"

# Build the URI end point for verifying a face
$cogVerifyFaceUrl = $cogUrl + "/verify"

# Verify images against previously loaded faces
foreach ($cogTestFile in (Get-childItem -path 'TestFaces\' -filter *.jpg))
{
    # Detect the face
    $cogDetFaceIDs = Invoke-RestMethod $cogDetFaceUrl -Headers $cogPGHeader -Infile $cogTestFile.FullName -Method Post 

    # Update the content type for verify message body
    $cogPGHeader.'Content-Type'="application/json"

    # Define the body for verification
    $cogVerifyBody = "{'faceID':'" + $cogDetFaceIDs.faceId + "',
                   'personId':'" + $cogPersonID.personId + "',
                   'personGroupId':'$cogPersonGroupID',

    }"

    # Verify the face
    $cogVerifyStatus = Invoke-RestMethod $cogVerifyFaceUrl -Headers $cogPGHeader -Body $cogVerifyBody -Method Post

    # Return the verification status and confidence
    write-host $cogVerifyStatus.isIdentical
    write-host $cogVerifyStatus.confidence
}


