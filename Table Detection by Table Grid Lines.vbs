'#Language "WWB-COM"
Option Explicit

' Class script: Zakaz
Delegate Function ComparerDelegate(a As Variant, b As Variant) As Boolean ' Delegate defintion for sorting comparers

Private Sub SL_Lines_LocateAlternatives(ByVal pXDoc As CASCADELib.CscXDocument, ByVal pLocator As CASCADELib.CscXDocField)
   'Find all horizontal and vertical lines on the page with the KRZ Header.
   Dim TablePageIndex As Long
   With pXDoc.Locators.ItemByName("SE_KRZ_Header").Alternatives
      If .Count=0 Then Exit Sub 'No header found
      TablePageIndex=.ItemByIndex(0).PageIndex
   End With
   Image_DetectGraphicLines(pXDoc.CDoc.Pages(TablePageIndex).GetImage, TablePageIndex, pLocator.Alternatives)
End Sub

Private Sub SL_TableGrids_LocateAlternatives(ByVal pXDoc As CASCADELib.CscXDocument, ByVal pLocator As CASCADELib.CscXDocField)
   'Group all horizontal and vertical lines into intersecting grids
   Dim lines As CscXDocFieldAlternatives, l As Long, c As Long, overlap As Double, Header As CscXDocFieldAlternative
   Dim alt As CscXDocFieldAlternative, bestTableIndex As Long, grids As CscXDocFieldAlternatives, found As Boolean
   With pXDoc.Locators.ItemByName("SE_KRZ_Header").Alternatives
       If .Count=0 Then Exit Sub 'No header found
       Set Header=.ItemByIndex(0)
   End With
   Set grids=pLocator.Alternatives
   Set lines=pXDoc.Locators.ItemByName("SL_Lines").Alternatives
   Alternatives_Sort(lines, AddressOf Comparer_TopLeftCorner)
   'Group all the lines on the page into grids
   Lines_Gridify(lines, grids)
   'Find the grid that is just under the table header and give it the best score
   For c =0 To grids.Count-1
      If grids(c).Top>Header.Top And (grids(c).Top<grids(bestTableIndex).Top Or grids(bestTableIndex).Top<Header.Top) Then bestTableIndex=c
   Next
   grids(bestTableIndex).Confidence=100
   'We need to sort the vertical lines from left to right, and then the horizontal lines from top to bottom.
   For c=grids.Count-1 To 0 Step -1
      If grids(c).SubFields.Count<2 Then
         grids.Remove(c) 'this is just an isolated line and not interesting
      Else
         Subfields_Sort(grids(c).SubFields,AddressOf Comparer_Left2RightTop2Bottom) 'sort all the lines in all the grids. We may use an alternative in the Validation Module
      End If
   Next
End Sub

Private Sub SL_KRZ_LocateAlternatives(ByVal pXDoc As CASCADELib.CscXDocument, ByVal pLocator As CASCADELib.CscXDocField)
   Dim table As CscXDocTable, lines As CscXDocSubFields, l As Long, row As CscXDocTableRow, v As Long, h As Long, w As Long, word As CscXDocWord
   Dim grid As CscXDocFieldAlternative,tl As Long, textlines As CscXDocTextLines,textline As CscXDocTextLine
   With pXDoc.Locators.ItemByName("TL_KRZ").Alternatives(0)
      If .Source=CscASSpecific Then Exit Sub ' This table was specifically trained
      Set table=.Table
   End With
   table.Rows.Clear
   With pXDoc.Locators.ItemByName("SL_TableGrids").Alternatives
      If .Count=0 Then Exit Sub ' no table grid found
      Set grid=.ItemByIndex(0)
   End With
   Set lines=grid.SubFields
   h=-1 'look for the first horizontal line in the table grid
   For l =0 To lines.Count-1
      If lines(l).Text="h" Then h=l:Exit For
   Next
   If h=-1 Then Exit Sub 'No horizontal lines in table grid
   Set textlines=pXDoc.Pages(grid.PageIndex).TextLines
   While tl<textlines.Count
      Set textline=textlines(tl)
      If textline.Top>grid.Top+grid.Height Then
         Exit While 'below table
      ElseIf textline.Top>grid.Top Then 'inside Table
         'Create a new table row if passed a horizontal line
         If h<lines.Count AndAlso textline.Top>lines(h).Top Then
            Set row=table.Rows.Append
            h=h+1
         End If
         v=0
         For w=0 To textline.Words.Count-1
            Set word=textline.Words(w)
            If v=lines.Count-1 Then
               'There are no horizontal lines and last vertical line not found.
               'add the word to current column
            ElseIf word.Left>lines(v+1).Left And lines(v+1).Text="v" Then
               v=v+1 'move to next column
            End If
            row.Cells(v).AddWordData(word)
         Next
      End If
      tl=tl+1
   Wend
   If table.Rows.Count<1 Then Exit Sub 'no table rows were found
   With table.Rows(0).Cells(1)
      If Len(.Text)-String_LevenshteinDistance("???????????? ?????",.Text)>8 Then
         table.Rows.Remove(0) ' the first row of the table is the header
      End If
   End With
   With table.Rows(table.Rows.Count-1).Cells(1)
      If Len(.Text)-String_LevenshteinDistance("?????",.Text)>4 Then
         table.Rows.Remove(table.Rows.Count-1) ' the last row of the table is a sum
      End If
   End With

