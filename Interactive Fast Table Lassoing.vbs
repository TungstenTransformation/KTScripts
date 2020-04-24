'#Language "WWB-COM"
' watch video FastTableLassoing.avi for a demo
Option Explicit
' Class script: Document
Private TableNameGlobal As String
Private RowIndexGlobal As Long
Private ColumnIndexGlobal As Long

Private Sub ValidationForm_DocumentLoaded(ByVal pXDoc As CASCADELib.CscXDocument)
   RowIndexGlobal=-1
   ColumnIndexGlobal=-1
   TableNameGlobal=""
End Sub

Private Sub ValidationForm_FieldGotFocus(ByVal pXDoc As CASCADELib.CscXDocument, ByVal pField As CASCADELib.CscXDocField)
   RowIndexGlobal=-1
   ColumnIndexGlobal=-1
   TableNameGlobal=""
End Sub

Private Sub ValidationForm_TableSelectionChanged(ByVal tableName As String, ByVal pXDoc As CASCADELib.CscXDocument)
   'The user clicked on the blue left edge of a table row - no cell has cursor focus
   TableNameGlobal=tableName
   RowIndexGlobal=-1
   ColumnIndexGlobal=-1
   ValidationForm.Labels(0).Text="select table=" & TableNameGlobal
End Sub

Private Sub ValidationForm_TableCellGotFocus(ByVal pXDoc As CASCADELib.CscXDocument, ByVal pField As CASCADELib.CscXDocField, ByVal rowIndex As Long, ByVal columnIndex As Long)
   RowIndexGlobal=rowIndex
   ColumnIndexGlobal=columnIndex
   TableNameGlobal=pField.Name
   ValidationForm.Labels(0).Text="focus table=" & TableNameGlobal
End Sub

Private Sub ValidationForm_AfterViewerLassoDrawn(ByVal pXDoc As CASCADELib.CscXDocument, ByVal pageIndex As Long, ByVal pField As CASCADELib.CscXDocField, ByVal TopPos As Long, ByVal LeftPos As Long, ByVal Width As Long, ByVal Height As Long, ByRef bCancel As Boolean)
   Dim lasso As CscXDocWord
   If TableNameGlobal="" Then Exit Sub ' we are not in a table
   Set lasso=New CscXDocWord
   lasso.PageIndex=pageIndex
   lasso.Left=LeftPos
   lasso.Top=TopPos
   lasso.Width=Width
   lasso.Height=Height
   bCancel=Table_ProcessRectangle(pField.Table, RowIndexGlobal, ColumnIndexGlobal, pXDoc, lasso)
   Set lasso=Nothing
End Sub

Private Sub ValidationForm_AfterTableCellConfirmed(ByVal pXDoc As CASCADELib.CscXDocument, ByVal pField As CASCADELib.CscXDocField, ByVal rowIndex As Long, ByVal columnIndex As Long)
   'Check for manipulation hotkeys
   TableCell_CheckForHotKey(pField.Table, rowIndex, columnIndex, pXDoc)
End Sub

Public Function Table_ProcessRectangle(Table As CscXDocTable, rowIndex As Long, columnIndex As Long, pXDoc As CscXDocument, Rectangle As CscXDocWord) As Boolean
   'returns true if the lasso was handled
   Dim rows As Dictionary, columns As CscCollection, overlapVertical As Boolean, overlapAllColumns As Boolean, rowCount As Long, colCount As Long
   Dim splitColumn As Boolean, splitRow As Boolean
   Set rows=Table_FindOverlapRows(Table, Rectangle)
   Set columns=Table_FindOverlapColumns(Table,Rectangle)
   If rows.Count=0 And columns.Count=0 Then
      Return False 'Normal KTM Lasso
   ElseIf columns.Count=1 AndAlso Rectangle_IsCrossing(TableColumnRow_2Word(columns(1),Rectangle.PageIndex),Rectangle)=1 Then
      Table_SplitColumn(Table, pXDoc, columns(1), Rectangle)
   ElseIf rows.Count=1 AndAlso Rectangle_IsCrossing(TableColumnRow_2Word(rows(0),Rectangle.PageIndex),Rectangle)=2 Then
      Table_SplitRow(Table,rows(0),Rectangle)
   ElseIf rows.Count<2 And columns.Count<2 Then
      Return False 'This is a normal field lasso. Let KTM handle it (but we should remove word from other cell to prevent dupes)
   ElseIf rows.Count=0 Then
      Table_InsertWords(Table,XDocument_GetWordsInRect(pXDoc,Rectangle)) 'User added new rows above, below or inside table
   ElseIf rows.Count>1 And columns.Count=Table.Columns.Count Then
      Table_MergeRows(Table,rows)
   ElseIf rows.Count>1 Then
      Table_MergeColumns(Table,columns)
   Else
      ValidationForm.Labels(0).Text="Unsupported table lasso event!"
      Return False
   End If
   Set Rectangle=Nothing
   Return True 'KTM can ignore this lasso as already handled
