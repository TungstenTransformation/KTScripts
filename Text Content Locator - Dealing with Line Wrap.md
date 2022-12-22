# Dealing with line wrapped text in the Text Content Locator.
The Text Content locator [tokenizes](https://en.wikipedia.org/wiki/Lexical_analysis) [natural text](https://en.wikipedia.org/wiki/Natural_language_processing) in a document to extract fields.

In the following example, which is a speeding ticket in German, we want the Text Content Locator to retrieve the following fields from this text.  


| Field | Value |
|-------|-------|
| Vehicle | PKW |
| License | 3AK8017 |
| Date | 12.10.2022 |
| Time | 15:18 Uhr |
| Location | A38, AD Drammetal, km 0,492, Rampe zur A7, in Rtg. Kassel |
| Law | § 24 StVG |

Only Vehicle and License are single words. Date, Time, Location and Law are all multiword phrases, called **tokens**.


The following script runs after document validation (not in KTA) and correctly inserts all of the words in a field that are between the first and the last word.
```vb
Option Explicit

' Class script: TrafficFine
Private Sub Document_Validated(ByVal pXDoc As CASCADELib.CscXDocument)
   'This Event is Triggered when the Validation Screen is finished with the document. Does not work in KTA
   Dim F As Long
   For F=0 To pXDoc.Fields.Count-1
      Field_InterpolateWords(pXDoc, pXDoc.Fields(F))
   Next
End Sub

Public Sub Field_InterpolateWords(pXDoc As CscXDocument, Field As CscXDocField)
   'This checks if a Field contains at least two words. If these words are NOT adjacent then the text is cleared, all words are inserted into the Field and the text reconstructed
   'This is necessary for Text Content Locator training to be able to train from documents where fields line wrap.,
   Dim WFirst As Long, WLast As Long, W As Long, Words As CscXDocWords
   Set Words=Field.Words
   If Words.Count<2 Then Exit Sub 'This field contains zero or one word
   WFirst= Words(0).IndexOnDocument 'index of first word in field
   WLast = Words(Words.Count-1).IndexOnDocument 'index of last word in field
   If WLast < WFirst+1 Then Exit Sub ' exit if there are no words BETWEEN the fields.
   'This field contains at least two words
   'remove the text and words it has
   Field.Text=""
   While Words.Count>0
      Words.Remove(0)
   Wend
   'Add all the words, including the words between to the field. .Text will be filled automatically
   For W=WFirst To WLast
      Field.Words.Append(pXDoc.Words(W))
   Next
End Sub


```
