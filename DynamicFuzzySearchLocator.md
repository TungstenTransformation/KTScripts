# Dynamic Fuzzy Search Locator
This technique enables you to fuzzy search a document dynamically for a value produced by another locator.  
The [**Levenshtein**](https://en.wikipedia.org/wiki/Levenshtein_distance) [Format Definition](https://docshield.kofax.com/KTT/en_US/6.3.0-v15o2fs281/help/PB/ProjectBuilder/450_Extraction/FormatLocator/c_LevenshteinFormatDefinitions.html#id_c_LevenshteinFormatDefinitions) performs a fuzzy search.

**Example**. Search for the word amount on a money transfer.  
This document is a simple money transfer. It contains the amount in both numbers **4,535** and words [**dörtbinbeşyüzotuzbeş**](https://translate.google.com/?hl=en&sl=auto&tl=en&text=d%C3%B6rtbinbe%C5%9Fy%C3%BCz%20otuzbe%C5%9F&op=translate)  
![image](https://user-images.githubusercontent.com/47416964/112975242-b29ed980-9153-11eb-972e-f974ba578250.png)  
A format locator finds the amount
![image](https://user-images.githubusercontent.com/47416964/112975332-c9ddc700-9153-11eb-9d5b-ba5e32121d37.png)  
A second format locator is customized to do the following
* Call a field formatter to format all of the alternatives of a previous locator.  [Turkish Number to Words Conversion](TurkishNumbers.md)
![image](https://user-images.githubusercontent.com/47416964/112975497-05789100-9154-11eb-929d-cb5f4a1855f7.png)    
* delete all of the Field Definitions in the current Format Locator and replace them with the values in the previous locator
![image](https://user-images.githubusercontent.com/47416964/112975612-28a34080-9154-11eb-9c30-07b7926ca261.png)  
* search for the expression on the document
![image](https://user-images.githubusercontent.com/47416964/112976076-b1ba7780-9154-11eb-9546-b04615fac95d.png)
* The confidence of the alternative tells you how closely the number and words agree.

```vb
Option Explicit

' Class script: moneytransfer

Private Sub Document_BeforeLocate(ByVal pXDoc As CASCADELib.CscXDocument, ByVal locatorname As String)
   Select Case locatorname
   Case "FL_AmountsInWords"
      Alternatives_Format(pXDoc.Locators.ItemByName("FL_Amounts").Alternatives,"TurkishNumbers")
      XDoc_Locate(pXDoc,"FL_Amounts", locatorname)
   End Select
End Sub

Public Sub Alternatives_Format(Alts As CscXDocFieldAlternatives, FieldFormatterName As String)
   'Format all alternatives of a Locator with a field formatter
   Dim FieldFormatter As ICscFieldFormatter, A As Long, Field As New CscXDocField, Alt As CscXDocFieldAlternative
   Set FieldFormatter=Project.FieldFormatters.ItemByName(FieldFormatterName)
   For A=0 To Alts.Count-1
      Set Alt=Alts(A)
      Field.Text=Alt.Text
      FieldFormatter.FormatField(Field)
      Alt.Text=Field.Text
   Next
End Sub

Public Sub XDoc_Locate(pXDoc As CscXDocument, SearchValuesLocator As String, LevenshteinLocatorName As String)
   'Fuzzy search a document for the alternatives of a locator
   'This adds Levenshtein Format Definitions to a format locator based on the alternatives to the SearchValuesLocator
   'Add reference to Kofax Cascade Format Locator
   'This will dynamically edit a format locator by deleting the existing format definitions and adding new ones
   'Be warned. This script alters the project itself and can corrupt your project. Make backups
   'You will need to close and re-open the locator to see the changes that it made
   'Your document needs to be correctly classified, so that the locator definition can be found
   Dim SearchValues As CscXDocFieldAlternatives, S As Long
   Dim Lev As CscFormatDefinition, FormatDefinitions As CscFormatDefinitions
   Set FormatDefinitions=Project.ClassByName(pXDoc.ExtractionClass).Locators.ItemByName(LevenshteinLocatorName).LocatorMethod.FormatDefinitions
   FormatDefinitions.Clear()
   Set SearchValues=pXDoc.Locators.ItemByName(SearchValuesLocator).Alternatives
   For S=0 To SearchValues.Count-1
      Set Lev=FormatDefinitions.Add(SearchValues(S).Text)
      Lev.FormatType=CscFormatDefinitionType.Levenshtein
      Lev.IgnoreCase=True
      Lev.WholeWord=False
   Next
End Sub
```