End Sub


Public Function Comparer_TopLeftCorner(a As Variant, b As Variant) As Boolean
   'Sorts items by their top-left coordinate - good for finding crossing lines fast
   Return a.Left+a.Top<b.Left+b.Top
End Function

Public Function Comparer_Left2RightTop2Bottom(a As Variant, b As Variant) As Boolean
   'Used to sort lines so that verticals are sorted left to right before horizontals top to bottom
   If a.Text<>b.Text Then Return a.Text="v" 'Verticals before Horizontals
   If a.Text="v" Then Return a.Left<b.Left 'Sort verticals left to right
   Return a.Top<b.Top 'sort horizontals top to bottom
End Function

Public Sub Lines_Gridify(lines As CscXDocFieldAlternatives, ByRef grids As CscXDocFieldAlternatives)
   Dim l As Long, g As Long, grid As CscXDocFieldAlternative
   Dim vline As CscXDocSubField, gridFound As Boolean, overlap As Double
   For l =0 To lines.Count-1
      gridFound=False
      For g =0 To grids.Count-1
         Set grid=grids(g)
         overlap=Object_Overlap2D(lines(l),grid)
         If overlap>0 Then 'this line intersects the grid
            gridFound=True
            Exit For
         End If
      Next
      If Not gridFound Then Set grid=grids.Create
      Field_Copy(lines(l),grid.SubFields.Create(CStr(l)))
      Field_ExpandBoundingBoxBy(grid, lines(l))
      If gridFound Then Objects_Conflate(grids, AddressOf Object_IsOverlap2D) 'Merge grids that may now overlap each other
   Next
End Sub

Public Sub Objects_Conflate(fields As CscXDocFieldAlternatives, condition As ComparerDelegate)
   'Copy the subfields of one alternative to another if some condition is met
   Dim c As Long, d As Long
   While c<fields.Count-1
      d=c+1
      While d<fields.Count
         If condition.Invoke(fields(c),fields(d)) Then
            Field_Copy(fields(d).SubFields,fields(c),True)
            fields.Remove(d)
         Else
            d=d+1
         End If
      Wend
      c=c+1
   Wend
End Sub

Public Function Comparer_Top( a As Variant, b As Variant) As Boolean
   'Used to sort lines
   Return a.Top<b.Top
End Function

Public Sub Field_ExpandBoundingBoxBy(x As Object, y As Object)
   'Expands the coordinates of X to include Y
   Dim l As Long, t As Long, r As Long, b As Long
   If x.PageIndex=-1 And y.PageIndex<>-1 Then
      'field doesn't exist yet, so copy coordinates
      x.PageIndex=y.PageIndex
      x.Left=y.Left
      x.Top=y.Top
      x.Width=y.Width
      x.Height=y.Height
   End If
   If x.PageIndex<>y.PageIndex Then Exit Sub
   'field exists and is on same page so extend bounding box
   l=Min(x.Left,y.Left)
   r=Max(x.Left+x.Width,y.Left+y.Width)
   t=Min(x.Top,y.Top)
   b=Max(x.Top+x.Height,y.Top+y.Height)
   x.Left=l
   x.Width=r-l
   x.Top=t
   x.Height=b-t
