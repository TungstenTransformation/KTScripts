## Note
If a KT script contains the incredibly valuable keywords [**Return**](https://www.winwrap.com/web2/basic#!/ref/WWB-doc_return_instr.htm), **OrElse**, **AndAlso**, **IsNot** and **Iif**  
it needs to start with **'#Language "WWB-COM"**


```vb
'#Language "WWB-COM"
Private Sub Table_FromLocator(TableLocatorName As String, pXDoc As CscXDocument, LocatorName As String)
   'Copy the subfields of a locator into a Table. This doesn't check that the columns match, so you should!
   Dim Alternatives As CscXDocFieldAlternatives, A As Long, S As Long, SubField As CscXDocSubField, Row As CscXDocTableRow
   Dim W As Long, Table As CscXDocTable
   Set Alternatives=XDoc_RunPreviousLocator(pXDoc,LocatorName)
   With pXDoc.Locators.ItemByName(TableLocatorName).Alternatives(0)
      .Confidence=1    'Set the table's alternative's confidence=100% so that it gets copied to the Table Field
      Set Table=.Table
   End With
   Table.Rows.Clear 'remove anything from the table that the Automatic Table Locator may have found.

   'Copy all the subfields of the alternatives into the table cells
   For A=0 To Alternatives.Count-1
      Set Row=Table.Rows.Append
      For S=0 To Alternatives(A).SubFields.Count-1
         Set SubField=Alternatives(A).SubFields(S)
         For W=0 To SubField.Words.Count-1
            Row.Cells(S).AddWordData(SubField.Words(W))
         Next
         Row.Cells(S).Text=SubField.Text ' some subfields don't contain words
      Next
   Next
End Sub

Private Function XDoc_RunPreviousLocator(ByVal pXDoc As CASCADELib.CscXDocument,LocatorName As String) As CscXDocFieldAlternatives
   'This makes sure that the previous locators have been run. Project Builder can sometimes forget a locator's results.
   With pXDoc.Locators.ItemByName(LocatorName)
      If .Alternatives.Count=0 And Project.ScriptExecutionMode =CscScriptExecutionMode.CscScriptModeServerDesign Then  'Check that we are in Project Builder
         Project.ClassByName(pXDoc.ExtractionClass).Locate(pXDoc,.Index)  'run the locator
      End If
      Return .Alternatives  'return the locators' results
   End With
End Function
```
