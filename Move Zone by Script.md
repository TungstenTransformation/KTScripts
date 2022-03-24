# Moving zones by script.
The zones in the Advanced Zone locator (AZL) can be moved around by 3 different methods.
* Using Locators as Anchors. 
  *This is the prefered method and requires no scripting. You cannot use a script locator as an anchor.*
* Adding Zones to the Default Representation by Script.  
*This method is explained below*
* Editing the Zone Locator itself.  
  *This is not recommended nor supported, and needs to be done in milimeters rather than pixels.*

## Adding Zones to the Default Representation by Script
The first Representation in an XDocument containes the full page OCR layer. Projects that use the AZL may not have an OCR layer - in this case the script creates a new representation.  
When the AZL is executed it checks whether **pXDoc.Representations.Zones** contains a Zone for each subfield. If one exists then OCR is performed on the Zone coordinates.  
Pass into the function a Field, Subfield, Alternative or TableCell.

```vb
Public Sub AZL_MoveZone(ByVal pXDoc As CASCADELib.CscXDocument, ZoneName As String, location As Object)
   'Move a zone in an Advanced Locator to somewhere else
   'This adds the zones to a representation that the Advanced Zone Locator always chceks for in case zones need moving.
   Dim Rep As CscXDocRepresentation, Zone As CscXDocZone, Z As Long
   If pXDoc.Representations.Count=0 Then pXDoc.Representations.Create("AdvZoneLoc")
   Set Rep = pXDoc.Representations(0)
   'delete this zone if already here
   For Z= Rep.Zones.Count-1 To 0 Step -1 'always count backwards when deleting
      If Rep.Zones(Z).Name=ZoneName Then Rep.Zones.Remove(Z):Exit For
   Next
   Set Zone = New CscXDocZone
   Zone.Name = ZoneName
   Zone.Left = location.Left
   Zone.Top = location.Top
   Zone.Width = location.Width
   Zone.Height = location.Height
   Zone.PageNr = location.PageIndex
   Rep.Zones.Append(Zone)
   'Create Boxes for Debugging, as these are visible in the XDoc Browser
   Dim Box As New CscXDocBox
   Box.Left = location.Left
   Box.Top = location.Top
   Box.Width = location.Width
   Box.Height = location.Height
   Box.PageIndex=location.PageIndex
   Rep.Boxes.Append(Box)
End Sub
```