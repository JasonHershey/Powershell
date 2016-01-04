##############################################################################################################
## ParseFile Powershell Script
## Prses a text file containing WA State Real Estate Course info and creates a list of schools and courses
## Assumes contents of PDF file available from http://www.dol.wa.gov/business/realestate/docs/recat.pdf 
## was copied into a source text file
##############################################################################################################


#####
# Usage:
#      Script to run    sourceFile                    catalogName                                                      schoollist                        classlist
#      ---------------  ---------------------------   ------------------------------------------------------------     -------------------------         ------------------------
#      .\ParseFile.ps1  "C:\temp\coursecatalog.txt"   "DOL Real Estate Education Course Catalog December 15, 2015"    "C:\temp\schoollist.csv"          "C:\temp\schoollist.csv"
######



param (
    [string] $sourceFile =$(throw "Please give the file path and name of the source text file."),
    [string] $catalogName =$(throw "Please list the name and date of the catalog."),
    [string] $schoollist =$(throw "Please give the file path and name of the output school list file."),
    [string] $classlist =$(throw "Please give the file path and name of the output class list file.")
    )

## Read the contents of the source file
$fileContents = get-content $sourceFile

## Set some test variables to false
$schoolSection = $false
$newSchool=$false
$newClass=$false


## Go through each line of the source file
foreach ($lineContent in $fileContents)
{

## Check for the start of section 1, this is the start of parsing
if ($lineContent.startswith('SECTION 1: APPROVED PROPRIETARY SCHOOLS') -and $lineContent.Length -lt 40)
{
$schoolSection = $true
write-host 'start schools'
}

## Check for start of section 2A, this is the end of parsing
if ($lineContent.startswith('SECTION 2A: PROPRIETARY SCHOOLS OFFERING REAL ESTATE FUNDAMENTALS') -and $lineContent.Length -lt 66)
{
$schoolSection = $false
write-host 'end schools'
}

## Check for pattern indicating a school ID
if ($lineContent.Substring(0,5) -match "S\d{4}")
{
## set new school flag to true
$newSchool = $true

## set the school ID (the first five characters of the line)
$schoolID = $lineContent.Substring(0,5)

## set the school name (everything after the school ID but before first parens of school expiration)
$schoolName = $lineContent.Substring(6,$lineContent.IndexOf("(")-7)

## set the school expiration (10 characters after the parens)
$schoolExpiration =$lineContent.Substring($lineContent.IndexOf("(")+1,10)

## flag that the first line of a school has been processed
$schoolLine = 1
}

## Check if the first line was processed (and nothing more) and that we are not on the school ID/Name line
if (($schoolLine -eq 1) -and ($lineContent.Substring(0,5) -notmatch "S\d{4}"))
{
## set the school address as the line of the contents
$schoolAddress = $lineContent

## flag that the 2nd line of a school has been processed
$schoolLine = 2
}

## Check if the 2nd line was processed (and nothing more), and make sure that there is no comma (meaning its not a line with city and state, so it must be a suite)
if (($schoolLine -eq 2) -and ($lineContent -ne $schoolAddress) -and ($lineContent -notmatch ","))
{
## Add the suite to the school address
$schoolAddress = $schoolAddress + ", " + $lineContent

## flag that the 3rd line of a school has been processed
$schoolLine = 3
}

## Check if line 2 or 3 of school has been processed and there is a comma in the line (so it must be a city and state)
if (($schoolLine -ge 2) -and ($schoolLine -le 3) -and ($lineContent -match ","))
{

## set the school city as the portion of hte line before the comma
$schoolCity = $lineContent.Substring(0,$lineContent.IndexOf(","))

## set the school state as the next two characters after the comma (and a space)
$schoolState = $lineContent.Substring($lineContent.IndexOf(",")+2,2)

## set the school zip as the rest of the line after the state
try {
$schoolZip = $lineContent.Substring($lineContent.IndexOf($schoolState)+3,$lineContent.Length-$linecontent.IndexOf($schoolState)-3)
}
catch
{
write-host $Error[0]
}
## flag that the addresses are all done
$schoolLine = 4

}

## Check if the address is done and the pattern match indicating a phone number (area code in parens)
if (($schoolLine -eq 4) -and ($lineContent -match "\(\d{3}\)"))
{

## set the school phone as the line contents
$schoolPhone = $lineContent

## flag that the phone line is done
$schoolLine = 5
}

## check that the phone line has been processed and that the line starts with Admin:
if (($schoolLine -eq 5) -and ($lineContent -match "Admin: "))
{
## set the school admin as the line content minus Admin:
$schoolAdmin = $lineContent -replace ("Admin: ", "")

## flag that the admin line has been processed
$schoolLine = 6
}

## check if line length is greater than 5 and that first 5 characters match a course number pattern, but not a long course number pattern, and make sure we are in  the school section
if ($lineContent.Length -ge 5 -and ($lineContent.Substring(0,5) -match "C\d{4}") -and ($lineContent.Substring(0,6) -notmatch "C\d{4}S") -and $schoolSection)
{

## Check if a new school has started
if ($newSchool)
{
## write out the school info to the school list file
"{0},'{1}',{2},{3},{4},{5},{6},{7},{8}" -f $schoolID, $schoolName, $schoolExpiration, $schoolAddress, $schoolCity, $schoolState, $schoolZip, $schoolPhone, $schoolAdmin | Out-file -FilePath $schoollist -Append

## set the new school flag to false
$newSchool = $false
}

## check the newclass flag is true
$newClass = $true

## Set the class ID
$classID = $lineContent.Substring(0,$lineContent.IndexOf(" - "))


 ## Look for one of the class type strings
 ## set the class type name
 ## set the flags for each class type
 ## set the class hours (the characters after the class type name)
    if ($lineContent -match "-ONLINE Internet-based Instruction")
    {
    $classType="-ONLINE Internet-based Instruction"
    $className = $lineContent.Substring($lineContent.IndexOf("-")+2,$lineContent.IndexOf($classType)-($lineContent.IndexOf("-")+3))
    $classLive = $false
    $classCorrespondence = $false
    $classOnline = $true
    $classHours = $lineContent.Substring($lineContent.IndexOf($classType)+$classType.Length,$lineContent.Length-$lineContent.IndexOf($classType)-$classType.Length)
    }
    elseif ($lineContent -match "Internet-based Instruction")
    {
    $classType="Internet-based Instruction"
    $className = $lineContent.Substring($lineContent.IndexOf("-")+2,$lineContent.IndexOf($classType)-($lineContent.IndexOf("-")+3))
    $classOnline = $true
    $classCorrespondence = $false
    $classLive = $false
    $classHours = $lineContent.Substring($lineContent.IndexOf($classType)+$classType.Length,$lineContent.Length-$lineContent.IndexOf($classType)-$classType.Length)
    } 
    elseif ($lineContent -match "Live Lecture & Internet-based")
    {
    $classType="Live Lecture & Internet-based"
    $className = $lineContent.Substring($lineContent.IndexOf("-")+2,$lineContent.IndexOf($classType)-($lineContent.IndexOf("-")+3))
    $classLive = $true
    $classCorrespondence = $false
    $classOnline = $true
    $classHours = $lineContent.Substring($lineContent.IndexOf($classType)+$classType.Length,$lineContent.Length-$lineContent.IndexOf($classType)-$classType.Length)
    }
    elseif ($lineContent -match "Live Lecture & Video-based")
    {
    $classType="Live Lecture & Video-based"
    $className = $lineContent.Substring($lineContent.IndexOf("-")+2,$lineContent.IndexOf($classType)-($lineContent.IndexOf("-")+3))
    $classLive = $true
    $classCorrespondence = $true
    $classOnline = $false
    $classHours = $lineContent.Substring($lineContent.IndexOf($classType)+$classType.Length,$lineContent.Length-$lineContent.IndexOf($classType)-$classType.Length)
    }
    elseif ($lineContent -match "Live Lecture & Computer Based")
    {
    $classType="Live Lecture & Computer Based"
    $className = $lineContent.Substring($lineContent.IndexOf("-")+2,$lineContent.IndexOf($classType)-($lineContent.IndexOf("-")+3))
    $classLive = $true
    $classCorrespondence = $false
    $classOnline = $true
    $classHours = $lineContent.Substring($lineContent.IndexOf($classType)+$classType.Length,$lineContent.Length-$lineContent.IndexOf($classType)-$classType.Length)
    }
    elseif ($lineContent -match "Live Lecture & Correspondence")
    {
    $classType="Live Lecture & Correspondence"
    $className = $lineContent.Substring($lineContent.IndexOf("-")+2,$lineContent.IndexOf($classType)-($lineContent.IndexOf("-")+3))
    $classLive = $true
    $classCorrespondence = $true
    $classOnline = $false
    $classHours = $lineContent.Substring($lineContent.IndexOf($classType)+$classType.Length,$lineContent.Length-$lineContent.IndexOf($classType)-$classType.Length)
    }
    elseif ($lineContent -match "Live Lecture & Interactive")
    {
    $classType="Live Lecture & Interactive"
    $className = $lineContent.Substring($lineContent.IndexOf("-")+2,$lineContent.IndexOf($classType)-($lineContent.IndexOf("-")+3))
    $classLive = $true
    $classCorrespondence = $false
    $classOnline = $true
    $classHours = $lineContent.Substring($lineContent.IndexOf($classType)+$classType.Length,$lineContent.Length-$lineContent.IndexOf($classType)-$classType.Length)
    }
    elseif ($lineContent -match "Computer Based Training")
    {
    $classType="Computer Based Training"
    $className = $lineContent.Substring($lineContent.IndexOf("-")+2,$lineContent.IndexOf($classType)-($lineContent.IndexOf("-")+3))
    $classLive = $false
    $classCorrespondence = $true
    $classOnline = $false
    $classHours = $lineContent.Substring($lineContent.IndexOf($classType)+$classType.Length,$lineContent.Length-$lineContent.IndexOf($classType)-$classType.Length)
    }
    elseif ($lineContent -match "Computer Based")
    {
    $classType="Computer Based"
    $className = $lineContent.Substring($lineContent.IndexOf("-")+2,$lineContent.IndexOf($classType)-($lineContent.IndexOf("-")+3))
    $classLive = $false
    $classCorrespondence = $true
    $classOnline = $true
    $classHours = $lineContent.Substring($lineContent.IndexOf($classType)+$classType.Length,$lineContent.Length-$lineContent.IndexOf($classType)-$classType.Length)
    }
    elseif ($lineContent -match "Correspondence")
    {
    $classType="Correspondence"
    $className = $lineContent.Substring($lineContent.IndexOf("-")+2,$lineContent.IndexOf($classType)-($lineContent.IndexOf("-")+3))
    $classCorrespondence = $true
    $classOnline = $false
    $classLive = $false
    $classHours = $lineContent.Substring($lineContent.IndexOf($classType)+$classType.Length,$lineContent.Length-$lineContent.IndexOf($classType)-$classType.Length)
    }
    elseif ($lineContent -match "Video-based Instruction")
    {
    $classType="Video-based Instruction"
    $className = $lineContent.Substring($lineContent.IndexOf("-")+2,$lineContent.IndexOf($classType)-($lineContent.IndexOf("-")+3))
    $classCorrespondence = $true
    $classOnline = $false
    $classLive = $false
    $classHours = $lineContent.Substring($lineContent.IndexOf($classType)+$classType.Length,$lineContent.Length-$lineContent.IndexOf($classType)-$classType.Length)
    }
    elseif ($lineContent -match "Interactive Audio")
    {
    $classType="Interactive Audio"
    $className = $lineContent.Substring($lineContent.IndexOf("-")+2,$lineContent.IndexOf($classType)-($lineContent.IndexOf("-")+3))
    $classCorrespondence = $true
    $classOnline = $false
    $classLive = $false
    $classHours = $lineContent.Substring($lineContent.IndexOf($classType)+$classType.Length,$lineContent.Length-$lineContent.IndexOf($classType)-$classType.Length)
    }
    elseif ($lineContent -match "Live Lecture")
    {
    $classType="Live Lecture"
    $className = $lineContent.Substring($lineContent.IndexOf("-")+2,$lineContent.IndexOf($classType)-($lineContent.IndexOf("-")+3))
    $classLive = $true
    $classCorrespondence = $false
    $classOnline = $false
    $classHours = $lineContent.Substring($lineContent.IndexOf($classType)+$classType.Length,$lineContent.Length-$lineContent.IndexOf($classType)-$classType.Length)
    }
    elseif ($lineContent -match "-ONLINE")
    {
    $classType="-ONLINE"
    $className = $lineContent.Substring($lineContent.IndexOf("-")+2,$lineContent.IndexOf($classType)-($lineContent.IndexOf("-")+3))
    $classLive = $false
    $classCorrespondence = $false
    $classOnline = $true
    $classHours = $lineContent.Substring($lineContent.IndexOf($classType)+$classType.Length,$lineContent.Length-$lineContent.IndexOf($classType)-$classType.Length)
    }    
    elseif ($lineContent -match "CD-ROM")
    {
    $classType="CD-ROM"
    $className = $lineContent.Substring($lineContent.IndexOf("-")+2,$lineContent.IndexOf($classType)-($lineContent.IndexOf("-")+3))
    $classLive = $false
    $classCorrespondence = $true
    $classOnline = $false
    $classHours = $lineContent.Substring($lineContent.IndexOf($classType)+$classType.Length,$lineContent.Length-$lineContent.IndexOf($classType)-$classType.Length)
    }    
    else
    {
    $classType=""
    $className = $lineContent.Substring($lineContent.IndexOf("-")+2,$lineContent.LastIndexof(" ")-$lineContent.IndexOf("-")-2)
    $classLive = $false
    $classCorrespondence = $false
    $classOnline = $false
    $classHours = $lineContent.Substring($lineContent.IndexOf($className)+$className.Length+1,$lineContent.Length-$lineContent.IndexOf($className)-$className.Length-1)
    }

}
## this section does the same as the last, only it checks for a longer course ID (ends in S)
elseif ($lineContent.Length -ge 6 -and $lineContent.Substring(0,6) -match "C\d{4}S"  -and $schoolSection)
{
if ($newSchool)
{
"{0},'{1}',{2},{3},{4},{5},{6},{7},{8}" -f $schoolID, $schoolName, $schoolExpiration, $schoolAddress, $schoolCity, $schoolState, $schoolZip, $schoolPhone, $schoolAdmin | Out-file -FilePath $schoollist -Append
$newSchool = $false
}

$newClass = $true
$classID = $lineContent.Substring(0,6)

    if ($lineContent -match "-ONLINE Internet-based Instruction")
    {
    $classType="-ONLINE Internet-based Instruction"
    $className = $lineContent.Substring($lineContent.IndexOf("-")+2,$lineContent.IndexOf($classType)-($lineContent.IndexOf("-")+3))
    $classLive = $true
    $classCorrespondence = $false
    $classOnline = $false
    $classHours = $lineContent.Substring($lineContent.IndexOf($classType)+$classType.Length,$lineContent.Length-$lineContent.IndexOf($classType)-$classType.Length)
    }
    elseif ($lineContent -match "Internet-based Instruction")
    {
    $classType="Internet-based Instruction"
    $className = $lineContent.Substring($lineContent.IndexOf("-")+2,$lineContent.IndexOf($classType)-($lineContent.IndexOf("-")+3))
    $classOnline = $true
    $classCorrespondence = $false
    $classLive = $false
    $classHours = $lineContent.Substring($lineContent.IndexOf($classType)+$classType.Length,$lineContent.Length-$lineContent.IndexOf($classType)-$classType.Length)
    } 
    elseif ($lineContent -match "Live Lecture & Internet-based")
    {
    $classType="Live Lecture & Internet-based"
    $className = $lineContent.Substring($lineContent.IndexOf("-")+2,$lineContent.IndexOf($classType)-($lineContent.IndexOf("-")+3))
    $classLive = $true
    $classCorrespondence = $false
    $classOnline = $true
    $classHours = $lineContent.Substring($lineContent.IndexOf($classType)+$classType.Length,$lineContent.Length-$lineContent.IndexOf($classType)-$classType.Length)
    }
    elseif ($lineContent -match "Live Lecture & Video-based")
    {
    $classType="Live Lecture & Video-based"
    $className = $lineContent.Substring($lineContent.IndexOf("-")+2,$lineContent.IndexOf($classType)-($lineContent.IndexOf("-")+3))
    $classLive = $true
    $classCorrespondence = $true
    $classOnline = $false
    $classHours = $lineContent.Substring($lineContent.IndexOf($classType)+$classType.Length,$lineContent.Length-$lineContent.IndexOf($classType)-$classType.Length)
    }
   elseif ($lineContent -match "Live Lecture & Computer Based")
    {
    $classType="Live Lecture & Computer Based"
    $className = $lineContent.Substring($lineContent.IndexOf("-")+2,$lineContent.IndexOf($classType)-($lineContent.IndexOf("-")+3))
    $classLive = $true
    $classCorrespondence = $false
    $classOnline = $true
    $classHours = $lineContent.Substring($lineContent.IndexOf($classType)+$classType.Length,$lineContent.Length-$lineContent.IndexOf($classType)-$classType.Length)
    }
    elseif ($lineContent -match "Live Lecture & Correspondence")
    {
    $classType="Live Lecture & Correspondence"
    $className = $lineContent.Substring($lineContent.IndexOf("-")+2,$lineContent.IndexOf($classType)-($lineContent.IndexOf("-")+3))
    $classLive = $true
    $classCorrespondence = $true
    $classOnline = $false
    $classHours = $lineContent.Substring($lineContent.IndexOf($classType)+$classType.Length,$lineContent.Length-$lineContent.IndexOf($classType)-$classType.Length)
    }
    elseif ($lineContent -match "Live Lecture & Interactive")
    {
    $classType="Live Lecture & Interactive"
    $className = $lineContent.Substring($lineContent.IndexOf("-")+2,$lineContent.IndexOf($classType)-($lineContent.IndexOf("-")+3))
    $classLive = $true
    $classCorrespondence = $false
    $classOnline = $true
    $classHours = $lineContent.Substring($lineContent.IndexOf($classType)+$classType.Length,$lineContent.Length-$lineContent.IndexOf($classType)-$classType.Length)
    }
    elseif ($lineContent -match "Computer Based Training")
    {
    $classType="Computer Based Training"
    $className = $lineContent.Substring($lineContent.IndexOf("-")+2,$lineContent.IndexOf($classType)-($lineContent.IndexOf("-")+3))
    $classLive = $false
    $classCorrespondence = $true
    $classOnline = $false
    $classHours = $lineContent.Substring($lineContent.IndexOf($classType)+$classType.Length,$lineContent.Length-$lineContent.IndexOf($classType)-$classType.Length)
    }
    elseif ($lineContent -match "Computer Based")
    {
    $classType="Computer Based"
    $className = $lineContent.Substring($lineContent.IndexOf("-")+2,$lineContent.IndexOf($classType)-($lineContent.IndexOf("-")+3))
    $classLive = $false
    $classCorrespondence = $true
    $classOnline = $false
    $classHours = $lineContent.Substring($lineContent.IndexOf($classType)+$classType.Length,$lineContent.Length-$lineContent.IndexOf($classType)-$classType.Length)
    }
    elseif ($lineContent -match "Correspondence")
    {
    $classType="Correspondence"
    $className = $lineContent.Substring($lineContent.IndexOf("-")+2,$lineContent.IndexOf($classType)-($lineContent.IndexOf("-")+3))
    $classCorrespondence = $true
    $classOnline = $false
    $classLive = $false
    $classHours = $lineContent.Substring($lineContent.IndexOf($classType)+$classType.Length,$lineContent.Length-$lineContent.IndexOf($classType)-$classType.Length)
    }
    elseif ($lineContent -match "Video-based Instruction")
    {
    $classType="Video-based Instruction"
    $className = $lineContent.Substring($lineContent.IndexOf("-")+2,$lineContent.IndexOf($classType)-($lineContent.IndexOf("-")+3))
    $classCorrespondence = $true
    $classOnline = $false
    $classLive = $false
    $classHours = $lineContent.Substring($lineContent.IndexOf($classType)+$classType.Length,$lineContent.Length-$lineContent.IndexOf($classType)-$classType.Length)
    }
    elseif ($lineContent -match "Interactive Audio")
    {
    $classType="Interactive Audio"
    $className = $lineContent.Substring($lineContent.IndexOf("-")+2,$lineContent.IndexOf($classType)-($lineContent.IndexOf("-")+3))
    $classCorrespondence = $true
    $classOnline = $false
    $classLive = $false
    $classHours = $lineContent.Substring($lineContent.IndexOf($classType)+$classType.Length,$lineContent.Length-$lineContent.IndexOf($classType)-$classType.Length)
    }
    elseif ($lineContent -match "Live Lecture")
    {
    $classType="Live Lecture"
    $className = $lineContent.Substring($lineContent.IndexOf("-")+2,$lineContent.IndexOf($classType)-($lineContent.IndexOf("-")+3))
    $classLive = $true
    $classCorrespondence = $false
    $classOnline = $false
    $classHours = $lineContent.Substring($lineContent.IndexOf($classType)+$classType.Length,$lineContent.Length-$lineContent.IndexOf($classType)-$classType.Length)
    }
    elseif ($lineContent -match "-ONLINE")
    {
    $classType="-ONLINE"
    $className = $lineContent.Substring($lineContent.IndexOf("-")+2,$lineContent.IndexOf($classType)-($lineContent.IndexOf("-")+3))
    $classLive = $false
    $classCorrespondence = $false
    $classOnline = $true
    $classHours = $lineContent.Substring($lineContent.IndexOf($classType)+$classType.Length,$lineContent.Length-$lineContent.IndexOf($classType)-$classType.Length)
    }    
    elseif ($lineContent -match "CD-ROM")
    {
    $classType="CD-ROM"
    $className = $lineContent.Substring($lineContent.IndexOf("-")+2,$lineContent.IndexOf($classType)-($lineContent.IndexOf("-")+3))
    $classLive = $false
    $classCorrespondence = $true
    $classOnline = $false
    $classHours = $lineContent.Substring($lineContent.IndexOf($classType)+$classType.Length,$lineContent.Length-$lineContent.IndexOf($classType)-$classType.Length)
    }    
    else
    {
    $classType=""
    $className = $lineContent.Substring($lineContent.IndexOf("-")+2,$lineContent.LastIndexof(" ")-$lineContent.IndexOf("-")-2)
    $classLive = $false
    $classCorrespondence = $false
    $classOnline = $false
    $classHours = $lineContent.Substring($lineContent.IndexOf($className)+$className.Length+1,$lineContent.Length-$lineContent.IndexOf($className)-$className.Length-1)
    }
 
}

    ## check if we are in a school section and a new class
    if ($schoolSection -and $newClass)
    {
    ## write out the class info to the class list file
    "{0},'{1}',{2},{3},{4},{5},{6}" -f $schoolID, $classID, $className, $classLive, $classCorrespondence, $classOnline, $classHours | Out-file -FilePath $classlist -Append

    ## reset the new class file
    $newClass = $false
    }



}