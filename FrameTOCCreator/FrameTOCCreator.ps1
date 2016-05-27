##################################################################################################################
## FrameTOCCreator.ps1 - Copyright 2016 by Tellus Consulting and Project Management
## Developer - Jason Hershey
## The primary purpose of this script is to create a Table of Contents (TOC) file in HTML, from a Word document
## source file. As part of the process, it will also create an HTML version of the Word document.
## This script does NOT create the frameset that will consume the TOC file
## Assumptions and pre-requisites:
## This script assumes all input and output files will be located in the same local file folder as the script.
## The user must of the Microsoft Word client installed on their local machine. Any current version should work
## but development and testing were done on Word 2016.
## A pre-requisite for the process to work is that the Word document must have TOC bookmarks for the headings.
## This may require that you add a TOC to the document, from within Word, before running this script.  After you 
## add the TOC and save the Word document, you can then delete the TOC itself from the Word document.
##
## Inputs for this file are:
##      - $wordDoc - The source Word document. 
##      - $outputFileName - The base name you want for the output HTML file. You don't need to add the file extension
##                          and you should not provide the full path to the file.
##      - $tocFileName - This is the output name of the HTML TOC file.  Again, do not provide the file extenstion
##                       or file path
##      - $debugFlag - This script createse several temporary files as part of the TOC and HTML output file
##                     creation process.  The script deletes the files when its done with them.  Setting the
##                     This parameter to $true will tell the script to leave the files and not delete them. 
##                     This could be useful for troubleshooting.
##################################################################################################################
param (
[string] $wordDoc = $(throw "Provide the name of the source word document. (Do not provide the path.)"),
[string] $outputFileName =$(throw "Provide the base name for the output file. (No file extension or file path.)"),
[string] $tocFileName=$(throw "Provide the base name of the toc file that will get created. (No file extension or path.)"),
[bool] $debugFlag = $false
)

