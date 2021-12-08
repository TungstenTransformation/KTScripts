# Column Locator
This locator finds all the text columns on a document and returns each column as an alternative in the locator.  
The alternatives can then be used to extract paragraphs, to classify by paragraph or column, or to run NLP over columns or paragraphs.  
![image](https://user-images.githubusercontent.com/47416964/104158346-7037ed00-53ed-11eb-80ee-746cc475bd8a.png)
![image](https://user-images.githubusercontent.com/47416964/104158379-8a71cb00-53ed-11eb-8748-5a72e7b6e94a.png)

Add this script to the class containing a script locator with the name **SL_Column**.
The algorithm merges together words that are "close" together into columns.  
There is one parameter **gapH**. Any words that are horizontally closer to each other than **horizontal Gap** will be merged into a column object.  
The confidence of each column is just 99.9%, 99.8%, 99.7% etc so that the columns appear in the order that they were created. The column order does not reflect the order on the document (In the second image above you see that column 99.9% is still there and that 99.8, 99.7, 99.6 & 99.5 were merged into it - this happened because the first word on the page is high in the top right corner. That is why column 1 has 99.4%). The columns will need [sorting](Alternatives%20Sort.md) so that the have the order that they do on the document.

## Script
```vb
Private Sub SL_Columns_LocateAlternatives(ByVal pXDoc As CASCADELib.CscXDocument, ByVal pLocator As CASCADELib.CscXDocField)
   Dim Columns As CscXDocFieldAlternatives, Column As CscXDocFieldAlternative, C As Long, CStart As Long, CEnd As Long, D As Long
   Dim Word As CscXDocWord, Words As CscXDocWords, W As Long
   Dim P As Long, gapH As Long, Headers As CscXDocFieldAlternatives, H As Long, HeaderLine() As Long
   gapH=10
   Set Columns=pLocator.Alternatives
   ReDim HeaderLine(pXDoc.Pages.Count-1)
   Set Headers=pXDoc.Locators.ItemByName("FL_Headers").Alternatives
   For H=0 To UBound(HeaderLine)
      HeaderLine(H)=-1 ' on most pages we need to accept line 0  - page without header
   Next
   For H=0 To Headers.Count-1
      HeaderLine(Headers(H).PageIndex)=Headers(H).Words(0).LineIndex
   Next
   CStart=0
   For P=0 To pXDoc.Pages.Count-1 ' loop through all pages
      Set Words=pXDoc.Pages(P).Words
      For W=0 To Words.Count-1 ' loop through all words on the page
         Set Word=Words(W)
         If Word.LineIndex> HeaderLine(Word.PageIndex) Then ' we are below the header
            'put word into correct column
            Set Column = Nothing
            If Columns.Count<>CStart Then 'if we already have columns on this page
               For C=CStart To Columns.Count-1 'find if any existing column is "above" the word
                  If Object_HorizontalDistance(Columns(C),Word)<gapH Then
                     Set Column=Columns(C)
                     Exit For
                  End If
               Next 'column
            End If
            If Column Is Nothing Then 'add a new column if the word isn't "close" to an existing column
               Set Column=Columns.Create
               Column.Confidence=1-Columns.Count/1000 ' just to keep the columns in order of creation
            End If
            Column.Words.Append(Word)
            'merge columns ' as columns grow, they may get close to each other - this merges "sub"-columns.
            For C=Columns.Count-2 To CStart Step -1 'count backwards because we are deleting
               For D=Columns.Count-1 To C+1 Step -1
                  If Object_HorizontalDistance(Columns(C),Columns(D))<gapH Then
                     For W=0 To Columns(D).Words.Count-1 'copy all words to new column
                        Columns(C).Words.Append(Columns(D).Words(W))
                     Next
                     Columns.Remove(D)
                  End If
               Next
            Next
         End If
      Next 'word
      CStart=Columns.Count
   Next 'page

   ' remove small columns
   For C= Columns.Count-1 To 0 Step -1
      If Columns(C).Words.Count<4 Or Len(Columns(C).Text) <20 Then Columns.Remove(C)
   Next

   'here we need to sort paragraphs
   Alternatives_Sort(Columns,AddressOf Comparer_AboveOrLeft)

   For C=0 To Columns.Count-1
      Columns(C).Confidence = 1-(C/100)  'preserve the order of the columns by setting artificial confidences 100%, 99%, 98%, etc..
     Object_SortWords(Columns(C), pXDoc) 'put all of the words in the paragraph in the correct order. The merging above doesn't preserve word order.
   Next

End Sub

Sub Object_SortWords(a As Object, pXDoc As CscXDocument)
   Dim W As Long, Sorted As CscXDocWords
   Set Sorted=pXDoc.GetWordsInRect(a.PageIndex,a.Left,a.Top,a.Width,a.Height)
   While a.Words.Count>0
      a.Words.Remove(0)
   Wend
   a.Text=""
   For W=0 To Sorted.Count-1
      a.Words.Append(Sorted(W))
   Next
End Sub

Public Function Object_HorizontalDistance( a As Object, b As Object) As Long
   Return Max(Abs(b.Left+b.Width/2-a.Left-a.Width/2)-b.Width/2-a.Width/2,0)
End Function
```