End Sub

Public Function Object_IsOverlap2D(a As Variant, b As Variant) As Boolean
   Return Object_Overlap2D(a,b)>0
End Function

Public Function Object_Overlap2D( a As Object, b As Object) As Double
   'returns percentage overlap of two fields, subfields or alternatives (0.0 if no overlap, 1.0 if perfect overlap)
   'Check if fields are on the same page and that both exist
   If a.PageIndex <> b.PageIndex Or a.PageIndex=-1 Then  Return 0
   If a.Width=0 Or b.Width=0 Then Return 0 'avoid division by zero
   Dim overlapArea As Double
   overlapArea=Max((Min(a.Left+a.Width,b.Left+b.Width)-Max(a.Left,b.Left)),0) * Max((Min(a.Top+a.Height,b.Top+b.Height)-Max(a.Top,b.Top)),0)
   Return overlapArea/Max(a.Width*a.Height,b.Width*b.Height)
End Function

Public Function Line_VerticalOverlap( a As Object, b As Object) As Double

   'Calculates the vertical overlap of two fields and returns 0<=overlap<=1
   Dim o As Double
   If a.PageIndex<>b.PageIndex Then Return 0
   If TypeOf a Is ICscXDocLine Then
      If a.EndY = a.StartY Or b.Height=0 Then Exit Function
      o=Max((Min(a.EndY,b.Top+b.Height)-Max(a.StartY,b.Top)),0)
      Return o/Max(a.EndY-a.StartY,b.Height)
   Else
      o=Max((Min(a.Top+a.Height,b.Top+b.Height)-Max(a.Top,b.Top)),0)
      Return o/Max(a.Height,b.Height)
   End If
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

Private Sub Image_DetectGraphicLines(pImage As CscImage,pageIndex As Long,ByRef alts As CscXDocFieldAlternatives)
   ' Add reference to Kofax Cascade Forms Processing
   Dim pLinesDetection As CSCFORMSLib.CscLinesDetection
   Dim xLeft As Long
   Dim xWidth As Long
   Dim yTop As Long
   Dim yHeight As Long
   Dim i As Long ,j As Long
   Dim l As CscLineInfo
   ' check color format
   If pImage.BitsPerSample <> 1 Or pImage.SamplesPerPixel <> 1 Then Exit Sub
   ' setup parameters for lines detection
   Set pLinesDetection = New CscLinesDetection
   pLinesDetection.DetectHorCombs = False
   pLinesDetection.DetectHorDotLines = False
   pLinesDetection.DetectHorLines = True
   pLinesDetection.DetectVerLines = True
   pLinesDetection.MinHorLineLenMM = 40
   pLinesDetection.MinVerLineLenMM = 10
   ' start lines detection
   pLinesDetection.DetectLines( pImage, pImage.Width/100, pImage.Height/100, pImage.Width*.98, pImage.Height*.98)

   For i = 0 To pLinesDetection.HorLineCount-1
      Set l=pLinesDetection.GetHorLine(i)
      With alts.Create()
         .PageIndex=pageIndex
         .Left=l.StartX
         .Top=l.StartY
         .Width=l.EndX-l.StartX
         .Height=10'l.EndY-l.StartY
         .Confidence=1
         .Text="h"
      End With
   Next
   For i = 0 To pLinesDetection.VerLineCount-1
      Set l=pLinesDetection.GetVerLine(i)
      With alts.Create()
         .PageIndex=pageIndex
         .Left=l.StartX
         .Top=l.StartY
         .Width=10'l.EndX-l.StartX
         .Height=l.EndY-l.StartY
         .Confidence=1
         .Text="v"
      End With
   Next
