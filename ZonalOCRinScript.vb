Public Function XDocument_ZonalOCR(ByVal pXDoc As CscXDocument, zone As Object, ProfileName As String) As CscXDocChars
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
