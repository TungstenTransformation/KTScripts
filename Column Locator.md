# Column Locator
This locator finds all the text columns on a document and returns each column as an alternative in the locator.  
The alternatives can then be used to extract paragraphs, to classify by paragraph or column, or to run NLP over columns or paragraphs.  
Add this script to the class containing a script locator with the name **SL_Column**
## Script
```vb
'#Language "WWB-COM"
Option Explicit

Private Sub SL_Columns_LocateAlternatives(ByVal pXDoc As CASCADELib.CscXDocument, ByVal pLocator As CASCADELib.CscXDocField)
   Dim Columns As CscXDocFieldAlternatives, Column As CscXDocFieldAlternative, C As Long, CStart As Long, CEnd As Long, D As Long
   Dim Word As CscXDocWord, Words As CscXDocWords, W As Long
   Dim P As Long, gapH As Long, gapV As Long
   gapH=10
   gapV=3
   Set Columns=pLocator.Alternatives
   CStart=0
   For P=0 To pXDoc.Pages.Count-1
      Set Words=pXDoc.Pages(P).Words
      For W=0 To Words.Count-1
         Set Word=Words(W)
         'put word into correct column
         Set Column = Nothing
         If Columns.Count<>CStart Then
            For C=CStart To Columns.Count-1
               If Object_HorizontalDistance(Columns(C),Word)<gapH Then
                  Set Column=Columns(C)
                  Exit For
               End If
            Next 'column
         End If
         If Column Is Nothing Then
            Set Column=Columns.Create
            Column.Confidence=1-Columns.Count/1000 ' just to keep the columns in order of creation
         End If
         Column.Words.Append(Word)
         'merge columns
         For C=Columns.Count-2 To CStart Step -1
            For D=Columns.Count-1 To C+1 Step -1
               If Object_HorizontalDistance(Columns(C),Columns(D))<gapH Then
                  For W=0 To Columns(D).Words.Count-1
                     Columns(C).Words.Append(Columns(D).Words(W))
                  Next
                  Columns.Remove(D)
               End If
            Next
         Next
      Next 'word
      CStart=Columns.Count
   Next 'page
End Sub

Public Function Object_isClose(a As Object, b As Object, gapH As Long, gapV As Long) As Boolean
   If Object_HorizontalDistance(a,b)<=gapH And Object_VerticalDistance(a,b)<gapV Then Return True
   Return False
End Function


Public Function Object_Distance( a As Object, b As Object) As Long
   Return Min(Object_HorizontalDistance(a,b),Object_VerticalDistance(a,b))
End Function

Public Function Object_VerticalDistance( a As Object, b As Object) As Long
   Return Max(Abs(b.Top+b.Height/2-a.Top-a.Height/2)-b.Height/2-a.Height/2,0)
End Function

Public Function Object_HorizontalDistance( a As Object, b As Object) As Long
   Return Max(Abs(b.Left+b.Width/2-a.Left-a.Width/2)-b.Width/2-a.Width/2,0)
End Function

Public Function Object_OverlapHorizontal( a As Object, b As Object,Optional offset As Long=0,Optional differentPages As Boolean=False) As Double
   'Calculates the horizontal overlap of two fields and returns 0<=overlap<=1
   'Overlap=1 is also returned if one field is inside the other
   If (Not differentPages And (a.PageIndex <> b.PageIndex)) Or a.PageIndex=-1 Or a.Width = 0 Or b.Width=0 Then Return 0
   Return Max((Min(a.Left+a.Width,b.Left+b.Width+offset)-Max(a.Left,b.Left+offset)),0)/Min(a.Width,b.Width)
End Function

Public Function Object_VerticalOverlap( a As Object, b As Object,Optional ignorePage As Boolean=False) As Double
   'Calculates the vertical overlap of two fields and returns 0<=overlap<=1
   'Overlap=1 is also returned if one field is inside the other
   Dim o As Double
   If (Not ignorePage And (a.PageIndex <> b.PageIndex)) Or a.PageIndex=-1 Then Exit Function
   If a.Height = 0 Or b.Height=0 Then Exit Function
   o=Max((Min(a.Top+a.Height,b.Top+b.Height)-Max(a.Top,b.Top)),0)
   Return o/Min(a.Height,b.Height)
End Function

Public Function Max(v1, v2)
   Return IIf( v1 > v2, v1, v2)
End Function

Public Function Min(v1, v2)
   Return IIf( v1 < v2, v1, v2)
End Function
```
