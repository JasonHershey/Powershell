##################################################################################################################
## XMLSR.ps1 - Copyright 2016 by Tellus Consulting and Project Management
## Developer - Jason Hershey
## This script is provided under the GNU General Public License License
## The purpose of this script, and the associated config file, is provide a set of search and replace functions
## to use on XML files.  The functions come in 3 varieties
## -- Standard text-based search and replace
## -- Simple XPath/XML-based search and replace
## -- XML transform-based search and replace
## 
## Inputs for this file are:
##      - $sourceFolder - Path to folder containing XML files to update. 
##      - $outputFolder - Path to folder where updates files will be saved.
##      - $configFile - Path and name of XMLSR config file
## Syntax
## .\XMLSR.ps1 -configFile .\xmlsrconfig.xml -sourceFolder .\input -outputFolder .\output
## 
##################################################################################################################

## Parameters

param (
[string] $sourceFolder, # Optional parameter if provided in config file
[string] $outputFolder, # Optional if provided in config file
[string] $configFile=$(throw "Provide the path and name of the XMSR config file")
)


#################################################################################################################

## Functions

Function logger
{
param(
[string] $messagetype, 
[string] $logmessage
)

write-host ($messagetype + ": " + $logmessage)

}

Function textSR
{
param([xml] $xmlFile)

## process each xmlsrnode in the config file

try
{
foreach ($txtsrnode in $configData.SelectNodes('//txtsr'))
    {
    if ($xmlFile.OuterXml -match $txtsrnode.search.InnerText)
        {
        logger -messagetype "Info" -logmessage ("Replacing all instances of " + $txtsrnode.search.InnerText + " with " + $txtsrnode.replace.InnerText)
        
        $xmlFile.InnerXml=$xmlFile.OuterXml -replace $txtsrnode.search.InnerText, $txtsrnode.replace.InnerText

        }
  
    else
        {
        logger -messagetype "Info" -logmessage ("No instances of '" + $txtsrnode.search.InnerText + "' found.")
        }
    }
 }
 catch
 {
 logger -messagetype "Error" -logmessage $Error[0]
 }
 
 }


Function xmlSR
{
param([xml] $xmlFile)

## process each xmlsrnode in the config file
try
{
foreach ($xmlsrnode in $configData.SelectNodes('//xmlsr'))
    {
        ## check if any of target xml file has any of the nodes we are searching for
        if ($xmlFile.SelectNodes($xmlsrnode.search.InnerText).Count)
        {
        foreach ( $searchNode in $xmlFile.SelectNodes($xmlsrnode.search.InnerText))
            {
                if ($xmlsrnode.replace.InnerText -eq '')
                    {
                    ## if the replace node is empty, then it means the search node should be deleted
                    logger -messagetype "Info" -logmessage ("Removing node: " + $searchNode.OuterXml)
                   
                    $outputholder=$searchNode.ParentNode.RemoveChild($searchNode)
                   
                    }
                else
                    {
                        if ($xmlsrnode.replace.InnerText -match "%1")
                        {
                        ## if the replace node contains a %1 then replace the %1 with the inner text of the search node
                        ## This allows you to use the existing text, as is, in the replace  
                        $tempReplace=$xmlsrnode.replace.InnerText.Replace('%1',$searchNode.InnerText)
                        }
                        else
                        {
                        ## We will replace the existing node completely
                        $tempReplace = $xmlsrnode.replace.InnerText
                        }
                    
                    ## create the xml node and replace the original with the new node
                    $tempNode = $xmlFile.CreateDocumentFragment()
                    $tempNode.InnerXml=$tempReplace
                   
                    logger -messagetype "Info" -logmessage ("Replacing node: " + $searchNode.OuterXml + " with node: " + $tempNode.OuterXml)

                    $outputholder=$searchNode.ParentNode.ReplaceChild($tempNode,$searchNode)
                    }

                    
            }
        }
        else
        {
        logger -messagetype "Info" -logmessage ("No instances of " + $xmlsrnode.SelectNodes('search').InnerText + " found")
        }
    }
}
catch
{
logger -messagetype "Error" -logmessage $Error[0]
}
}

