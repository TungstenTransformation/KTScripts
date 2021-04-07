# Separation By Locator
This script will assume that every document is classified to the same class, and that a locator is used to find out where to separate the document.  
**Trainable Document Separation** is not used. This is a customization of **Standard Document Separation**.    
![image](https://user-images.githubusercontent.com/47416964/113839226-ca97de00-978f-11eb-959c-ac4e977d2c85.png)

KT provides three events that can be used for custom [Document Separation](https://docshield.kofax.com/KTT/en_US/6.3.0-v15o2fs281/help/SCRIPT/ScriptDocumentation/c_StandardDocumentSeparation.html)
* **Document_BeforeSeparatePages**(ByVal pXDoc As CASCADELib.CscXDocument, ByRef bSkip As Boolean) 
*This event provides you with the entire batch of pages as a single document*  
If you set bSkip=true then no separation will occur and  Document_SeparateCurrentPage will not be called.  

* **Document_SeparateCurrentPage**(pXDoc As CASCADELib.CscXDocument, ByVal PageNr As Long, bSplitPage As Boolean, RemainingPages As Long)  
*This event is called for every single page and provides you with the "batch of pages" and a pointer to the current page.*  
All this script does is set pXDoc.CDoc.Pages(PageNr).SplitPage=bSplitPage.  
If you set bSplitPage=true, then this page will become the first page of a new document.  
if you ignore **RemainingPages**, then the same event will be called for the next page.
* **Document_AfterSeparatePages**(ByVal pXDoc As CASCADELib.CscXDocument)  
The Document is not actually split until AFTER **Document_AfterSeparatePages** has run. This is your last chance to change pXDoc.CDoc.Pages(PageNr).SplitPage for each page.

# Two Strategies
The attached sample set contains 11 pages that contain single numbers on most pages.  
**1, ,1,2,3, ,4,5,6,5,5**  
These need to be separated into 6 documents  
**1- -1,2,3- ,4,5,6-6-6**  
The separation locator finds nothing on page 2 of document 1 and page 2 of document 3.   
Document 1 contains a blank page in the middle. The most complicated part of the script is ensuring that page 3 of document 1 remains part of the document.  
We cannot use the simplistic strategy *make a new document if the locator has a different value than the previous page*. We need to look before the blank pages.    

Some locators find only ONE result and then stop. We need to call these locators for each page.
* database locator
* trainable group locators
* table locator
* zone locator
* Address Locator
* Vendor Locator
* Sentiment Locator

Some locators find ALL results on all pages. We can call these locator ONCE for all pages.
* format locator
* barcode locator  

# Strategy 1. Call a separation locator for each page.
* Right-click on your desired class and select **Default Classification Result**  
![image](https://user-images.githubusercontent.com/47416964/113843239-b35aef80-9793-11eb-9f7e-4be06e06d06c.png)

* Create a class called **separation** to hold your separation locator(s)
* Disable "Valid classification result" and "Available for manual classification". This class will only be used by your script, you don't want it to be used for classification nor seen by the validation users.  
![image](https://user-images.githubusercontent.com/47416964/113843019-88709b80-9793-11eb-8ed9-ae7b95d786a4.png)



# Strategy 2. Call a separation locator for the entire document.
*problem: This script makes page 3 of document 4 a new document*
```vb
Private Sub Document_BeforeSeparatePages(ByVal pXDoc As CASCADELib.CscXDocument, ByRef bSkip As Boolean)
   'Build an array of numbers for each page
   Dim A As Long, Alt As CscXDocFieldAlternative, Alts As CscXDocFieldAlternatives
   ReDim Numbers(pXDoc.Pages.Count-1)
   Project.RootClass.Extract(pXDoc)
   Set Alts=pXDoc.Locators.ItemByName("FL_Number").Alternatives
   For  A=0 To Alts.Count-1
      Set Alt=Alts(A)
      If Alt.Confidence>0.8 Then Numbers(Alt.PageIndex)=Alt.Text
   Next
End Sub

Private Sub Document_SeparateCurrentPage(pXDoc As CASCADELib.CscXDocument, ByVal PageNr As Long, bSplitPage As Boolean, RemainingPages As Long)
   'This keeps handing you the parent document over and over with a new pagenr. This pXDoc is not actually split, but pages are
   'copied out of it into the new "real" xdocuments
   If PageNr=0 Then ' this is to prevent the array lookup looking for -1, and we never split the first page anyway
      bSplitPage= False
   ElseIf Numbers(PageNr)="" Then ' current page has no number so part of previous document
      bSplitPage= False
   ElseIf Numbers(PageNr)=Numbers(PageNr-1) Then ' same number = same document
      bSplitPage=False
   Else
      bSplitPage=True  ' current page has a different number than previous page, so new document
   End If
End Sub
```
