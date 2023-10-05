Public Function Pages_Compare(page1 As CscXDocPage, page2 As CscXDocPage,XRes As Long, YRes As Long) As CscXDocField
   'Find as many unique anchors between the two pages and work out the shift and scaling between them
   'This algorithm is very robust against OCR errors.
   'The algorithm has order of page.words.count, i.e. linear, so VERY FAST.
   Dim Words1 As Dictionary, Words2 As Dictionary, WordText As String, X() As Long, Y() As Long
   Dim Word1 As CscXDocWord, Word2 As CscXDocWord, Results As New CscXDocField
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
   LinearRegression(Vectors,True,Results.Alternatives.Create,XRes,Results.Alternatives.Count-1) 'Calculate horizontal shift, scale and smoothness
   LinearRegression(Vectors,False,Results.Alternatives.Create,YRes,Results.Alternatives.Count-1) 'Calculate vertical shift, scale and smoothness
   Return Results
End Function

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