Function xformSR
{
param([xml] $xmlFile)

## process each xmlsrnode in the config file
try
{
foreach ($xformsrnode in $configData.SelectNodes('//xmlxform'))
    {
     if ($xformsrnode.xform.InnerText -eq '')
                    {
                    ## if the xform node is empty this is not a valid search
                    logger -messagetype "Error" -logmessage "xform node cannot be empty."
                    }

        ## check if any of target xml file has any of the nodes we are searching for
        if ($xmlFile.SelectNodes($xformsrnode.target.InnerText).Count -ge 1)
        {
        foreach ( $searchNode in $xmlFile.SelectNodes($xformsrnode.target.InnerText))
            {
               
                        $xslt = New-Object System.Xml.Xsl.XslCompiledTransform;
                        $xslt_set = New-Object System.Xml.Xsl.XsltSettings;
                        $xmlResolver = New-Object System.Xml.XmlUrlResolver;
                        $xmlArgList = New-Object System.Xml.Xsl.XsltArgumentList;
                        $xslt_set.EnableScript = $true;
                       
                       
                        $tempxsltfile = [IO.Path]::GetTempFileName()
                        $tempinfile = [IO.Path]::GetTempFileName()
                        $tempoutfile = [IO.Path]::GetTempFileName()

                        # create and load temp XSLT from config file entry
                        [xml] $tempXSLT=''
                        $tempXSLT.InnerXml=$xformsrnode.xform.InnerText
                        $tempXSLT.Save($tempxsltfile)
                        $xslt.Load($tempxsltfile,$xslt_set,$xmlResolver)
                        

                        # create temporary xml file from search results
                        [xml] $tempxFile=''
                        $tempxFile.InnerXml=$searchNode.OuterXml
                        $tempxFile.Save($tempinfile)


                        # create temporary xml output file (streamwriter)
                        $textStream = [System.IO.StreamWriter] ($tempoutfile)
                        
                        
                        # transform the temporary xml input file to the output textstream
                        try
                        {
                        $xslt.Transform($tempinfile,$xmlArgList, $textStream)
                        }
                        catch
                        {
                        logger -messagetype "Error" -logmessage "Transformation of search node '$searchNode.InnerXml' did not work."
                        }

                        #close the textstream
                        $textStream.Close()
                        
                        
                        
                         ## create a temporary xml node and load it with the content of the temporary xml file
                        $tempNode = $xmlFile.CreateDocumentFragment()
                        [xml] $outXml = Get-Content ($tempoutfile)
                        $tempNode.InnerXml=$outXml.DocumentElement.OuterXml
                       
                       
                                           
                    ## replace the original with the new node
                    logger -messagetype "Info" -logmessage ("Replacing node: " + $searchNode.OuterXml + " with node: " + $tempNode.InnerXml)
                    $outputholder=$searchNode.ParentNode.ReplaceChild($tempNode,$searchNode)

                    #delete temp files
                    Remove-Item $tempxsltfile
                    Remove-Item $tempinfile
                    Remove-Item $tempoutfile

                    
            }
        }
        else
        {
        logger -messagetype "Info" -logmessage ("No instances of " + $xformsrnode.SelectNodes('target').InnerText + " found")
        }
    }
}
catch
    {
    logger -messagetype "Error" -logmessage $Error[0]
    }
}




       
################################################################################################################
# Get current folder in case it is needed
$currentFolder = (Get-Item -Path ".\" -Verbose).FullName + "\"

###############################################################
# Read config file
###############################################################

if (Test-Path $configFile)
{
[xml] $configData = Get-Content -Path $configFile
}
else
{
logger -messagetype "Error" -logmessage "Config file path '$configFile' does not exist"
break
}

################################################################################################################
# Configuration data

# check if sourceFolder was provided, and if not, check the config file.
if ($sourceFolder -eq '')
{
    if ($configData.xmlsrconfig.commonconfig.sourcefolder -ne '')
    {
    logger -messagetype "Info" -logmessage ("sourceFolder defined in config file - " + $configData.xmlsrconfig.commonconfig.sourcefolder)
    $sourceFolder=$configData.xmlsrconfig.commonconfig.sourcefolder
    }
    else
    {
    logger -messagetype "Error" -logmessage "If sourceFolder parameter is not provided, then the config file must have sourcefolder element defined."
    break
    }
}

# check if outputFolder was provided, and if not, check the config file.
if ($outputFolder -eq '')
{
    if ($configData.xmlsrconfig.commonconfig.outputfolder -ne '')
    {
    logger -messagetype "Info" -logmessage ("outputFolder defined in config file - " + $configData.xmlsrconfig.commonconfig.outputfolder)
    $outputFolder=$configData.xmlsrconfig.commonconfig.outputfolder
    }
    else
    {
    logger -messagetype "Error" -logmessage "If outputFolder parameter is not provided, then the config file must have outputfolder element defined."
    break
    }
}

#expand folder names
$sourceFolder=(Get-Item $sourceFolder).FullName
$outputFolder=(Get-Item $outputFolder).FullName

## set xml namespace
$nspace = $configData.xmlsrconfig.commonconfig.namespace

## count the number of search configs
## we'll use this info later to see if we can skip some work
$txtsrcount = $configData.xmlsrconfig.txtsrs.SelectNodes('txtsr').Count
$xmlsrcount = $configData.xmlsrconfig.xmlsrs.SelectNodes('xmlsr').Count
$xformcount = $configData.xmlsrconfig.xmlxforms.SelectNodes('xmlxform').Count


if (!($txtsrcount -or $xmlsrcount -or $xformcount))
{
logger -messagetype "Error" -logmessage "There are no configurations in the Config File. Ending process early"
break
}

################################################################################################################

##################################
## Validate folders
##################################

## Check for sourceFolder. If it does not exist or is empty, then no point in continuing.
if(!(Test-Path $sourceFolder))
{
logger -messagetype "Error" -logmessage "The source folder '$sourceFolder' does not exist. Ending the process early."
break
}
elseif ((Get-ChildItem -Path $sourceFolder -Filter "*.xml").Count -eq 0)
{
logger -messagetype "Error" -logmessage "The source folder '$sourceFolder' does not contain any xml files. Ending the process early."
break
}

## Check for outputFolder. If it does not exist attempt to create it.
if(!(Test-Path $outputFolder))
{
    try
    {
    md $outputFolder
    }
    catch
    {
    logger -messagetype "Error" -logmessage "The output folder '$outputFolder' does not exist and could not be created. Ending the process early."
    break
    }
}

################################################################################################################



################################################################################################################
## Main function
################################################################################################################


## process each xml file in the source folder
foreach ($tempFile in (Get-ChildItem -Path $sourceFolder -Filter "*.xml"))
{

    ## load the xml file as xml
    [xml] $xfile = Get-Content -Path ($tempfile.FullName)

    ## Create xml namespace if configured

    if ($nspace.name -ne '')
    {
    $ns = New-Object Xml.XmlNamespaceManagr $xmldoc.NameTable
    $ns.AddNamespace($nspace.name,$nspace.uri)
    }


    if ($txtsrcount)
    {
    textSR $xFile
    $xFile.save($tempFile.FullName.Replace($sourceFolder,$outputFolder))
    }
    else
    {
    $txtsrcount
    logger -messagetype "Info" -logmessage "No text-based SRs to perform. $txtsrcount 1"
    }

    if ($xmlsrcount)
    {
    xmlSR $xFile
    $xFile.save($tempFile.FullName.Replace($sourceFolder,$outputFolder))
    }
    else
    {
    logger -messagetype "Info" -logmessage "No xml-based SRs to perform."
    }

    if ($xformcount)
    {
    xformSR $xFile
    $xFile.save($tempFile.FullName.Replace($sourceFolder,$outputFolder))
    }
    else
    {
    logger -messagetype "Info" -logmessage "No transform-based SRs to perform."
    }

}



             