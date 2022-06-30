# Custom Classification
Kofax Transformation classifies each page of a document as part of classification and separation.  
Classification has 4 steps.
1. Layout Classification.
2. Text Classification.
3. Instruction Classification.
4. Custom Classification.
## Layout Classification.  
This is very fast (~100 pages/second) and just uses the pixels of the page. If it is successful then OCR and Text classification are skipped.
## Text Classification.  
This is performed if Layout Classification fails and after OCR is performed. The text of the page is cleaned of punctuation and broken up into letter [N-grams](https://en.wikipedia.org/wiki/N-gram). eg "tax amount" contains the bigrams "ta,ax,xa,am,mo,ou,un,nt", the trigrams "tax,axa,xam,amo,mou,oun,unt", etc. KT uses N-grams up to 25 letters long. All N-grams are stored in a database along with the association to classes. This provides a fast and robust way to clasify pages. It doesn't matter if there are OCR errors, many other N-grams will work.
## Instruction Classification.  
This is a simple and not-recommended way to classify documents. It is a lot of work to configure and can easily produce errors that are almost impossible to resolve. OCR errors will also cause it to fail. It is recommended to use any of the 3 other methods.
## Custom Classification.
 This method uses the Script Event **Document_AfterClassify** to classify a document.  
 Locators that are added to the Project Level of a Class are executed BEFORE classification and can be used to classify documents. 
 ### Barcode Classification
 _This simple example will assume that the barcode contains the exact name of the document class._
 1. Add a Barcode Locator to the Project Level.
 2. Accept the warning because, yes this is exactly what we want!  
 ![image](https://user-images.githubusercontent.com/103566874/176593343-374e048e-b3d9-42fa-8ad5-627086514410.png)  
 2. Configure the Barcode Locator to search for only the kind of locator that classifies for you. _Barcode locators are very slow and it is recommended to restrict them to precisely the type and length of barcodes you are looking for for speed and accuracy._
 2. Add this script to the Project Level Class.
 ```vb
 Private Sub Document_AfterClassifyXDoc(ByVal pXDoc As CASCADELib.CscXDocument)
   Dim Alternative As CscXDocFieldAlternative, C As Long, Match As Boolean
   With pXDoc.Locators.ItemByName("BL").Alternatives
      If .Count=0 Then Exit Sub ' No barcode was found, so no custom classification
      Set Alternative=.ItemByIndex(0)
   End With
   'Check that the Barcode contains a valid class name
   For C=0 To Project.ClassCount-1
      If Project.ClassByIndex(C).Name=Alternative.Text Then
         Match=True
         Exit For
      End If
   Next
   If Not Match Then Exit Sub ' The barcode does not contain a valid classs name
   pXDoc.Reclassify(Alternative.Text, Alternative.Confidence) ' reclassify the document according to the barcode
End Sub
 ```
