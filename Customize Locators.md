# Customizing Any Locator
All locators (including Table Locators) in Kofax Transformation are customizable. The script events **Document_BeforeLocate** and **Document_AfterLocate** run on every locator. This gives you the chance to prepare a locator up front or to change the results of a loator
When a locator is run or when you press **Test** on a locator the following 4 steps happen
1. **Document_BeforeLocate** is called
1. The locator runs normally
1. **Document_AfterLocate** is called
1. The alternatives are re-sorted. (This is very cool! your script can add/delete alternatives and change the confidences)

Here is an example of Document_AfterLocate dealing with 5 different locators
```vb
Private Sub Document_AfterLocate(ByVal pXDoc As CASCADELib.CscXDocument, ByVal LocatorName As String)
   Select Case LocatorName
      Case "TL_Procedures" 'do some custom work on the table
         Table_Procedures(pXDoc,pXDoc.Locators.ItemByName(LocatorName).Alternatives(0).Table)
      Case "FL_LastNames", "FL_FirstNames", "FL_Procedures" ' remove alternatives below 100%
         Alternatives_RemoveBelow(pXDoc.Locators.ItemByName(LocatorName).Alternatives,1.00)
      Case "FL_Amounts" ' remove alternatives below 75%
         Alternatives_RemoveBelow(pXDoc.Locators.ItemByName(LocatorName).Alternatives,0.75)
   End Select
End Sub
```
## Document_BeforeLocate
Set a region dynamically in a locator at runtime
```vb
Public Sub Locator_SetRegion(ByVal pXDoc As CASCADELib.CscXDocument, LocatorName As String, Region As Object)
   'This locator dynamically sets the region on a following locator.
   'You can pass it a field, alternative, subfield - any object that contains pageid, left, width, top and height.
   'Your documents MUST already be classified for this to work. So before you test a locator, make sure that the document is classified (F5) or extracted (F6)
   Dim Page As CscCDocPage
   Set Page=pXDoc.CDoc.Pages(Region.PageIndex)
   With Project.ClassByName(pXDoc.ExtractionClass).Locators.ItemByName(LocatorName).LocatorRegions
      .Clear ' remove all regions from the locator
      'Documents have coordinates in pixels and regions are measured in millimeters.
      'To convert pixels to mm, we need to divide by the resolution (dots per inch) and then multiply by 25.4 (1 inch is exactly 25.4 mm, https://en.wikipedia.org/wiki/Inch)
      .AddRegion("RegionName",Region.Left/Page.XRes*25.4,Region.Top/Page.YRes*25.4,Region.Width/Page.XRes*25.4,Region.Height/Page.YRes*25.4,0,1)
   End With
End Sub
```

## Document_AfterLocate
Remove Alternatives below a threshhold.
```vb
Private Sub Alternatives_RemoveBelow(Alts As CscXDocFieldAlternatives, Confidence As Double)
   Dim A As Long
   For A=Alts.Count-1 To 0 Step -1 'always count backwards when deleting
      If Alts(A).Confidence<Confidence Then Alts.Remove(A)
   Next
End Sub
```
Format all Alternatives and remove those that fail.
```vb
Private Sub Alternatives_RemoveBad(Alts As CscXDocFieldAlternatives, FormatterName as string)
   Dim A As Long, F as New CscXDocField
   For A=Alts.Count-1 To 0 Step -1 'always count backwards when deleting
      F.text=alts(A).text
      If project.FieldFormatters.ItemByName(FormatterName).FormatField(F) Then 
        alts(A).text=F.text
      Else
        Alts.Remove(A)
      End If
   Next
End Sub
```