End Sub

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
   If Field_HasSubFields(a) And Field_HasSubFields(b) Then
      For i = 0 To a.SubFields.Count-1
         Dim sf As New CscXDocSubField
         Field_Copy(a.SubFields(i),b.SubFields.Create(a.SubFields(i).Name),Append)
      Next
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
Public Function Field_HasSubFields(a As Object) As Boolean
   Return (TypeOf a Is CscXDocField Or TypeOf a Is CscXDocFieldAlternative)
End Function

Sub Alternatives_Clear(alts As CscXDocFieldAlternatives)
   While alts.Count>0
      alts.Remove(0)
   Wend
End Sub

'======================================================'
'Winwrap implementation of efficent and fast sort algorithm http://en.wikipedia.org/wiki/Quicksort
'This algorithm can sort an array of any kind of object
'Customize the Object_Compare function for your sorting needs.

Public Sub Alternatives_Sort(alternatives As CscXDocFieldAlternatives, Comparer As ComparerDelegate)
   'Sort alternatives using a comparer
   'we have to copy the alternatives to an array, sort the array and then copy back to the alternatives
   Dim alts() As CscXDocFieldAlternative, a As Long
   ReDim alts(alternatives.Count-1)
   For a =0 To alternatives.Count-1
      Set alts(a)=alternatives(a)
   Next
   Array_Sort(alts, Comparer)
   While alternatives.Count>0
      alternatives.Remove(0)
   Wend
   For a=0 To UBound(alts)
      Field_Copy(alts(a),alternatives.Create)
   Next
End Sub

Public Sub Subfields_Sort(subfields As CscXDocSubFields, Comparer As ComparerDelegate)
   'Sort subfields using a comparer
   'we have to copy the subfields to an array, sort the array and then copy back to the subfields
   Dim sfs() As CscXDocSubField, s As Long
   ReDim sfs(subfields.Count-1)
   For s=0 To subfields.Count-1
      Set sfs(s)=subfields(s)
   Next
   Array_Sort(sfs, Comparer)
   subfields.Clear
   For s =0 To UBound(sfs)
      Field_Copy(sfs(s),subfields.Create(CStr(s)))
   Next
End Sub

Private Sub Array_Sort(ByRef a As Variant, Comparer As ComparerDelegate)
   Quicksort_Sort(a,0,UBound(a),Comparer)
End Sub

Sub Quicksort_Sort(ByRef a As Variant, ByVal Left As Integer, ByVal Right As Integer,Comparer As ComparerDelegate)
   Dim pivot As Integer
   If Right > Left  Then
      pivot = Quicksort_GetPivot(Left, Right)
      pivot = Quicksort_Partition(a, Left, Right, pivot, Comparer)
      Quicksort_Sort(a, Left, pivot, Comparer)
      Quicksort_Sort(a, pivot + 1, Right, Comparer)
   End If
End Sub

Function Quicksort_GetPivot(ByVal Left As Integer, ByVal Right As Integer)
   'Return a random integer between Left and Right
   Return (Rnd()*(Right-Left+1)*1000) Mod (Right-Left+1) + Left
End Function

Function Quicksort_Partition(ByRef a As Variant, ByVal l As Integer, ByVal r As Integer, ByRef pivot As Integer, Comparer As ComparerDelegate)
   Dim i,store As Integer
   Dim piv As Variant
   Set piv = a(pivot)
   Object_Swap(a(r), a(pivot))
   store = l
   For i = l To r - 1
      If Comparer.Invoke(a(i),piv) Then
          Object_Swap(a(store), a(i))
          store = store + 1
      End If
   Next
   Object_Swap(a(r), a(store))
   Return store
End Function

Sub Object_Swap(ByRef v1 As Variant, ByRef v2 As Variant)
   Dim tmp As Variant
   Set tmp = v1
   Set v1 = v2
   Set v2 = tmp
End Sub
'======================================================'

Public Function String_FuzzyMatch(ByVal a As String, ByVal b As String, Optional removeSpaces As Boolean = False) As Double
   'returns 0.0 for no match, 1.0 for perfect match, in between for fuzzy match.
   If removeSpaces Then
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
   'eg "kitten" and "kitchen" have a difference of 1 insertion of "c" + 1 substitution of "h"=2

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
