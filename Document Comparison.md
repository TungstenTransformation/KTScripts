# Document Comparison

This script compares a document with another document and shows all differences in a table list, where they can be accepted or rejected.  This supports documents of any length and efficiently finds all the differences.  
The results are shown in a table. You can see the deletions are shown with *-DEL-* and insertions with *-INS-*.
The new document is marked as valid and the original is read-only. The user only has to confirm a result by pressing ENTER and rejecting by pressing SPACE and ENTER.  
![image](https://user-images.githubusercontent.com/47416964/90763659-5cc5a180-e2e7-11ea-8451-01e65b69448a.png)  
This simple example is only showing mistmatches. You can adjust to show more word context for each documen, but if you click or tab onto the Document Text, then the document image will scroll to show the document.  
The script is fast and will find the optimal match - if the documents are very similar the match is even faster.  
If you want to see both documents, you will have to merge the images of the original documents together, or launch it with an external program...

# Configuration
* Add the following script to  the document class you want to compare or to any higher class.
* Create a Table Model with 3 columns **Document**, **OK** and **Original**  
![image](https://user-images.githubusercontent.com/47416964/90763048-51be4180-e2e6-11ea-9896-3d1ae87ca7f0.png)
* Add a Table Locator to the class called "TL_Diffs". The name is checked in the Sub *Document_AfterLocate* below, which customizes the table locator.
* You will need a method to find the reference document that you want to compare with. The script below just uses the first Extraction Training Sample from the class. 
#  Design your Validation Form
* Make column 2 very narrow and set as a checkbox.
* Make column 3 read only.
# How it works
The algorithm finds all the unique words in each document, and then finds the largest match of unique words between the two documents. This breaks the document into smaller documents - this is done successively until unique word matches are found. The remaining document fragments are then aligned using backtracking of the [Levenshtein Distance](https://en.wikipedia.org/wiki/Levenshtein_distance).
```vbscript
'#Language "WWB-COM"
Option Explicit

' Class script: diff
'==========================
'Sort Function Delegates https://github.com/KofaxRPA/KTScripts/blob/master/QuickSort.vb
Delegate Function ComparerDelegate(a As Variant, b As Variant) As Boolean ' Delegate definition for sorting comparers. These MUST come first in the script so that the compiler can find them
Public Function Comparer_WidthLarge( a As Variant, b As Variant) As Boolean
   'Used to sort by width of elements, largest first
   Return a.Width > b.Width
End Function
Public Function Comparer_Left( a As Variant, b As Variant) As Boolean
   'Used to sort by left pixel of elements, smallest first
   Return a.Left < b.Left
End Function
'=============================

Private Sub Document_AfterLocate(ByVal pXDoc As CASCADELib.CscXDocument, ByVal LocatorName As String)
   Dim refXDoc As New CscXDocument
   If LocatorName="TL_Diffs" Then   'Custom Table Locator
      Set refXDoc=XDoc_GetReferenceDocument(pXDoc) ' write your logic here to find the reference document
      Document_Compare(pXDoc, refXDoc,LocatorName) 'Put document differences into the tablelocator
   End If
End Sub

Private Sub Document_Compare(ByVal pXDoc As CASCADELib.CscXDocument, refXDoc As CscXDocument, TableLocName As String)
   'Compare this document with it's reference document and put results into a table
   Dim Row As CscXDocTableRow, WordsA As CscXDocWords, WordsB As CscXDocWords, W As Long, Table As CscXDocTable
   If pXDoc.ExtractionClass="" Then Exit Sub
   With pXDoc.Locators.ItemByName(TableLocName).Alternatives(0)
      .Confidence=1
      Set Table=.Table
   End With
   Table.Rows.Clear 'ignore what Table Locator may have found!
   Set WordsA=TextLines2Words(pXDoc.TextLines) 'pxdoc.words is not in natural order. pxdoc.Textlines.words is in correct order
   Set WordsB=TextLines2Words(refXDoc.TextLines)
   Words_Align(WordsA,WordsB)
   For W =0 To WordsA.Count-1
      If WordsA(W).Text<>WordsB(W).Text Then 'equal
         Set Row = Table.Rows.Append()
         Row.Cells(0).AddWordData(WordsA(W))
         Row.Cells(2).Text=WordsB(W).Text
      End If
   Next
End Sub

Private Function XDoc_GetReferenceDocument(pXDoc As CscXDocument) As CscXDocument
   'Find the first training sample for the exctraction class
   Dim refXDoc As New CscXDocument, refXDocDir As String, refXDocFileName As String
   refXDocDir=Left(Project.FileName,InStrRev(Project.FileName,"\")) & "ExtractionTraining\" & pXDoc.ExtractionClass
   ChDir refXDocDir
   refXDocFileName=Dir("*.xdc")
   If refXDocFileName="" Then Err.Raise(457,,"Cannot find original document for class " & pXDoc.ExtractionClass)
   refXDoc.Load(refXDocFileName)
   Return refXDoc
End Function

Public Sub Words_Align(ByRef WordsA As CscXDocWords,ByRef WordsB As CscXDocWords)
   Dim Matches As CscXDocFieldAlternatives, score As Double
   Set Matches=Matches_Find(WordsA, WordsB,score)
   If score<0.2 Then Exit Sub ' these texts are not matching in any way - don't even try
   Alternatives_Sort(Matches,AddressOf Comparer_WidthLarge) 'sort matching texts by size
   Matches_DeleteConflicts(Matches) 'delete outlier runs
   Alternatives_Sort(Matches,AddressOf Comparer_Left) ' re-sort matching texts or order
   Levenshtein_Calculate(Matches, WordsA, WordsB) ' aligns all words using the perfect matches
End Sub

'===FAST LEVENSHTEIN============================
'Fast Levenshtein matching of large documents

Public Sub Levenshtein_Calculate(Matches As CscXDocFieldAlternatives, ByRef WordsA As CscXDocWords, ByRef WordsB As CscXDocWords)
   Dim Match As CscXDocFieldAlternative, M As Long, Inserts As Long, Deletes As Long
   Dim AStart As Long, AEnd As Long, BStart As Long, BEnd As Long
   If Matches.Count=0 Then Exit Sub
   For M=0 To Matches.Count-1
      Set Match=Matches(M)
      AEnd= Match.Left + Inserts
      BEnd= Match.Top  + Deletes
      Levenshtein_Forward(WordsA,WordsB,AStart,AEnd,BStart,BEnd,Inserts,Deletes)
      AStart=Match.Left + Match.Width-1  + Inserts
      BStart=Match.Top  + Match.Height-1 + Deletes
   Next
   AEnd= WordsA.Count-1
   BEnd= WordsB.Count-1
   Levenshtein_Forward(WordsA,WordsB,AStart,AEnd,BStart,BEnd,Inserts,Deletes)
End Sub

Public Sub Levenshtein_Forward(ByRef WordsA As CscXDocWords, ByRef WordsB As CscXDocWords, AStart As Long, AEnd As Long, BStart As Long, BEnd As Long, ByRef Inserts As Long, ByRef Deletes As Long)
   Dim Matrix() As Long, A As Long, B As Long, WordA As CscXDocWord, WordB As CscXDocWord, del As Double, Ins As Double, subs As Double
   ReDim Matrix(AEnd-AStart+1,BEnd-BStart+1)
   For A=1 To UBound(Matrix,1)
      Matrix(A,0)=Len(WordsA(AStart+A-1).Text)+Matrix(A-1,0)
   Next
   For B=1 To UBound(Matrix,2)
      Matrix(0,B)=Len(WordsB(BStart+B-1).Text)+Matrix(0,B-1)
   Next
   For A  = AStart To AEnd
      Set WordA=WordsA(A)
      For B = BStart To BEnd
         Set WordB=WordsB(B)
         del = Matrix( A  -AStart,B +1-BStart)+Len(WordA.Text)' + delcost   '*B/wordsB.Count) ' cost of deletion
         Ins = Matrix( A+1-AStart,B   -BStart)+Len(WordB.Text)' cost of insertion
         subs= Matrix( A  -AStart,B   -BStart)+String_LevenshteinDistanceBasic(WordA.Text,WordB.Text)'1-String_FuzzyMatch(WordA.Text,WordB.Text) 'Perform Levenshtein on the words themselves at the character level
         Matrix(A+1-AStart,B+1-BStart)=Min(Ins,Min(del,subs))
      Next
   Next
   Levenshtein_Traceback(WordsA,WordsB,AStart,BStart, Matrix, Inserts, Deletes)
End Sub

Sub Matrix_Log(Matrix() As Long, ByRef WordsA As CscXDocWords, ByRef WordsB As CscXDocWords,AStart  As Long, BStart As Long)
   Dim A As Long, B As Long, AEnd As Long, BEnd As Long
   Exit Sub
   AEnd=AStart+UBound(Matrix,1)-1
   BEnd=BStart+UBound(Matrix,2)-1
    Open "c:\temp\out.txt" For Output As 1
   Print #1, "A\B" & vbTab &"-" & vbTab;
   For B= BStart To BEnd+1
      Print #1, WordsB(B).Text & vbTab;
   Next
   Print #1
   Print #1,"-" & vbTab;
   For A = AStart To AEnd+1
      For B = BStart To BEnd+1
         Print #1, Format(Matrix(A-AStart,B-BStart),"0.00")&vbTab;
      Next
      Print #1
      If A<AEnd+1 Then Print #1, WordsA(A).Text & vbTab;
   Next
   Print #1
   Print #1, Words_Text(WordsA, vbTab)
   Print #1, Words_Text(WordsB, vbTab)
   Close #1
   Shell("Notepad.exe c:\temp\out.txt",vbNormalFocus)
End Sub

Public Sub Levenshtein_Traceback(ByRef WordsA As CscXDocWords, ByRef WordsB As CscXDocWords, AStart As Long, BStart As Long, Matrix() As Long, ByRef Inserts As Long, ByRef Deletes As Long)
   Dim del As Double, Ins As Double, subs As Double, Word As CscXDocWord, WordA As CscXDocWord, WordB As CscXDocWord
   Dim A As Long, B As Long
   A=AStart+UBound(Matrix,1)-1
   B=BStart+UBound(Matrix,2)-1
   While A>AStart And B>BStart
      del = Matrix( A - 1-AStart, B    -BStart) ' cost of deletion
      Ins = Matrix( A    -AStart, B - 1-BStart) ' cost of insertion
      subs =Matrix( A - 1-AStart, B - 1-BStart)  'cost of substition or match
      Select Case Min(Min(subs,Ins),del)
         Case subs
            A=A-1:B=B-1
         Case Ins
            Set Word= New CscXDocWord
            Word.Text="-INS-"
            Words_Insert(WordsA,Word,A)
            B=B-1
            Inserts=Inserts+1
         Case del
            Set Word= New CscXDocWord
            Word.Text="-DEL-"
            Words_Insert(WordsB,Word,B)
            A=A-1
            Deletes=Deletes+1
      End Select
   Wend
   While B=BStart And A>AStart ' the rest are deletes at the beginning
      Set Word= New CscXDocWord
      Word.Text="-DEL-"
      Words_Insert(WordsB,Word,B+1)
      A=A-1
      Deletes=Deletes+1
   Wend
   While A=AStart And B>BStart' the rest are inserts at the beginning
      Set Word= New CscXDocWord
      Word.Text="-INS-"
      Words_Insert(WordsA,Word,A+1)
      B=B-1
      Inserts=Inserts+1
   Wend
   Matrix_Log(Matrix,WordsA,WordsB,AStart,BStart)
End Sub

'====Match Functions to speed up Levenshtein=================================
'finds large runs of text that have not changed at all, so Levenshtein can be skipped

Public Sub Matches_DeleteConflicts(Matches As CscXDocFieldAlternatives)
   Dim M As Long, N As Long, Match As CscXDocFieldAlternative, NextMatch As CscXDocFieldAlternative
   While M<Matches.Count-1
      Set Match=Matches(M)
      N=M+1
      While N<Matches.Count
         Set NextMatch=Matches(N)
         If (NextMatch.Top<Match.Top And NextMatch.Left+NextMatch.Width>Match.Left) Or _
            (NextMatch.Top+NextMatch.Height>Match.Top+Match.Height And NextMatch.Left<Match.Left) _
            Then
            Matches.Remove(N)
         Else
            N=N+1
         End If
      Wend
      M=M+1
   Wend
End Sub

Public Function Matches_Find(ByRef WordsA As CscXDocWords,ByRef WordsB As CscXDocWords, ByRef Score As Double) As CscXDocFieldAlternatives
   Dim uniqueA As Dictionary, UniqueB As Dictionary
   Dim Matches As CscXDocFieldAlternatives, Match As CscXDocFieldAlternative, Word As CscXDocWord, WordText As String, Words() As Variant, W As Long
   Set uniqueA=Words_FindUniqueWords(WordsA)
   Set UniqueB=Words_FindUniqueWords(WordsB)
   Dictionaries_MakeDoublyUnique(uniqueA, UniqueB) 'remove all unique words that are not in BOTH dictionaries
   With New CscXDocField
      Set Matches=.Alternatives
   End With
   Dim d As Dictionary
   Score=0
   Words=uniqueA.Keys
   For Each WordText In Words
      If Not IsEmpty(uniqueA(WordText)) Then ' There is a bug in MSCripts.Dictionary where removing a key randomly doesn't remove it, but rather leaves it empty
         Set Word=uniqueA(WordText)
         Set Match=Matches.Create
         Match.Words.Append(Word)
         Match.Left=CLng(Word.StringTag)
         Match.Top=CLng(UniqueB(Word.Text).StringTag)
         Match.Width=1
         Match.Height=1
         Score=Score+1
         While Match.Left>0 And Match.Top>0 AndAlso WordsA(Match.Left-1).Text=WordsB(Match.Top-1).Text ' add matching words to the left
            Match.Left=Match.Left-1
            Match.Top=Match.Top-1
            Match.Width=Match.Width+1
            Match.Height=Match.Height+1
            Score=Score+1
            Set Word=WordsA(Match.Left)
            If uniqueA.Exists(Word.Text) Then 'these unique words are in the same run, so merge them
               uniqueA.Remove(Word.Text)
               UniqueB.Remove(Word.Text)
            End If
         Wend
         While Match.Left+Match.Width<WordsA.Count AndAlso Match.Top+Match.Width<WordsB.Count AndAlso WordsA(Match.Left+Match.Width).Text=WordsB(Match.Top+Match.Width).Text 'add matching words to the right
            Set Word=WordsA(Match.Left+Match.Width)
            If uniqueA.Exists(Word.Text) Then 'these unique words are in the same run, so merge them
               uniqueA.Remove(Word.Text)

               UniqueB.Remove(Word.Text)
            End If
            Match.Width=Match.Width+1
            Match.Height=Match.Height+1
            Score=Score+1
      Wend
      End If
   Next
   Score=Score/Max(WordsA.Count,WordsB.Count)
   Return Matches
End Function

Sub Dictionaries_MakeDoublyUnique(DictA As Dictionary, DictB As Dictionary)
   Dim Word As String
   For Each Word In DictA.Keys
      If Not DictB.Exists(Word) Then DictA.Remove(Word)
   Next
   For Each Word In DictB.Keys
      If Not DictA.Exists(Word) Then DictB.Remove(Word)
   Next
End Sub

Function Words_Text(Words As CscXDocWords, Delim As String) As String
   Dim result As String, W As Long
   For W=0 To Words.Count-1
      result=result & Words(W).Text & Delim
   Next
   Return result
End Function

Public Sub Words_Insert(Words As CscXDocWords, Word As CscXDocWord, Pos As Long)
   'Workaround to Words.Insert, which doesn't work in KTM 5.5.2.10
   Dim Temp As New CscXDocWords,W As Long
   For W = Pos To Words.Count-1

      Temp.Append(Words(W))
   Next
   While Words.Count>Pos
      Words.Remove(Pos)
   Wend
   Words.Append(Word)
   For W = 0 To Temp.Count-1
      Words.Append(Temp(W))
   Next
   Set Temp=Nothing
End Sub

Public Function Words_FindUniqueWords(Words As CscXDocWords) As Dictionary
   'This makes a dictionary of all words and keeps only unique words

   Dim Dict As New Dictionary, Key As String
   Dim W As Long, Word As CscXDocWord
   For W =0 To Words.Count-1
      Set Word=Words(W)
      Word.StringTag=CStr(W) 'each word remembers it's position in the phrase
      If Dict.Exists(Word.Text) Then

         Set Dict.Item(Word.Text)=Nothing ' this word is not unique
      Else
         Dict.Add(Word.Text, Word)
      End If
   Next
   'remove duplicates
   For Each Key In Dict.Keys
      If Dict.Item(Key) Is Nothing Then Dict.Remove(Key)
   Next
   Return Dict
End Function

Public Function Max(A,B)  'typeless function, works with any object type that supports >. returns the same object type
   Return IIf(A>B,A,B)
End Function

Public Function Min(A,B)
   Return IIf(A<B,A,B)
End Function


Public Function String_LevenshteinDistanceBasic(A As String ,B As String) As Integer
   'http://en.wikipedia.org/wiki/Levenshtein_distance
   'Levenshtein distance between two strings, used for fuzzy matching
   'Returns the number of character differences between the two strings.
   'eg LevenshteinDistance("kitten","kitchen") = 2 = insertion of "c" + substitution of "t" for "h"

   Dim i As Long, j As Long, cost As Long, d() As Long
   Dim Ins As Long, del As Long, subs As Long  ' for counting insertions, deletions and substitutions
   If Len(A) = 0 Then Return Len(B)
   If Len(B) = 0 Then Return Len(A)
   ReDim d(Len(A), Len(B))
   For i = 0 To Len(A)
      d(i, 0) = i
   Next
   For j = 0 To Len(B)
      d(0, j) = j
   Next
   For i = 1 To Len(A)
     For j = 1 To Len(B)
         cost = IIf (Mid(A, i, 1) = Mid(B, j, 1),0,1)   ' cost of substitution
         del = ( d( i - 1, j ) + 1 ) ' cost of deletion
         Ins = ( d( i, j - 1 ) + 1 ) ' cost of insertion
         subs = ( d( i - 1, j - 1 ) + cost ) 'cost of substitution or match
         d(i,j)= Min(Ins, Min(del,subs))
      Next
   Next
   Return d(Len(A), Len(B))
End Function

Public Function String_FuzzyMatch(ByVal A As String, ByVal B As String, Optional removeSpaces As Boolean = False) As Double
   'returns 0.0 for no match, 1.0 for perfect match, in between for fuzzy match.
   If removeSpaces Then
      A=Replace(A," ","")
      B=Replace(B," ","")
   End If
   If InStr(a,",")>1 Then a=Replace(a,",","")
   If InStr(a,".")>1 Then B=Replace(B,",","")
   If Len(a)= 0 Or Len(B)=0 Then Return 0
   Return CDbl(1.0 - String_LevenshteinDistanceBasic(a, B)/ Max(Len(a),Len(B)))
End Function

Private Function TextLines2Words(TextLines As CscXDocTextLines) As CscXDocWords
   Dim Words As New CscXDocWords, TL As Long, W As Long
   For TL=0 To TextLines.Count-1
      For W=0 To TextLines(TL).Words.Count-1
         Words.Append(TextLines(TL).Words(W))
      Next
   Next
   Return Words
End Function

Function Words_Slice(Words As CscXDocWords,ByRef a As Long, ByRef B As Long)
   'return a slice of a word list
   Dim W As Long, Slice As New CscXDocWords
   For W=a To B-1
      Slice.Append(Words(W))
   Next
   Return Slice
End Function

Sub Words_Trim(Words As CscXDocWords,ByRef a As Long, ByRef B As Long)
   'remove a group of words from a word list
   Dim W As Long
   For W= B-1 To a Step -1
      Words.Remove(W)
   Next
End Sub

Sub Words_InsertWords(Words As CscXDocWords, Ins As CscXDocWords, a As Long)
   Dim W As Long
   For W=0 To Ins.Count-1
      Words_Insert(Words,Ins(W),a+W)
   Next
End Sub

'==========================
'Sort Function Delegates https://github.com/KofaxRPA/KTScripts/blob/master/QuickSort.vb

Sub Alt_Copy(a As CscXDocFieldAlternative, B As CscXDocFieldAlternative)
   Dim W As Long
   For W=0 To a.Words.Count-1
      B.Words.Append(a.Words(W))
   Next
   B.Left=a.Left
   B.Width=a.Width
   B.PageIndex=a.PageIndex
   B.Top=a.Top
   B.Height=a.Height
   B.StringTag=a.StringTag
   B.Confidence=a.Confidence
   B.Text=a.Text
End Sub

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
      Alt_Copy(alts(a),alternatives.Create)
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

```
