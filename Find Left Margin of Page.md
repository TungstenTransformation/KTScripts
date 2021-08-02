# Find the Left Margin of a Page
This finds the left margin of the text on a page. It also stores the value in the XDocument's XValues for future reference, so it doens't need to be recalculated.  
This is useful for aligning scanned pages with each other, as the scanner may have cropped the left edge of the image.  
Table Algorithms need to know the left margin so that text columns align correctly from page to page.  
```vb
Function Page_LeftMargin(pXDoc As CscXDocument, PageIndex As Long) As Double
   'Find the left text margin of the text of the document. Store in XValues for future use
   Dim Hist As New CscXDocField, T As Long, B As Long, TextLine As CscXDocTextLine, XValue As String
   Const Bucket = 5 ' make each histogram bucket 5 pixels wide
   XValue="Page_LeftMargin"+CStr(PageIndex)
   'if we already know the value for this page, just return it
   If pXDoc.XValues.ItemExists(XValue) Then Return CDbl(pXDoc.XValues.ItemByName(XValue).Value)
   'Create all the histogram buckets
   While Hist.Alternatives.Count<pXDoc.CDoc.Pages(PageIndex).Width
      Hist.Alternatives.Create
   Wend
   'Add the first word of every textline on the page into the histogram
   For T=0 To pXDoc.Pages(PageIndex).TextLines.Count-1
      Set TextLine=pXDoc.Pages(PageIndex).TextLines(T)
      B=Int(TextLine.Left/Bucket)
      Hist.Alternatives(B).Words.Append(TextLine.Words(0))
   Next
   For B=0 To Hist.Alternatives.Count-1
      If Hist.Alternatives(B).Words.Count>4 Then Exit For 'find first bucket with 5 words in it
   Next
   'Average the left edge of each word in this bucket
   With Hist.Alternatives(B).Words
      For T=0 To .Count-1
         Page_LeftEdge=Page_LeftEdge+.ItemByIndex(0).Left
      Next
      Page_LeftMargin=Page_LeftMargin/.Count
   End With
   pXDoc.XValues.Add(XValue,Format(Page_LeftMargin,"0.00"),True)
End Function
```
