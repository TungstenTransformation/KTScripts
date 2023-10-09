'#Language "WWB-COM"
Option Explicit
'This script classifies a page based on the position of EVERY uniqie word on the page.
'It combines the power of text classification with the precision of word position.
'it can detect subtle differences between two document types that differ by only a few words
'   (perhaps one extra line of text was added or removed)
' If a forms document has a very slight adjustment from version to version, this can distinguish them easily.

' https://github.com/KofaxTransformation/KTScripts/blob/master/Text%20Layout%20Classification%20and%20Registration.md


Private Sub Document_AfterClassifyXDoc(ByVal pXDoc As CASCADELib.CscXDocument)
   Document_Reclassify(pXDoc)
End Sub

Private Sub Document_Reclassify(pXDoc As CscXDocument)
   Dim C As Long, ClassId As Long, ClassName As String, confidence As Double, CR As CscResult
   Dim BestClassID As Long, BestConfidence As Double
   BestConfidence=0
   Set CR=pXDoc.ClassificationResult
   For C=0 To CR.NumberOfConfidences-1 'Loop through all the best classification results from Layout and Text Classification.
      confidence=Document_TextLayoutClassification(pXDoc,CR.BestClassId(C)) 'Recalculate the confidence using "Text Layout" Algorithm
      If confidence>BestConfidence Then 'keep track of the best result
         BestConfidence=confidence
         BestClassID=C
      End If
      CR.SetResultItem(ClassId,confidence,CR.BestResultType(ClassId))
   Next
   pXDoc.Reclassify(Project.ClassByID(BestClassID).Name,BestConfidence) 'reclassify the document to the best class
End Sub

Private Function Document_TextLayoutClassification(pXDoc As CscXDocument, ClassId As Long) As Double 'returns confidence of "text layout" algorithm
   Dim Sample As New CscXDocument, FolderName As String, FileName As String, ClassName As String, R As Long
   Dim confidence As Double
   'Get the first classification training sample  :TODO look in the SQLLite database for the first active document
   FolderName=Left(Project.FileName,InStrRev(Project.FileName,"\")-1) & "\ClassificationTraining\" & Project.ClassByID(ClassId).Name
   FileName=Dir(FolderName & "\*.xdc")
   If FileName ="" Then Return 0' check that this class actually has training samples
   Sample.Load(FolderName & "\" & FileName)
   Dim Results As CscXDocField
   Set Results=Pages_Compare(pXDoc.Pages(0),Sample.Pages(0),pXDoc.CDoc.Pages(0).XRes,pXDoc.CDoc.Pages(0).YRes) 'compare the first pages only
   'Multiply the R factor (smoothness of linear fit) and raise to the power of 10 to punish poor matches
   confidence=(Results.Alternatives(0).SubFields.ItemByName("Smoothness").Confidence * Results.Alternatives(1).SubFields.ItemByName("Smoothness").Confidence)^10
   Return confidence
End Function

Private Sub SL_UniqueWords_LocateAlternatives(ByVal pXDoc As CASCADELib.CscXDocument, ByVal pLocator As CASCADELib.CscXDocField)
   'Your document MUST be classified before calling this locator, in order to be able to find the sample image in the AZL.
   'This function is purely here for debugging. it is so that you can see the unique words that are used for matching
   Dim I As Long, StartWordIndexRef As Long, StartWordIndex As Long, EndWordIndexRef As Long, EndWordIndex As Long
   Dim AZLSampleDoc As CscXDocument, LeftShift As Double, DownShift As Double, Tolerance As Double, confidence As Double
   Dim AZLSampleDocFileName As String
   AZLSampleDocFileName =Left(Project.FileName,InStrRev(Project.FileName,"\")) & "Samples\" & Class_GetClassPath(pXDoc.ExtractionClass) & "\Sample0.xdc"
   Set AZLSampleDoc = New CscXDocument
   AZLSampleDoc.Load(AZLSampleDocFileName)
   For I=0 To pXDoc.Pages.Count - 1
      Pages_Compare(AZLSampleDoc.Pages(I),pXDoc.Pages(I),pXDoc.CDoc.Pages(I).XRes,pXDoc.CDoc.Pages(I).YRes)
   Next
End Sub

Private Function Class_GetClassPath(ClassName As String) As String
   'Recursively work out the ClassPath
   Dim ParentClass As CscClass
   Set ParentClass=Project.ClassByName(ClassName).ParentClass
   If ParentClass Is Nothing Then
      Return ClassName
   Else
      Return Class_GetClassPath(ParentClass.Name) & "\" & ClassName
   End If
End Function