End Function

Public Function Rectangle_IsCrossing(RA As Object, RB As Object) As Long
   'This checks if RB and A cross each other in the middle
   'returns 0 for on crossing, 1 for vertical, 2 for horizontal
   Dim overlap As Double
   If RA.PageIndex<>RB.PageIndex Then Return 0
   overlap=Rectangle_Overlap2D(RA,RB)
   If overlap=0 Or overlap=1 Then Return 0  'ie they don't touch or one is inside the other
   If RA.Left<RB.Left AndAlso RB.Left+RB.Width<RA.Left+RA.Width Then Return 1
   If RA.Top<RB.Top AndAlso RB.Top+RB.Width<RA.Top+RA.Height Then Return 2
   Return 0 'they don't cross each other. one rectangle pokes out only from one side of the other
End Function

Public Sub Table_InsertWords(Table As CscXDocTable, words As CscXDocWords)
   Dim Row As CscXDocTableRow, w As Long, word As CscXDocWord, c As Long
   If Table.Rows.Count=0 Then Exit Sub ' There is no table row to use as pattern
   If Table.Rows(0).StartPage=-1 Then Exit Sub 'the first row of the table has no words in it, hence no pattern to use
   Set Row=Table.Rows(0)
   For w =0 To words.Count-1
      Set word=words(w)
      While Row.IndexInTable<Table.Rows.Count AndAlso Row.TextlineIndexStart<word.LineIndex
         If Row.IndexInTable=Table.Rows.Count-1 Then
            Set Row=Table.Rows.Append
            Exit While
         Else
            Set Row=Table.Rows(Row.IndexInTable+1)
         End If
      Wend
      For c =0 To Table.Columns.Count-1
         If Rectangle_OverlapHorizontal(word,TableColumnRow_2Word(Table.Columns(c),word.PageIndex))>0 Then
            Row.Cells(c).AddWordData(word)
            Exit For
         End If
      Next
   Next
End Sub

Public Function Table_CalculateSumByColumn(Table As CscXDocTable, columnName As String, ByRef bSumIsValid As Boolean) As Double
   Dim r As Long
   'Format each table cell in this column. This will set the .DoubleValue and the .DoubleFormatted parameters on each cell in the column.
   For r =0 To Table.Rows.Count-1
      DefaultAmountFormatter.FormatTableCell(Table.Rows(r).Cells.ItemByName(columnName))
   Next
   Table_CalculateSumByColumn=Table.GetColumnSumByName(columnName,bSumIsValid)
   Project.FieldFormatters.ItemByName().FormatTableCell
End Function

Public Sub Table_SplitRow(Table As CscXDocTable, Row As CscXDocTableRow, Rectangle As CscXDocWord)
   Err.Raise(1,,"splitRow not implemented!")
End Sub
Public Sub Table_SplitColumn(Table As CscXDocTable, pXDoc As CscXDocument, Column As CscXDocTableColumn, Rectangle As CscXDocWord)
   'This splits all words in the column into three groups - left of, inside, and right of the rectangle
   Dim r As Long, w As Long, words As CscXDocWords,dictID As Long, cellLeft As CscXDocTableCell, cellRight As CscXDocTableCell
   If Column.IndexInTable=Table.Columns.Count-1 Then Exit Sub 'Cannot split rightmost column
   Dim t As New CscXDocTable
   t.QuickCreate(4,5)

   Dim c As New CscCollection

   For r=0 To Table.Rows.Count-1
      Set cellLeft=Table.Rows(r).Cells(Column.IndexInTable)
      Set cellRight=Table.Rows(r).Cells(Column.IndexInTable+1)
      Set words=XDocument_GetWordsInsideRect(pXDoc,cellLeft)
      cellLeft.Text=""
      cellLeft.PageIndex=-1
      cellRight.Text=""
      cellRight.PageIndex=-1
      For w =0 To words.Count-1
         If words(w).Left+words(w).Width<Rectangle.Left Then cellLeft.AddWordData(words(w)) Else cellRight.AddWordData(words(w))
      Next
   Next
