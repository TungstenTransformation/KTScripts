# Text Deskew Algorithm for Kofax Transformation
This script enables Kofax Transformation to deskew B&W images, PDF documents, and any other document that fails to deskew correctly with VRS or OCR Engine.  
Kofax VRS can deskew color and grayscale images, but it cannot deskew B&W images.  
Kofax Transformation cannot deskew PDFs.  
Kofax RPA has no access to VRS.  
Abby Finereader within Kofax Transformation can rotate ±90°,180°, but it has difficulties deskewing text reliably.  
This algorithm runs **after** OCR is performed in Kofax Transformation and calculates the deskew angle of the page based on the OCR text.  
This angle can then be used to physically rotate the image (TODO) or to rotate the text layer of document, run locators, and re-rotate words back for User Validation.(TODO)  
**All locators** except Zone Locator and Barcode Locator rely on words being assigned to the correct text lines. If this fails because of skewing then locators will fail. This seriously impacts particularly the **Table Locator** and the learing **Group Locators**. It also has an impact on format locators and the **Database Locator**.  
This script solves all of these problems and also handles **B&W deskew** and **PDF deskew**  

The algorithm calculates the angle between all word pairs that are "next to" each other on the page and builds a histogram of these angles. The peak of the histogram is then taken as the skew angle (including some smoothing for neighbours)

