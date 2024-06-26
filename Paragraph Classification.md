# Paragraph Classification

This version uses the new Paragraph features in Kofax Transformation Modules 10.4 from November 2020.  
If you are using KTM 10.3, RPA 11.2 or KTA ?? or earlier look at this [older version](Paragraph%20Classification%20.old).

Sometimes it is useful to classify individual paragraphs in a document

*   You are looking for paragraphs in a document with a particular vocab or sentiment.
*   You want to calculate the sentiment of each paragraph separately
*   You want to classify a document based on a particular paragraph, ignoring all others.  
    The default text classifier returns the classification result of the entire page or document. This _can_ dilute results that come from paragraphs.

## How to Detect Paragraphs

In **Project Settings/Recognition** you can enable Paragraph Detection.

![](https://user-images.githubusercontent.com/47416964/122932995-82d82a00-d36e-11eb-8203-716a83afc04d.png)

And choose any settings that you like. ([Documentation)](https://docshield.kofax.com/KTA/en_US/7.8.0-dpm5ap0jk8/help/TD/ProjectBuilder/100_UserInterface/GeneralWindows/r_ParagraphDetectionSettingsWindow.html)

![](https://user-images.githubusercontent.com/47416964/122933095-9d120800-d36e-11eb-8dfa-68cae1d6f6d8.png)

When you perform page-level OCR, the paragraphs are detected and added to the XDocument. 

![](https://user-images.githubusercontent.com/47416964/122933611-16a9f600-d36f-11eb-9afd-d3eaf3c33ab5.png)

At the bottom of this document is a script to copy paragraphs into a Table Locator.

![image](https://user-images.githubusercontent.com/47416964/91288142-ec100080-e790-11ea-9565-1e6bc443513a.png)

## How to classify any text

There is a script function below **(String\_Classify)** that takes any text as input and returns a Classification Result object (CscResult), which contains the information you see below.  

![image](https://user-images.githubusercontent.com/47416964/91288210-02b65780-e791-11ea-88d5-23055adb0913.png)

## How to classify paragraphs

The String classification code was run inside the table locator and the best classification result was put into column 2 and the classification scores where put into column 3. This can help you and your customer understand how well classification is working and know what to train or not.  

![image](https://user-images.githubusercontent.com/47416964/91288282-1b267200-e791-11ea-8340-e2c0874b94b3.png)

## How to train paragraph classification using the Validation Interface

_If you already have text-based paragraphs ready for training you can skip this section._

Now we need to put things together. This is where you work together with a document expert **from the business unit** to carefully train their documents.

1.  Open a representative document set in Project Builder.

_Read page 16 of_ [_Best Practices in Kofax Transformation_](https://github.com/KofaxRPA/Kofax-Transformation-Best-Practices/releases) _for what “representative” means_

1.  Select the Class with your paragraph table locator in the project tree. Select the documents and **Extract**. You should now have all the paragraphs in the table locators – they won’t be classified yet.
2.  Open Validation Screen (F8) (Sorry KTA users, you’ll have to do this the long way by creating jobs…)
3.  I manually classified Paragraph 2 as “p” and Paragraph 2 as “”, because I want this trained as a Null paragraph.

_You need negative examples and lots of them. Without any null examples everything will be put into another class. You don't want to rely just on them getting low scores. If you are training an AI to recognize dogs in photos, then you should also give it lots of examples of cats and other things that are not dogs. Negative training is important._

1.  Simply delete paragraphs you don’t like and start classifying the rest. In the image below I manually classified paragraph 1 as 'p' and paragraph 2 as '' and selected paragraphs 3-7 in orange and will delete them.

![image](https://user-images.githubusercontent.com/47416964/91289232-5d9c7e80-e792-11ea-8190-a1f32576f618.png)

1.  Make the class names single characters so it’s fast to type. Press ENTER to confirm the class name.
2.  Create a Validation Rule to enforce that the class names can only be “p”, “h”, “v” or “”. _(KTA users have to do this the KTA way…)_

![image](https://user-images.githubusercontent.com/47416964/91293593-8f184880-e798-11ea-8f29-d486e4869301.png)

1.  Process 10 or more documents and then close Validation. _(In KTA retrieve your validated XDoc files with the Repository Browser)_
2.  You will see that your files have an asterisk, meaning that they haven’t been saved. Save them by pressing the save icon

![image](https://user-images.githubusercontent.com/47416964/91293824-e4ecf080-e798-11ea-97d1-490e81eac44a.png)

1.  above the documents and the asterisk will disappear.

![image](https://user-images.githubusercontent.com/47416964/91293885-fa621a80-e798-11ea-949b-efe9e0958807.png)

1.  **WARNING. Be careful here to avoid loss of data!!** You just spent a long time creating valuable training files (also called "perfect" files or "golden files"). These are incredibly precious! Do not lose or overwrite them!!
2.  Backup your files by selecting all the files.
3.  Right-click on on the files and select "Open in Windows Explorer"

![image](https://user-images.githubusercontent.com/47416964/91294096-4d3bd200-e799-11ea-80e9-39f75a630978.png)

1.  Add them to a zip file.

![image](https://user-images.githubusercontent.com/47416964/91294315-9db32f80-e799-11ea-9454-6cf5bec04d83.png)

1.  Put the zip file somewhere safe.
2.  Now you need to split all of those paragraphs into individual text files. Switch the document Viewer into Hierarchy Mode.

![image](https://user-images.githubusercontent.com/47416964/91294417-c1767580-e799-11ea-8322-40f36fdab7e3.png)

1.  You can now configure **Runtime Script Events**. Click the tiny triangle next to the yellow lightning icon.

![image](https://user-images.githubusercontent.com/47416964/91294482-e23ecb00-e799-11ea-87f4-7cedf297aa0e.png)

1.  Select **Batch\_Close** and close this window. This feature is for testing batch and application level scripts – we will MISUSE 😊 this feature to write LOTS of text files.

_In production you can put the script into the event Document\_Validated if you want to creatae new training files at runtime, or in Kofax RPA, your robot can write these training files.._  
_KTA users don’t have access to script event **Batch\_Close**. They will have to create another temp class in the project and pack this script into Document\_AfterExtract without the document loop – select all docs, extract all and then delete the script. (Ask if you need help!)_

1.  Run the script **Paragraphs2Text** from below by clicking the lightning icon (CTRL-F11)

![image](https://user-images.githubusercontent.com/47416964/91294779-57aa9b80-e79a-11ea-97d8-02e1a272b8b1.png)

1.  This script will write a text file for each and every paragraph into the folder txt inside your project, with a folder for each Paragraph Class.

![image](https://user-images.githubusercontent.com/47416964/91295018-b07a3400-e79a-11ea-966a-ebcd3f2363ca.png)

![image](https://user-images.githubusercontent.com/47416964/91295041-b96b0580-e79a-11ea-8f05-b9305446aeda.png)

1.  Make sure that you have the exact Paragraph structure inside your Document Project (casing is important)

![image](https://user-images.githubusercontent.com/47416964/91295069-c8ea4e80-e79a-11ea-81e2-e12e33eec0dd.png)

## Importing your sample Paragraphs into the Project

1.  Now open the txt folder as a document set. Make sure all settings are EXACTLY as below. Path **..\\txt\\Paragraph**. Set Source files to **Text files** and **Include Subdirectories** and **Assign subdirectory as class for each document**.
2.  Well done. You now have classification files per paragraph with correct Assigned Class. In the document viewer you can inspect these files and correct classes (this is where you will come at runtime to deal with new training samples.)

![image](https://user-images.githubusercontent.com/47416964/91295347-39916b00-e79b-11ea-8f50-4b5d83bd405c.png)

1.  **WARNING!!** You are now at another VERY BAD danger point. Be very careful here. It’s easy to misclick, and there is no confirmation dialog, when converting to a Benchmark Set and a Classification Training Set. We will do both!
2.  Right-Click on the document set and select **Use as Benchmark Set**

![image](https://user-images.githubusercontent.com/47416964/91297843-487a1c80-e79f-11ea-9b94-f3d5c5cef3e8.png)

1.  Run the Classification Benchmark. This is now your baseline

![image](https://user-images.githubusercontent.com/47416964/91297874-5760cf00-e79f-11ea-94a1-592bc7ef4f3a.png)

![image](https://user-images.githubusercontent.com/47416964/91297886-5e87dd00-e79f-11ea-93e8-60b0be20724e.png)

1.  Convert Your Benchmark Set to a Classification Training Set

![image](https://user-images.githubusercontent.com/47416964/91297922-6cd5f900-e79f-11ea-9d67-9359d18a1f76.png)

1.  Retrain Classification

![image](https://user-images.githubusercontent.com/47416964/91297960-79f2e800-e79f-11ea-9139-85ed93aa539b.png)

1.  Run your benchmark again and keep adding training files.
2.  Remember your goal is human productivity, not accuracy – do not be distracted. Your metric is documents/person/day, which you can massively improve, not classification accuracy, which you cannot perfect.

## Scripts

### Classify Text

```vbnet
Public Function String_Classify(t As String, pXDoc As CscXDocument) As CscResult
Dim Node As New CscDocNode, DocSet As New CscFileDocSet
Dim TextRep As New CscTextRepresentation
TextRep.Text=t
Node.Representations.Append(TextRep)
Set DocSet.RootDoc = Node
Project.ClassifyDocSet(DocSet)
Return Node.GetResult(Project.ClsResultRepTag)
End Function

Function ClassificationResult_ToString(CR As CscResult) As String
Dim Result As String, R As Long
For R=0 To CR.NumberOfConfidences -1
If CR.BestClassId(R)<>0 Then Result=Result & Project.ClassByID(CR.BestClassId(R)).Name & " (" & Format(CR.BestConfidence(R),"0.00%") & "); "
Next
If Result="" Then Return Result
Return Left(Result,Len(Result)-2)
End Function
```

```vbnet
Private Sub Document_AfterLocate(ByVal pXDoc As CASCADELib.CscXDocument, ByVal LocatorName As String)
   'Customize a Table Locator to show all the paragraphs of a document
   Select Case LocatorName
   Case "TL_Paragraphs"
      Table_LoadParagraphs(pXDoc.Locators.ItemByName(LocatorName).Alternatives(0).Table,pXDoc, 0)
   End Select

End Sub

Private Sub Table_LoadParagraphs(Table As CscXDocTable, pXDoc As CscXDocument, ColumnNumber As Long)
   'Copy all paragraphs of a document into a column of a table
   Dim P As Long, Paragraphs As CscXDocParagraphs, Words As CscXDocWords, W As Long, Row As CscXDocTableRow
   Table.Rows.Clear
   Set Paragraphs=pXDoc.Representations(0).Paragraphs
   For P=0 To Paragraphs.Count-1
      Set Words=Paragraphs(P).Words
      'The entire text of the Paragraph is in Words.Text You can use this text to decide which paragraphs to put in the table, eg by classifying them using the function above String_Classify
      Set Row=Table.Rows.Append
      For W=0 To Words.Count-1
         Row.Cells(ColumnNumber).AddWordData(Words(W))
      Next
   Next
End Sub
```

````vbnet
### Paragraphs2Text
```vba
'#Language "WWB-COM"
Option Explicit

' Project Script
Private Sub Batch_Close(ByVal pXRootFolder As CASCADELib.CscXFolder, ByVal CloseMode As CASCADELib.CscBatchCloseMode)
   Dim X As Long
   For X=0 To pXRootFolder.DocInfos.Count-1
      XDoc_Paragraphs2Text(pXRootFolder.DocInfos(X).XDocument)
   Next
End Sub

Public Sub XDoc_Paragraphs2Text(pXDoc As CscXDocument)
   Dim R As Long, cl As String, path As String, I As Long, filename As String, Row As CscXDocTableRow
   path=Left(Project.FileName,InStrRev(Project.FileName,"\"))+"txt\Paragraph\"
   If Not Dir_Exists(path) Then MkDir path
   With pXDoc.Fields.ItemByName("Clauses").Table.Rows
      For R=0 To .Count-1
         Set Row=.ItemByIndex(R)
         If Row.Cells(1).Valid And Len(Row.Cells(0).Text)>0 Then 'Only consider validated paragraphs that contain text
            cl=Row.Cells(1).Text 'The classname is in the second column
            If cl="" Then cl="Null"
            If Not Dir_Exists(path & cl) Then MkDir path & cl
            For I=1 To 100000
               filename=path &  cl & "\" & Format(I,"000000") & ".txt"
               If Not File_Exists(filename) Then 'loop until we find an unused filename.
                  Open filename For Output As #1
                  Print #1, vbUTF8BOM & Row.Cells(0).Text 'Make a UTF-8 file. Even Americans and other ASCII lovers should do this too!
                  Close #1
                  Exit For
               End If
            Next
         End If
      Next
   End With
End Sub
Function File_Exists(file As String) As Boolean
   On Error GoTo ErrorHandler
   Return (GetAttr(file) And vbDirectory) = 0
   Exit Function
ErrorHandler:
End Function

Function Dir_Exists(DirName As String) As Boolean
    On Error GoTo ErrorHandler
    Return GetAttr(DirName) And vbDirectory
ErrorHandler:
End Function
````
