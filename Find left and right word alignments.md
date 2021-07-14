# Find left and right word alignments
This script finds left and right aligned blocks of text and marks them as such. It seperates them into subfields, that can be viewed. The 'type' subfield shows whether the text is right or left aligned, the distance from the left side of the page in pixels and the number of words in that subfield.
To use it, make a locator called **SL_Alignment** and create three subfields called type, left and right respectively. Then paste this code into the script window.  
![image](https://user-images.githubusercontent.com/87315965/125295023-1a54eb00-e325-11eb-9f56-4aed3003c069.png)  
An example result would look like this:  
![image](https://user-images.githubusercontent.com/87315965/125295224-4d977a00-e325-11eb-8381-f132bc2425d2.png)
```vba
Private Sub SL_Alignment_LocateAlternatives(ByVal pXDoc As CASCADELib.CscXDocument, ByVal pLocator As CASCADELib.CscXDocField)
   Dim PageWidth As Long, Histogram As CscXDocFieldAlternatives, Words As CscXDocWords, Word As CscXDocWord, W As Long, BucketSize As Double, Count As Long
   Dim H As Long, T As Long, TextLine As CscXDocTextLine, BiggestBucket As CscXDocSubField, Sum As Double, Side As String, ExitAll As Boolean, sf As String
   Dim OldHistogramSize As Long, AcceptableOverlap As Integer, Side2 As String, Distance As Long, Page As Long, AcceptableSpacing As Double
   Page=0
   PageWidth=pXDoc.CDoc.Pages(Page).Width
   BucketSize=6
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
   For T=5 To pXDoc.Pages(Page).TextLines.Count-5
      Set TextLine=pXDoc.Pages(Page).TextLines(T)
      For W=0 To TextLine.Words.Count-1
         Set Word=TextLine.Words(W)
         H=Word.Left/BucketSize
         Histogram(H).SubFields.ItemByName("left").Words.Append(Word)
         H=(Word.Left+Word.Width)/BucketSize
         Histogram(H).SubFields.ItemByName("right").Words.Append(Word)
      Next
   Next
   For H=Histogram.Count-1 To 0 Step -1
      If Histogram(H).SubFields.ItemByName("left").Words.Count=0 And Histogram(H).SubFields.ItemByName("right").Words.Count=0 Then
         Histogram.Remove(H)
      End If
   Next
   OldHistogramSize = Histogram.Count+1
   While Histogram.Count < OldHistogramSize
      'This script combines horizontally overlapping buckets
      OldHistogramSize = Histogram.Count
      For H=Histogram.Count-2 To 0 Step -1
         If Histogram(H).SubFields.ItemByName("left").Words.Count > 0 Then
            Side="left"
         Else
            Side="right"
         End If
         If Histogram(H+1).SubFields.ItemByName("left").Words.Count > 0 Then
            Side2="left"
         Else
            Side2="right"
         End If
         If Object_OverlapHorizontal(Histogram(H).SubFields.ItemByName(Side), Histogram(H+1).SubFields.ItemByName(Side2)) > 0 Then
            AcceptableOverlap=1
            For T=0 To Histogram(H).SubFields.ItemByName(Side).Words.Count-1
               If Histogram(H).SubFields.ItemByName(Side).Words(T).Left + Histogram(H).SubFields.ItemByName(Side).Words(T).Width > Histogram(H+1).SubFields.ItemByName(Side2).Left Then
                  AcceptableOverlap = AcceptableOverlap-1
               End If
               If AcceptableOverlap<1 Then Exit For
            Next
            If AcceptableOverlap < 1 Then
               If Histogram(H).SubFields.ItemByName(Side).Words.Count > Histogram(H+1).SubFields.ItemByName(Side2).Words.Count Then
                  For T=0 To T=Histogram(H+1).SubFields.ItemByName(Side2).Words.Count-1
                     If Not Word_Inside(Histogram(H+1).SubFields.ItemByName(Side2).Words(T),Histogram(H).SubFields.ItemByName(Side).Words) Then
                        Histogram(H).SubFields.ItemByName(Side).Words.Append(Histogram(H+1).SubFields.ItemByName(Side2).Words(T))
                     End If
                  Next
                  Histogram.Remove(H+1)
               Else
                  For T=0 To Histogram(H).SubFields.ItemByName(Side).Words.Count-1
                     If Not Word_Inside(Histogram(H).SubFields.ItemByName(Side).Words(T),Histogram(H+1).SubFields.ItemByName(Side2).Words) Then
                        Histogram(H+1).SubFields.ItemByName(Side2).Words.Append(Histogram(H).SubFields.ItemByName(Side).Words(T))
                     End If
                  Next
                  Histogram.Remove(H)
               End If
            End If
         End If
      Next
   Wend
   For H=Histogram.Count-2 To 1 Step -1
      'This script adds tiny buckets to the nearest large bucket
      If Histogram(H).SubFields.ItemByName("left").Words.Count > 0 Then
         Side="left"
      ElseIf Histogram(H).SubFields.ItemByName("right").Words.Count > 0 Then
         Side="right"
      End If
      If Histogram(H).SubFields.ItemByName(Side).Words.Count < 6 Then
         Distance=pXDoc.CDoc.Pages(0).Width
         For Each sf In Split("left right")
            If Abs(Histogram(H).SubFields.ItemByName(Side).Left - (Histogram(H-1).SubFields.ItemByName(sf).Left+Histogram(H-1).SubFields.ItemByName(sf).Width)) < Distance Then
               Distance=Abs(Histogram(H).SubFields.ItemByName(Side).Left - (Histogram(H-1).SubFields.ItemByName(sf).Left+Histogram(H-1).SubFields.ItemByName(sf).Width))
               T=-1
               Side2=sf
            End If
            If Abs((Histogram(H).SubFields.ItemByName(Side).Left+Histogram(H).SubFields.ItemByName(Side).Width) - Histogram(H+1).SubFields.ItemByName(sf).Left) < Distance Then
               Distance=Abs((Histogram(H).SubFields.ItemByName(Side).Left+Histogram(H).SubFields.ItemByName(Side).Width) - Histogram(H+1).SubFields.ItemByName(sf).Left)
               T=1
               Side2=sf
            End If
         Next
         If Histogram(H).SubFields.ItemByName(Side).Words.Count > 0 Then
            For W=0 To Histogram(H).SubFields.ItemByName(Side).Words.Count-1
               If Not Word_Inside(Histogram(H).SubFields.ItemByName(Side).Words(W), Histogram(H+T).SubFields.ItemByName(Side2).Words) Then
                  Histogram(H+T).SubFields.ItemByName(Side2).Words.Append(Histogram(H).SubFields.ItemByName(Side).Words(W))
               End If
            Next
         End If
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

Function Word_Inside(Word As CscXDocWord, List As CscXDocWords) As Boolean
   Dim I As Integer
   For I=0 To List.Count-1
      If Word.IndexOnDocument = List(I).IndexOnDocument Then
         Return True
      End If
   Next
   Return False
End Function
```
