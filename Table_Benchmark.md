## Table Benchmark.
This article shows you how to add a table benchmark to your Transformation Project. It uses the standard Extraction Benchmark. 
This process was designed for KTA, though it will also work in KTM and RPA.  
The benchmark looks like this:  
![Alt text](image.png)
There are 5 Table Benchmark Fields  
![Alt text](image-1.png)
* **TableRowCount** *This table has the correct number of rows 5.*
* **TableTotalPriceSum** *This table has the incorrect column sum of 0.00. it should have 8309.00.*
* **TableRowAlignment** *81% of the rows are aligned. Rows 1 & 4 are misaligned.*
* **TableColumnAlignment** *87% of the columns are aligned. Column 7 is misaligned.*
* **TableCells** *7 cells contain the wrong text.*

This example uses [this sample document].  The correct table seen below, but I manually removed 3 text lines from row 1 and 2 textlines from row 4, just to show how the benchmark works.
![image](https://github.com/KofaxTransformation/KTScripts/assets/103566874/f2472ff8-6ff4-4ea8-b0e7-24f8cc54876f)

The **Automatic Table Locator** incorrectly reads the **Total Price** column, which is really useful for testing a benchmark!  
![image](https://github.com/KofaxTransformation/KTScripts/assets/103566874/76565a7a-3d2a-4772-b989-f2e23c910ac2)

## The overall process.
*Here is an overview of each step, which is giving in detail later below.*
* Create a normal Transformation process in KTA.
* Make sure image processing is enabled if using PDF documents.
* Turn on online-learning
* Add step for storing the original document name into an XValue.
* Collect sample documents. Load them into a test set in Transformation Designer. Convert this to a benchmark set. 
* Import your benchmark documents into KTA scan application.
* In KTA Validation validate your documents making sure that every field and table cell is perfect. Add the document to online-learning.
* In Transformation Designer import new training samples.
* Drag these new samples into a new test set.
* Add the [Benchmarking script] to your project.
* Extract (F6) your new samples. This will copy the truth into your benchmark training set.
* Run the Extraction Benchmark.

## Add the Benchmark fields to your project
* Add the 5 benchmark fields to your project
![Alt text](image.png)
* Set each field to be always valid.  
![Alt text](image-2.png)
  * Add the script [Table_Benchmark.vb](Table_Benchmark.vb) to the class containing your table locator and 5 benchmark fields.

## KTA
* to be able to use PDF text and lasso in PDF documents, you need to run image processing.  
![Image Processing Config](images/image_processing.png)
* Make sure that in the process settings, you are using PDF Text.  Click on blank-space in process map and Click "Capture" Settings. 
![Alt text](images/pdf_text_extraction.png)

## Copying Original FileName into the XDoc.
2 methods- via xdocs and via input variables
https://docshield.kofax.com/KTA/en_US/7.11.0-h49vd5omev/help/SDK_Documentation/latest/class_agility_1_1_sdk_1_1_services_1_1_capture_document_service.html#aaba3bff7a12638891a3cc0dcfa8a4b44
![image](https://github.com/KofaxTransformation/KTScripts/assets/47416964/32629529-e5bf-49e4-bc26-2b1c90a13207)
![image](https://github.com/KofaxTransformation/KTScripts/assets/47416964/655f3ac5-3c89-492c-b75d-5f31788cae93)
### input variables
use input variables and read them in KT script from project.InputVariables(??)
![image](https://github.com/KofaxTransformation/KTScripts/assets/47416964/aa7abd2e-f99d-486a-8fd9-dd6eb3192d39)
![image](https://github.com/KofaxTransformation/KTScripts/assets/47416964/4654f449-b99f-4dbe-86cc-6673319bbbb0)


## Making golden files
* Turn on online learning.
* import documents into KTA.
* validate the tables, making them perfect.
* make sure you add files to online learning.
* finish validation
* import new samples into TD.
* drag these samples into the same folder where the original files are.
* Extract the new samples. This will run code in Document_AfterExtract that will find the OriginalFileName in XValues, and then copy all the fields into the OriginalFileName.
* You can now delete the new import samples. the original files contain the truth.
* Run the benchmark.
* if you detect that you made mistakes in validation. go back to workqueue in KTA and sleect "Reprocess". Fix them in Validation.
* when you are happy wiht your golden files you can run the workflow to end to delete the files from KTA.
