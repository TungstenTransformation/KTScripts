# Find left and right word alignments
This script finds left and right aligned blocks of text and marks them as such. To use it, create a Locator called **SL_Alignment** and paste this code.  
The text displays whether the column is right or left aligned, its distance in pixels from the left edge and the number of words in that column. That would look like this:  
![image](https://user-images.githubusercontent.com/87315965/125619632-37eb02b5-f308-4089-a0d8-37587d0614a0.png)  
An example result of the document would look like this:  
![image](https://user-images.githubusercontent.com/87315965/125619734-d8511753-de2d-45d4-8dfb-e2f635c8550e.png)  
```vba
Private Sub SL_Alignment_LocateAlternatives(ByVal pXDoc As CASCADELib.CscXDocument, ByVal pLocator As CASCADELib.CscXDocField)
   Dim PageWidth As Long, Histogram As CscXDocFieldAlternatives, Words As CscXDocWords, Word As CscXDocWord, W As Long, BucketSize As Double, Count As Long
   Dim H As Long, T As Long, TextLine As CscXDocTextLine, Sum As Double, Page As Long, AcceptableSpacing As Double, Distance As Long
   Dim OldHistogramSize As Long, AcceptableOverlap As Long, LeftDistance As Double, RightDistance As Double, Side As String, AllSpaces As Long
   Page=0
   PageWidth=pXDoc.CDoc.Pages(Page).Width
   BucketSize=20
   Set Histogram=pLocator.Alternatives
   For H=0 To PageWidth/BucketSize 'Creates the buckets
      With Histogram.Create
         '.Text=CStr(H)
         .Confidence=1-H/10000
      End With
   Next
   RightDistance=0
   AllSpaces=0
   For T=5 To pXDoc.Pages(Page).TextLines.Count-5
      'Adds the words to the buckets
      Set TextLine=pXDoc.Pages(Page).TextLines(T)
      For W=0 To TextLine.Words.Count-1
         Set Word=TextLine.Words(W)
         H=Word.Left/BucketSize
         Histogram(H).Words.Append(Word)
      Next
   Next
   For H=Histogram.Count-1 To 0 Step -1
      'Deletes empty buckets
      If Histogram(H).Words.Count=0 Then
         Histogram.Remove(H)
      End If
   Next
   OldHistogramSize = Histogram.Count+1
   While Histogram.Count < OldHistogramSize
      'Combines horizontally overlapping buckets
      OldHistogramSize = Histogram.Count
      For H=Histogram.Count-2 To 0 Step -1
         If Object_OverlapHorizontal(Histogram(H), Histogram(H+1)) > 0 Then
            AcceptableOverlap=1
            For T=0 To Histogram(H).Words.Count-1
               If Histogram(H).Words(T).Left + Histogram(H).Words(T).Width > Histogram(H+1).Left Then
                  AcceptableOverlap = AcceptableOverlap-1
               End If
               If AcceptableOverlap<1 Then Exit For
            Next
            If AcceptableOverlap < 1 Then
               If Histogram(H).Words.Count >= Histogram(H+1).Words.Count Then
                  For T=0 To Histogram(H+1).Words.Count-1
                     If Not Word_Inside(Histogram(H+1).Words(T),Histogram(H).Words) Then
                        Histogram(H).Words.Append(Histogram(H+1).Words(T))
                     End If
                  Next
                  Histogram.Remove(H+1)
               Else
                  For T=0 To Histogram(H).Words.Count-1
                     If Not Word_Inside(Histogram(H).Words(T),Histogram(H+1).Words) Then
                        Histogram(H+1).Words.Append(Histogram(H).Words(T))
                     End If
                  Next
                  Histogram.Remove(H)
               End If
            End If
         End If
      Next
   Wend
   For H=Histogram.Count-2 To 1 Step -1
      'Adds tiny buckets to the nearest large bucket and combines columns that are very close to each other
      Distance=pXDoc.CDoc.Pages(0).Width
      AcceptableSpacing=6
      If Abs(Histogram(H).Left - (Histogram(H-1).Left+Histogram(H-1).Width)) < Distance Then
         Distance=Abs(Histogram(H).Left - (Histogram(H-1).Left+Histogram(H-1).Width))
         T=-1
      End If
      If Abs((Histogram(H).Left+Histogram(H).Width) - Histogram(H+1).Left) < Distance Then
         Distance=Abs((Histogram(H).Left+Histogram(H).Width) - Histogram(H+1).Left)
         T=1
      End If
      If Histogram(H).Words.Count < 6 Or Distance < AcceptableSpacing Then
         If Histogram(H).Words.Count > 0 Then
            For W=0 To Histogram(H).Words.Count-1
               If Not Word_Inside(Histogram(H).Words(W), Histogram(H+T).Words) Then
                  Histogram(H+T).Words.Append(Histogram(H).Words(W))
               End If
            Next
         End If
         Histogram.Remove(H)
      End If
   Next
   For H=0 To Histogram.Count-1
      'Calculates the size of the buckets and the alignment of the words
      Sum=0
      LeftDistance=0
      RightDistance=0
      Count = Histogram(H).Words.Count
      For T=0 To Histogram(H).Words.Count-1
         Sum=Sum+Histogram(H).Words(T).Left
      Next
      For T=0 To Histogram(H).Words.Count-1
         LeftDistance=LeftDistance+Abs(Histogram(H).Left-Histogram(H).Words(T).Left)
         RightDistance=RightDistance+Abs(Histogram(H).Left+Histogram(H).Width-Histogram(H).Words(T).Left-Histogram(H).Words(T).Width)
      Next
      If LeftDistance>RightDistance Then
         Side="right"
      Else
         Side="left"
      End If
      Histogram(H).Text=Side & " " & Format(Sum/Count, "0.00") & " " & CStr(Count)
   Next
End Sub

Function Word_Inside(Word As CscXDocWord, List As CscXDocWords) As Boolean
   Dim I As Long
   For I=0 To List.Count-1
      If Word.IndexOnDocument = List(I).IndexOnDocument Then
         Return True
      End If
   Next
   Return False
End Function
```