End Sub

Public Function TableColumnRow_2Word(RowColumn As Object, PageIndex As Long) As CscXDocWord
   Dim word As New CscXDocWord
   If Not (TypeOf RowColumn Is ICscXDocTableRow Or TypeOf RowColumn Is ICscXDocTableColumn) Then Err.Raise(235,,"This function only supports TableRow and TableColumn")
   With RowColumn
      word.PageIndex=PageIndex
      word.Left=.Left(PageIndex)
      word.Top=.Top(PageIndex)
      word.Width=.Width(PageIndex)
      word.Height=.Height(PageIndex)
   End With
   Return word
End Function

Public Sub Table_MergeColumns(Table As CscXDocTable, columns As CscCollection)
   Dim r As Long, c As Long, Cell As CscXDocTableCell, word As CscXDocWord
   If columns.Count<2 Then Err.Raise(1,,"no 2 columns to merge!")
   Set word=New CscXDocWord
   For c =2 To columns.Count 'CSCCollection is 1-based and we start from second
      For r =0 To Table.Rows.Count-1
         Set Cell=Table.Rows(r).Cells(columns(c).IndexInTable)
         Field_Copy(Cell,word)
         Table.Rows(r).Cells(columns(1).IndexInTable).AddWordData(word)
         Set word = New CscXDocWord
         Cell.AddWordData(word) 'reset the cell
      Next
   Next
End Sub

Public Sub Table_MergeRows(Table As CscXDocTable, rows As Dictionary)
   Dim r As Long, c As Long, Cell As CscXDocTableCell, word As CscXDocWord
   If rows.Count<2 Then Err.Raise(1,,"no 2 rows to merge!")
   Set word=New CscXDocWord
   For r =1 To rows.Count-1
      For c =0 To Table.Columns.Count-1
         Field_Copy(rows(r).Cells(c),word)
         rows(0).Cells(c).AddWordData(word)
      Next
   Next
   For r=rows.Count-1 To 1 Step -1
      Table.Rows.Remove(rows(r).IndexInTable)
   Next
End Sub

Public Function Table_FindOverlapColumns(Table As CscXDocTable, Rectangle As CscXDocWord) As CscCollection
   Dim columns As CscCollection, c As Long
   Set columns= New CscCollection
   For c =0 To Table.Columns.Count-1
      If Rectangle_OverlapHorizontal(TableColumnRow_2Word(Table.Columns(c),Rectangle.PageIndex),Rectangle)>0 Then
         columns.Add(Table.Columns(c),CStr(columns.Count+1))
      End If
   Next
   Return columns
End Function

Public Function Table_FindOverlapRows(Table As CscXDocTable, Rectangle As CscXDocWord) As Dictionary
   Dim rows As New Dictionary,r As Long
   For r=0 To Table.Rows.Count-1
      If Table.Rows(r).StartPage =Rectangle.PageIndex Or Table.Rows(r).EndPage=Rectangle.PageIndex Then
         If Rectangle_OverlapVertical(TableColumnRow_2Word(Table.Rows(r),Rectangle.PageIndex),Rectangle)>0 Then
            rows.Add(rows.Count,Table.Rows(r))
         End If
      End If
   Next
   Return rows
End Function

