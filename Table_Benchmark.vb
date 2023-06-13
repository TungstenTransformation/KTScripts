'#Language "WWB-COM"
Option Explicit

' Class script: invoice

Private Sub Document_AfterExtract(ByVal pXDoc As CASCADELib.CscXDocument)
   Table_Benchmark(pXDoc, "LineItems", "Total Price", DefaultAmountFormatter)
End Sub

Sub Table_Benchmark(pXDoc As CscXDocument, TableFieldName As String, SumColumnName, SumColumnAmountFormatter As CscAmountFormatter)
   'Compare a Table Field in an XDoc with the Truth Table Field in the XDoc stored on the filesystem
   Dim Table As CscXDocTable, SumIsValid As Boolean, Field As CscXDocField, ErrDescription As String, Truth As New CscXDocument, TruthTable As CscXDocTable
   Set Table=pXDoc.Fields.ItemByName(TableFieldName).Table
   Truth.Load(pXDoc.FileName)
   Set TruthTable=Truth.Fields.ItemByName(TableFieldName).Table
   Set Field=pXDoc.Fields.ItemByName("TableRowCount")
   Field.Text=CStr(Table.Rows.Count)
   Field.Confidence=1.00: Field.ExtractionConfident=True
   If SumColumnName<>"" Then
      Set Field=pXDoc.Fields.ItemByName("Table" & Replace(SumColumnName," ","")&"Sum")
      Field.Text=Format(Table.GetColumnSum(Table.Columns.ItemByName(SumColumnName).IndexInTable,SumIsValid),"0.00")
      If SumIsValid Then SumColumnAmountFormatter.FormatField(Field)
      Field.Confidence=1.00: Field.ExtractionConfident=True
   End If
   Set Field=pXDoc.Fields.ItemByName("TableRowAlignment")
   Field.Text=Format(Tables_RowAlignment(pXDoc,Table,TruthTable,ErrDescription),"0.00")
   If ErrDescription <> "" Then Field.Text= Field.Text & vbCrLf & " Bad Rows:" & ErrDescription ' so we can see the misaligned row numbers in the benchmark
   Field.Confidence=1.00: Field.ExtractionConfident=True
   ErrDescription=""
   Set Field=pXDoc.Fields.ItemByName("TableColumnAlignment")
   Field.Text=Format(Tables_ColumnAlignment(pXDoc,Table,TruthTable, ErrDescription),"0.00")
   If ErrDescription <> "" Then Field.Text= Field.Text & vbCrLf & " Bad Columns:" & ErrDescription ' so we can see the misaligned column numbers in the benchmark
   Field.Confidence=1.00: Field.ExtractionConfident=True
   Set Field=pXDoc.Fields.ItemByName("TableCells")
   Field.Text=Format(Tables_CompareCells(Table,TruthTable,ErrDescription),"0.00")
   If ErrDescription <> "" Then Field.Text= Field.Text & vbCrLf&  ErrDescription ' so we can see the wrong text in the benchmark 'only show 10 results!
   Field.Confidence=1.00: Field.ExtractionConfident=True
End Sub

Function Tables_RowAlignment(pXDoc As CscXDocument, Table As CscXDocTable, TruthTable As CscXDocTable, ByRef ErrDescription As String) As Double
   'Calculate the alignment from 0.00 to 1.00 between the rows of two tables.
   Dim Alignment As Double, R As Long, TotalAlignment As Double
   ErrDescription=""
   If Table.Rows.Count=0 Then Return 0
   If TruthTable.Rows.Count=0 Then Return 0
   For R=0 To Table.Rows.Count-1
      If R<TruthTable.Rows.Count Then
         Alignment =Rows_Alignment(Table.Rows(R),TruthTable.Rows(R))
         If Alignment <1.00 Then ErrDescription=ErrDescription & CStr(R+1) & ","
         TotalAlignment=TotalAlignment+ Alignment
      End If
   Next
   If ErrDescription<>"" Then ErrDescription= Left(ErrDescription,Len(ErrDescription)-1) 'remove trailing space
   Return TotalAlignment/Max(Table.Rows.Count,TruthTable.Rows.Count) ' returns 1.00 if perfect alignment
End Function

Function Rows_Alignment(Row1 As CscXDocTableRow, Row2 As CscXDocTableRow) As Double
   'Calculate the alignment between 2 rows.
   Dim A As Double, B As Double, Overlap As Double, P As Long, Pages As Long
   'Some rows can page wrap onto another page. It's actually possible for a single row to cover many pages, but unlikely.
   If Row1.StartPage<>Row2.StartPage Then Return 0
   If Row1.EndPage<>Row2.EndPage Then Return 0
   For P=Row1.StartPage To Row1.EndPage
      If Row1.Height(P)>0 And Row2.Height(P)>0 Then
         A=Max(Row1.Top(P)+Row1.Height(P)-Row2.Top(P),0) ' distance from top of row2 to bottom of row1
         B=Max(Row2.Top(P)+Row2.Height(P)-Row1.Top(P),0) ' distance from top of row1 to bottom of row2
         Overlap =Overlap+ Min(A,B)/Max(A,B) ' divide the inside overlap by the outer span. If they are the same, then it gives 1.00
      End If
   Next
   Pages = Max(Row1.EndPage-Row1.StartPage+1,Row2.EndPage-Row2.StartPage+1) ' calculate if any row wraps across one or more pages
   Return Overlap/Pages
