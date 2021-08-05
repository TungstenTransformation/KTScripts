# Spellchecker  
This script uses a fuzzy database to spellcheck a string. To use it simply make a Locator called SL_Spellcheck 
and make it a Script Locator. Then paste the code below into the script field.  Make sure that your database is of type "Associative Search"
```vba
Private Sub SL_Spellcheck_LocateAlternatives(ByVal pXDoc As CASCADELib.CscXDocument, ByVal pLocator As CASCADELib.CscXDocField)
   Dim Test As String, Results As CscXDocFieldAlternatives, NumWords As Long, R As Long, T As Long, Word As String, Words() As String
   Dim ResultWords() As String, H As Long, NewWords() As String
   Test = ""
   Test = Trim(UCase(Test))
   'Test = Replace(Test, "§", "Ş")
   'Set Results = Database_FuzzySearch("Turkish_banks", "WORD", Test, 100, 0.01)
   Set Results = Project.Databases.ItemByName("Turkish_banks_asd").AssociativeSearch.SearchText(Test, 100).Alternatives
   NumWords = UBound(Split(Test))
   ReDim Words(NumWords) As String
   ReDim NewWords(NumWords) As String
   Words = Split(Test)
   For R=0 To Results.Count-1
      ReDim ResultWords(UBound(Split(Results(R).Text)))
      ResultWords = Split(Results(R).Text)
      NumWords = UBound(Split(Results(R).Text))
      For T=0 To UBound(Words)-NumWords
         For H=0 To NumWords
            If String_LevenshteinDistance(ResultWords(H), Words(T+H)) > Len(ResultWords(H))\3 Then 'The words don't match up
               Exit For
            End If
            If H=NumWords Then 'The entire phrase is compatible
               For H=0 To NumWords
                  If NewWords(T+H)="" Then
                     NewWords(T+H) = ResultWords(H)
                  Else
                     Exit For
                  End If
               Next
               Exit For
            End If
         Next
      Next
   Next
   For R=0 To UBound(NewWords)
      If NewWords(R)="" Then
         NewWords(R)=Words(R)
      End If
   Next
   Test=Join(NewWords, " ")
   pLocator.Alternatives.Create.Text=Test
End Sub

Public Function String_LevenshteinDistance(a As String ,b As String) as Long
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
