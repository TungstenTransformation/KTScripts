# Image Cleanup before Page Recognition
Kofax Transformation has **Image Cleanup** profile that can remove/thicken/thin lines and remove speckles. They are found in Project Settings/Image Cleanup.
These image cleanup profiles are used by the Advanced Zone Locator, but they are also avialbe via script.  
The following script runs an image cleanup profile called "RemoveLines" over each page of a document and performs OCR with Page Recognition Profile "Omnipage" after the document is classified. This way you can choose to only perform the mage cleanup on particular classes. If you want to do this for every document class you can call the routine from **Document_BeforeClassifyXDoc**.

Note that Image Cleanup only works on black&white images. If your image is grayscale or color the script will use Kofax VRS to convert the image temporarily to black & white.
```vba
Option Explicit

' Project Script

Private Sub Document_AfterClassifyXDoc(ByVal pXDoc As CASCADELib.CscXDocument)
   Select Case pXDoc.ExtractionClass
      Case "NewClass1"
         ImageCleanFullPageRecognition(pXDoc, "RemoveLines", "OmniPage")
   End Select
End Sub



'##################################################################################################################
'# This example script describes how to perform image clean and full page recognition on a document in script
'##################################################################################################################
Public Sub ImageCleanFullPageRecognition( pXDoc As CscXDocument,  ImageCleanProfileName As String,  OCRProfileName As String)
   'Add reference to "Kofax Memphis Forms 4.0" in Menu/Edit/References...
   Dim P As Long, Image As CscImage, CleanedImage As CscImage
   Dim ImageCleanupProfile As  IMpsImageCleanupProfile,RecogProfile As IMpsRecogProfile, PageRecognizer As New MpsPageRecognizing
   Dim oICP As MpsImageCleanupProfile
   Dim oPRP As IMpsPageRecogProfile
   Dim oPR As New MpsPageRecognizing

   '# Remove any representations, before proceeding to perform image clean and full page recognition
   While pXDoc.Representations.Count>1
      pXDoc.Representations.Remove(0)
   Wend

   '# Go through each page of the document and image clean and full page recognition
   For P = 0 To pXDoc.CDoc.Pages.Count -1
      Set Image = pXDoc.CDoc.Pages(P).GetImage                       '# Get the original page image
      'ImageCleanupProfiles only work with Black&white images
      If Image.BitsPerSample>1 Then Set Image=Image.BinarizeWithVRS()
      '# Perform image clean
      Set ImageCleanupProfile = Project.ImageCleanupProfiles.ItemByName(ImageCleanProfileName)   '# Get the image clean profile from the project settings
      Set CleanedImage = ImageCleanupProfile.IPP.Preprocess(Image)               '# Image clean the original page image temporarily

      '# The next line is for debug purposes only. For a runtime environment comment out the line
      Image.Save("C:\temp\Test_" & Format(P,"00") & ".tif")

      '# Perform full text recognition on the image that has been cleaned
      pXDoc.CDoc.Pages(P).SetImage(CleanedImage)                           '# Replace the original page image with the image that has been cleaned

      '# At runtime the full page text recognition will be performed with the profile defined in the class properties, i.e. the default profile
      '# And the pXDoc will retain the oTemporaryImage until the next document is loaded by Kofax Transformation
      If Project.ScriptExecutionMode = CscScriptExecutionMode.CscScriptModeServerDesign Then
         Set RecogProfile = Project.RecogProfiles.ItemByName(OCRProfileName)              '# Get the page recognistion profile from the project settings
         PageRecognizer.Recognize(pXDoc, RecogProfile, P)                                        '# Perform recognition on the page
         pXDoc.CDoc.Pages(P).SetImage(Image)                         '# Replace the page image with the original page image
      End If

   Next

   '# At design time the text lines need to be analysed. At runtime this will be done automatically
   If Project.ScriptExecutionMode = CscScriptExecutionMode.CscScriptModeServerDesign Then pXDoc.Representations(0).AnalyzeLines

End Sub
```