Public Function String_FuzzyMatch(ByVal a As String, ByVal b As String, optional removeSpaces As Boolean = false) As Double
   'returns 0.0 for no match, 1.0 for perfect match, in between for fuzzy match.
   If removeSpaces then
      a=Replace(a," ","")
      b=Replace(b," ","")
   End If
   If Len(a)= 0 Or Len(b)=0 Then Return 0
   Return CDbl(1.0 - String_LevenshteinDistance(a, b)/ Max(Len(a),Len(b)))
End Function

Private Function XDocument_SearchLineFuzzy(ByVal pXDoc As CscXDocLib.CscXDocument, ByVal pageIndex As Integer, ByVal compareText As String, ByRef confidence As Double) As Integer
   Dim i As Long, bestIndex As Long
   Dim conf As Double, bestConf As Double
   bestIndex=-1
   For i = 0 To pXDoc.Pages(pageIndex).TextLines.Count - 1
      conf = String_FuzzyMatch(compareText, pXDoc.Pages(pageIndex).TextLines(i).Text, True)
      If conf > bestConf Then bestConf = conf : bestIndex = i
   Next
   confidence = bestConf
   return bestIndex
End Function


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

Public Sub Words_Align(ByRef wordsA As CscXDocWords,ByRef wordsB As CscXDocWords)
   Dim a As Long, b As Long, x As Long, y As Long, c As Long
   Dim uniqueA As Dictionary, uniqueB As Dictionary, word As String
   'Search for split point
   Set uniqueA=Words_FindUniqueWords(wordsA)
   Set uniqueB=Words_FindUniqueWords(wordsB)
   'find a group of 3 unique words.
   a=wordsA.Count-1:x=a
   b=wordsB.Count-1:y=b
   While x>=0 And y>=0
      word=wordsA(x).Text
      If uniqueA.Exists(word) AndAlso uniqueB.Exists(word) Then
         If c=0 AndAlso uniqueB(word)<=y Then 'start of new potential triplet
            y=uniqueB(word)
         ElseIf uniqueB(word)=y-1 Then 'search further through the potential triplet
            y=y-1
         End If
            c=c+1
         If c=3 Then
            'we have a unique triplet
            Words_LevenshteinTraceback(wordsA,wordsB,x,a,y,b)
            a=x
            b=y
            c=0
         End If
      Else ' no match
         c=0
         y=b
      End If
      x=x-1
   Wend
   x=0
   y=0
   If a>0 Or b>0 Then Words_LevenshteinTraceback(wordsA,wordsB,x,a,y,b)
End Sub

Public Sub Words_LevenshteinTraceback(ByRef wordsA As CscXDocWords, ByRef wordsB As CscXDocWords, ByRef x As Long, ByRef a As Long, ByRef y As Long, ByRef b As Long)
   Dim d() As Long, cost As Long, del As Long, ins As Long, subs As Long, word As CscXDocWord
   Dim u As Long, v As Long
   ReDim d(wordsA.Count-x,wordsB.Count-y)
   For u=0 To wordsA.Count-x
      d(u,0)=u
   Next
   For v=1 To wordsB.Count-y
      d(0,v)=v
   Next
   'build levenshtein matrix
   For u = 1 To wordsA.Count-x
      For v = 1 To wordsB.Count-y
         cost=IIf(wordsA(u+x-1).Text=wordsB(v+y-1).Text,0,1)
         del = ( d( u - 1, v ) + 1 ) ' cost of deletion
         ins = ( d( u, v - 1 ) + 1 ) ' cost of insertion
         subs = ( d( u - 1, v - 1 ) + cost ) 'cost of substition or match
         d(u,v)=Min(ins,Min(del,subs))
      Next
   Next
   'traceback
   u=wordsA.Count-x
   v=wordsB.Count-y
   While u>0 And u>0
      del = d( u - 1, v ) ' cost of deletion
      ins = d( u, v - 1 ) ' cost of insertion
      subs = d( u - 1, v - 1)  'cost of substition or match
      Select Case Min(Min(subs,ins),del)
      Case subs
         u=u-1:v=v-1
      Case ins
         Set word= New CscXDocWord
         word.Text="--INS--"
         Words_Insert(wordsA,word,u+x)
         a=a+1
         v=v-1
      Case del
         Set word= New CscXDocWord
         word.Text="--DEL--"
         Words_Insert(wordsB,word,v+y)
         b=b+1
         u=u-1
      End Select
   Wend
