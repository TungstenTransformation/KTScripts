# Table Extraction By Regex
Extracting tables via regex is simple and effective if the following are true.
* All of the documents have the same table columns in the same order
* All of the table cells are compulsory. Optional cells will result in following cells shifted to the left
* The OCR quality is excellent. If there are OCR errors that break the regex pattern, then those rows will be omitted

## Configuration
1. Add a Table Model to your project.
2. Add a Table Locator to your class.
3. Add the Table Model to the Table Locator.
4. Set the Table Locator to "Manual" and make sure it has no other settings. This is to effectively disable the table locator, since you will customize it.
5. Add a Table field and associate the field to the table locator
6. Determine your Regex Pattern to match all cells in the row.
 * **([\d\,\.]+)\s+(.*?)\s+([\d\,\.\-]+)\s+([\d\,\.\-]+)\s+([\d\,\.\-]+)\s+([\d\,\.\-]+)** matches number, text, number, number, number
 * **[\d\,\.\-]+** matches numbers containing 0-9,.-. (Note that OCR engines easily mix up "." and "," so the regex is not so strict about order.
 * **\s+** matches space(s) between the cells.
 * **(.\*?)** is a [non-greedy](https://www.rexegg.com/regex-quantifiers.html) match for anything - this is useful to match a text description when all the other cells are numeric.
8. Add the following script to the Class script
```vb
Option Explicit

' Class script: mizan
'#Language "WWB-COM"

Private Sub Document_AfterLocate(ByVal pXDoc As CASCADELib.CscXDocument, ByVal LocatorName As String)
   Dim Locator As CscXDocField, Pattern As String, Rows As CscXDocFieldAlternatives
   Set Locator=pXDoc.Locators.ItemByName(LocatorName)
   Select Case Locator.Name
   Case "TL"
      Pattern="([\d\.]+)\s+(.*?)\s+([\d\,\.]+)\s+([\d\,\.]+)\s+([\d\,\.]+)\s+([\d\,\.]+)"
      Set Rows=pXDoc.Locators.ItemByName("FL_Rows").Alternatives
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
         Set Row=Table.Rows.Append
         W=0
         For R=0 To min(UBound(results), Row.Cells.Count-1)
            If results(R)<>"" Then ' add words
               For c=0 To String_CountSpaces(results(R))
                  Row.Cells(R).AddWordData(Words(W))
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
   Dim c As Long
   For c=1 To Len(a)
      If Mid(a,c,1)=" " Then String_CountSpaces=String_CountSpaces+1
   Next
End Function


Private Function String_RegexSearch(txt As String, Pattern As String,ByRef results() As String) As Long
   'This function is the simplest way to split strings
   'Add refence to "Microsoft VBScript Regular Expressions 5.5"
   'Returns as an array regex matches and the number of result-sets found, however only the first result-set is returned
   'e.g. Searching for pattern "(\d).(\d)(\d+)" in text "4/5460" will return "4","5","460"
   'Failed searches will return an empty array and zero
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