Public Sub TableCell_CheckForHotKey(Table As CscXDocTable, rowIndex As Long, columnIndex As Long, pXDoc)
   Dim Cell As CscXDocTableCell
   Set Cell=Table.Rows(rowIndex).Cells(columnIndex)
   If InStr(Cell.Text,"!")=0 Then
      Exit Sub 'no hotkeys
   ElseIf InStr(Cell.Text,"!<<")>0 Then
      Table_MoveCell(Table,Cell, Cell.ColumnIndex-1)
   ElseIf InStr(Cell.Text,"!>>")>0 Then
      Table_MoveCell(Table,Cell, Cell.ColumnIndex+1)
   ElseIf InStr(Cell.Text,"!--")>0 Then
      Table_MoveColumn(Table,Cell.ColumnIndex, Cell.ColumnIndex-1)
   ElseIf InStr(Cell.Text,"!++")>0 Then
      Table_MoveColumn(Table,Cell.ColumnIndex, Cell.ColumnIndex+1)
   ElseIf InStr(Cell.Text,"!tt")>0 Then
      Table_SetFirstRowOnPage(Table,rowIndex)
   ElseIf InStr(Cell.Text,"!bb")>0 Then
      Table_SetLastRowOnPage(Table,rowIndex)
   ElseIf InStr(Cell.Text,"!..")>0 Then
      Table_ClearColumn(Table,columnIndex)
   End If
End Sub

Public Sub Table_ClearColumn(Table As CscXDocTable, columnIndex As Long)
   Dim r As Long
   For r=0 To Table.Rows.Count
      With Table.Rows(r).Cells(columnIndex)
         .Text=""
         .PageIndex=-1
      End With
   Next
End Sub



Public Sub Table_MoveCell(Table As CscXDocTable, Cell As CscXDocTableCell, columnIndex As Long)
   'Move a Table Cell to another column in the same row
   Dim word As New CscXDocWord
   If columnIndex<0 Or columnIndex>=Table.Columns.Count Or columnIndex=Cell.ColumnIndex Then Exit Sub 'invalid column
   Field_Copy(cell,word) 'Copy the table cell into a temporary CSCXDocWord to insert it into the table - this handles all cell/row/table coordinates
   Table.Rows(cell.RowIndex).Cells(columnIndex).AddWordData(word)
   Set word=Nothing
   cell.Text="" 'Empty the old cell
   cell.PageIndex=-1 'remove coordinate references
End Sub

Public Sub Table_MoveColumn(Table As CscXDocTable, oldColumnIndex As Long, newColumnIndex As Long)
   'Move all cells in a table column to another table column
   Dim r As Long
   If newColumnIndex<0 Or newColumnIndex>=Table.Columns.Count Or newColumnIndex=oldColumnIndex Then Exit Sub 'invalid columnid
   For r =0 To Table.Rows.Count-1
      Table_MoveCell(Table,Table.Rows(r).Cells(oldColumnIndex),newColumnIndex)
   Next
End Sub

Public Sub Table_SetFirstRowOnPage(Table As CscXDocTable, rowIndex As Long)
   Dim r As Long
   For r=0 To rowIndex-1
      Table.Rows.Remove(0) 'remove first row of table
   Next
End Sub

Public Sub Table_SetLastRowOnPage(Table As CscXDocTable, rowIndex As Long)
   While Table.Rows.Count>rowIndex
      Table.Rows.Remove(Table.Rows.Count-1) 'remove last row of table
   Wend
End Sub

'RECTANGLE FUNCTIONS-----------------------------------------------------------
Public Function Rectangle_IsAbove(a As Object, b As Object) As Boolean
   'returns true if a is above b on the page or on a previous page
   If a.PageIndex<b.PageIndex Then Return True
   If a.PageIndex>b.PageIndex Then Return False
   Return a.Top+a.Height<b.Top
End Function

Public Function Rectangle_IsBelow(a As Object, b As Object) As Boolean
   Return Not Rectangle_IsAbove(b,a)
End Function

Public Function XDocument_GetWordsInsideRect(pXDoc As CscXDocument, Rectangle As Object) As CscXDocWords
   'A strict version of CSCXDocument.GetWordsInRect that only accepts words COMPLETELY inside the rectangle, not just partially overlapping
   Dim w As Long, words As CscXDocWords
   With Rectangle
      If .PageIndex =-1 Then Return Nothing
      Set words=pXDoc.GetWordsInRect(.PageIndex,.Left,.Top,.Width,.Height)
   End With
   For w = words.Count-1 To 0 Step -1
      If Rectangle_Overlap2D(Rectangle,words(w))<1 Then words.Remove(w)
   Next
   Return words
