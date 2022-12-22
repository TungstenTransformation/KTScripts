# Dealing with line wrapped text in the Text Content Locator.
The Text Content locator [tokenizes](https://en.wikipedia.org/wiki/Lexical_analysis) [natural text](https://en.wikipedia.org/wiki/Natural_language_processing) in a document to extract fields.

In the following example, which is a speeding ticket in German, we want the Text Content Locator to retrieve the following fields from this text.  
![image](https://user-images.githubusercontent.com/103566874/209109037-433680ff-71e3-4ba3-9a2c-42cf122afec1.png)


| Field | Value |
|-------|-------|
| Vehicle Type | PKW |
| License | 3AK8017 |
| Date | 12.10.2022 |
| Time | 15:18 |
| Location | A38, AD Drammetal, km 0,492, Rampe zur A7, in Rtg. Kassel |
| Law | § 24 StVG |

Only Vehicle and License are single words. Date, Time, Location and Law are all multiword phrases, called **tokens**.  
The Location coontains 12 words that wrap around.  It is very important the Text Content Locator sees all 12 of these words, so that it knows that **in** is the first word before the field and **folgende** is the first word after the first.  
The text is tokenized as   
*dem Führer des {Vehicle Type}, {License} wird vorgeworfen, am {Date}, um {Time} Uhr in {Location} folgende Ordnungswidrigkeit nach {Law} begangen zu
haben*
Note that ALL the information is inside the {tokens} and that all of the words are just the **Text Context** but don't contain any field information. The Text Content locator will now learn that **um** comes 1 token after {Date} and is one token before {Time}. It will also learn that **um** is 4 tokens in front of {Location}. This is why you need t give the TCL many training samples so it can learn all of the possibilities, and also have the power to tokenize sentenece that it has not seen before.  

In Kofax Transformation Validation it can be difficult to put the correct words in the field because of line wrapping. 

It is important the the XDocument contains each of these words.
```xml
<text>A38, AD Drammetal, km 0,492, Rampe zur A7, in Rtg. Kassel</text>
<words>21;22;23;24;25;26;27;28;29;30;31;</words>
```
Do the following in Kofax Transformation
* Drag the mouse from the first word to the end of the line.  
![image](https://user-images.githubusercontent.com/103566874/209107934-77e68865-d7cf-4cdd-8d63-6cad1f7d22c9.png)  
![image](https://user-images.githubusercontent.com/103566874/209107995-c22a0def-17ce-4541-9bbb-c60017f4fa5d.png)  
![image](https://user-images.githubusercontent.com/103566874/209108028-5cbd9823-31ff-4e5d-bff6-d12208a9ad35.png)  
* CTRL-drag the mouse for the first word of the second line to the last word.  
![image](https://user-images.githubusercontent.com/103566874/209108160-4f7ebfca-9488-4703-8cf8-2ff5a851b5af.png)  
* The field contains the correct text, but the image viewer and the red box highlight too much text. Ignore this!  
![image](https://user-images.githubusercontent.com/103566874/209108276-a0d42372-935a-4831-89ca-cce677e9e96d.png)  
![image](https://user-images.githubusercontent.com/103566874/209108706-b0509c5d-bec1-41c5-8fbd-0094b2f596f8.png)
* If you make a mistake, clear the field and try again.  
![image](https://user-images.githubusercontent.com/103566874/209108468-1bd89645-1658-4fc1-be62-b3480d737478.png)


If you have problems with the text, the selected words, you can run the following script after document validation (not in KTA) which  correctly inserts all of the words in a field that are between the first and the last word.
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
