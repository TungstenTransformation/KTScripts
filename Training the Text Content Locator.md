# Training the Text Content Locator
*(This guide is compatible with KTM, KTA, RPA, KTT and RTTI.)*

The [**Text Content Locator**](https://docshield.kofax.com/KTT/en_US/6.3.0-v15o2fs281/help/PB/ProjectBuilder/450_Extraction/TextContentLocator/c_TextContentLocator.html) is a [**Natural Language Processing**](https://en.wikipedia.org/wiki/Natural_language_processing) **(NLP)** locator for finding any tokens in a text. The other NLP locator in Kofax Transfromation is the Named Entity Locator, which is not trainable.

*   purely text based and does not use any word coordinates.
*   the only locator that ignores line-wrapping.
*   requires training from many documents. You should have many hundreds if not thousands of documents.  
*   can be trained to find any values in the text. The Text Content Locator internally [tokenizes](https://www.analyticsvidhya.com/blog/2020/05/what-is-tokenization-nlp/) the text and then extracts any values you have trained for. The Named Entity Locator looks for specific Named Entities amongst the tokens.

This guide will assume that you have an Excel file with the following format, where the exact text is in one cell and the exact values (**Amount** and **Person**) perfectly match the text. _It is VERY important that the spelling of the field values **perfectly** matches the spelling in the text, because the Text Content Locator needs to learn the context of each value. For example "600$" is directly before the word "Stone" and two words before "Rob"._

<table><tbody><tr><td>Text</td><td>Amount</td><td>Person</td></tr><tr><td>Please pay Rob Stone 600$</td><td>600$</td><td>Rob Stone</td></tr><tr><td>I want to transfer five hundred dollars to Ben Senf</td><td>five hundred dollars</td><td>Ben Senf</td></tr><tr><td>Please pay the amount of 400.30 USD to the account of Erich Kelp</td><td>400.30 USD</td><td>Erick Kelp</td></tr></tbody></table>

## Convert the Data to Text Files.

1.  Create a folder on your harddrive to put the training files.  
![](https://user-images.githubusercontent.com/47416964/123088026-88447b80-d425-11eb-8edb-73882ef6b13c.png)
1.  Enter the data into Microsoft Excel.  
![](https://user-images.githubusercontent.com/47416964/123087797-3bf93b80-d425-11eb-8108-1ca80d19d26a.png)
1.  In Microsoft Excel press **ALT-F11** to open the visual basic editor.  
![](https://user-images.githubusercontent.com/47416964/123086368-a4dfb400-d423-11eb-96f9-0cc7f5a6e867.png)
1.  Open **View/Code (F7)** to see the code window.  
![](https://user-images.githubusercontent.com/47416964/123086578-df495100-d423-11eb-9d58-a4728cd78361.png)
1.  Paste the following code. Check the starting cell "A2" and the output path "C:\\temp\\moneytransfer"  
```vba
Option Explicit
' Class script: moneytransfer

Private Sub Document_AfterExtract(ByVal pXDoc As CASCADELib.CscXDocument)
   Dim Textline As String, Values() As String, I As Long, FileId As Long, Word As CscXDocWord, FieldNames() As String, W As Long
   Dim StartWord As CscXDocWord, LastWord As CscXDocWord, F As Long, Field As CscXDocField, Path As String, ImageName As String
   Path="c:\temp\moneytransfer\"
   'Add an image to the file if it is still a text file. To Train the TCL an xdoc must be image-based and not text-based
   If pXDoc.CDoc.SourceFiles(0).FileType="TEXT" Then
      ImageName=Replace(pXDoc.FileName, ".xdc",".png")
      FileCopy Path & "1x1.png", ImageName
      pXDoc.ReplacePageSourceFile(ImageName,"TIFF",0,0)
   End If

   'Convert the XDocument Filename "moneytransfer\0007.xdc" to 7.
   FileId=CLng(Replace(Mid(pXDoc.FileName,InStrRev(pXDoc.FileName,"\")+1),".xdc",""))
   Open Path & "truth.txt" For Input As #1
   Line Input #1, Textline
   'the first line of the truth file has the field names
   FieldNames=Split(Textline,vbTab)
   'Search through truth file for the correct row
   While Not EOF(1) And I<FileId
      Line Input #1, Textline
      I=I+1
   Wend
   Close #1
   Values=Split(Textline,vbTab)
   'Loop through each field in the truth file
   For F=0 To UBound(Values)
      Set Field=pXDoc.Fields.ItemByName(FieldNames(F))
      'find the start and last word in the text matching the value
      Phrase_FindInWords(Values(F),pXDoc.Words, StartWord, LastWord)
      If Not StartWord Is Nothing Then
         'add the entire phrase to the field. Now the fields know the word id's and the Text Locator can train
         For W= StartWord.IndexOnDocument To LastWord.IndexOnDocument
            Field.Words.Append(pXDoc.Words(W))
         Next
         Field.Confidence=1.00 ' it is the truth! so set the confidence to 100%
         Field.ExtractionConfident=True
      End If
   Next
End Sub

Sub Phrase_FindInWords(searchText As String ,Words As CscXDocWords,ByRef StartWord As CscXDocWord, ByRef LastWord As CscXDocWord)
   'Find a phrase in a longer text and return the first and last word of that phrase
   Dim W As Long, Start As String, C As Long, Pos As Long
   Set StartWord=Nothing
   Set LastWord=Nothing
   If searchText="" Then Exit Sub
   Pos=InStr(LCase(Words.Text),LCase(searchText))
   Select Case Pos
   Case Is <1
      Exit Sub 'Nothing to search for. Err.Raise(1234,,"Cannot find '" & searchText & "' in ' " & Words.Text & "'.")
   Case 1
      Start="" 'first word of text is a match
   Case Else ' match found in middle of text
      Start=Left(Words.Text,Pos-1)
   End Select

   For C=1 To Len(Start)
      If Mid(Start,C,1)=" " Then W=W+1
   Next
   Set StartWord=Words(W)
   Set LastWord=Words(W+UBound(Split(searchText," ")))
End Sub
```
1. Press the **Reload Document Set** icon so that Project Builder sees that these are image files and not text files. The document icon is no longer a letter "A".
![image](https://user-images.githubusercontent.com/47416964/123135180-cb1c4880-d451-11eb-9450-c4db2514a56a.png)
3. Select your documents and **Extract (F6)**. You will see the correct values in the Extraction results with confidence=100%, a green check mark and in the document window
![image](https://user-images.githubusercontent.com/47416964/123102044-f04e8e00-d434-11eb-8970-23d1d969837f.png)  
1. If there is an error in your data, the script will crash with an error message. Correct your text file and try again.  
*In this example I had "Erich" in the text, but was looking for "Erick".*  
![image](https://user-images.githubusercontent.com/47416964/123102285-30157580-d435-11eb-8cf8-408b07a66371.png)
1. Save all of your documents (and the * will disappear from after the names)  
![image](https://user-images.githubusercontent.com/47416964/123102691-9dc1a180-d435-11eb-8080-95a288be829a.png)
1. If you open the Xdocument with the XDoc Browser you will not see the words in the field, but if you unizp the XDoc using 7zip and open it in an xml viewer you will see the word id's in the Field.  Here you can see that "Rob Stone" is words 2 & 3. These are the values that the training will be using.
![image](https://user-images.githubusercontent.com/47416964/123103908-bbdbd180-d436-11eb-9e33-a9835d0a3712.png)

##Training and Benchmarking##
You are now ready to run the first benchmark and see the zero results. After training this should be much better!
1. Right-click on **Test Set** and convert your test set to a **Benchmark Set**.  
![image](https://user-images.githubusercontent.com/47416964/123104479-445a7200-d437-11eb-994a-85ce3b66ceef.png)  
1. Open the **Extraction Benchmark** from the View Menu and press **Start**
![image](https://user-images.githubusercontent.com/47416964/123104565-5b00c900-d437-11eb-96ec-6c836007f92d.png)
1. You have perfect results because that **Document_AfterExtract** is still in the script!!  
![image](https://user-images.githubusercontent.com/47416964/123104917-a87d3600-d437-11eb-91c6-4475c766847e.png)
2. Remove the **Document_AfterExtract** from the script and re-run the Extraction Benchmark.  Here you will see that there are no results, and that the project has 100% [false negatives](https://en.wikipedia.org/wiki/False_positives_and_false_negatives) (yellow).  
![image](https://user-images.githubusercontent.com/47416964/123105088-cba7e580-d437-11eb-805f-85b4f39e15f8.png)
3. Drag all of your documents to the **Extract Set** to train them.  
![image](https://user-images.githubusercontent.com/47416964/123105407-14f83500-d438-11eb-8fc8-1b7b07caec17.png)
3. 















