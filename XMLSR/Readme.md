## XMLSR PowerShell script

The purpose of this script, and the associated config file, is provide a set of search and replace functions to use on XML files. 
It was designed for a client who had XML files that need updated, but that did not have access to the source code that actually creates 
the XML.

These are the three kinds of search-and-replaces that can be configured:
- Standard text-based search and replace Supports regex expressions.
- Simple XPath/XML-based search and replace Uses XPaths to find XML nodes and replaces them with provided text/xml. If no replacement is provided, the target XML node is deleted.
- XML transform-based search and replace Uses XPaths to find XML nodes and then transforms those nodes with provides XML transform (XSLT), replacing the target node with the results.

Inputs for this file are:
- **$sourceFolder** - Path to folder containing XML files to update.
- **$outputFolder** - Path to folder where updates files will be saved.
- **$configFile** - Path and name of XMLSR config file

A sample config file, xmlsrconfig-github.xml, is provided along with a test XML file, xmlsr-test.xml.

### Syntax

```
 .\XMLSR.ps1 -configFile .\xmlsrconfig-github.xml -sourceFolder .\input -outputFolder .\output
```
