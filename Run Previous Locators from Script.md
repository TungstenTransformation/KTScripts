# Testing Script locators that rely on other locators for input.
When testing in Project Builder, it is possible that locators "forget" their test results, and hence following locator don't get the input they need.
Here are 3 solutions to solve this problem
1. Open the "Test" Button in the Locator and select "Run all previous Locators"
2. Test a previous locator Locator.
  * Don't close it (that can make it forget)
  * Rather, double-click the next locator you need. This double-clicking closes the current locator WITHOUT forgeting it's results.
  * Use the following script, where you can tell the script locator what the previous locators are, and they are run dynamically if they have "forgotten" their results.

# Running previous locators via script.
*Your XDoc **must** be classified for this to work. You will get an error if the XDoc is unclassified. It needs to be classified so that the script can find the locators in the Class Tree.
If you don't classify the XDocument, then the script will assume the Default Class.*

```vb
Private Function XDoc_PreviousLocator(ByVal pXDoc As CASCADELib.CscXDocument,LocatorName As String) As CscXDocFieldAlternatives
   'This makes sure that the previous locators have been run. Project Builder can sometimes forget a locator's results.
   Dim ClassName As String
   ClassName=IIf(pXDoc.ExtractionClass="",Project.ClassByID(Project.DefaultClassId),pXDoc.ExtractionClass)
   With pXDoc.Locators.ItemByName(LocatorName)
      If .Alternatives.Count=0 And Project.ScriptExecutionMode =CscScriptExecutionMode.CscScriptModeServerDesign Then  'Check that we are in Project Builder
         Project.ClassByName(ClassName).Locate(pXDoc,.Index)  'find the locator in the Class Tree and run it
      End If
      Return .Alternatives  'return the locator's results
   End With
End Function

Private Sub Scriptlocator_Altneratives(ByVal pXDoc As CASCADELib.CscXDocument,pLocator As CSCXDocField)
   Dim PONumbers as CSCXDocFieldAlternatives
   Set PONumbers=XDoc_PreviousLocator(pXDoc,"AE_PONumber")  ' This will get all the alternatives found by the locator "AE_PONumber". The locator will be executed if empty.
   If PONumbers.Count=0 Then Exit Sub
End Sub
```
