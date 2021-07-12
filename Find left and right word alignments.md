# Find left and right word alignments
This script finds left and right aligned blocks of text and marks them as such. It seperates them into subfields, that can be viewed.  
To use it, make a locator called **SL_Alignment** and create three subfields called type, left and right respectively. Then paste this code into the script window.  
![image](https://user-images.githubusercontent.com/87315965/125295023-1a54eb00-e325-11eb-9f56-4aed3003c069.png)  
An example result would look like this:  
![image](https://user-images.githubusercontent.com/87315965/125295224-4d977a00-e325-11eb-8381-f132bc2425d2.png)
```vba
Private Sub SL_Alignment_LocateAlternatives(ByVal pXDoc As CASCADELib.CscXDocument, ByVal pLocator As CASCADELib.CscXDocField)
   Dim PageWidth As Long, Histogram As CscXDocFieldAlternatives, Words As CscXDocWords, Word As CscXDocWord, W As Long, BucketSize As Double, Count As Long
   Dim H As Long, T As Long, TextLine As CscXDocTextLine, BiggestBucket As CscXDocSubField, Sum As Double, Side As String, ExitAll As Boolean, sf As String
   PageWidth=pXDoc.CDoc.Pages(0).Width
   BucketSize=20
   Set Histogram=pLocator.Alternatives
   For H=0 To PageWidth/BucketSize
      With Histogram.Create
         '.Text=CStr(H)
         .Confidence=1-H/10000
         For Each sf In Split("type left right")
            .SubFields.Create(sf)
         Next
      End With
   Next
   For T=5 To pXDoc.Pages(0).TextLines.Count-5
      Set TextLine=pXDoc.Pages(0).TextLines(T)
      For W=0 To TextLine.Words.Count-1
         Set Word=TextLine.Words(W)
         H=Word.Left/BucketSize
         Histogram(H).SubFields.ItemByName("left").Words.Append(Word)
         H=(Word.Left+Word.Width)/BucketSize
         Histogram(H).SubFields.ItemByName("right").Words.Append(Word)
      Next
   Next
   Set BiggestBucket=Histogram(0).SubFields.ItemByName("left")
   For H=0 To Histogram.Count-1
      If Histogram(H).SubFields.ItemByName("left").Words.Count>BiggestBucket.Words.Count Then
         Set BiggestBucket=Histogram(H).SubFields.ItemByName("left")
      ElseIf Histogram(H).SubFields.ItemByName("right").Words.Count>BiggestBucket.Words.Count Then
         Set BiggestBucket=Histogram(H).SubFields.ItemByName("right")
      End If
   Next
   For H=Histogram.Count-1 To 0 Step -1
      If Histogram(H).SubFields.ItemByName("left").Words.Count<BiggestBucket.Words.Count*0.5 And Histogram(H).SubFields.ItemByName("right").Words.Count<BiggestBucket.Words.Count*0.5 Then
         Histogram.Remove(H)
      End If
   Next
   For H=0 To Histogram.Count-1
      Sum=0
      If Histogram(H).SubFields.ItemByName("left").Words.Count > 0 Then
         Side = "left"
      Else
         Side="right"
      End If
      Count = Histogram(H).SubFields.ItemByName(Side).Words.Count
      For T=0 To Histogram(H).SubFields.ItemByName(Side).Words.Count-1
         Sum=Sum+Histogram(H).SubFields.ItemByName(Side).Words(T).Left
         If Side="right" Then
            Sum=Sum+Histogram(H).SubFields.ItemByName(Side).Words(T).Width
         End If
      Next
      Histogram(H).SubFields(0).Text=Side & " " & Format(Sum/Count, "0.00") & " " & CStr(Count)
   Next
End Sub
```
