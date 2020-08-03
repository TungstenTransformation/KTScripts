# Detect Page Size  
Tthe following script can be used with a script locator or other script event to detect the size of a page.
If returns results like "A3" 98.5%. A scanned document will never have the perfect size, and Kofax VRS may crop the image - so a check needs to be fuzzy.
This script will find the best page size out of more than 20 standard US and ISO 216 (A4, A5,..) [paper sizes](https://en.wikipedia.org/wiki/Paper_size)
```vb
Private Sub SL_Size_LocateAlternatives(ByVal pXDoc As CASCADELib.CscXDocument, ByVal pLocator As CASCADELib.CscXDocField)
    Page_GetSize(pXDoc.CDoc.Pages(0),pLocator.Alternatives)
End Sub
 
Public Sub Page_GetSize(Page As CscCDocPage,alts As CscXDocFieldAlternatives)
   'Returns "A4", "A3",... "US Letter", "unknown dpi", "unknown", as well as the confidence of the match
   'Fuzzy match as VRS crops pages
   Dim Dimension As String, Dimensions As String, Values() As String, Confidence As Double
   If Page.XRes=0 Or Page.YRes=0 Then
      With alts.Create
         .Text="unknown dpi"
         .Confidence=1
         Exit Sub
      End With
   End If
   If Page.Width=0 Or Page.Height=0 Then
      With alts.Create
         .Text="not a page"
         .Confidence=1
         Exit Sub
      End With
  End If
   'Width and Height of various formats in inches.
   Dimensions="A8:2.07:2.93,A7:2.93:4.14,A6:4.14:5.85,A5:5.85:8.27,A4:8.27:11.70,A3:11.70:16.54,A2:16.54:23.40,A1:23.40:33.08,A0:33.08:46.80,Credit Card:3.375:2.375"
   'http://en.wikipedia.org/wiki/Paper_size#Other_sizes 
   Dimensions=Dimensions & ",Organizer J:2.75:5,Compact:4.25:6.75,Half Letter:5.5:8.5,Executive:7.25:10.5,Government-Letter:8:10.5,Foolscap:8.27:13"
   Dimensions=Dimensions & ",Letter:8.5:11,Folio:8.5:13,Legal:8.5:14,Quarto:9:11,US Std Fanfold:11:14.875,Ledger:11:17,Super-B:13:19,Post:15.5:19.5"
   Dimensions=Dimensions & ",Crown:15:20,Large Post:16.5:21,Demy:17.5:22.5,Medium:18:23,Broadsheet:18:24,Royal:20:25,Elephant:23:28,Double Demy:22.5:35,Quad Demy:35:45"
   For Each Dimension In Split(Dimensions,",")
      Values=Split(Dimension,":")
      Confidence=Page_ScoreSize(Page,CDbl(Values(1)), CDbl(Values(2)))
      If Confidence>0.4 Then
         With alts.Create
            .Text=Values(0)
            .Confidence=Confidence
         End With
      End If
   Next
End Sub
 
Public Function Page_ScoreSize(Page As CscCDocPage, width As Long, height As Long) As Double
   'if the page has the same area and the same edge ratio it gets 100%, anything else gets less
   Dim AreaRatio As Double, EdgeRatio As Double
   If Page.Width=0 Or Page.Height=0 Then Return 0
   AreaRatio=Page.Width/Page.XRes*Page.Height/Page.YRes/(width*height)
   If AreaRatio>1 Then AreaRatio=1/AreaRatio
   EdgeRatio = Max(Page.Width/Page.Height,Page.Height/Page.Width)/Max(width/height,height/width)
   If EdgeRatio>1 Then EdgeRatio=1/EdgeRatio
   Return AreaRatio*EdgeRatio
End Function
 
Public Function Max(a,b)
   Return IIf(a>b,a,b)
End Function

```
