# Export a Table to CSV
This script can be used in Project Designer to export a Table Field to a CSV file for testing, reporting and benchmarking.  
To run it just Extract the Document (F6) in Project Designer.
```vb
Private Sub Document_AfterExtract(ByVal pXDoc As CASCADELib.CscXDocument)
   'Check that we are in the Designer and not in runtime
   If Project.ScriptExecutionMode = CscScriptExecutionMode.CscScriptModeServerDesign Then
      Table_ToCSV(pXDoc.Fields.ItemByName("Table").Table, "C:\temp\table.csv")
   End If
End Sub

Public Sub Table_ToCSV(Table As CscXDocTable, FileName As String)
   'Output a Table Field to a CSV file.
   Dim R As Long, Row As CscXDocTableRow, C As Long, Cell As CscXDocTableCell, Delimiter As String
   Delimiter = vbTab  ' or "," or ";"
   Open FileName For Output As #1
   print #1, vbUTF8BOM;  'To make a UTF-8 text file instead of an ANSI text file.
   'Print headers
   For C=0 To Table.Columns.Count-1
      Print #1, Table.Columns(C).Name & Delimiter;   ' the semicolon suppresses newline
   Next
   Print #1, 'new line
   'Print each table row
   For R=0 To Table.Rows.Count-1
      Set Row=Table.Rows(R)
      For C=0 To Row.Cells.Count-1
         Set Cell=Row.Cells(C)
         Print #1, Replace(Cell.Text,Delimiter,"") & Delimiter;  ' Make sure the delimiter is NOT in the table cell!!
      Next
      Print #1,
   Next
   Close #1
End Sub
```
