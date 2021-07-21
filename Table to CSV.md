# Export a Table to CSV
this script can be used in the Designer to export a Table Field to a CSV file for testing, reporting and benchmarking.
```vb
Private Sub Document_AfterExtract(ByVal pXDoc As CASCADELib.CscXDocument)
   'only run this script in designer, not at runtime
   If Project.ScriptExecutionMode = CscScriptExecutionMode.CscScriptModeServerDesign Then
      Table_ToCSV(pXDoc.Fields.ItemByName("Table").Table, "C:\temp\table.csv")
   End If
End Sub

Public Sub Table_ToCSV(Table As CscXDocTable, FileName As String)
   Dim R As Long, Row As CscXDocTableRow, C As Long, Cell As CscXDocTableCell, Delimiter As String
   Open FileName For Output As #1
   Delimiter =vbTab
   'Print headers

   For C=0 To Table.Columns.Count-1
      Print #1, Table.Columns(C).Name & Delimiter;   ' the semicolon suppresses newline
   Next
   Print #1, 'new line
   For R=0 To Table.Rows.Count-1
      Set Row=Table.Rows(R)
      For C=0 To Row.Cells.Count-1
         Set Cell=Row.Cells(C)
         Print #1, Cell.Text & Delimiter;
      Next
      Print #1,
   Next
   Close #1
End Sub
```
