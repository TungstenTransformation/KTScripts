Public Sub SL_CustomZones(ByVal pXDoc As CASCADELib.CscXDocument, ByVal pLocator As CASCADELib.CscXDocField)
   'Add a script locator to your class called SL_CustomZones 
   'Script Locator . This creates a zone at left=50,top=300, width=24, height = 25 and calls OCR Profile "FR_HandAlphanum".
   Dim Zone As New CscXDocFieldAlternative, OCR_Chars As CscXDocChars
   Set Zone= pLocator.Alternatives.Create
   Zone.PageIndex=0 ' First Page
   Zone.Left=50 ' Pixels
   Zone.Width=25
   Zone.Top=300
   Zone.Height=25
   Set OCR_Chars=XDocument_ZonalOCR(pXDoc,Zone,"FR_HandAlphanum")
   Zone.Text=OCR_Chars.Text
   Zone.Confidence=OCR_Chars.ConfAvg
End Sub

Public Function XDocument_ZonalOCR(ByVal pXDoc As CscXDocument, zone As Object, ProfileName As String) As CscXDocChars
   'Zone can be a cscxdocfield, cscxdocword, cscxdocfieldalternative
   'Add reference to C:\Program Files (x86)\Common Files\Kofax\Components\MpsForms.6.0.dll
   'Perform zonal ocr on the CSCXDOCFIELD or CSCXDocSubfield passed in.
   Dim ZR As New MpsZoneRecognizing, ZonalProfile As IMpsRecogProfile, Image As CscImage, chars As CscXDocChars
   Dim ResultText As String, ResultConf As Double
   'Check if profile name exists and is zonal
   If Not Project.RecogProfiles.ItemExistsByName(ProfileName) Then Err.Raise(4566,"The profile " & ProfileName & " does not exist!")
   Set ZonalProfile=Project.RecogProfiles.ItemByName(ProfileName)
   If Not ZonalProfile.Type=MpsRecogType.MpsRecogTypeZone Then Err.Raise(4567,ProfileName & " is not a Zonal Profile!")
   If zone.PageIndex<0 Or zone.PageIndex>pXDoc.CDoc.Pages.Count-1 Then Err.Raise(4568, "Invalid Page Number: " & zone.PageIndex & "!")
   Set Image = pXDoc.CDoc.Pages(zone.PageIndex).GetBitonalImage(Project.ColorConversion)
   Set chars=New CscXDocChars
   ZR.Recognize(Image, ZonalProfile, zone.Left, zone.Top, zone.Width, zone.Height, ResultText, ResultConf, chars)
   zone.Text=ResultText
   zone.Confidence=ResultConf
   Return chars
End Function
