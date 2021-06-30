# Table Extraction By Regex
Extracting tables via regex is simple and effective if the following are true.
* All of the documents have the same table columns in the same order
* All of the table cells are compulsory. Optional cells will result in following cells shifted to the left
* The OCR quality is excellent. If there are OCR errors that break the regex pattern, then those rows will be omitted

## Configuration
1. Add a Format Locator to your project that finds all table rows.
1. Add a Table Model to your project.
2. Add a Table Locator to your class.
3. Add the Table Model to the Table Locator.
4. Set the Table Locator to "Manual" and make sure it has no other settings. This is to effectively disable the table locator, since you will customize it.  
![image](https://user-images.githubusercontent.com/47416964/123967562-b7736380-d9b6-11eb-8fd6-c90ed15dfb63.png)
6. Add a Table field and associate the field to the table locator
7. Determine your Regex Pattern to match all cells in the row.
   * **([\d\,\.]+)\s+(.*?)\s+([\d\,\.\-]+)\s+([\d\,\.\-]+)\s+([\d\,\.\-]+)\s+([\d\,\.\-]+)** matches number, text, number, number, number
   * The round brackets () match each cell. The example above is looking for numeric, text, numeric, numeric, numeric cells.
   * **[\d\,\.\-]+** matches numbers containing 0-9,.-. (Note that OCR engines easily mix up "." and "," so the regex is not so strict about order).
   * **\s+** matches space(s) between the cells. There should only be one space between words in KT, but sometimes PDFs do very wierd things and have multiple spaces and/or tabs, that OCR engines do not do.
   * **(.\*?)** is a [non-greedy](https://www.rexegg.com/regex-quantifiers.html) match for anything - this is useful to match a text description when all the other cells are numeric.
8. Add the script below to the Class script. The script does the following
  * Uses the script event **Document_AfterLocate** to run **Table_AddRowsFromAlternatives** after the Text Locator has run.
  * Deletes any table rows that might exist (**Table.Rows.Clear**)
  * Loops through the alternatives of the format locator.
    * Check if the alternative matches the regex.
    * If it matches then add a new table row
    * Add all the words of the text line to the correct cell in the row (by word counting) using the method **AddWordData**, which not only adds text to the cells, it also adds word coordinates, which update the cell, row and table coordinates.
10. You will need to add references to **Kofax Cascade Table Locator** and **Microsoft VB Regular Expressions 5.5** in **Script Menu/Edit/References...**  
![image](https://user-images.githubusercontent.com/47416964/123967709-de319a00-d9b6-11eb-8901-6b9aaa952cf9.png)

```vb
Option Explicit

' Class script: mizan
'#Language "WWB-COM"

Private Sub Document_AfterLocate(ByVal pXDoc As CASCADELib.CscXDocument, ByVal LocatorName As String)
   Dim Locator As CscXDocField, Pattern As String, Rows As CscXDocFieldAlternatives
   Set Locator=pXDoc.Locators.ItemByName(LocatorName)
   Select Case Locator.Name
   Case "TL" 'if we are in the Table Locator
      Pattern="([\d\.]+)\s+(.*?)\s+([\d\,\.]+)\s+([\d\,\.]+)\s+([\d\,\.]+)\s+([\d\,\.]+)" ' Regex Pattern for all cells in the row
      Set Rows=pXDoc.Locators.ItemByName("FL_Rows").Alternatives 'all the rows of text on the document that need to be added to the table
      Table_AddRowsFromAlternatives(Locator.Alternatives(0).Table,Rows,Pattern,pXDoc)
   End Select
End Sub

Private Sub Table_AddRowsFromAlternatives(Table As CscXDocTable, Alts As CscXDocFieldAlternatives,Pattern As String, pXDoc As CscXDocument)
   'Add reference to Kofax Cascade Table Locator
   Dim Row As CscXDocTableRow, a As Long, Words As CscXDocWords, Cell As CscXDocTableCell, W As Long, results() As String, R As Long, c As Long
   Dim TableLoc As CscTableLocator
   Set TableLoc= Project.ClassByName("mizan").Locators.ItemByName("TL").LocatorMethod
   Table.Rows.Clear
   For a=0 To Alts.Count-1
      Set Words=Alts(a).Words
      If String_RegexSearch(Words.Text,Pattern,results)>0 Then
         Set Row=Table.Rows.Append ' Add a new row to the table
         W=0 ' for keeping track of the word id in the text line.
         For R=0 To min(UBound(results), Row.Cells.Count-1) ' loop through the Regex results
            If results(R)<>"" Then ' add words
               For c=0 To String_CountSpaces(results(R)) 'count the number of words in the cell value (text cells may contain more than one word)
                  Row.Cells(R).AddWordData(Words(W)) ' Add word and coordinates to the table cell.
                  W=W+1
               Next
            End If
         Next
      End If
   Next
End Sub

Function min(a,b)
   Return IIf(a>b,a,b)
End Function

Function String_CountSpaces(a As String) As Long
   'Calculates how many spaces are in string
   return len(a)-len(replace(a," ",""))
End Function

Private Function String_RegexSearch(txt As String, Pattern As String,ByRef results() As String) As Long
   'This function is the simplest way to split strings
   'Add refence to "Microsoft VBScript Regular Expressions 5.5"
   'Returns as an array regex matches and the number of result-sets found, however only the first result-set is returned
   'e.g. Searching for pattern "(\d).(\d)(\d+)" in text "4/5460" will return "4","5","460"
   'Failed searches will return an empty array and 0 
   Dim regex As VBScript_RegExp_55.IRegExp2
   Dim matches As VBScript_RegExp_55.IMatchCollection2
   Dim a As Long
   Set regex = New VBScript_RegExp_55.RegExp
   regex.Pattern=Pattern
   Set matches = regex.Execute(txt)
   If matches.Count>0 Then
      With matches(0)
         ReDim results(.SubMatches.Count)
         For a = 0 To .SubMatches.Count-1
            results(a)=.SubMatches(a)
         Next
      End With
   End If
   Return matches.Count
End Function
```