```vba
Option Explicit
'#Language "WWB-COM"

' Class script: NewClass1

Const π= Atn(1)*4    ' 3.141592653589793238


Private Sub SL_RotateText_LocateAlternatives(ByVal pXDoc As CASCADELib.CscXDocument,ByVal pLocator As CASCADELib.CscXDocField)
   Dim Angle As Double, P As Long
   If pXDoc.Representations.Count=0 Then Exit Sub ' there is no OCR text
   For P=0 To pXDoc.CDoc.Pages.Count-1
      Angle=XDocument_CalculateTextSkew(pXDoc,0)
      With pLocator.Alternatives.Create
         .Confidence=1-P/100
         .Text=Format(Angle,"0.0000") & " rad (" & Format(Degrees(Angle),"##.00") & "°)"
         .StringTag=CStr(CInt(Angle*1000)) ' store angle for later use independent of regional settings
      End With
      XDocument_RotateText(pXDoc,P,Angle)
   Next
   'rebuild the text lines on the document
   pXDoc.Representations.Remove(0)' remove old rep
   pXDoc.Representations(0).AnalyzeLines
   pXDoc.Save
End Sub

Public Sub XDocument_RotateText(pXDoc As CscXDocument, PageNumber As Long, Angle As Double)
   'This rotates all text on the page through an angle (in radians) about the center of the page
   'it saves all word coordinates in an XValue for restoration later
   Dim C As Double, S As Double, M As Double, N As Double, Page As CscXDocPage, W As Long, X As Double, Y As Double
   Dim OCR As CscXDocRepresentation, Rotated As CscXDocRepresentation
   Dim XValue As CscXValue, XValueName As String, Word As CscXDocWord
   XValueName="Page " & Format(PageNumber,"000")
   If pXDoc.Representations.Count=0 Then Exit Sub ' there is no OCR text
   If pXDoc.XValues.ItemExists(XValueName) Then Exit Sub ' we have already rotated this page
   Set OCR=pXDoc.Representations(0)
   Set Rotated= pXDoc.Representations.Create(OCR.Name & " Rotated")
   C=Cos(Angle)
   S=Sin(Angle)
   With pXDoc.CDoc.Pages(PageNumber)' Find central coordinate of page to rotate around.
     ' M=.Width/2*(1-C)+.Height/2*S  ' We rotate the words relative to the middle of the page.
     ' N=.Height/2*(1-C)-.Width/2*S  '  This is the fixed part of the transform. It is the same for each word.
   End With
   Set Page=pXDoc.Pages(PageNumber)
   pXDoc.XValues.Add(XValueName,"",True)
   Set XValue=pXDoc.XValues.ItemByName(XValueName)
   For W=Page.Words.Count-1 To 0 Step -1
      Set Word=New CscXDocWord
      With Page.Words(W)
         XValue.Value=XValue.Value & CStr(.Left) & "," & CStr(.Top) & ";"
         Word.Text=.Text
         Word.Left=Round(.Left*C+.Top*S+M,0)
         Word.Top=Round(.Top*C-.Left*S+N,0)
         Word.Width=.Width
         Word.Height=.Height
         'Word.Confidence=.Confidence
         Rotated.Pages(PageNumber).AddWord(Word)
         Word.StringTag=CStr(.Left) & "," & CStr(.Top)
      End With
   Next
   pXDoc.Save
End Sub



Public Function XDocument_CalculateTextSkew(XDocument As CscXDocument, PageNumber As Long) As Double
   Dim hist(100) As Long, T As Long, Words As CscXDocWords, W As Long, Word1 As CscXDocWord, Word2 As CscXDocWord
   Dim H As Long, N As Long, BestN As Long, Mean As Double, Weight As Double, V As Long
   Dim Angle As Double, Page As CscXDocPage
   Dim Skewrange As Double
   Skewrange=Radians(22.5)  'only consider skews between -22.5° and 22.5°.
   Set Page=XDocument.Pages(PageNumber)
   For T=0 To Page.TextLines.Count-1
      Set Words=XDocument.TextLines(T).Words
      For W=0 To Words.Count-2
         Set Word1=Words(W)
         For V=W+1 To Words.Count-1
            Set Word2=Words(V)
            If Word_Gap(Word1,Word2)>0.5 Then ' only consider words that are right after each other - no large gaps
               Angle =arctan(Word_MidV(Word2)-Word_MidV(Word1),Word_MidH(Word2)-Word_MidH(Word1))
               If Abs(Angle)<Skewrange Then ' we ignore skews outside of skewrange
                  'The histogram maps the angle range -Skewrange-->+SkewRange onto the array [0...100]
                  N=Round((Angle/(Skewrange*2)+0.5)*UBound(hist),0)
                  hist(N)=hist(N)+1
               End If
            End If
         Next
      Next
   Next

   For N=0 To UBound(hist) 'find peak of histogram
      If hist(N)>hist(BestN) Then BestN=N
   Next

   For N=0 To UBound(hist) ' build a cheap 'Guassian' around the peak to consider the near neighbors to optimize the angle
      Mean=Mean+N*hist(N)/(Abs(BestN-N)+1)  'Weight the neighbours to consider their size, but punish by distance.
      Weight=Weight+hist(N)/(Abs(BestN-N)+1)
   Next
   Return (Mean/Weight/UBound(hist)-0.5)*Skewrange*2 'convert the histogram coordinate back to radians
End Function


Private Function Radians(Degrees As Double) As Double
   Return Degrees*π/180
End Function

Private Function Degrees(Radians As Double) As Double
   Return Radians*180/π
End Function

Private Function Word_MidV(Word As CscXDocWord) As Double
   'returns the vertical coordinate through the middle of the word
   Return Word.Top+Word.Height/2.0
End Function

Private Function Word_MidH(Word As CscXDocWord) As Double
   'returns the horizontal coordinate through the middle of the word
   Return Word.Left+Word.Width/2.0
End Function

Private Function Word_Gap(Word1 As CscXDocWord, Word2 As CscXDocWord) As Double
   'returns the size of the relative gap between words. returns zero of the word doesn't follow closely
   If Word2.Left<=Word1.Left Then Return 0
   Return Word1.Width/(Word2.Left-Word1.Left)
End Function

Private Function arctan(y As Double, x As Double) As Double
   'https://en.wikipedia.org/wiki/Atan2#Definition_and_computation
   If x=0 Then
      If y>0 Then Return π/2
      If y<0 Then Return -π/2
      Return 0 ' We don't throw an undefined exception because https://en.wikipedia.org/wiki/Atan2#Realizations_of_the_function_in_common_computer_languages
   ElseIf x>0 Then
      Return Atn(y/x)
   ElseIf y>=0 Then
      Return Atn(y/x)+π
   Else
      Return Atn(y/x)-π
   End If
End Function
```
