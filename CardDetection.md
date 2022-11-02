# Find identity cards on a larger document
This script identifies smaller documents on a page containing more than 1 document.
It loops through all child classes of **card** and matches the words in the one classification training sample to the test document.  
![image](https://user-images.githubusercontent.com/47416964/199506513-11de768c-6392-4a5e-9ae7-46c7989eccc7.png)  
Add a script locator **SL_ClassifyCard** to the document class.  
Test the Locator. It will produce results in the Alternatives.  
```vb
'#Language "WWB-COM"
Option Explicit

' Class script: document

Private Sub SL_ClassifyCard_LocateAlternatives(ByVal pXDoc As CASCADELib.CscXDocument, ByVal pLocator As CASCADELib.CscXDocField)
   Dim Cl As CscClass, C As Long
   With Project.ClassByName("card").SubClasses
      For C= 1 To .Count
         Set Cl=.ItemByIndex(C)
         SL_CalculatePageShift_LocateAlternatives(pXDoc,pLocator, Cl.Name)
      Next
   End With
End Sub

Private Sub SL_CalculatePageShift_LocateAlternatives(ByVal pXDoc As CASCADELib.CscXDocument, ByVal pLocator As CASCADELib.CscXDocField,ClassName As String)
   'Your document MUST be classified before calling this locator, in order to be able to find the sample image in the AZL.
   'This function is purely here for debugging. it is so that you can see the unique words that are used for matching
   Dim I As Long, StartWordIndexRef As Long, StartWordIndex As Long, EndWordIndexRef As Long, EndWordIndex As Long
   Dim SampleDoc As CscXDocument, LeftShift As Double, DownShift As Double, Tolerance As Double, Confidence As Double
   Dim SampleDocFileName As String
   SampleDocFileName =Left(Project.FileName,InStrRev(Project.FileName,"\")) & "ClassificationTraining\" & ClassName
   SampleDocFileName=SampleDocFileName & "\" &Dir(SampleDocFileName & "\*.xdc") 'get first XDoc in the folder
   Set SampleDoc = New CscXDocument
   SampleDoc.Load(SampleDocFileName)
   For I=0 To pXDoc.Pages.Count - 1
      Pages_Compare(SampleDoc.Pages(I),pXDoc.Pages(I),pLocator.Alternatives,pXDoc.CDoc.Pages(I).XRes,pXDoc.CDoc.Pages(I).YRes,ClassName)
   Next
End Sub

Public Sub Pages_Compare(page1 As CscXDocPage, page2 As CscXDocPage,Results As CscXDocFieldAlternatives, XRes As Long, YRes As Long, ClassName As String)
   'Find as many unique anchors between the two pages and work out the shift and scaling between them
   'This algorithm is very robust against OCR errors.
   'The algorithm has order of page.words.count, i.e. linear, so VERY FAST.
   Dim Words1 As Dictionary, Words2 As Dictionary, WordText As String, X() As Long, Y() As Long
   Dim Word1 As CscXDocWord, Word2 As CscXDocWord
   Dim VectorField As CscXDocField, Result As CscXDocFieldAlternative, B As Long, C As Long
   Dim Vectors As CscXDocFieldAlternatives, Vector As CscXDocFieldAlternative
   Set VectorField=New CscXDocField
   Set Vectors=VectorField.Alternatives
   Set Words1=Page_GetUniqueWords(page1,0,page1.Words.Count-1)
   Set Words2=Page_GetUniqueWords(page2,0,page2.Words.Count-1)
   'Build a list of the unique words that appear on BOTH pages
   'Open "C:\temp\words.txt" For Output As #1
   For Each WordText In Words1.Keys
     If Len(WordText) >= 3  And IsNumeric(WordText) = False Then 'only match words with 6 or more characters
         If Words2.Exists(WordText) Then 'This unique word appears on both pages
            Set Word1=Words1(WordText)
            Set Word2=Words2(WordText)
            Set Vector=Vectors.Create
            Vector.Left=Word1.Left+Word1.Width/2
            Vector.Top=Word1.Top+Word1.Height/2
            Vector.Width=Word2.Left+Word2.Width/2
            Vector.Height=Word2.Top+Word2.Height/2
            Vector.Text=Word1.Text
    '        Print #1, Vector.Text & vbTab & CStr(Vector.Left) & vbTab & CStr(Vector.Top) & vbTab & CStr(Vector.Width) & vbTab & CStr(Vector.Height)
         End If
    End If
   Next
   Set Result= Results.Create
   Result.SubFields.Create("Class").Text=ClassName
   If Vectors.Count<4 Then ' Do nothing if less than 4 text anchors
      Result.SubFields.Create("Anchors").Text=CStr(Vectors.Count)
      Result.Confidence=1.0-(Results.Count*0.000001)
      Result.SubFields.Create("Confidence").Text="0.0%"
      Exit Sub
   End If
   LinearRegression(Vectors,True,Result,XRes,Results.Count-1) 'Calculate horizontal shift, scale and smoothness
   Set Result= Results.Create : Result.SubFields.Create("Class")
   LinearRegression(Vectors,False,Result,YRes,Results.Count-1) 'Calculate vertical shift, scale and smoothness
   Line_RemoveOutliers(Vectors,Results, 3.0) ' remove all outlier points (mismatched words) more than 3.0 times the average distance away.
   'While Results.Count>0
   '   Results.Remove(0)
   'Wend
   'recalculate the lines without the outlier points
   Set Result= Results.Create : Result.SubFields.Create("Class")
   LinearRegression(Vectors,True,Result,XRes,Results.Count-1) 'Calculate horizontal shift, scale and smoothness
   Set Result= Results.Create : Result.SubFields.Create("Class")
   LinearRegression(Vectors,False,Result,YRes,Results.Count-1) 'Calculate vertical shift, scale and smoothness
End Sub

Public Sub Line_RemoveOutliers(Vectors As CscXDocFieldAlternatives, Results As CscXDocFieldAlternatives, Tolerance As Double)
   Dim V As Long, Vector As CscXDocFieldAlternative, Result As CscXDocFieldAlternative
   Dim AverageDistance As Double
   Set Result=Results(Results.Count-2)
   'Calculate average distance for horizontal points
   AverageDistance=0
   For V=Vectors.Count-1 To 0 Step 0-1
      Set Vector=Vectors(V)
      Vector.Confidence=Line_Distance(Vector.Left,Vector.Width,Result)
      AverageDistance=AverageDistance+Vector.Confidence
   Next
   AverageDistance=AverageDistance/Vectors.Count
   'remove points with horizontal distance 3 times the average
   For V=Vectors.Count-1 To 0 Step 0-1
      Set Vector=Vectors(V)
      If Vector.Confidence>AverageDistance*Tolerance Then
         Vectors.Remove(V)
      End If
   Next
   Set Result=Results(Results.Count-1)
   'Calculate average distance for vertical points
   AverageDistance=0
   For V=Vectors.Count-1 To 0 Step 0-1
      Set Vector=Vectors(V)
      Vector.Confidence=Line_Distance(Vector.Top,Vector.Height,Result)
      AverageDistance=AverageDistance+Vector.Confidence
   Next
   AverageDistance=AverageDistance/Vectors.Count
   'remove points with vertical distance 3 times the average
   For V=Vectors.Count-1 To 0 Step 0-1
      Set Vector=Vectors(V)
      If Vector.Confidence>AverageDistance*3 Then
         Vectors.Remove(V)
      End If
   Next
End Sub

Public Function Line_Distance(A As Double, B As Double, LR As CscXDocFieldAlternative)
   'Calculates the distance from a point (A,B) to a line y= Scale *x + Shift.
   'https://en.wikipedia.org/wiki/Distance_from_a_point_to_a_line#Line_defined_by_an_equation
   Dim Scale As Double, Shift As Double
   Scale=LR.SubFields.ItemByName("Scale").Confidence
   Shift=LR.SubFields.ItemByName("Shift").Confidence
   Return Abs(Scale*A - B + Shift)/Sqr(Scale^2+Shift^2)
End Function

Public Function Page_GetUniqueWords(page As CscXDocPage,StartWordIndex As Long,EndWordIndex As Long) As Dictionary
   'Add Reference to "Microsoft Scripting Runtime" for Dictionary
   'Find all words on the page that only appear once
   Dim w As Long, Word As CscXDocWord, WordText As String
   Dim Words As New Dictionary
   For w=StartWordIndex To EndWordIndex
      Set Word=page.Words(w)
      If Words.Exists(Word.Text) Then
         Set Words(Word.Text) = Nothing 'this word is not unique
      Else
         Words.Add(Word.Text,Word)
      End If
   Next
   For Each WordText In Words.Keys 'Remove the non-unique words
      If Words(WordText) Is Nothing Then Words.Remove(WordText)
   Next
   Return Words
End Function

Public Sub LinearRegression(Vectors As CscXDocFieldAlternatives, Horizontal As Boolean, Result As CscXDocFieldAlternative, Resolution As Long,AlternativeIndex As Double)
   'http://en.wikipedia.org/wiki/Simple_linear_regression' https://www.easycalculation.com/statistics/learn-regression.php
   'The 1st Alternative has the horizonatal Scaling=M, Shift=B, and Confidence=flatness of the paper.
   'The 2nd Alternative has the vertical    Scaling=M, Shift=B, and Confidence=flatness of the paper.
   Dim X As Double, Y As Double, Sx As Double, Sy As Double, Sxy As Double, Sxx As Double, Syy As Double, V As Long
   Dim B As Double, M As Double, N As Long, R As Double
   For V= 0 To Vectors.Count-1
      If Horizontal Then
         X=Vectors(V).Left
         Y=Vectors(V).Width
      Else
         X=Vectors(V).Top
         Y=Vectors(V).Height
      End If
      Sx=Sx+X
      Sy=Sy+Y
      Sxy=Sxy+X*Y
      Sxx=Sxx+X^2
      Syy=Syy+Y^2
   Next
   N=Vectors.Count
   M=(N*Sxy-Sx*Sy)/(N*Sxx-Sx^2)  'slope of linear regression
   B=(Sy-M*Sx)/N                 'y intercept of linear regression
   R=(N*Sxy-Sx*Sy)/Sqr((N*Sxx-Sx^2)*(N*Syy-Sy^2))  'correlation 1.00=perfect fit= smooth paper
   With Result.SubFields.Create("Anchors")
      .Confidence=N
      .Text=CStr(N)
   End With
   With Result.SubFields.Create("Confidence")
      R=Max(R,0)
      Result.Confidence=R
      .Confidence=R
      .Text=Format(R,"0.0%")
   End With
   With Result.SubFields.Create("Shift")
      .Confidence=B
      .Text=Format(B,"0.000")
   End With
   With Result.SubFields.Create("Scale")
      .Confidence=M
      .Text=Format(M,"0.0%")
   End With

   With Result.SubFields.Create("DPI")
      .Confidence=Resolution
      .Text=CStr(Resolution)
   End With
   With Result.SubFields.Create("Direction")
      .Confidence=1
      .Text=IIf(Horizontal,"Horizontal","Vertical")
   End With

   ' Result.Confidence=IIf(Vector,1.1,1.0)

'this was done To maintain the Right order For All the pages. Each page will have 2 alternatives (Horizontal And Vertical)
   Result.Confidence=1.0-(AlternativeIndex*0.000001)
End Sub

Function Max(a,B)
   Return IIf(a>B,a,B)
End Function



Private Function Class_GetClassPath(ClassName As String) As String
   'Recursively work out the ClassPath
   If ClassName = "" Then Err.Raise(345,,"The XDocument must be classified before this locator is called!")
   Dim ParentClass As CscClass
   Set ParentClass=Project.ClassByName(ClassName).ParentClass
   If ParentClass Is Nothing Then
      Return ClassName
   Else
      Return Class_GetClassPath(ParentClass.Name) & "\" & ClassName
   End If
End Function

```
