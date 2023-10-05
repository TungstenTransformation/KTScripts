# Text Layout Algorithm (called "TL" below)
TL uses the location of almost every word on the page to either *classify the page* or *register OCR zones*.
Every unique word on the page is *aligned* to it's corresponding word on the other document. This gives the precise vertical shift and stretch, and horizontal shift and stretch. TL is VERY robust against OCR errors because even if 60% of the words had OCR errors, we would still find the correct alignment with the remaining 40% easily.  

TL allows subpixel accuracy in **registering** OCR zones because we have used 100s of words on the page to do the registration.
TL  allows **very precise classification** because if the documents are only slightly different then words don't have the same alignment with each other. This can easily detect when an extra line of text has been added to the middle of a document

TL takes about 1 second for the comparison between the document and the training sample in the project class.  

Place this code into the Project level script. Add a reference to Microsoft Scripting Runtime.

## Text Layout Classification
TL is very useful when
*  2 document classes differ only by a few words. Maybe an extra sentence or 1 less sentence.

 If you use it to compare with 10 documents, then it would take 10 seconds. It is best to classify documents with the in-built fast "Layout Classification" and "Text Classification", and then do sub-classification with the variants of a class.  
Here is a Classification Benchmark for a set of Japanese Forms that are almost identical with each other - they vary only in a few words and phrases.  
 ![image](https://user-images.githubusercontent.com/47416964/88191031-491d1180-cc3b-11ea-910c-07834060d9c7.png)

```vb


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


```

 ### Example.
 Your project has document classes **A**, **B** and **C**, which are quite different from each other. Document **B** has variants **B1** to **B6** that are quite similiar to each other and are subclasses of **B** because although they have the same fields, some or all of the locators need to be different.    
 After a document is either classified as **B** or **B1** to **B6**, TL tests the document with all 7 classes with the *Text Layout* algorithm and assigns the document to the class with the best match.

## Text Layout Registration
improvements on 23 September 2022
* mismatched words are ignored. (outliers to the linear regression are removed and the line of best fit is recalculated) This makes the algorithm precise and robust.
* It now only requires a single script locator essentially for debugging. The script event **Document_BeforeLocate** is now used to run the zone shifting from *within* the Advanced Zone Locator. 
* improved documentation. 

This algorithm is very useful when you need to perform OCR on a document and the document 
* has MANY background words on the page, as is typical on a US government or insurance form
* is highly stretched in one direction. 
* has a strong zoom (e.g. a photo from a mobile phone with the camera far back) 
* came from a mobile phone and the camera was at an angle to the paper.
* has zones shifted more than 10mm.

TL uses every unique word on the page as an anchor. This is much better than manually configuring a few anchors yourself.  

**NOTICE** Please test the Advanced Zone Locator** with the following registration settings *before* you try this algorithm.
Usually these settings mean you do not need to use my custom algorithm.
1. Make sure Registration Type is **custom**
1. Disable **Anchors** (don't use anchors as they are lots of work and don't do as good a job 
1. Enable **Lines** if your document has many vertical and horizontal lines on it
1. Enable **OCR** if your document has a lot of background text (which is what Layout Classification uses as well!)
1. Enable **Layout**
1. Enable **Account for Local Distortion**.   (TL checks for distortion across the whole page)
1. Set **Local re-registration** to max of 10 mm horizontally and vertically. (my algorithm has unlimited re-registration distance)
1. Disable **Registration Failure makes zone invalid** as you want to see where the zones would be found.
![image](https://user-images.githubusercontent.com/47416964/87690499-d66aec80-c789-11ea-8bcc-618a41180ae1.png)

Kofax Transformation has support for adjusting the zones of a Zone Locator by script - we will use this technique here as well.
## How Text Layout Registration Works
1. Find all unique words on Document A (This is the document you want to classify or register) using a Dictionary object. This is very fast.
2. Find all unique words on Document B (This is either the classification sample document or Zone Locator's sample document)
3. Find all unique words on Document A that are on Document B. These are the anchor words we will use to align the documents.
4. Plot the X coordinate of each word in Document A against the X coordinate of each word in Document B and calculate the line passing through them using [linear regression](https://www.easycalculation.com/statistics/learn-regression.php), a High School math technique.  
![image](https://user-images.githubusercontent.com/47416964/191963260-bea2e2cd-7478-4559-8b6d-87a70ce34d8d.png)

5. Linear Regression calculates 
* the slope, M, of the line corresponds to the **scale**. In the example you see that the document is 2.091 times *wider* than the original document and 2.090 times *higher*.
* the intercept, B, of the line corresponds to the **pixel shift**. In the example you see that the document has shifted -37.2 pixels horizontally and 189.7 pixels vertically
* the **Confidence**, R, of the line, shows how well the dots fit on a straight line. 1.0000 shows perfect both horizontally and vertically.
* This example used 75 unique words that matched between the two documents as anchors.   
![image](https://user-images.githubusercontent.com/47416964/191963050-dba951ae-575e-41cc-9547-626c4b9f9ba9.png)

```vb
'#Language "WWB-COM"

Option Explicit
'This script uses all unique words on a page to register OCR and OMR zones to subpixel accuracy.
'!!! IMPORTANT !!!!
' Add on Menu/Edit/References...
'           "Microsoft Scripting Runtime" for Dictionary to find and match unique words
'           "Kofax Cascade Advanced Zone Locator" for retrieving the Zone Definitions
'Create One Locator
'  SL_CalculatePageShift (used for debugging, with subfields Scale, Shift, Confidence, Words, DPI.)
'  AZL (on the Registration Tab set to "None")

' Class script: document

Private Sub Document_BeforeLocate(ByVal pXDoc As CASCADELib.CscXDocument, ByVal LocatorName As String)
   If LocatorName = "AZL" Then
      'Move the Zones in the Advanced Zone Locator based on the Shifts and Scale
      Dim Shifts As CscXDocFieldAlternatives
      Dim Zones As CscXDocSubFields, AZL As CscAdvZoneLocator
      Set Shifts=pXDoc.Locators.ItemByName("SL_CalculatePageShift").Alternatives
      Set AZL = Project.ClassByName(pXDoc.ExtractionClass).Locators.ItemByName(LocatorName).LocatorMethod
      Zones_Shift(AZL.Zones,Shifts,pXDoc.Representations(0))
   End If
End Sub

Private Sub SL_CalculatePageShift_LocateAlternatives(ByVal pXDoc As CASCADELib.CscXDocument, ByVal pLocator As CASCADELib.CscXDocField)
   'Your document MUST be classified before calling this locator, in order to be able to find the sample image in the AZL.
   'This function is purely here for debugging. it is so that you can see the unique words that are used for matching
   Dim I As Long, StartWordIndexRef As Long, StartWordIndex As Long, EndWordIndexRef As Long, EndWordIndex As Long
   Dim AZLSampleDoc As CscXDocument, LeftShift As Double, DownShift As Double, Tolerance As Double, Confidence As Double
   Dim AZLSampleDocFileName As String
   AZLSampleDocFileName =Left(Project.FileName,InStrRev(Project.FileName,"\")) & "Samples\" & Class_GetClassPath(pXDoc.ExtractionClass) & "\Sample0.xdc"
   Set AZLSampleDoc = New CscXDocument
   AZLSampleDoc.Load(AZLSampleDocFileName)
   'Find which pages have zones on them
   Dim AZLDef As CscAdvZoneLocator, ZonesExist() As Boolean, Z As Long
   Set AZLDef=Project.ClassByName(pXDoc.ExtractionClass).Locators.ItemByName(LocatorName).LocatorMethod
   ReDim ZonesExist((pXDoc.Pages.Count-1))
      For Z=0 To AZLDef.Zones.Count-1
         ZonesExist(AZLDef.Zones(Z).PageNr)=True
      Next
   For I=0 To pXDoc.Pages.Count - 1
      if ZonesExist(I) then
         Pages_Compare(AZLSampleDoc.Pages(I),pXDoc.Pages(I),pLocator.Alternatives,pXDoc.CDoc.Pages(I).XRes,pXDoc.CDoc.Pages(I).YRes)
      else
         pLocator.Alternatives.Add.Confidence=1.00
         pLocator.Alternatives.Add.Confidence=1.00
      end if
   Next
End Sub

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
   'Open "C:\temp\words.txt" For Output As #1
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
    '        Print #1, Vector.Text & vbTab & CStr(Vector.Left) & vbTab & CStr(Vector.Top) & vbTab & CStr(Vector.Width) & vbTab & CStr(Vector.Height)
         End If
    End If
   Next
   'Close #1
   LinearRegression(Vectors,True,Results.Create,XRes,Results.Count-1) 'Calculate horizontal shift, scale and smoothness
   LinearRegression(Vectors,False,Results.Create,YRes,Results.Count-1) 'Calculate vertical shift, scale and smoothness
   Line_RemoveOutliers(Vectors,Results, 3.0) ' remove all outlier points (mismatched words) more than 3.0 times the average distance away.
   While Results.Count>page1.words(0).pageIndex
      Results.Remove(Results.Count-1)
   Wend
   'recalculate the lines without the outlier points
   LinearRegression(Vectors,True,Results.Create,XRes,Results.Count-1) 'Calculate horizontal shift, scale and smoothness
   LinearRegression(Vectors,False,Results.Create,YRes,Results.Count-1) 'Calculate vertical shift, scale and smoothness
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
   With Result.SubFields.Create("Scale")
      .Confidence=M
      .Text=Format(M,"0.000")
   End With
   With Result.SubFields.Create("Shift")
      .Confidence=B
      .Text=Format(B,"0.000")
   End With
   With Result.SubFields.Create("Confidence")
      .Confidence=R
      .Text=Format(R,"0.0000")
   End With
   With Result.SubFields.Create("Words")
      .Confidence=N
      .Text=CStr(N)
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

Public Sub Zones_Shift(AZLZones As CscAdvZoneLocZones, Shifts As CscXDocFieldAlternatives, Rep As CscXDocRepresentation)
   Dim Z As Long, XDocZone As CscXDocZone
   While Rep.Zones.Count>0
      Rep.Zones.Remove(0)
   Wend
   For Z=0 To AZLZones.Count-1
      Set XDocZone=Zone_Shift(AZLZones(Z),Shifts,Rep)
      Rep.Zones.Append(XDocZone)
   Next
End Sub

Public Function Zone_Shift(AZLZone As CscAdvZoneLocZone, Shifts As CscXDocFieldAlternatives, Rep As CscXDocRepresentation) As CscXDocZone
   Dim XDocZone As CscXDocZone, X As Double, Y As Double, Right As Long, Bottom As Long
   Set XDocZone=New CscXDocZone
   XDocZone.PageNr=AZLZone.PageNr
   XDocZone.Name=AZLZone.Name
   'Shift the top right corner
   X=AZLZone.Left+AZLZone.Width
   Y=AZLZone.Top
   Coordinate_Shift(X,Y,Shifts,AZLZone.PageNr)
   Right=X
   'Shift the bottom left corner
   X=AZLZone.Left
   Y=AZLZone.Top+AZLZone.Height
   Coordinate_Shift(X,Y,Shifts,AZLZone.PageNr)
   Bottom=Y
   'Shift the Top Left corner
   X=AZLZone.Left
   Y=AZLZone.Top
   Coordinate_Shift(X,Y,Shifts,AZLZone.PageNr)
   XDocZone.Left=X
   XDocZone.Top=Y
   XDocZone.Width=Right-XDocZone.Left
   XDocZone.Height=Bottom-XDocZone.Top
   Return XDocZone
End Function

Public Sub Coordinate_Shift(ByRef X As Double, ByRef Y As Double, Shifts As CscXDocFieldAlternatives, page As Integer)
   Dim XRes As Long, YRes As Long, xm As Double, xb As Double, ym As Double, yb As Double
   With Shifts(page*2)
      xm=.SubFields.ItemByName("Scale").Confidence
      xb=.SubFields.ItemByName("Shift").Confidence
      XRes=.SubFields.ItemByName("DPI").Confidence
   End With
   With Shifts(page*2+1)
      ym=.SubFields.ItemByName("Scale").Confidence
      yb=.SubFields.ItemByName("Shift").Confidence
      YRes=.SubFields.ItemByName("DPI").Confidence
   End With
   X=X/25.4*XRes
   Y=Y/25.4*YRes
   X=xm*X+xb  'The Linear regression function gave us these slopes m and intercepts b.
   Y=ym*Y+yb
End Sub



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
