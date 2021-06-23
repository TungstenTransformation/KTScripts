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
Sub MakeTextFiles()
    Dim Cell As Range, I As Long
    I = 1
    Set Cell = ActiveSheet.Range("A2")
    While Cell.Value <> ""
       Open "C:\temp\moneytransfer\" & Format(I, "0000") & ".txt" For Output As #1
       Print #1, Cell.Value
       Close #1
       I = I + 1
       Set Cell = Cell.Offset(1, 0) ' Get next cell below
    Wend
End Sub
```
6.  Run the script by pressing **Play (F5)**.  
![](https://user-images.githubusercontent.com/47416964/123088227-c5a90900-d425-11eb-84fb-5bd8d88713a1.png)
1. Your training files have now been created.  
![image](https://user-images.githubusercontent.com/47416964/123088977-abbbf600-d426-11eb-99b2-b9d02fb99e2a.png)
## Import the Text Files into Kofax Transformation
1. Create a project in Kofax Transformation Project Builder.
2. Add a class called **moneytransfer** and add the Fields **Person** and **Amount**.
3. Add a Text Content Locator with Subfields **Person** and **Amount**.  
![image](https://user-images.githubusercontent.com/47416964/123089625-7b288c00-d427-11eb-8333-f10cd27d85a7.png)
1. Assign the Locator Subfields to the fields.  
![image](https://user-images.githubusercontent.com/47416964/123089706-94313d00-d427-11eb-9911-1cfe05955aad.png)
1. Import the Text Files by selecting **Text Files** as the Source Files.  
![image](https://user-images.githubusercontent.com/47416964/123089825-bd51cd80-d427-11eb-9965-3d620952f492.png)
1. Select all of your documents and assign them to the class **money transfer**.  *This will be needed for benchmarking later.*
![image](https://user-images.githubusercontent.com/47416964/123090021-f25e2000-d427-11eb-9d04-39ebd5e268ef.png)
1. Select all of your documents and **Extract (F6)** them. *This will assign fields to all of the documents. You will see that they contain empty values with confidence 0%. This is because the Text Content Locator has found nothing.*  
![image](https://user-images.githubusercontent.com/47416964/123090274-3fda8d00-d428-11eb-800f-e419c0ca1045.png)
1. Open the **Choose Details** window and select **Person**and **Amount**. You can now see all the values in the Document list.  
![image](https://user-images.githubusercontent.com/47416964/123090521-86c88280-d428-11eb-9be3-c63205a35b88.png)  
![image](https://user-images.githubusercontent.com/47416964/123090547-9051ea80-d428-11eb-881e-c6adcabf6e1a.png)  
![image](https://user-images.githubusercontent.com/47416964/123090584-9ba51600-d428-11eb-842d-931decf8cfb5.png)  

##Import the Truth into the Documents
*We will now load the Person and Amount values into the XDoc Fields. It is important that we also find the correct word id's in the document so that the Text Content Locator can see the context of the values to be trained*
1. Copy the **Amount** and **Person** columns from Excel into a Text File and save it as "C:\temp\moneytransfers\truth.txt"  
![image](https://user-images.githubusercontent.com/47416964/123091602-da879b80-d429-11eb-8d77-d695e6bb05fe.png)
1. Add the following script to **Document_AfterExtract** in the class **moneytransfer** 
*(The script event **Document_AfterExtract** is often misused to set field values in projects. This should normally be done in a script locator. However in this case we need to use **Document_AfterExtract** for the following reasons)*
* We don't want to break the connection between **Text Content Locator** and the two fields.
* We will be training the **unformatted** amounts and so be avoiding the number formatter that your project should be using.
```vba
Option Explicit

' Class script: moneytransfer

Private Sub Document_AfterExtract(ByVal pXDoc As CASCADELib.CscXDocument)
   Dim Textline As String, Values() As String, I As Long, FileId As Long, Word As CscXDocWord, FieldNames() As String, W As Long
   Dim StartWord As CscXDocWord, LastWord As CscXDocWord, F As Long, Field As CscXDocField
   'Convert the XDocument Filename "moneytransfer\0007.xdc" to 7.
   FileId=CLng(Replace(Mid(pXDoc.FileName,InStrRev(pXDoc.FileName,"\")+1),".xdc",""))
   Open "c:\temp\moneytransfer\truth.txt" For Input As #1
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
      'add the entire phrase to the field. Now the fields know the word id's and the Text Locator can train
      For W= StartWord.IndexOnDocument To LastWord.IndexOnDocument
         Field.Words.Append(pXDoc.Words(W))
      Next
      Field.Confidence=1.00 ' it is the truth! so set the confidence to 100%
      Field.ExtractionConfident=True
   Next
End Sub

Sub Phrase_FindInWords(searchText As String ,Words As CscXDocWords,ByRef StartWord As CscXDocWord, ByRef LastWord As CscXDocWord)
   'Find a phrase in a longer text and return the first and last word of that phrase
   Dim W As Long, Start As String, C As Long
   If InStr(Words.Text,searchText)<1 Then Err.Raise(1234,,"Cannot find '" & searchText & "' in ' " & Words.Text & "'.")
   Start=Left(Words.Text,InStr(Words.Text,searchText)-1)
   For C=1 To Len(Start)
      If Mid(Start,C,1)=" " Then W=W+1
   Next
   Set StartWord=Words(W)
   Set LastWord=Words(W+UBound(Split(searchText," ")))
End Sub
```
1. Select your documents and **Extract (F6)**. You will see the correct values in the Extraction results with confidence=100%, a green check mark and in the document window
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
1. We have perfect results because that **Document_AfterExtract** is still in the script!!  
![image](https://user-images.githubusercontent.com/47416964/123104917-a87d3600-d437-11eb-91c6-4475c766847e.png)
2. 