End Sub

Public Sub Words_Insert(words As CscXDocWords, word As CscXDocWord, pos As Long)
   'Workaround to Words.Insert, which doesn't work in KTM 5.5.2.10
   Dim temp As New CscXDocWords,w As Long
   For w = pos To words.Count-1
      temp.Append(words(w))
   Next
   While words.Count>pos
      words.Remove(pos)
   Wend
   words.Append(word)
   For w = 0 To temp.Count-1
      words.Append(temp(w))
   Next
   Set temp=Nothing
End Sub


Public Function Words_FindUniqueWords(words As CscXDocWords) As Dictionary
   'This makes a dictionary of all words and keeps only unique words
   Dim dict As New Dictionary, key As String
   Dim w As Long, word As CscXDocWord
   For w =0 To words.Count-1
      Set word=words(w)
      If dict.Exists(word.Text) Then
         Set dict.Item(word.Text)=Nothing ' this word is not unique
      Else
         dict.Add(word.Text, word)
      End If
   Next
   'remove duplicates
   For Each key In dict.Keys
      If dict.Item(key) is Nothing Then dict.Remove(key)
   Next
   Return dict
End Function

Function String_StrongNormalize(t As String) As String
   'reduces every character to string to character set. eg "aBc $123.56" ->"a ?000.00"
   Dim ch,out As String
   Dim i As Integer
   For i = 1 To Len(t)
      ch=Mid(t,i,1)
      Select Case AscW(ch)
      Case Is > &h04f9 'beyond Cyrillic
         out = out & "?"
      Case Is > &h0400 'Cyrillic
         out = out & "c"
      Case Is > &h00bf 'Page 2 utf-8
         out = out & "a"
      Case Is > &h007a
         'ignore strange characters
      Case Is > &h0040 'Alphabetic
         out = out & "a"
      Case Is > &h0039  ':;<=>?@
         out = out & " "
      Case Is > &h002f ' numeric
         out = out & "0"
      Case &h0025,&h002c,&h002d,&h002e ' %,-.
         out = out & ch
      Case Is > &h0019 ' keep spaces
         out=out & " "
      Case Else
         'ignore lower ASCII
      End Select
   Next
   While InStr(out,"cc")
      out=Replace(out,"cc","c")
   Wend
   While InStr(out,"aa")
      out=Replace(out,"aa","a")
   Wend
   While InStr(out,"c c ")
      out=Replace(out,"c c ","c ")
   Wend
   While InStr(out,"a a ")
      out=Replace(out,"a a ","a ")
   Wend
   While InStr(out,"  ")
      out=Replace(out,"  "," ")
   Wend
   Return out
End Function

Public Function String_StrongNormalizeDigits(a As String) As String
   'replaces every digit with "d"
   a=UCase(a)
   Dim c As String
   For Each c In Split("0 1 2 3 4 5 6 7 8 9")
      a=Replace(a,c,"d")
   Next
   Return a
End Function
Public Function String_StrongNormalizeAlphabetic(a As String) As String
   'replaces every alphabetic character with "a"
   Dim c As String
   Dim i As Integer
   For i=1 To Len(a)
      c=Mid(a,i,1)
      If String_IsUpperCaseOrUnicode(c) Then a=Replace(a,c,"a")
   Next
   Return a
End Function

Public Function String_IsUpperCaseOrUnicode(c As String) As Boolean
   Dim x As Integer
   x=AscW(c)
   Return (x>&h40 And x<&h5b) Or (x>&hc0)
End Function

public Function Alternatives_LineUp(a as CSCXDocAlternatives, b as CSCXDOCAlternatives)
   'a is a list of alternatives  each alternative is a character on the textline, with left & width interpolated from the word
   'TStringTag is set to the strongly normalised value. Eg if .Text=C then .StringTag=a for alphabetic.)
   While i<a.Count And j<b.Count
      If a(i).Left+a(i).Width<b(j).Left Then 'the top word is left of the bottom word
         i=i+1
      ElseIf a(i).Left> b(j).Left + b(j).Width Then 'the top word is right of the bottom word
         j=j+1
      Else 'top word is above the bottom word
         aligned=aligned+1
         If a(i).StringTag=b(j).StringTag Then Match=Match+1
         i=i+1
         j=j+1
      End If
   Wend
   Return aligned*Match/CDbl(IIf(a.Count>b.Count,a.Count,b.Count)^2)
End Function
