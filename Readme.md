This folder contains various powershell scripts I've created for personal use or small client projects.  Enjoy

### XMLSR PowerShell script
The purpose of this script, and the associated config file, is provide a set of search and replace functions
to use on XML files.  It was designed for a client who had XML files that need updated, but that did not have access to the source code that actually creates the XML.

The functions come in 3 varieties:
 - **Standard text-based search and replace** Supports regex expressions.
 - **Simple XPath/XML-based search and replace** Uses XPaths to find XML nodes and replaces them with provided text/xml. If no replacement is provided, the target XML node is deleted.
 - **XML transform-based search and replace** Uses XPaths to find XML nodes and then transforms those nodes with provides XML transform (XSLT), replacing the target node with the results.
 
Inputs for this file are:
 - $sourceFolder - Path to folder containing XML files to update. 
 - $outputFolder - Path to folder where updates files will be saved.
 - $configFile - Path and name of XMLSR config file

A sample config file, _xmlsrconfig-github.xml_, is provided along with a test XML file, _xmlsr-test.xml_.

#### Syntax
 ```
 .\XMLSR.ps1 -configFile .\xmlsrconfig-github.xml -sourceFolder .\input -outputFolder .\output
```


### ParseFile PowerShell script
Parses a text file containing WA State Real Estate Course info and creates a list of schools and courses.
Assumes contents of PDF file available from [http://www.dol.wa.gov/business/realestate/docs/recat.pdf](http://www.dol.wa.gov/business/realestate/docs/recat.pdf) was copied into a source text file.
A copy of the sourcefile usedfor my testing is included in the folder with the powershell script

#### Usage:
```
Script to run     sourceFile                  catalogName                                                   schoollist                  classlist
---------------   --------------------------- ------------------------------------------------------------  -------------------------   ------------------------

.\ParseFile.ps1  "C:\temp\coursecatalog.txt"  "DOL Real Estate Education Course Catalog December 15, 2015"    "C:\temp\schoollist.csv"  "C:\temp\schoollist.csv"
```

### FrameTOCCreator PowerShell script
Reads a Microsoft Word document and generates an HTML TOC file and also saves the Word document as an HTML file. The two files can be used with a frameset HTML file (using Frames or iframes) to create a simple 'help file' system.
This script does NOT create the frameset that will consume the TOC file
#### Assumptions and pre-requisites:
- This script assumes all input and output files will be located in the same local file folder as the script.
- The user must of the Microsoft Word client installed on their local machine. Any current version should work but development and testing were done on Word 2016.
- A pre-requisite for the process to work is that the Word document must have TOC bookmarks for the headings.This may require that you add a TOC to the document, from within Word, before running this script.  After you add the TOC and save the Word document, you can then delete the TOC itself from the Word document.

#### Included files
The FrameTOCCreator folder contains the source Windows PowerShell script, a config file, and sample files. The full list is:
- FrameTOCCreatorconfig.ps1 - This is the Windows PowerShell script. See the script for full details on usage.
- FrameTOCCreatorconfig.xml - This XML file contains configurable data for use in the script. For example, you can define the heading styles that the script should look for, and you can customize the HTML output for the TOC file.
- default.htm - A sample frameset html file is provided. This file contains the following sections/divs:
  - header - The header div is for a top header section for your page
  - toc - The toc div is a container for the toc iframe
  - content - The content div is a container for the target content file
  - footer - The footer div is for a bottom footer sectino for your page
- help.css - A simple CSS file that does some formatting for the sample files
- source.docx - A sample source Word document. Used to generate the sample output files.
- toc.htm - A sample toc htm file generated from source.docx, using the script.
- content.htm - A sample content htm file generated from source.docx

#### Usage:
```
Script to run         wordDoc               outputFileName             tocFileName       debugFlag
--------------------  ---------------------- ------------------------- -----------------  ------------------

.\FrameTOCCreator.ps1  -wordDoc "source.docx" -outputFileName "content" -tocFileName "toc" -debugFlag $false
``` 
where
- wordDoc - The source Word document. 
- outputFileName - The base name you want for the output HTML file. You don't need to add the file extension and you should not provide the full path to the file.
- tocFileName - This is the output name of the HTML TOC file.  Again, do not provide the file extenstion or file path
- debugFlag - This script createse several temporary files as part of the TOC and HTML output file creation process.  The script deletes the files when its done with them.  Setting this parameter to $true will tell the script to leave the files and not delete them. This could be useful for troubleshooting.

### VRecognition PowerShell script
This script is a short example/test of the Azure cognitive services voice recogntion apis.  You can find more details about these apis 
at [Speaker Recognition APIs](https://azure.microsoft.com/en-us/services/cognitive-services/speaker-recognition/).
My purpose in creating the script is to make sure I understand how the APIs work.  Im a big fan of PowerShell and I find it a great place to prototype and practice.

### FRecognition PowerShell script
This script is a short example/test of the Azure cognitive services facial recogntion apis.  You can find more details about these apis 
at [Facial Recognition APIs](https://docs.microsoft.com/en-us/azure/cognitive-services/face/).
My purpose in creating the script is to make sure I understand how the APIs work.  

## License

These scripts are provided under the GNU General Public License [License](license.md)
