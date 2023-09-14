# How to sort Alternatives

## New Method using .NET SortedList (2023)
This script  
* Create a SortedList using any function of your choice. Here is use the function *Scorer_TextLineAndWordIndex*. 
* After filling the SortedList it contains the indexes of the alternatives in the correct sort order.
* Duplicate all the the Alternatives (using [Field_Copy](Field_Copy.vb)) on the Alternatives Object in the correct order.
* Delete all the original Alternatives.
* Rescore all the Alternatives from 100% down to 90% so that they sort in the 
Locator's Test Window.

Example 
```vb
Alternatives_Sort(pXDoc.Locators.ItemByName(LocatorName).Alternatives,pXDoc,AddressOf Scorer_TextLineAndWordIndex)
```

Make sure that the top of the script contains
```vb
'#Language "WWB-COM"
Option Explicit
Delegate Function AlternativeScorerDelegate(A As CscXDocFieldAlternative, pXDoc As CscXDocument) As Double
```
The Sorting Script can be anywhere in your Class Script. 
Make sure to also add [Field_Copy](Field_Copy.vb).
```vb
'=========================================
' Sorting Alternatives
'=========================================

Public Function Scorer_TextLineAndWordIndex(Alt As CscXDocFieldAlternative, pXDoc As CscXDocument) As Double
   With Alt.Words(0) 'return the position of the word on the document. Word 5 of 10 on textline 7 will get a score of 7+5/10=7.5
      Return .LineIndex+.IndexInTextLine/pXDoc.TextLines(.LineIndex).Words.Count
   End With
End Function

Sub Alternatives_Sort(Alts As CscXDocFieldAlternatives, pXDoc As CscXDocument, Scorer As AlternativeScorerDelegate)
   Dim SortedList As Object, A As Long, AltsCount As Long
   'https://learn.microsoft.com/en-us/dotnet/api/system.collections.sortedlist?view=net-7.0
   Set SortedList=CreateObject("System.Collections.Sortedlist")
   AltsCount=Alts.Count
   For A=0 To AltsCount-1 'Sort all the Alts
      If Alts(A).Words(0).Text="account" Then
         A=A
      End If
      SortedList.Add(Scorer.Invoke(Alts(A),pXDoc),A)
   Next
   For A=0 To AltsCount-1 'Copy all the Alts to the end of the list in sorted order
      Field_Copy (Alts(SortedList.getbyindex(A)), Alts.Create)
   Next
   While Alts.Count>AltsCount
      Alts.Remove(0)
   Wend
   For A=0 To Alts.Count-1 'rescore everything so they sort in Locator's test window
      Alts(A).Confidence=1-A/Alts.Count/100
   Next
End Sub
```

## Old Method using QuickSort in VBA
This [script](QuickSort.vb) sorts alternatives based an any custom criteria using the [QuickSort](https://en.wikipedia.org/wiki/Quicksort) algorithm, which can sort thousands of alternatives per second.
Kofax Transformation automatically sorts alternatives based on their confidence. You can take advantage of this in script locators and in the the event **Document_AfterLocate** :
any alternatives created will be automatically re-sorted by their confidence before the next locator starts.   
If you need to sort by another criteria, then use the following script.  
After that, if you change all of the confidences to match the new order then your order will be kept.  
A sort algorithm uses **comparers** to perform the sort. The script provides the following comparers (you can also make your own custom comparers)
* Comparer_Left2RightTop2Bottom
* Comparer_TopLeftCorner
* Comparer_AboveOrLeft   *useful for sorting paragraphs on a page*
* Comparer_Confidence

**TopLeftCorner** is suitable for sorting columns on a page.  
You will need to copy the script to your project and make sure that the Delegate line is at the top of your script
```vb
Delegate Function ComparerDelegate(a As Variant, b As Variant) As Boolean ' Delegate definition for sorting comparers
```
You can sort your Alternatives by calling
```vb
Alternatives_Sort(pLocator.Alternatives, AddressOf Comparer_TopLeftCorner)
````

You will need to include [Field_Copy](Field_Copy.vb) script that sorting uses.
