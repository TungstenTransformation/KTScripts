'======================================================'
'Winwrap implementation of efficent and fast sort algorithm http://en.wikipedia.org/wiki/Quicksort
'This algorithm can sort an array of any kind of object
'Customize the Object_Compare function for your sorting needs.

'Example
'Alternatives_Sort(pField.Alternatives, AddressOf Comparer_Confidence)
'Subfields_Sort(pLocator.Alternatives(0).Subfields, AddressOf Comparer_TopLeftCorner)


'THIS DELEGATE DEFINTION NEEDS TO BE AT THE TOP OF THE SCRIPT
Delegate Function ComparerDelegate(a As Variant, b As Variant) As Boolean ' Delegate definition for sorting comparers

'Examples of comparers, used by the sorting algoritm
Public Function Comparer_Left2RightTop2Bottom(a As Variant, b As Variant) As Boolean
   'Used to sort lines so that verticals are sorted left to right before horizontals top to bottom
   If a.Text<>b.Text Then Return a.Text="v" 'Verticals before Horizontals
   If a.Text="v" Then Return a.Left<b.Left 'Sort verticals left to right
   Return a.Top<b.Top 'sort horizontals top to bottom
End Function

Public Function Comparer_TopLeftCorner(a As Variant, b As Variant) As Boolean
   'Sorts items by their top-left coordinate - good for grouping graphical lines together
   If a.PageIndex<>b.PageIndex Then return a.PageIndex<b.PageIndex
   Return a.Left+a.Top < b.Left+b.Top
End Function

 Public Function Comparer_AboveOrLeft(a As Variant, b As Variant) As Boolean
   'Sorts items by their top-left coordinate - good for grouping graphical lines together
   If a.PageIndex<>b.PageIndex Then Return a.PageIndex<b.PageIndex
   If a.Top+a.Height<b.Top Then  'a is above b
      If a.Left <= b.Left And a.Left+a.Width >= b.Left Then Return True ' a overlaps b horizontally to the left
      If b.Left <= a.Left And b.Left+b.Width >= a.Left Then Return False ' a overlaps a horizontally to the right
      'a and b do not overlap horizontally, but b is under a
      Return a.Left<b.Left
   End If
   If a.Left+a.Width<b.Height Then  'a is left of b
      If a.Top <= b.Top And a.Top+a.Height >= b.Top Then Return True ' a overlaps b vertically but is higher
      If b.Top <= a.Top And b.Top+b.Height >= a.Top Then Return True 'a overlaps b vertically but is lower  (there are two or more columns here...)
      'a and b do not overlap horizontally, but b is under a
      Return a.Top < b.Top
   End If
   'if we got here the two objects overlap so we return one further in the top left.
   Return a.Left+a.Top < b.Left+a.Top
End Function

Public Function Comparer_Confidence( a As Variant, b As Variant) As Boolean
   'Used to sort lines
   Return a.Confidence > b.Confidence
End Function

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

Public Sub Alternatives_SortBySubfield(alternatives As CscXDocFieldAlternatives, SubfieldName As String, Comparer As ComparerDelegate)
   'Sort Alternatives based on a particular Subfield
   'we have to copy the correct subfield to an array, sort the array
   'and then copy the alternatives based on the subfield order
   Dim alts() As CscXDocFieldAlternative, a As Long
   Dim sfs() As CscXDocSubField, s As Long
   'copy the required subfield into an array
   ReDim sfs(alternatives.Count-1)
   For a =0 To alternatives.Count-1
      Set sfs(a)=alternatives(a).SubFields.ItemByName(SubfieldName)
      sfs(a).LongTag=a ' so subfield knows which alternative it belongs to!
   Next
   'copy the alts into an array, so they are preserved when we remove them from the locator
   ReDim alts(alternatives.Count-1)
   For a =0 To alternatives.Count-1
      Set alts(a)=alternatives(a)
   Next
   'sort the subfields with the comparer
   Array_Sort(sfs, Comparer)
   'remove all alternatives from the locator
   While alternatives.Count>0
      alternatives.Remove(0)
   Wend
   'copy the alternatives back in the order of the sorted subfield
   For a=0 To UBound(sfs)
      Field_Copy(alts(sfs(a).LongTag),alternatives.Create)
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
