# Insert Missing Rows into a Table

This script searches through the textlines within the table and if any are missing, it inserts a new row at the correct position and copies ALL the words in the textline into the table row.  
It uses the column left & width on that particular page to insert the words.  
This script is best called in the Document Event **Document_AfterLocate**.
Add the script to the document class containing the Table Locator.
```vb
Public Sub Table_InsertMissingRows(LocatorName As String,pXDoc As CscXDocument)
   'This script finds textlines that were skipped in the table locator and inserts them
   'This does NOT insert rows at the beginning of the table, nor after the end of the table
   Dim Table As CscXDocTable, Row As CscXDocTableRow, T As Long
   Set Table=pXDoc.Locators.ItemByName("TL").Alternatives(0).Table
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

Public Sub TableRow_InsertWords(Words As CscXDocWords, Table As CscXDocTable, Row As CscXDocTableRow)
   'Add Words to a Table Row, using the Column coordinates to find the correct cell
   Dim W As Long, Word As CscXDocWord, C As Long, Column As New CscXDocField
   For W=0 To Words.Count-1
      Set Word=Words(W)
      For C=0 To Table.Columns.Count-1 'Find the correct column to insert the word into
         Column.PageIndex=Word.PageIndex
         Column.Left=Table.Columns(C).Left(Column.PageIndex)
         Column.Width=Table.Columns(C).Width(Column.PageIndex)
         If Object_OverlapHorizontal(Word,Column)>0 Then
            Row.Cells(C).AddWordData(Word)
            Exit For
         End If
      Next
   Next
End Sub

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
