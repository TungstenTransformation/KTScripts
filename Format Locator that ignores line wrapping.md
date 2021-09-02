# How to Run a Format Locator across all the text of a document.
A Format Locator can use Dictionaries to search for phrases. Sometimes these phrases wrap around to different lines.  
For example, you are looking for **Medicare Claims** on this document.  
![image](https://user-images.githubusercontent.com/47416964/131869295-363d438e-d55e-45a0-9de8-15a838548a2c.png)

The normal format locator will find **Medicare** as one result with 57% and **Claims** will be a second result with 43%.    
![image](https://user-images.githubusercontent.com/47416964/131869506-e3b641f4-5920-45e0-bb81-777a9c0dea94.png)

The script below returns the following results. **Medicare Claims** with 100%. The Green Box looks wrong, but that is the box that surrounds the word **Medicare** and **Claims**.  
![image](https://user-images.githubusercontent.com/47416964/131869748-7ea8063c-ef80-497b-83f2-16b7bb7dea74.png)


## Steps
1. Add a second class to your project called **Phrases**. This is a class that is not used by any other documents
1. Add a locator to this class **FL_Phrase** and configure it however you like with expressions or dictionaries.
1. Add a script locator **SL_Phrases** to your class with the script from below.
1. Select a confidence threshold for your results.
2. Run your locator



```vb
Option Explicit

' Class script: Document

Private Sub SL_Phrases_LocateAlternatives(ByVal pXDoc As CASCADELib.CscXDocument, ByVal pLocator As CASCADELib.CscXDocField)
   Locator_ExtractFromAllText(pXDoc,"WholeText","FL_Phrase",0.75,pLocator.Alternatives)
End Sub


Sub Locator_ExtractFromAllText(pXDoc As CscXDocument, ClassName As String, LocatorName As String, Threshold As Double, Results As CscXDocFieldAlternatives)
   'Run a locator over all the text of a document, ignoring line-wrapping
   Dim Temp As New CscXDocument, W As Long, Word As CscXDocWord, LeftPos As Long, A As Long, Alts As CscXDocFieldAlternatives, Result As CscXDocFieldAlternative
   Temp.CopyPages(pXDoc,0,1) ' copy the first page to a temp document
   'remove all words from the temp document
   While Temp.Words.Count>0
      Temp.Words.Remove(0)
   Wend
   LeftPos=0
   'Copy ALL the words from ALL the pages of the document onto a SINGLE TEXT LINE on the temp document
   For W=0 To pXDoc.Words.Count-1' pXDoc.Words.Count-1
      Set Word=New CscXDocWord
      Word.PageIndex=0
      Word.Top=0
      Word.Height=15
      Word.Left=LeftPos
      Word.Width=1
      Word.Text=pXDoc.Words(W).Text
      'Temp.Pages(0).AddWord(Word)
      Temp.Pages(0).AddWord(Word)
      LeftPos=LeftPos+(Len(Word.Text)+1)*15
   Next
   'recalculate the textlines that locators look at. There will be only one text line
   Temp.Representations(0).AnalyzeLines

   With Project.ClassByName(ClassName)
      .Locate(Temp,.Locators.ItemByName(LocatorName).Index)
   End With
   Set Alts=Temp.Locators.ItemByName(LocatorName).Alternatives
   For A=0 To Alts.Count-1
      If Alts(A).Confidence > Threshold Then
      Set Result=Results.Create
      Result.Confidence=Alts(A).Confidence
         For W=0 To Alts(A).Words.Count-1
            Result.Words.Append(pXDoc.Words(Alts(A).Words(W).IndexOnDocument))
         Next
      End If
   Next
   Set Temp = Nothing

End Sub

```