##################################################################################################################
## We assume all the files are in the current folder
##################################################################################################################
$currentFolder = (Get-Item -Path ".\" -Verbose).FullName + "\"

##################################################################################################################
## Constants - These values are used later and may need changed based on differences in source Word documents
##             values are obtained from a config file to remove the amount of hard-coding in the script
## $headingStyle - This is the base name for the style used for headings. We assume heading styles are all named
##                 similarly, like 'Heading 1', 'Heading 2', etc.
## $heading1Style - Indicates a 1st level heading
## $heading2Style - Indicates a 2nd level heading
## $heading3Style - indicates a 3rd level heading
## $tocLevelstart - Template for a new list level (<ul>)
## $tocLevelend - Template for ending a list level ($tocLevelend)
## $tocEntrytemplate - The template for a TOC entry. We assume TOCs are unordered lists in HTML, with no bullet
## $fileHeader - The start TOC HTML file, which will include CSS calls that might change.
##################################################################################################################
$configFilepath = $currentFolder + "FrameTOCCreatorconfig.xml"
[xml] $configData = Get-Content -Path $configFilepath

$headingStyle = $configData.SelectSingleNode("//headingcommon").InnerText 
$heading1Style = $configData.SelectSingleNode("//heading1").InnerText  
$heading2Style = $configData.SelectSingleNode("//heading2").InnerText  
$heading3Style = $configData.SelectSingleNode("//heading3").InnerText 

$tocLevelstart=$configData.SelectSingleNode("//toclevelstart").InnerText 
$tocLevelend=$configData.SelectSingleNode("//toclevelend").InnerText 
$tocEntrytemplate=$configData.SelectSingleNode("//tocentry").InnerText 

$fileHeader=$configData.SelectSingleNode("//tocfilestart").InnerText 
$fileFooter=$configData.SelectSingleNode("//tocfileend").InnerText 

##################################################################################################################
## Set the names of output and temp files based on inputs
##################################################################################################################
$sourceFile = $outputFileName + "_temp.htm"
$xmlFile = $outputFileName + "_temp.xml"
$outputFile = $outputFileName + ".htm"
$tocFile = $tocFileName + ".htm"



############################################################################
## Open the Word document and create an XML and HTML version for processing
############################################################################
$word=new-object -ComObject "Word.Application"
$myDoc = $word.documents.Open($currentFolder+$wordDoc)
$myDoc.SaveAs2($currentFolder+$xmlFile,19)
$myDoc.SaveAs2($currentFolder+$sourceFile,10)
$myDoc.SaveAs2($currentFolder+$outputFile,10)
$myDoc.Close()
$word.Quit()


############################################################################
## initialize some values
############################################################################
$global:currentLevel=0

############################################################################
## functions used in the main code
############################################################################
function closelevel
{
$global:currentLevel=$global:currentLevel-1
$tocLevelend | out-file $tocFile -Append
}


function raiselevel
{
$tocLevelstart | out-file $tocFile -Append
$global:currentLevel=$global:currentLevel+1
}

## Start the TOC file
$fileHeader |Out-File $tocFile


## Open the XML file
$xmldoc = New-Object XML
$xmldoc.Load($currentFolder+$xmlFile)
$ns = New-Object Xml.XmlNamespaceManager $xmldoc.NameTable
$ns.AddNamespace('w','http://schemas.openxmlformats.org/wordprocessingml/2006/main')

foreach ($heading in $xmldoc.SelectNodes("//w:p[w:pPr[w:pStyle[contains(@w:val,$headingStyle)]]]",$ns))
{
    if ($heading.SelectNodes("./w:pPr/w:pStyle/@w:val", $ns).value -eq $heading1Style)
    { 
        write-host "Processing 1st level heading: " $heading.InnerText
        if ($global:currentLevel -gt 0) 
        {
        While($global:currentLevel -gt 1) 
            {
            closelevel
            }
        }
        else
        {
        raiselevel
        }

        $tocEntry=$tocEntrytemplate.Replace("{linktext}",$heading.InnerText)
        if ($heading.SelectSingleNode(".//w:bookmarkStart/@w:name", $ns).value -match '_Toc')
        {

        $tocEntry = $tocEntry.Replace("{anchor}",$heading.SelectSingleNode(".//w:bookmarkStart/@w:name", $ns).value)
        }
        else
        {
        $tocEntry = $tocEntry.Replace("{anchor}","Link text not found")
        }

        $tocEntry.Replace("{url}",$outputFile) | out-file $tocFile -Append
    }
    
    if ($heading.SelectNodes("./w:pPr/w:pStyle/@w:val", $ns).value -eq $heading2Style)
    { 
        write-host "Processing 2nd level heading: " $heading.InnerText
        switch ($global:currentLevel)
        {
        0 {raiselevel; break}
        1 {raiselevel; break}
        2 {break}
        3 {closelevel; break}
        }
        
        $tocEntry=$tocEntrytemplate.Replace("{linktext}",$heading.InnerText)
       
        if ($heading.SelectSingleNode(".//w:bookmarkStart/@w:name", $ns).value -match '_Toc')
        {
        $tocEntry = $tocEntry.Replace("{anchor}",$heading.SelectSingleNode(".//w:bookmarkStart/@w:name", $ns).value)
        }
        else
        {
        $tocEntry = $tocEntry.Replace("{anchor}","Link text not found")
        }
        $tocEntry.Replace("{url}",$outputFile) | out-file $tocFile -Append
     }

     if ($heading.SelectNodes("./w:pPr/w:pStyle/@w:val", $ns).value -eq $heading3Style)
    { 
        write-host "Processing 3rd level heading: " $heading.InnerText
        switch ($global:currentLevel)
        {
            0 {raiselevel;raiselevel; break}
            1 {raiselevel;raiselevel; break}
            2 {raiselevel; break}
            3 {closelevel; break}
        }
        $tocEntry=$tocEntrytemplate.Replace("{linktext}",$heading.InnerText)
       
        if ($heading.SelectSingleNode(".//w:bookmarkStart/@w:name", $ns).value -match '_Toc')
        {
        $tocEntry = $tocEntry.Replace("{anchor}",$heading.SelectSingleNode(".//w:bookmarkStart/@w:name", $ns).value)
        }
        else
        {
        $tocEntry = $tocEntry.Replace("{anchor}","Link text not found")
        }

        $tocEntry.Replace("{url}",$outputFile) | out-file $tocFile -Append
     }

}

While($global:currentLevel -ge 1) 
        {
        write-host "Closing open level: " $global:currentLevel
        closelevel
        }

$fileFooter | out-file $tocFile -Append

if (!$debugFlag)
{
Remove-Item $sourceFile
Remove-Item $xmlFile
}
