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
 1. Add a Barcode Locator to the Project Level.
 
