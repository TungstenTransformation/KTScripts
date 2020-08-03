# Split a Page
The following Kofax Transformation project level script will split A3 pages in documents vertically, inserting a new batch. It **must** be run from the event Batch_Open, because it adds pages to the document.
You can also run it from Batch_Close, but that is too late, because you normally want to split a document before classifying, not after extraction.

```vb
'#Language "WWB-COM"
Option Explicit

' Project Script

Private Sub Batch_Open(ByVal pXRootFolder As CASCADELib.CscXFolder)
   Dim D As Long, P As Long, DocInfo As CscXDocInfo
   For D=0 To pXRootFolder.DocInfos.Count-1
      Set DocInfo=pXRootFolder.DocInfos(D)
      For P=0 To DocInfo.PageCount-1
         If Page_IsA3(DocInfo.XDocument.CDoc.Pages(P)) Then
            Document_SplitPage(DocInfo,P,True) 'split A3 pages vertically
            P=P+1 ' skip the newly created page
         End If
      Next
   Next
End Sub

Private Sub Document_SplitPage(pXDocInfo As CscXDocInfo, PageNo As Long, Optional Vertical As Boolean =True)
   'Split a page and add it to the document
   'You MUST call this from Batch_Open or Batch_Close event for the page to be accessible outside of KT
   Dim Page As CscImage, Page1 As New CscImage, Page2 As New CscImage, ColorFormat As CscImageColorFormat
   Set Page=pXDocInfo.XDocument.CDoc.Pages(PageNo).GetImage
   If Page.IsBinary Then
      ColorFormat= CscImgColFormatBinary
   ElseIf Page.IsColor Then
      ColorFormat=CscImgColFormatRGB24
   ElseIf Page.IsGray Then
      If Page.BitsPerSample=4 Then ColorFormat=CscImgColFormatGray4
      If Page.BitsPerSample=8 Then ColorFormat=CscImgColFormatGray8
      If Page.BitsPerSample=16 Then ColorFormat=CscImgColFormatGray16
   End If
   If Vertical Then
      Page1.CreateImage(ColorFormat,Page.Width/2,Page.Height,Page.XResolution,Page.YResolution)
      Page2.CreateImage(ColorFormat,Page.Width/2,Page.Height,Page.XResolution,Page.YResolution)
      Page1.CopyRect(Page,0,0,0,0,Page.Width/2,Page.Height)
      Page2.CopyRect(Page,Page.Width/2,0,0,0,Page.Width/2,Page.Height)
   Else ' Horizontal
      Page1.CreateImage(ColorFormat,Page.Width,Page.Height/2,Page.XResolution,Page.YResolution)
      Page2.CreateImage(ColorFormat,Page.Width,Page.Height/2,Page.XResolution,Page.YResolution)
      Page1.CopyRect(Page,0,0,0,0,Page.Width,Page.Height/2)
      Page2.CopyRect(Page,0,Page.Height/2,0,0,Page.Width,Page.Height/2)
   End If
   Page1.Save(Page1.FileName,Page1.FileFormat)
   Page2.Save(Replace(Page1.FileName & ".split.tif"),Page1.FileFormat)
   'Insert a new page into the document, so that Kofax Capture knows it is there. This will cost a page count in the license
   Batch.CopyPage(pXDocInfo,PageNo,PageNo+1) ' This event can only be called from Batch_Open or Batch_Close
   'Replace the pages
   pXDocInfo.XDocument.CDoc.Pages(PageNo).SetImage(Page1)
   pXDocInfo.XDocument.CDoc.Pages(PageNo+1).SetImage(Page2)
   pXDocInfo.XDocument.Save()
End Sub

Private Sub SL_Size_LocateAlternatives(ByVal pXDoc As CASCADELib.CscXDocument, ByVal pLocator As CASCADELib.CscXDocField)
    Page_GetSize(pXDoc.CDoc.Pages(0),pLocator.Alternatives)
End Sub

Public Function Page_IsA3(Page As CscCDocPage) As Boolean
   Dim Score As Double
   If Page.Width=0 Or Page.Height=0 Or Page.XRes=0 Or Page.YRes=0 Then Return False
   Score=Page.Width*Page.XRes*Page.Height*Page.YRes/11.7/16.54  'A3= 11.7 x 16.54 inch²
   Score=Min(Score,1/Score) ' calculate how close the area of the page is to an A3 page
   Score=Score*Min(Page.Width/Page.Height/11.7*16.54,Page.Height/Page.Width/16.54*11.7) ' calculate how close the edge ratio is to the A3 edge ratio = sqrt(2)=16.54/11.7
   'score will be 100% for perfect A3, otherwise smaller. An A4 page will get score 50%
   If Score >0.9 Then Return True ' accept some cropping.
End Function

Public Sub Page_GetSize(Page As CscCDocPage,alts As CscXDocFieldAlternatives)
   'This can be used in a script locator – pass in pLocator.Alternatives as the second parameter
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
   'Width and Height of various formats in inches. 1 inch = 25.4mm
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
   'if the page has the same width and height then its area ratio=100% and the edge ratio=100%, otherwise it gets a worse score.
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

Public Function Min(a,b)
   Return IIf(a<b,a,b)
End Function

```
