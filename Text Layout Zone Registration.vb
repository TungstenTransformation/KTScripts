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
      if ZonesExist(I) and pXdoc.Pages.Count <= AZLSampleDoc.Pages.Count then
         Pages_Compare(AZLSampleDoc.Pages(I),pXDoc.Pages(I),pLocator.Alternatives,pXDoc.CDoc.Pages(I).XRes,pXDoc.CDoc.Pages(I).YRes)
      else
         pLocator.Alternatives.Add.Confidence=1.00
         pLocator.Alternatives.Add.Confidence=1.00
      end if
   Next
End Sub