End Function

Function Tables_ColumnAlignment(pXDoc As CscXDocument, Table As CscXDocTable,TruthTable As CscXDocTable,ByRef ErrDescription As String) As Double
   'Calculate the alignment from 0.00 to 1.00 between the columns of two tables.
   Dim Alignment As Double, C As Long
   Dim TotalAlignment As Double
   ErrDescription=""
   If Table.Columns.Count<> TruthTable.Columns.Count Then Return 0 ' these tables are not using the same table model!!!
   For C=0 To Table.Columns.Count-1
      If C<TruthTable.Columns.Count Then
         Alignment=Columns_Alignment(Table.Columns(C),TruthTable.Columns(C),Table)
         If Alignment <1.00 Then ErrDescription=ErrDescription & CStr(C+1) & ","
         TotalAlignment=TotalAlignment+ Alignment
      End If
   Next
   If ErrDescription<>"" Then ErrDescription= Left(ErrDescription,Len(ErrDescription)-1) 'remove trailing space
   Return TotalAlignment/Table.Columns.Count ' returns 1.00 if perfect alignment
End Function


Function Columns_Alignment(Column1 As CscXDocTableColumn, Column2 As CscXDocTableColumn, Table As CscXDocTable) As Double
   'Calculate the alignment between two columns
   Dim A As Double, B As Double, Overlap As Double, P As Long, Pages As Long, StartPage As Long, EndPage As Long
   If Column1.StartPage<>Column2.StartPage Then Return 0
   If Column1.EndPage<>Column2.EndPage Then Return 0
   StartPage=Table.Rows(0).StartPage 'There is a bug that Column.StartPage and Column.EndPage are always -1, so i need to read from rows.
   EndPage=Table.Rows(Table.Rows.Count-1).EndPage
   For P= StartPage To EndPage
      If Column1.Width(P)=0 And Column2.Width(P)=0 Then
         Overlap=Overlap+1' we allow empty columns
      Else
         A=Max(Column1.Left(P)+Column1.Width(P)-Column2.Left(P),0)
         B=Max(Column2.Left(P)+Column2.Width(P)-Column1.Left(P),0)
         Overlap=Overlap+Min(A,B)/Max(A,B)
      End If
   Next
   Pages = Max(Column1.EndPage-Column1.StartPage+1,Column2.EndPage-Column2.StartPage+1) ' calculate how many pages
   Return Overlap/Pages
End Function

Function Tables_CompareCells(Table As CscXDocTable, TruthTable As CscXDocTable, ByRef ErrDescription As String) As Double
   'Compare the cells between two tables and count and report on the mismatches.
   Dim R As Long, C As Long, Cell As CscXDocTableCell, TruthCell As CscXDocTableCell, Errors As Long
   Const MAXERRORS=10 'only show this many errors
   'Check that all the table cells agree
   ErrDescription=""
   If Table.Columns.Count<>TruthTable.Columns.Count Then
      ErrDescription = "Tables should have same table models"
      Return 0
   End If
   For R=0 To Table.Rows.Count-1
      For C=0 To Table.Columns.Count-1
         If R<TruthTable.Rows.Count Then
            Set Cell=Table.Rows(R).Cells(C)
            Set TruthCell=TruthTable.Rows(R).Cells(C)
            If Cell.Text<>TruthCell.Text Then
               If Errors <MAXERRORS Then
                  ErrDescription= ErrDescription & vbCrLf & "R" & CStr(R+1) & "C" & CStr(C+1) & ":  " & String_Truncate(Cell.Text) & vbCrLf & Space(12) &"[" & String_Truncate(TruthCell.Text) & "]"
               End If
               Errors = Errors +1
            End If
         End If
      Next
   Next
   ErrDescription = "Total Cell Errors: " & CStr(Errors) & vbCrLf & ErrDescription
   Return 1-Errors/Table.Rows.Count/Table.Columns.Count
End Function

Function String_Truncate(A As String) As String
   'Truncate a string and add an ellipsis … if too long
   Const MAXTEXT=35 'truncate all text to this many characters
   Return Left(A,MAXTEXT) & IIf(Len(A)>MAXTEXT, "…","")
End Function

Function Min(A,B) 'typeless function works with all variable types
   Return IIf(A<B,A,B)
End Function

Function Max(A,B)
   Return IIf(A>B,A,B)
End Function
