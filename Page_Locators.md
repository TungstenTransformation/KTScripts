# Page Locators
This is an incredibly powerful technique in Kofax Transformation for designing and running locators on specific pages of documents and can dramatically simplify your projects and make them far more powerful and flexible.  
This technique can make Page Separation completely obsolete in some cases. In many projects complicated solutions are built to separate documents carefully, but often we are only interested in a few specific pages within those documents. If we find those pages, and ignore all others, we can run locators just on them.  

## Technique
You can either loop through all the pages of a document and run locators over evey page, or first [classify each page](Page_Classification.md) and then run locators only on relevant pages
### Create Classes, Locators and Fields for the relevant pages
1. Add a top-level class to your project called Page and deselect **Valid Classification Result** and **Available for Manual Classification** since we don't want this class to interfere with document classification in this project.  
![image](https://user-images.githubusercontent.com/47416964/128839233-a71236a7-2e08-48a7-a98c-afe9e332276b.png)  
1. Underneath this Class and Classes for each Page that you want locators to run on and deselect the Classification Attributes.  *In my example we have the case where somewhere in the document is a two-page FormX and a 1 page FormY.*  
![image](https://user-images.githubusercontent.com/47416964/128844588-eb83e3f4-70b8-495d-9c06-e5e00a0c1f18.png)
1. In each of these locators write and locators, fields and validation rules that you need - just as if they were normal documents.
### Create in the main class a master script to manage it all
1. In the main class you will need a script locator that loops through the pages and extracts pages 1 at a time. This script will also need to bring the field results back into the main document, so it is important that field names match between the class definition and page definition. It is even possible to copy page results into a table field in the main document.
2. Select **Group Field** In the **Field Definition** tab of the script locator and add Subfields that exactly match the names of the fields that you want copied from the Page Fields.  
![image](https://user-images.githubusercontent.com/47416964/128846720-e5d00fbe-0cc9-43d6-824e-9bcc11efe82a.png)

3. Add a script locator **SL_ExtractPages**.
```vb
Private Sub SL_ExtractPages_LocateAlternatives(ByVal pXDoc As CASCADELib.CscXDocument, ByVal pLocator As CASCADELib.CscXDocField)
   Dim P As Long, Page As CscXDocument, F As Long, Alternative As CscXDocFieldAlternative, SubField As CscXDocSubField
   Dim PageClassName as string
   Set Alternative=pLocator.Alternatives.Create
   For P=0 To pXDoc.Pages.Count-1
      Set Page=New CscXDocument
      Page.CopyPages(pXDoc,P,0)
      'TODO Add your logic here to decide if and which Page Locators to call.
      'For example you can use https://github.com/KofaxRPA/KTScripts/blob/master/Page_Classification.md to classify the page
      Project.ClassByName(PageClassName).Extract(Page)
      For F=0 To Page.Fields.Count-1
         Set SubField=Alternative.SubFields.Create(Page.Fields(F).Name)
         Field_CopyToSubfield(Page.Fields(F),SubField,P)
         Alternative.Confidence=Alternative.Confidence+SubField.Confidence
      Next
      'Set the parent alternatives confidence to be tha average of the subfields' confidences
      Alternative.Confidence=Alternative.Confidence/Alternative.SubFields.Count
   Next
End Sub

Private Function Field_CopyToSubfield(F As CscXDocField, S As CscXDocSubField, PageId as Long)
   'Copy a field to a subfield in another document
   S.PageIndex=F.PageId
   S.Left=F.Left
   S.Width=F.Width
   S.Top=F.Top
   S.Height=F.Height
   S.Confidence=F.Confidence
   S.ExtractionConfident=F.ExtractionConfident
   S.Text=F.Text
End Function

```
