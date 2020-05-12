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

Private Sub SL_Angle_LocateAlternatives(ByVal pXDoc As CASCADELib.CscXDocument, ByVal pLocator As CASCADELib.CscXDocField)
   Dim hist(100) As Long, T As Long, Words As CscXDocWords, W As Long, Word1 As CscXDocWord, Word2 As CscXDocWord
   Dim H As Long, N As Long, BestN As Long, Mean As Double, Weight As Double, V As Long
   Dim angle As Double
   Dim Skewrange As Double
   Skewrange=π/8  'only consider skews between -22.5° and 22.5°.
   For T=0 To pXDoc.TextLines.Count-1
      Set Words=pXDoc.TextLines(T).Words
      For W=0 To Words.Count-2
         Set Word1=Words(W)
         For V=W+1 To Words.Count-1
            Set Word2=Words(V)
            If Word_Gap(Word1,Word2)>0.5 Then ' only consider words that are right after each other - no large gaps
               angle =arctan(Word_MidV(Word2)-Word_MidV(Word1),Word_MidH(Word2)-Word_MidH(Word1))
               If Abs(angle)<Skewrange Then ' we ignore skews outside of skewrange
                  'The histogram maps the angle range -Skewrange-->+SkewRange onto the array [0...100]
                  N=Round((angle/(Skewrange*2)+0.5)*UBound(hist),0)
                  hist(N)=hist(N)+1
               End If
            End If
         Next
      Next
   Next
   With pLocator.Alternatives.Create ' show the histogram for debugging
      For N=0 To UBound(hist)
         If hist(N)>hist(BestN) Then BestN=N
         .Text = .Text & CStr(hist(N)) & ";"
      Next
   End With

   For N=0 To UBound(hist) ' build a cheap 'Guassian' around the peak to consider the near neighbors to optimize the angle
      Mean=Mean+N*hist(N)/(Abs(BestN-N)+1)  'Weight the neighbours to consider their size, but punish by distance.
      Weight=Weight+hist(N)/(Abs(BestN-N)+1)
   Next
   angle=(Mean/Weight/UBound(hist)-0.5)*Skewrange*2
   With pLocator.Alternatives.Create
      .Confidence=1
      .Text=Format(angle,"0.0000") & " rad (" & Format(Degrees(angle),"##.00") & "°)"
   End With
End Sub

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
