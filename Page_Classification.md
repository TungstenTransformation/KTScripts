# Page Classification
This script allows you to classify individual pages within a document dynamically.  
This can be combined with [Page Locators](Page_Locators.md) to find specific pages within large documents and apply locators to those pages directly, especially when the particular page you are looking for could be anywhere within the doucment, or perhaps is missing.  
This technique uses the not-well-known [**Classification Locator**](https://docshield.kofax.com/KTT/en_US/6.3.0-v15o2fs281/help/PB/ProjectBuilder/450_Extraction/ClassificationLocator/c_ClassificationLocator.html) which **embeds** a *reference project* within another project and is compatible with KTA, RPA, KTM, KTT and KMC.
## Create a Page Classification Project
1. Open a new Project Builder and create a new project purely for Page Classification.
2. If you have PDF documents [Convert your PDF Documents to TIFF images](https://github.com/KofaxRPA/KTScripts/blob/master/PDFtoTiff.md) without losing your PDF Text. You need to do this to be able to split the PDFs into pages.
3. Switch to Hierarchy View.  
![image](https://user-images.githubusercontent.com/47416964/128835363-45569ee0-59f9-44b2-b172-a3e5bc34f696.png)
1. Split your documents into individual pages.  
![image](https://user-images.githubusercontent.com/47416964/128835457-51aee596-658f-471e-8e1c-7efb77344d4d.png)
3. Create a top-level Document Class called Page and give it sub-classes with the names of each Page.
4. Make sure you also have a class called **junk** or **ignore** for pages you don't care about. (The Classification Algorithm works better when it knows what it should ignore)
5. Drag pages into the correct classes and train the project for Classification.
6. Close the Project.
## Add the Page Classification Project to your main project
This technique uses **Page Level Locators**
1. Add a top-level class **Page** to your project. Deselect **Valid classification Result** for it.  
2. Add a [**Classification Locator**](https://docshield.kofax.com/KTT/en_US/6.3.0-v15o2fs281/help/PB/ProjectBuilder/450_Extraction/ClassificationLocator/c_ClassificationLocator.html) to the Page Class and call it **CL_Page**
![image](https://user-images.githubusercontent.com/47416964/128837230-2cafc86c-8e3e-460c-8a00-d81181d27408.png)
3. In your "Main" document class add a Script Locator **SL_ClassifyPages**
```vb
Private Sub SL_ClassifyPages_LocateAlternatives(ByVal pXDoc As CASCADELib.CscXDocument, ByVal pLocator As CASCADELib.CscXDocField)
   Dim P As Long, Page As CscXDocument, PageClassificationResults As CscXDocFieldAlternatives
   For P=0 To pXDoc.Pages.Count-1
      Set Page=New CscXDocument
      Page.CopyPages(pXDoc,P,0)
      Project.ClassByName("Page").Locate(Page,Project.ClassByName("Page").Locators.ItemByName("CL_Page").Index)
      Set PageClassificationResults=Page.Locators.ItemByName("CL_Page").Alternatives
      If PageClassificationResults.Count>0 Then
         'PageClassificationResults(0).Text contains the Class Name of the Page
         'PageClassificationResults(0).Confidence contains the Classification confidence of the page
         'TODO. you know the classification of the page and can write your custom code here
      End If
   Next
End Sub
```

