Public Function XDocument_ZonalOCR(ByVal pXDoc As CscXDocument, ByRef zone As Object, ProfileName As String) As CscXDocChars
   'Add reference to C:\Program Files (x86)\Common Files\Kofax\Components\MpsForms.6.0.dll
   'Perform zonal ocr on the CSCXDOCFIELD or CSCXDocSubfield passed in.
  'returns the text and confidence via the zone paramater and the character level data in the return value
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
            
Public Sub Document_PerformOCRonPage(pxdoc As CscXDocument,p As Long,profile As IMpsRecogProfile)
   'Add reference to C:\Program Files (x86)\Common Files\Kofax\Components\MpsForms.6.0.dll
   'Calls the given OCR profile on the pth page of the xdocument
   Dim w As Long
   Dim word As CscXDocWord
   Dim image As CscImage, imageVRS As CscImage
   Dim rep As CscXDocRepresentation
   ' Add reference to "Kofax Memphis Forms 4.0"
   Dim PageRecognizer As New MpsPageRecognizing
   Dim tempXdoc As new CscXDocument
   Set image = pxdoc.CDoc.Pages(p).GetImage 'This loads a TIFF image or renders a PDF as 300dpi image.
   Set imageVRS=image.BinarizeWithVRS()
   tempXdoc.CopyPages(pxdoc,p,1)
   tempXdoc.CDoc.Pages(0).SetImage imageVRS
   ' Call Full Page OCR Profile
   PageRecognizer.Recognize(tempXdoc, profile, 0)
   'copy all the words back to the original document
   For w = 0 To tempXdoc.Words.Count-1
      Set word = New CscXDocWord
      With tempXdoc.Words(w)
         word.Height = .Height
         word.Top = .Top
         word.Left = .Left
         word.Width = .Width
         word.Text = .Text
         word.PageIndex = .PageIndex
      End With
      pxdoc.Pages(p).AddWord(word)
   Next
   'Force KTM to find all text lines.
   'Rebuild pXDoc.TextLines (KTM does the line segmentation, not the OCR engine)
   pxdoc.Representations(0).AnalyzeLines
   pxdoc.Save
End Sub
