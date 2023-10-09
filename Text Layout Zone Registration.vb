'#Language "WWB-COM"

Option Explicit
'This script uses all unique words on a page to register OCR and OMR zones to subpixel accuracy.
'!!! IMPORTANT !!!!
' Add on Menu/Edit/References...
'           "Microsoft Scripting Runtime" for Dictionary to find and match unique words
'           "Kofax Cascade Advanced Zone Locator" for retrieving the Zone Definitions
'Create One Locator
'  SL_CalculatePageShift (used for debugging, with subfields Scale, Shift, Confidence, Words, DPI.)
'  AZL (on the Registration Tab set to "None")

' Class script: document

Private Sub Document_BeforeLocate(ByVal pXDoc As CASCADELib.CscXDocument, ByVal LocatorName As String)
   If LocatorName = "AZL" Then
      'Move the Zones in the Advanced Zone Locator based on the Shifts and Scale
      Dim Shifts As CscXDocFieldAlternatives
      Dim Zones As CscXDocSubFields, AZL As CscAdvZoneLocator
      Set Shifts=pXDoc.Locators.ItemByName("SL_CalculatePageShift").Alternatives
      Set AZL = Project.ClassByName(pXDoc.ExtractionClass).Locators.ItemByName(LocatorName).LocatorMethod
      Zones_Shift(AZL.Zones,Shifts,pXDoc.Representations(0))
   End If
End Sub

Private Sub SL_CalculatePageShift_LocateAlternatives(ByVal pXDoc As CASCADELib.CscXDocument, ByVal pLocator As CASCADELib.CscXDocField)
   'Your document MUST be classified before calling this locator, in order to be able to find the sample image in the AZL.
   'This function is purely here for debugging. it is so that you can see the unique words that are used for matching
   Dim I As Long, StartWordIndexRef As Long, StartWordIndex As Long, EndWordIndexRef As Long, EndWordIndex As Long
   Dim AZLSampleDoc As CscXDocument, LeftShift As Double, DownShift As Double, Tolerance As Double, Confidence As Double
   Dim AZLSampleDocFileName As String
   AZLSampleDocFileName =Left(Project.FileName,InStrRev(Project.FileName,"\")) & "Samples\" & Class_GetClassPath(pXDoc.ExtractionClass) & "\Sample0.xdc"
   Set AZLSampleDoc = New CscXDocument
   AZLSampleDoc.Load(AZLSampleDocFileName)
   'Find which pages have zones on them
   Dim AZLDef As CscAdvZoneLocator, ZonesExist() As Boolean, Z As Long
   Set AZLDef=Project.ClassByName(pXDoc.ExtractionClass).Locators.ItemByName(LocatorName).LocatorMethod
   ReDim ZonesExist((pXDoc.Pages.Count-1))
      For Z=0 To AZLDef.Zones.Count-1
         ZonesExist(AZLDef.Zones(Z).PageNr)=True
      Next
   For I=0 To pXDoc.Pages.Count - 1
      if I < AZLSampleDoc.Pages.Count AndAlso ZonesExist(I) then
         Pages_Compare(AZLSampleDoc.Pages(I),pXDoc.Pages(I),pLocator.Alternatives,pXDoc.CDoc.Pages(I).XRes,pXDoc.CDoc.Pages(I).YRes)
      else
         pLocator.Alternatives.Add.Confidence=1.00
         pLocator.Alternatives.Add.Confidence=1.00
      end if
   Next
End Sub
Public Sub Zones_Shift(AZLZones As CscAdvZoneLocZones, Shifts As CscXDocFieldAlternatives, Rep As CscXDocRepresentation)
   Dim Z As Long, XDocZone As CscXDocZone
   While Rep.Zones.Count>0
      Rep.Zones.Remove(0)
   Wend
   For Z=0 To AZLZones.Count-1
      Set XDocZone=Zone_Shift(AZLZones(Z),Shifts,Rep)
      Rep.Zones.Append(XDocZone)
   Next
End Sub

Public Function Zone_Shift(AZLZone As CscAdvZoneLocZone, Shifts As CscXDocFieldAlternatives, Rep As CscXDocRepresentation) As CscXDocZone
   Dim XDocZone As CscXDocZone, X As Double, Y As Double, Right As Long, Bottom As Long
   Set XDocZone=New CscXDocZone
   XDocZone.PageNr=AZLZone.PageNr
   XDocZone.Name=AZLZone.Name
   'Shift the top right corner
   X=AZLZone.Left+AZLZone.Width
   Y=AZLZone.Top
   Coordinate_Shift(X,Y,Shifts,AZLZone.PageNr)
   Right=X
   'Shift the bottom left corner
   X=AZLZone.Left
   Y=AZLZone.Top+AZLZone.Height
   Coordinate_Shift(X,Y,Shifts,AZLZone.PageNr)
   Bottom=Y
   'Shift the Top Left corner
   X=AZLZone.Left
   Y=AZLZone.Top
   Coordinate_Shift(X,Y,Shifts,AZLZone.PageNr)
   XDocZone.Left=X
   XDocZone.Top=Y
   XDocZone.Width=Right-XDocZone.Left
   XDocZone.Height=Bottom-XDocZone.Top
   Return XDocZone
End Function

Public Sub Coordinate_Shift(ByRef X As Double, ByRef Y As Double, Shifts As CscXDocFieldAlternatives, page As Integer)
   Dim XRes As Long, YRes As Long, xm As Double, xb As Double, ym As Double, yb As Double
   With Shifts(page*2)
      xm=.SubFields.ItemByName("Scale").Confidence
      xb=.SubFields.ItemByName("Shift").Confidence
      XRes=.SubFields.ItemByName("DPI").Confidence
   End With
   With Shifts(page*2+1)
      ym=.SubFields.ItemByName("Scale").Confidence
      yb=.SubFields.ItemByName("Shift").Confidence
      YRes=.SubFields.ItemByName("DPI").Confidence
   End With
   X=X/25.4*XRes
   Y=Y/25.4*YRes
   X=xm*X+xb  'The Linear regression function gave us these slopes m and intercepts b.
   Y=ym*Y+yb
End Sub

