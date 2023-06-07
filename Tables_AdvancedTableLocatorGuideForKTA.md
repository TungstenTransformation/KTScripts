# Train Tables in KTA (Advanced Table Locator)
This in-depth step-by-step guide will take you through the following steps  
* Collecting sample files to build a KT project in KTA.
    *  naming them well to make them easy to sort and work with.
    * creating subsets.
* Creating a new, simpler KT project for testing locators and documents and building training files, without interupting your main KTA project.
* Converting TIFF to PDF to dramatically speed up development time without losing PDF-text.
* Getting the truth into the sample documents.
* Importing the truth documents from KTA into Transformation Designer and restoring the original file names
* Building a table benchmark using metafields
    * Row Count.
    * Row alignment.
    * Column alignment.
    * True/false positive/negative count.
    * 1st Row concatenation.
    * Text Column concatentation.
    * Numeric Column sums.
* Combining Advanced Table Locator (ATL) with Automatic Table Locator, Specific Online Learning and Manual Table Locator to optimize table extraction.
    * "Voting" by script between ATL and TL.
    * Enhancing TL by script to improve
        * find missing rows.
        * switch columns.
        * check for missing words.
        * fixing line-wrapped table cells.
* Migrating XDocs from the training project into your main KTA project without losing data.
* Training and benchmarking in your main KTA project.

## Collecting Sample Files
Collect 1 day's worth of documents from your customer.  
You need **representative** files for your project. The sample files need to represent what actually happens in a normal day - the good, bad and weird documents - all of them.
* Make sure they include all the "good" documents and all the "bad" documents and all the "weird" documents.
* Your project has to have excellent extraction performance on the "good" documents and have great user productuvity on the "bad" documents. You cannot simply consider the "bad" documents out-of-scope. You need to demonstrate your solution is excellent for bad documents - make it easy and fast for the human to enter data in validation.
* Ask the customer "Are there any other documents? Is that all? Got any weird ones? Different documents at different times of years?" Tell them, "Any different documents that appear later are out of scope".  
Name them well.
* Nicest is **CompanyName_idnumber**.That makes them easy to find and sort and identify.
* Open Windows Explorer and turn on **Preview Pane**. This is one of the best tools for examining, renaming and sorting files.

![image](https://github.com/KofaxTransformation/KTScripts/assets/47416964/a3c3ad54-41b5-499e-b7ef-929e62dd0a1e)  
* In Windows Explorer you can also enable **NavigationPane/ExpandToOpenFolders**  to view folders that you can use to name documents.  
![image](https://github.com/KofaxTransformation/KTScripts/assets/47416964/3c48b20d-50d0-4403-97f3-fa1d4e0f2e4f)
* When you import the documents into Transformation Designer.
You can now quickly look through the documents to rename them. Transformation Designer does have the clustering tool, but that is not really effective for browsing documents - and it forces you to name every document correctly first time - it can me more frustrating than beneficial.
* import files into Transformation Designer with the following settings to create a subset for each folder in windows explorer.  
![image](https://github.com/KofaxTransformation/KTScripts/assets/47416964/d1f50599-840b-47b2-861c-f9140164ed03)

## Replace all of your PDFs with TIFFs
PDF Documents are problematic for Transformation Designer because
- every time you run a locator or classify the document the PDF renderer has to redraw each page.
- You cannot split or change pages in a pdf document
The Xdocs are loaded with the text from the PDF documents. 
[This script](PDFtoTiff.md) generates singlepage TIFF images from the PDF document and replaces them in the XDoc. The PDF is then disconnected from the XDoc.  
Now you have the perfect text, single pages you can re-order and images for fast locators and benchmarks. No downsides!

## Build a small training project in Transformation Designer.
You want this project small and fast for rapid development and testing.  
* Add a top level document class and a subclass to contain the documents you want to train.  
![image](https://github.com/KofaxTransformation/KTScripts/assets/47416964/cb501607-9551-440c-b502-d0e3ec1749d4)
* Select **Enable Table Detection** in the class details.  
![image](https://github.com/KofaxTransformation/KTScripts/assets/47416964/7e5f7778-794c-43ba-b01f-895082d16e06)
* Add the table model and field that you need.
* Add a Field Group **TableBenchmark** and the fields **TableRowCount**, **TableRowAlignment**, **TableColumnAligment**, **TableTP**, **TableFN**, **TableTN**, **TableFP**, which will be used for the table benchmarking.
![image](https://github.com/KofaxTransformation/KTScripts/assets/47416964/6f826fd4-d457-47a7-b115-7b7700ddbb8c)  
* Add the **Advanced Table Locator** (ATL) and the **Table Locator** (TL)and assign them the table model.
* Assign your Table Field to the **Table Locator**.  We will use a script to copy the ATL to the TL if it is a better result. This way we can benefit from the online learning of the TL, while the ATL has no online learning.



## Copying Original FileName into the XDoc.
2 methods- via xdocs and via input variables
https://docshield.kofax.com/KTA/en_US/7.11.0-h49vd5omev/help/SDK_Documentation/latest/class_agility_1_1_sdk_1_1_services_1_1_capture_document_service.html#aaba3bff7a12638891a3cc0dcfa8a4b44
![image](https://github.com/KofaxTransformation/KTScripts/assets/47416964/32629529-e5bf-49e4-bc26-2b1c90a13207)
![image](https://github.com/KofaxTransformation/KTScripts/assets/47416964/655f3ac5-3c89-492c-b75d-5f31788cae93)
### input variables
use input variables and read them in KT script from project.InputVariables(??)
![image](https://github.com/KofaxTransformation/KTScripts/assets/47416964/aa7abd2e-f99d-486a-8fd9-dd6eb3192d39)
![image](https://github.com/KofaxTransformation/KTScripts/assets/47416964/4654f449-b99f-4dbe-86cc-6673319bbbb0)
