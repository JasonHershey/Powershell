This folder contains various powershell scripts I've created for personal use.  Enjoy

### ParseFile Powershell Script
Parses a text file containing WA State Real Estate Course info and creates a list of schools and courses.
Assumes contents of PDF file available from [http://www.dol.wa.gov/business/realestate/docs/recat.pdf](http://www.dol.wa.gov/business/realestate/docs/recat.pdf) was copied into a source text file.
A copy of the sourcefile usedfor my testing is included in the folder with the powershell script

#### Usage:
Script to run     sourceFile                  catalogName                                                   schoollist                  classlist
---------------   --------------------------- ------------------------------------------------------------  -------------------------   ------------------------
.\ParseFile.ps1  "C:\temp\coursecatalog.txt"  "DOL Real Estate Education Course Catalog December 15, 2015"    "C:\temp\schoollist.csv"  "C:\temp\schoollist.csv"
