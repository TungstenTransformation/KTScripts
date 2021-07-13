# Insert Missing Rows into a Table

This script contains two Subroutines  
* **Table_InsertMissingRows**  
searches through the textlines within the table and if any are missing, it inserts a new row at the correct position and copies ALL the words in the textline into the table row.  
* **Table_InsertMissingWords**  
searches through table rows for words that are missing from the table and inserts them.   

It uses the column left & width on that particular page to insert the words.  
These scripts are best called in the Document Event **Document_AfterLocate**.  
Add the script to the document class containing the Table Locator.
```vb
Private Sub Document_AfterLocate(ByVal pXDoc As CASCADELib.CscXDocument, ByVal LocatorName As String)
   Select Case LocatorName
   Case "TL"
      Table_InsertMissingRows(LocatorName,pXDoc)
      Table_InsertMissingWords(LocatorName,pXDoc)
   End Select
End Sub
Public Sub Table_InsertMissingRows(LocatorName As String,pXDoc As CscXDocument)
   'This script finds textlines that were skipped in the table locator and inserts them
   'This does NOT insert rows at the beginning of the table, nor after the end of the table
   Dim Table As CscXDocTable, Row As CscXDocTableRow, T As Long
   Set Table=pXDoc.Locators.ItemByName(LocatorName).Alternatives(0).Table
   If Table.Rows.Count<2 Then Exit Sub
   Set Row=Table.Rows(0)
   'Loop through all the textlines that are in the table.
   For T=Table.Rows(0).TextlineIndexStart To Table.Rows(Table.Rows.Count-1).TextlineIndexEnd
      If Row.IndexInTable=Table.Rows.Count-1 Then Exit For ' we reached the end of the table.
      If T<Row.TextlineIndexStart Then
         'this textline is missing from the table so insert a new Table Row
         Set Row=Table.Rows.Insert(Row.IndexInTable)
         TableRow_InsertWords(pXDoc.TextLines(T).Words,Table,Row)
      End If
      Set Row=Table.Rows(Row.IndexInTable+1)
   Next
End Sub

Public Sub Table_InsertMissingWords(LocatorName As String,pXDoc As CscXDocument)
   'This script finds textlines that were skipped in the table locator and inserts them
   'This does NOT insert new rows
   'This does not work well if table cells are multilined and a word to add is LEFT of an existing word in the cell
   Dim Table As CscXDocTable, Row As CscXDocTableRow, R As Long, T As Long, C As Long
   Dim Words As CscXDocWords, Word As CscXDocWord, W As Long
   Set Table=pXDoc.Locators.ItemByName(LocatorName).Alternatives(0).Table
   For R=0 To Table.Rows.Count-1
      Set Row=Table.Rows(R)
      For T=Row.TextlineIndexStart To Row.TextlineIndexEnd
         Set Words=pXDoc.TextLines(T).Words
         For W=0 To Words.Count-1
            Set Word=Words(W)
            C=Table_FindColumn(Word,Table)
            'If the word fits in a table column, but is not already in the table cell then add it
            If C>-1 And Object_OverlapHorizontal(Word,Row.Cells(C))=0 Then
               Row.Cells(C).AddWordData(Word)
            End If
         Next
      Next
   Next
End Sub

Public Sub TableRow_InsertWords(Words As CscXDocWords, Table As CscXDocTable, Row As CscXDocTableRow)
   'Add ALL Words to a Table Row, using the Column coordinates to find the correct cell
   Dim W As Long, Word As CscXDocWord, C As Long
   For W=0 To Words.Count-1
      Set Word=Words(W)
      C=Table_FindColumn(Word,Table)
      If C>-1 Then Row.Cells(C).AddWordData(Word)
   Next
End Sub

Public Function Table_FindColumn(a As Object, Table As CscXDocTable) As Long
   'Find the table column that aligns with the given object Word, Field, Alternative, Subfield
   Dim C As Long, Column As New CscXDocField
   For C=0 To Table.Columns.Count-1 'Find the correct column to insert the word into
      Column.PageIndex=a.PageIndex
      Column.Left=Table.Columns(C).Left(Column.PageIndex)
      Column.Width=Table.Columns(C).Width(Column.PageIndex)
      If Object_OverlapHorizontal(a,Column)>0 Then Return C
   Next
   Return -1 ' no match
End Function

Public Function Object_OverlapHorizontal( a As Object, b As Object) As Double
   'Calculates the horizontal overlap of two fields and returns 0<=overlap<=1
   'Overlap=1 is also returned if one field is inside the other
   If a.Width = 0 Or b.Width=0 Then Return 0
   Return Max((Min(a.Left+a.Width,b.Left+b.Width)-Max(a.Left,b.Left)),0)/Min(a.Width,b.Width)
End Function

Function Min(a,b) 'This is a typeless function. If given integers it will return an integer. If given strings, it will return a string
   Return IIf(a<b,a,b)
End Function

Function Max(a,b)
   Return IIf(a>b,a,b)
End Function
```