End Function

Public Function XDocument_GetWordsInRect(pXDoc As CscXDocument, Rectangle As Object) As CscXDocWords
   With Rectangle
      Return pXDoc.GetWordsInRect(.PageIndex,.Left,.Top,.Width,.Height)
   End With
End Function



Public Function Rectangle_Overlap2D( a As Object, b As Object) As Double
   'returns percentage overlap of two fields, subfields or alternatives (0.0 if no overlap, 1.0 if perfect overlap)
   'Check if fields are on the same page and that both exist
   If a.PageIndex <> b.PageIndex Or a.PageIndex=-1 Then  Return 0
   Dim overlapArea As Double
   overlapArea=Max((Min(a.Left+a.Width,b.Left+b.Width)-Max(a.Left,b.Left)),0) * Max((Min(a.Top+a.Height,b.Top+b.Height)-Max(a.Top,b.Top)),0)
   Return overlapArea/Min(a.Width*a.Height,b.Width*b.Height)
End Function

Public Function Rectangle_OverlapHorizontal( a As Object, b As Object,Optional PixelShift As Long=0,Optional ignorePageIndex As Boolean=False) As Double
   'Calculates the horizontal overlap of two fields and returns 0<=overlap<=1
   'Overlap=1 is also returned if one field is inside the other
   'offset has the number of pixels of horizontal shift between the two objects
   'PixelShift is the horizontal difference between two pages (perhaps the second page was shifted left by the scanner...)
   If (Not ignorePageIndex And (a.PageIndex <> b.PageIndex)) Or a.PageIndex=-1 Or a.Width = 0 Or b.Width=0 Then Return 0
   If a.Width=0 Or b.Width=0 Then Exit Function
   Return Max((Min(a.Left+a.Width,b.Left+b.Width+PixelShift)-Max(a.Left,b.Left+PixelShift)),0)/Min(a.Width,b.Width)
End Function

Public Function Rectangle_OverlapVertical( a As Object, b As Object,Optional ignorePageIndex As Boolean=False) As Double
   'Calculates the vertical overlap of two fields and returns 0<=overlap<=1
   'Overlap=1 is also returned if one field is inside the other
   'offset has the number of pixels of vertical shift between the two objects
   If (Not ignorePageIndex And (a.PageIndex <> b.PageIndex)) Or a.PageIndex=-1 Then Return 0
   If a.Height = 0 Or b.Height=0 Then Exit Function
   Return Max((Min(a.Top+a.Height,b.Top+b.Height)-Max(a.Top,b.Top)),0)/Min(a.Height,b.Height)
End Function

Public Function Max(v1, v2)  'typeless function, returns the same type that is given as input
   Return IIf( v1 > v2, v1, v2)
End Function

Public Function Min(v1, v2)
   Return IIf( v1 < v2, v1, v2)
End Function

