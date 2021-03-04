# Convert PDF to TIFF in KTM, KTA, RPA, KTT or RTTI
PDF documents have the following disadvantages when building a project in Project Builder
* PDF documents cannot be merged, split, or pages deleted.
* PDF documents make *testing* barcode, zone and table locators VERY SLOW.  
*Kofax Transformation needs to "render" a PDF page to pixels for pixel-based locators (The automatic table locator which is looking for horizontal and vertical lines) and layout classification to see the non-text parts of the document. This rendering can take about 1 second/page.*

Here is how to make your locators, benchmarks and classification run 10x or more faster in KT Project Builder.  
This script converts the PDFs into TIFF images and gives these benefits
* The PDF text layer is preserved.
* documents can be split, merged, pages deleted.
* All locators, layout classification and all Benchmark Tools now run at full speed.

*This script makes Project Builder run faster, but it does **not** make your project run faster at production time. It provides no value for production systems.*

1. Add the script below to the project level script, by right-clicking on **Project Class** in the Project Tree and selecting **Show Script**
1. Open your Document Set with PDF Documents.
1. Select the Documents that you want to convert from PDF to TIFF.
1. Select **Classify** From **Process Menu** (or Press F5).
1. Save the Documents by clicking **Save Selected Documents** (the single floppy disk icon, not the double!).  
![image](https://user-images.githubusercontent.com/47416964/98676998-aceb5780-235c-11eb-9eff-30d04fbf7fc3.png)
1. Reload your Document Set.  
![image](https://user-images.githubusercontent.com/47416964/98677185-f5a31080-235c-11eb-9fbd-854847a0eb64.png)
1. You now see that the PDF icon ![image](https://user-images.githubusercontent.com/47416964/98677290-1bc8b080-235d-11eb-8d9d-744e81204eb0.png)
 is gone, and that the the XDocuments are now TIFF based ![image](https://user-images.githubusercontent.com/47416964/98677260-12d7df00-235d-11eb-8cc8-76713b68f089.png)
1. In Windows Explorer you will see the original PDF, the XDocument and each of the TIFF images.  
![image](https://user-images.githubusercontent.com/47416964/98677952-161f9a80-235e-11eb-8681-a821089439f9.png)
1. Remove the script from your project if you no longer needed. It can run in produciton, but only if you want theses TIFFs at runtime for some reason. 
1. To undo everything and revert back to the PDFs directly, load the document set with Source files set to PDF only.  
![image](https://user-images.githubusercontent.com/47416964/98678073-4bc48380-235e-11eb-99b6-ed321373384c.png)


# The script function does the following
* Create a single-page TIFF image for each page. (Kofax Capture, KTM and KTA all prefer to work with single page TIFFS. Export connectors can merge them to mulit-page tiffs if needed)
* Optionally perform basic VRS on the image.
* Replace each page in the XDoc with the TIFF pages.
* Preserve the PDF Text layer to avoid performing OCR.

```vb
Private Sub Document_AfterClassifyXDoc(ByVal pXDoc As CASCADELib.CscXDocument)
      XDocument_ReplacePDFwithTIFF(pXDoc)
End Sub

Public Sub XDocument_ReplacePDFwithTIFF(pXDoc As CscXDocument)
   'Project Builder is very slow with PDFs. use this the keep the pdf text but use TIFF images for speed while testing
   Dim P As Long, Image As CscImage, Filename As String
   For p=0 To pXDoc.CDoc.Pages.Count-1
      Set image=pXDoc.CDoc.Pages(p).GetImage'.BinarizeWithVRS() ' The Table Locator NEEDS black&white images for vertical&horizontal line detection
      filename=Replace(pXDoc.FileName,".xdc","_") & Format(p+1,"000") & ".tif"
      image.Save(filename,CscImgFileFormatTIFFFaxG4)
      pXDoc.ReplacePageSourceFile(filename,"TIFF",p,0)
   Next
   pXDoc.Save
End Sub
```
