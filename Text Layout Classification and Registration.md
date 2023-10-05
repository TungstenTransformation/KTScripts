# Text Layout Algorithm (called "TL" below)
Text Layout uses the location of **every unique word** on the page to either [classify a page]() or [register OCR zones]().  

Text Layout allows subpixel accuracy in **registering** OCR zones because we  use 100s of words on the page to do the registration.

Text Layout  allows **very precise classification** because if the documents are only slightly different then words don't have the same alignment with each other. This can easily detect when an extra line of text has been added to the middle of a document.

Every unique word on the page is *aligned* to its corresponding word on the other document. This gives the precise vertical shift and stretch, and horizontal shift and stretch. Text Layout is VERY robust against OCR errors because even if 60% of the words had OCR errors, we would still find the correct alignment with the remaining 40% easily.  

TL takes a fraction of a second for the comparison between the document and the training sample in the project class.

## Text Layout Classification
Text Layout Classification is very useful when
*  2 document classes differ only by a few words. Maybe an extra sentence or 1 less sentence.

 If you use it to compare with 10 documents, then it would take a few seconds. It is best to classify documents with the in-built fast "Layout Classification" and "Text Classification", and then do sub-classification with the variants of a class.  
Here is a Classification Benchmark for a set of Japanese Forms that are almost identical with each other - they vary only in a few words and phrases.  
 ![Classification Benchmark](https://user-images.githubusercontent.com/47416964/88191031-491d1180-cc3b-11ea-910c-07834060d9c7.png)

 ### Example.
 Your project has document classes **A**, **B** and **C**, which are quite different from each other, so standard layout or text classification can be used. Document **B** has variants **B1** to **B6** that are quite similiar to each other and are subclasses of **B** because although they have the same fields, some or all of the locators need to be different.    
 After a document is either classified as **B** or **B1** to **B6**, Text Layout Classification can be used to test the document with all 7 classes with the *Text Layout* algorithm and assigns the document to the class with the best match.

## Add Text Layout Classification to your Project
* Open the Project Level Script.  
* Add [this line](https://www.winwrap.com/web2/basic/#!/ref/WWB-doc_language_def.htm) to the top of your project level script.
```vb
'#Language "WWB-COM"
```
* Add a Reference to **Microsoft Scripting Runtime** in Menu/Edit/References. We use a [Dictionary](https://learn.microsoft.com/en-us/office/vba/Language/Reference/User-Interface-Help/dictionary-object) to find and match words on the page.  
![Microsoft Scripting Runtime](images/MicrosoftScriptingRuntime.png)
* Add the [Text Layout Classification](/Text%20Layout%20Classification.vb) script to the Project Level Class.
* Add the [Text Layout](/Text%20Layout.vb) script to the Project level Class.
* Add classification training samples to your classes.
* Press F5 to classify your documents.


## Text Layout Zone Registration
This algorithm is very useful when you need to perform OCR on a document and the document 
* has MANY background words on the page, as is typical on a US government or insurance form.
* is highly stretched in one direction. 
* has a strong zoom (e.g. a photo from a mobile phone with the camera far back) 
* came from a mobile phone and the camera was at an angle to the paper.
* has zones shifted more than 10mm.

Text Layout Registration uses **every unique word** on the page as an anchor. This is much better and robuster than manually configuring a few anchors yourself.  

**NOTICE** Please test the **Advanced Zone Locator** with the following registration settings *before* you try this algorithm.
Usually these settings mean you do not need to use my custom algorithm.
1. Make sure Registration Type is **custom**
1. Disable **Anchors** (don't use anchors as they are lots of work and don't do as good a job 
1. Enable **Lines** if your document has many vertical and horizontal lines on it
1. Enable **OCR** if your document has a lot of background text (which is what Layout Classification uses as well!)
1. Enable **Layout**.
1. Enable **Account for Local Distortion**.   (TL checks for distortion across the whole page)
1. Set **Local re-registration** to max of 10 mm horizontally and vertically. (my algorithm has unlimited re-registration distance)
1. Disable **Registration Failure makes zone invalid** as you want to see where the zones would be found.
![image](https://user-images.githubusercontent.com/47416964/87690499-d66aec80-c789-11ea-8bcc-618a41180ae1.png)

Only if the above registration settings fail should you try to use this script.

Improvements in 5 October 2023
* Fixed issues with multipage documents. #6, #8 
* Pages without zones are skipped.  #7  

Improvements on 23 September 2022
* mismatched words are ignored. (outliers to the linear regression are removed and the line of best fit is recalculated) This makes the algorithm precise and robust.
* It now only requires a single script locator essentially for debugging. The script event **Document_BeforeLocate** is now used to run the zone shifting from *within* the Advanced Zone Locator. 
* improved documentation. 

## Add Text Layout Registration to your Project
* Open the Script Editor in Kofax Transformation.
* Add a Reference to **Microsoft Scripting Runtime** in Menu/Edit/References. We use a [Dictionary](https://learn.microsoft.com/en-us/office/vba/Language/Reference/User-Interface-Help/dictionary-object) to find and match words on the page.  
![Microsoft Scripting Runtime](images/MicrosoftScriptingRuntime.png)
* Add a reference to **Kofax Advanced Zone Locator 4.0**.
* Add [this line](https://www.winwrap.com/web2/basic/#!/ref/WWB-doc_language_def.htm)  to every Project Class that you will use for Zone Registration.
```vb
'#Language "WWB-COM"
```
* Add the [Text Layout Zone Registration](/Text%20Layout%20Zone%20Registration.vb) script to the Class script.
* Add the [Text Layout](/Text%20Layout.vb) script to the Class script.
* Add the Script Locator **SL_CalculatePageShift** to your project.  
* Add the Subfields  **Scale**, **Shift**, **Confidence**, **Words** and **DPI** to the locator. These are used both for debugging and are used in the Zone Locator to shift the zones.  
![image](https://user-images.githubusercontent.com/47416964/191963050-dba951ae-575e-41cc-9547-626c4b9f9ba9.png)

* Disable Registration in the Advanced Zone Locator. Remove all anchors from the AZL - you won't need them.
* Configure all of the Zones in the AZL.
* Test the AZL. If Text Layout finds enough anchors it should shift all of your zones perfectly.

### Notes
* The documents need to be linearly stretched for this to work.
* If the paper is curved and photographed it won't work. (Contact me if you need this to work for curved paper).
* If it is a fax that slipped while printing it won't work.

Kofax Transformation has support for adjusting the zones of a Zone Locator by script - we will use this technique here as well.

```vb

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