'FIELD COPY------------------------------------------------------------------
Sub Field_Copy(a As Object, b As Object,Optional Append As Boolean=False)
   'Intelligently and recursively copies most KTM objects into any other
   'CSCXDocField(s), CSCXDocFieldAlternatives, CSCXDocFieldAlternative, CSCXDocSubField
   'CSCXDocWord(s), CSCXDocTable, CSCXDocTableRow, CSCXDocTableCell, ICscXDocLine
   Dim i As Long, j As Long, word As CscXDocWord
   If TypeOf b Is CscXDocFieldAlternatives And Not (TypeOf a Is CscXDocFieldAlternatives) Then
      If Not Append Then Alternatives_Clear(b)
      Field_Copy(a,b.Create(),False)
      Exit Sub
   End If
   If TypeOf a Is CscXDocFieldAlternative And TypeOf b Is CscXDocField Then
      If Not Append Then Alternatives_Clear(b.Alternatives)
      Field_Copy(a,b.Alternatives.Create,False) 'Recurse
      Exit Sub
   End If
   If TypeOf a Is CscXDocSubFields Then
      For i =0 To a.Count-1
         Field_Copy(a(i),b,Append)
      Next
      Exit Sub
   End If
   If TypeOf b Is CscXDocSubFields Then
      If Not Append Then b.Clear
      Field_Copy(a,b.Create(a.Name),False)
      Exit Sub
   End If
   If TypeOf a Is CscXDocFields Then
      If Not TypeOf b Is CscXDocFields Then Exit Sub 'we only copy a Fields object into a Fields object
      For i = 0 To a.Count-1
         If b.Exists(a(i).Name) Then Field_Copy(a(i),b.ItemByName(a(i).Name),Append)
      Next
      Exit Sub
   End If

   If Field_HasTable(a) And Field_HasTable(b) Then
      If Not Append Then b.Table.Rows.Clear
      For i = 0 To a.Table.Rows.Count-1
         Field_Copy(a.Table.Rows(i),b.Table.Rows.Append)
      Next
   End If
   If TypeOf a Is CscXDocTableRow And TypeOf b Is CscXDocTableRow Then
      Dim aa As CscXDocTableCell, bb As CscXDocTableCell
      For i = 0 To a.Cells.Count-1
         For j =0 To b.Cells.Count-1
            If a.Cells(i).ColumnName=b.Cells(j).ColumnName Then
               Field_Copy(a.Cells(i), b.Cells(j))
            End If
         Next
      Next
      Exit Sub
   End If

   If TypeOf b Is CscXDocTableCell Then
      Set word=New CscXDocWord
      Field_Copy(a,word)
      b.AddWordData(word)
      Exit Sub
   End If


   If Not Append Then
      If TypeOf b Is CscXDocField Then
         While b.Alternatives.Count>0
            b.Alternatives.Remove(0)
         Wend
      ElseIf TypeOf b Is CscXDocFieldAlternative Then
         b.SubFields.Clear
      ElseIf TypeOf b Is CscXDocTable Then
         b.Rows.Clear
      End If
      If Field_HasWords(b) Then
         While b.Words.Count>0
            b.Words.Remove(0)
         Wend
      End If
      b.Text=""
   End If
   If Field_HasWords(a) And Field_HasWords(b) Then
      For i = 0 To a.Words.Count-1
         b.Words.Append(a.Words(i))
      Next
   End If

   If TypeOf a Is ICscXDocLine And Not TypeOf b Is ICscXDocLine Then
      b.Top=a.StartY
      b.Left=a.StartX
      b.Width=a.EndX-a.StartX
      b.Height=a.EndY-a.StartY
      b.PageIndex=a.PageIndex
   Else
      b.Top=a.Top
      b.Left=a.Left
      b.Width=a.Width
      b.Height=a.Height
      If Append Then b.Text=Trim(Replace(b.Text & " " & a.Text," ","  ")) Else b.Text=Trim(a.Text)
      b.PageIndex=a.PageIndex
   End If
   If TypeOf a Is CscXDocFieldAlternative AndAlso TypeOf b Is CscXDocFieldAlternative Then
       b.Source=a.Source 'Copy knowledgebase source info
   End If
   If Field_HasConfidence(a) And Field_HasConfidence(b) Then
       b.Confidence = a.Confidence
   End If
   If TypeOf a Is CscXDocField And TypeOf b Is CscXDocField Then
      For i = 0 To a.Alternatives.Count-1
         Field_Copy(a.Alternatives(i),b.Alternatives.Create(),Append) 'Recurse
      Next
   End If
End Sub

Public Function Field_HasTable(a As Object) As Boolean
   If Not(TypeOf a Is CscXDocField Or TypeOf a Is CscXDocFieldAlternative )Then Return False
   Return a.Table.Columns.Count<>0
End Function

Public Function Field_HasConfidence(a As Object) As Boolean
   Return TypeOf a Is CscXDocField Or TypeOf a Is CscXDocFieldAlternative Or TypeOf a Is CscXDocSubField
End Function
Public Function Field_HasWords(a As Object) As Boolean
   Return (TypeOf a Is CscXDocField Or TypeOf a Is CscXDocSubField Or TypeOf a Is CscXDocFieldAlternative Or TypeOf a Is CscXDocTextLine)
End Function

Sub Alternatives_Clear(alts As CscXDocFieldAlternatives)
   While alts.Count>0
      alts.Remove(0)
   Wend
End Sub
