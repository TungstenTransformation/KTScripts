'This script is used by
'Text Layout Classification and Text Layout Zone Registration.
'https://github.com/KofaxTransformation/KTScripts/blob/master/Text%20Layout%20Classification%20and%20Registration.md

Public Sub Pages_Compare(page1 As CscXDocPage, page2 As CscXDocPage,Results As CscXDocFieldAlternatives, XRes As Long, YRes As Long)
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
   For Each WordText In Words1.Keys
     If Len(WordText) >= 6  And IsNumeric(WordText) = False Then 'only match words with 6 or more characters
         If Words2.Exists(WordText) Then 'This unique word appears on both pages
            Set Word1=Words1(WordText)(0)
            Set Word2=Words2(WordText)(0)
            Set Vector=Vectors.Create
            Vector.Left=Word1.Left+Word1.Width/2
            Vector.Top=Word1.Top+Word1.Height/2
            Vector.Width=Word2.Left+Word2.Width/2
            Vector.Height=Word2.Top+Word2.Height/2
            Vector.Text=Word1.Text
         End If
    End If
   Next
   LinearRegression(Vectors,True,Results.Create,XRes,Results.Count-1) 'Calculate horizontal shift, scale and smoothness
   LinearRegression(Vectors,False,Results.Create,YRes,Results.Count-1) 'Calculate vertical shift, scale and smoothness
   Line_RemoveOutliers(Vectors,Results, 3.0) ' remove all outlier points (mismatched words) more than 3.0 times the average distance away.
   While Results.Count>page1.Words(0).PageIndex
      Results.Remove(Results.Count-1)
   Wend
   'recalculate the lines without the outlier points
   LinearRegression(Vectors,True,Results.Create,XRes,Results.Count-1) 'Calculate horizontal shift, scale and smoothness
   LinearRegression(Vectors,False,Results.Create,YRes,Results.Count-1) 'Calculate vertical shift, scale and smoothness
End Sub

Public Function Page_GetUniqueWords(Page As CscXDocPage,StartWordIndex As Long,EndWordIndex As Long) As Dictionary
   'Add Reference to "Microsoft Scripting Runtime" for Dictionary
   'Find all words on the page that only appear once
   Dim w As Long, Word As CscXDocWord, WordText As String
   Dim Words As New Dictionary
   For w=StartWordIndex To EndWordIndex
      Set Word=Page.Words(w)
      If Not Words.Exists(Word.Text) Then
         Words.Add(Word.Text,New CscXDocWords)
      End If
      Words(Word.Text).Append(Word)
   Next
   For Each WordText In Words.Keys 'Remove the non-unique words
      If Words(WordText).Count>1 Then Words.Remove(WordText)
   Next
   Return Words
End Function

Public Sub LinearRegression(Vectors As CscXDocFieldAlternatives, Vector As Boolean, Result As CscXDocFieldAlternative, Resolution As Long,AlternativeIndex As Double)
   'http://en.wikipedia.org/wiki/Simple_linear_regression' https://www.easycalculation.com/statistics/learn-regression.php
   'The 1st Alternative has the horizonatal Scaling=M, displacement=B, and Confidence=flatness of the paper.
   'The 2nd Alternative has the vertical    Scaling=M, displacement=B, and Confidence=flatness of the paper.
   Dim X As Double, Y As Double, Sx As Double, Sy As Double, Sxy As Double, Sxx As Double, Syy As Double, V As Long
   Dim B As Double, M As Double, N As Long, R As Double
   For V= 0 To Vectors.Count-1
      If Vector Then
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
   With Result.SubFields.Create("M")
      .Confidence=M
      .Text=Format(M,"0.000")
   End With
   With Result.SubFields.Create("B")
      .Confidence=B
      .Text=Format(B,"0.000")
   End With
   With Result.SubFields.Create("Smoothness")
      .Confidence=R
      .Text=Format(R,"0.0000")
   End With
   With Result.SubFields.Create("N")
      .Confidence=N
      .Text=CStr(N)
   End With
   With Result.SubFields.Create("Resolution")
      .Confidence=Resolution
      .Text=CStr(Resolution)
   End With
   With Result.SubFields.Create("Direction")
      .Confidence=1
      .Text=IIf(Vector,"Horizontal","Vertical")
   End With
   'this was done To maintain the Right order For All the pages. Each page will have 2 alternatives (Horizontal And Vertical)
   Result.Confidence=1.0-(AlternativeIndex*0.000001)
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
