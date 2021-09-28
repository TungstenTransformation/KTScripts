# Character level benchmark.
This script copies benchmark data (truth and extracted) into an Excel, copies the **snippets** into the cells as well, and **colors** the cells based on the character-level confidence.
The Excel document will look similar to this.  
![image](https://user-images.githubusercontent.com/47416964/135054311-d94b8258-4b70-4f1a-b632-100b590b4089.png)

```vb
Private Sub Batch_Close(ByVal pXRootFolder As CASCADELib.CscXFolder, ByVal CloseMode As CASCADELib.CscBatchCloseMode)
   Dim ExcelApp As Excel.Application, wb As Excel.Workbook, ws As Excel.Worksheet, X As Long, Truth() As String
   Dim FileName As String, FieldName As String, ScoreSheet As Excel.Worksheet, CharScores() As Double, WordScores() As Double, score As Double
   Dim ParentFolder As String, Row As Long, Col As Long, FileNameIndex As New Dictionary, cell As Excel.Range
   Dim field As CscXDocField, image As CscImage, snippet As CscImage, Shape As Excel.Shape
   FileName=pXRootFolder.DocInfos(0).XDocument.FileName
   FileName=Left(FileName,InStrRev(FileName,"\")) & "Golden Data.xlsx"
   While Not File_Exists(FileName) 'Search in parent folders for Golden Data.xslx
      ParentFolder=Left(FileName,InStrRev(FileName,"\")-1)
      ParentFolder=Left(ParentFolder,InStrRev(ParentFolder,"\"))
      FileName=ParentFolder & Mid(FileName,InStrRev(FileName,"\")+1)
   Wend
   Set ExcelApp = New Excel.Application 'Load Golden Data into array Truth
   ExcelApp.Visible=False
   Set wb=ExcelApp.Workbooks.Open(FileName)
   Set ws=wb.Worksheets.Item(pXRootFolder.DocInfos(0).ExtractionClass)
   With ws.Range("A1").CurrentRegion
      ReDim Truth(.Rows.Count,.Columns.Count)
      ReDim CharScores(.Columns.Count)
      ReDim WordScores(.Columns.Count)
      For Row=1 To .Rows.Count
         For Col=1 To .Columns.Count
            Truth(Row-1,Col-1)=.Cells(Row,Col).Value
            If Col=1 Then FileNameIndex.Add(Truth(Row-1,Col-1),Row-1)
         Next
      Next
   End With
   wb.Close(False)
   Begin Dialog UserDialog 370,140 ' %GRID:10,7,1,1
      TextBox 20,35,330,21,.TextBox1
      Text 20,14,330,14,"Enter Benchmark Name",.Text1
      CheckBox 30,70,230,14,"Export Snippets? (Slower) ",.CheckBoxSnippet
      OKButton 50,98,110,28
      CancelButton 190,98,140,28
   End Dialog
   Dim dlg As UserDialog
   On Error GoTo ExitSub
   Dialog dlg
   On Error GoTo 0

   'Create benchmark file
   Set wb=ExcelApp.Workbooks.Add()
   ExcelApp.DisplayAlerts = False
   ExcelApp.ScreenUpdating=False
   While wb.Worksheets.Count>1
      wb.Worksheets(1).Delete
   Wend
   ExcelApp.DisplayAlerts = True
   Set ws=wb.Worksheets(1)
   ws.Name="Benchmark"
   For Row=0 To pXRootFolder.DocInfos.Count-1
      For Col=0 To UBound(Truth,2) 'write header
         ws.Cells(3,Col+1).Value=Truth(0,Col)
      Next
      With pXRootFolder.DocInfos(Row).XDocument
         FileName=Replace(Mid(.FileName,InStrRev(.FileName,"\")+1),".xdc","")
         If FileNameIndex.Exists(FileName) Then
            X=FileNameIndex(FileName)
            ws.Cells(Row+4,1).Value=FileName
            ws.Cells(Row+4,2).Value=Truth(X,1) 'className
            For Col=1 To UBound(Truth,2)
               If .Fields.Exists(Truth(0,Col)) Then
                  Set field=.Fields.ItemByName(Truth(0,Col))
                  score=String_FuzzyMatch(Truth(X,Col),field.Text)
                  CharScores(Col)=CharScores(Col)+score
                  If score>0.99 Then WordScores(Col)=WordScores(Col)+1
                  Set cell=ws.Cells(Row+4,Col+1)
                  ExcelRange_InteriorColor(cell,score)
                  cell.Value="'" & field.Text & IIf(score=1,"",vbCrLf & Truth(X,Col))
                  If field.PageIndex>-1 And field.Width>0 And field.Height>0 And dlg.CheckBoxSnippet Then
                     Set image=.CDoc.Pages(field.PageIndex).GetImage
                     Set snippet=New CscImage
                     snippet.CreateImage(CscImgColFormatRGB24,field.Width,field.Height,image.XResolution,image.YResolution)
                     snippet.CopyRect(image,field.Left,field.Top,0,0,field.Width,field.Height)
                     snippet.Save(Environ("TEMP") & "\image.png",CscImgFileFormatPNG)
                     Set Shape=ws.Shapes.AddPicture(Environ("TEMP") & "\image.png",False,True,cell.Left,cell.Top,15/snippet.Height*snippet.Width,15)
                     If Shape.Width>cell.Width Then
                        cell.ColumnWidth=cell.ColumnWidth*Shape.Width/cell.Width
                     End If
                     cell.RowHeight= Shape.Height*3
                  End If
               End If
            Next
         End If
      End With
   Next
   For Col=2 To UBound(CharScores)-1
      score=CharScores(Col)/pXRootFolder.DocInfos.Count
      ws.Cells(2,Col+1).Value=Format(score,"0.0%")
      ExcelRange_InteriorColor(ws.Cells(2,Col+1),score)
      score=WordScores(Col)/pXRootFolder.DocInfos.Count
      ws.Cells(1,Col+1).Value=Format(score,"0.0%")
      ExcelRange_InteriorColor(ws.Cells(1,Col+1),score)
   Next
   ws.Cells(1,2).Value="word score"
   ws.Cells(2,2).Value="OCR score"
   With ws.Range("A1").CurrentRegion
      .VerticalAlignment=xlBottom
   End With

   FileName=pXRootFolder.DocInfos(0).XDocument.FileName
   wb.SaveAs(Left(FileName,InStrRev(FileName,"\")) & "Benchmark_" & Format(Now(),"yyyymmdd_hhMM") & " " & dlg.TextBox1 & ".xlsx")
   ExcelApp.ScreenUpdating=True
   ExcelApp.Visible=True
   Set ExcelApp=Nothing
exitsub:
End Sub
Public Function ExcelRange_InteriorColor (Range As Range, ratio As Double) As String
   Dim blue As Integer, green As Integer, red As Integer, pi As Double
   pi=4*Atn(1)
   blue = 0
   green = 255 *ratio' Sqr( Cos ( ratio * pi ))
   red = 255 * (1-ratio)'Sqr( Sin ( ratio * pi ))
   Range.Interior.Color=RGB(red,green,blue)
End Function
Public Function String_FuzzyMatch(ByVal a As String, ByVal b As String, Optional RemoveSpaces As Boolean = False) As Double
   'returns 0.0 for no match, 1.0 for perfect match, in between for fuzzy match.
   If RemoveSpaces Then
      a=Replace(a," ","")
      b=Replace(b," ","")
   End If
   If Len(a)= 0 Or Len(b)=0 Then Return 0
   Return CDbl(1.0 - String_LevenshteinDistance(a, b)/ Max(Len(a),Len(b)))
End Function

Public Function String_LevenshteinDistance(a As String ,b As String) As Integer
   'http://en.wikipedia.org/wiki/Levenshtein_distance
   'Levenshtein distance between two strings, used for fuzzy matching
   'Returns the number of character differences between the two strings.
   'eg LevenshteinDistance("kitten","kitchen") = 2 = insertion of "c" + substitution of "t" for "h"

   Dim i As Long, j As Long, cost As Long, d() As Long
   Dim ins As Long, del As Long, subs As Long  ' for counting insertions, deletions and substitutions
   If Len(a) = 0 Then Return Len(b)
   If Len(b) = 0 Then Return Len(a)
   ReDim d(Len(a), Len(b))
   For i = 0 To Len(a)
      d(i, 0) = i
   Next
   For j = 0 To Len(b)
      d(0, j) = j
   Next
   For i = 1 To Len(a)
     For j = 1 To Len(b)
         cost = IIf (Mid(a, i, 1) = Mid(b, j, 1),0,1)   ' cost of substitution
         del = ( d( i - 1, j ) + 1 ) ' cost of deletion
         ins = ( d( i, j - 1 ) + 1 ) ' cost of insertion
         subs = ( d( i - 1, j - 1 ) + cost ) 'cost of substitution or match
         d(i,j)= Min(ins, Min(del,subs))
      Next
   Next
   Return d(Len(a), Len(b))
End Function

Public Function Max(v1, v2) 'typeless generic function
   Return IIf (v1 > v2 ,v1 ,v2)
End Function

Public Function Min(v1, v2)
   Return IIf (v1 < v2 ,v1 ,v2)
End Function

```
