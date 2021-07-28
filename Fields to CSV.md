# Export XDocument Fields to a CSV File
This script can be used in Project Designer to export Fields to a CSV file for testing, reporting and benchmarking.  
To run it just Extract the Document (F6) in Project Designer.

See [Table to CSV.md](Table%20to%20CSV.md) for extracting table fields.
```vb
Private Sub Document_AfterExtract(ByVal pXDoc As CASCADELib.CscXDocument)
   'Check that we are in the Designer and not in runtime
   If Project.ScriptExecutionMode = CscScriptExecutionMode.CscScriptModeServerDesign Then
      Fields_ToCSV(pXDoc.Fields, Replace(pXDoc.FileName, ".xdc",".csv"))
   End If
End Sub

Public Sub Fields_ToCSV(Fields As CscXDocFields, FileName As String)
   Dim F As Long, Field As CscXDocField, Delimiter As String
   Delimiter = vbTab  ' or "," or ";"
   Open FileName For Output As #1
   Print #1, vbUTF8BOM;  'To make a UTF-8 text file instead of an ANSI text file.
   'Print headers
   For F=0 To Fields.Count-1
      Select Case Field.FieldType
      Case CscFieldTypeSimpleField
         Print #1, Fields(F).Name & Delimiter;   ' the semicolon suppresses newline
      Case CscFieldTypeTable
         'Do nothing
      End Select
   Next
   Print #1, 'new line
   'Print each field
   For F=0 To Fields.Count-1
      Set Field=Fields(F)
      Select Case Field.FieldType
      Case CscFieldTypeSimpleField
         Print #1, Replace(Field.Text, Delimiter, "") & Delimiter ; 'remove delimiters from field values
         'You could also output Format(Field.Confidence, "0.00") if you like
      Case CscFieldTypeTable
         'Do nothing
      End Select
   Next
   Close #1
End Sub
```
