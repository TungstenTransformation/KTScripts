# Converting an XDocument to a text file
This script generates a text file containing the OCR text of a document.
This is useful for text analysis or for training a classification model where you only need the text and don't want the original image files in the training model.  
1. Open your Classification or Shared Project in Transformation Designer.
1. Add the following script to the project level script.
1. Select as many documents as you like in the document view window.
1. Press F4 to OCR the documents if you have not done that already.
1. Press F5 to classify the documents. This script will run after each document is classified. It doesn't matter if classification is successful or not.
1. Open Windows Explorer and you will see a text file along with your XDoc and source files. You can move these text files to another folder and use them as your training samples.

```vb
Private Sub Document_AfterClassifyXDoc(ByVal pXDoc As CASCADELib.CscXDocument)
   'Write the OCR text of an xdoc to a text file
   If pXDoc.Words.Count=0 Then Exit Sub 'This document contains no OCR text
   Dim TextFileName As String, T As Long
   TextFileName=Replace(pXDoc.FileName,".xdc",".txt")
   Open TextFileName For Output As #1
   Print #1, vbUTF8BOM  'write a Unicode UTF-8 file
   For T=0 To pXDoc.TextLines.Count-1
      Print #1, pXDoc.TextLines(T).Text
   Next
   Close #1
End Sub
```