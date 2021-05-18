# Table Scripting Framework  
This framework shows how to build powerful table extraction algorithms and integrate them into Kofax Transformation such that
 * The automatic + learning mode is supported and indeed enhanced.  
![image](https://user-images.githubusercontent.com/47416964/112153265-60a20500-8be3-11eb-925f-c17186109ef5.png)
   * The Learning mechanism in the Table Locator works as follows
     1. Find the best classification matches of the document with the specific training set/knowledge bases.
     2. For the best N (5?) specific samples see if they have a manual **Table Definition**, that was either trained in Project Builder with the **Edit Document** dialog, or thta was automatically generated from an online learning sample.  
![image](https://user-images.githubusercontent.com/47416964/112153912-12d9cc80-8be4-11eb-9f7f-901db1875b55.png)

 * The Test feature of the Table Locator works, including running on-demand the required previous locators that the scripts need  
![image](https://user-images.githubusercontent.com/47416964/112153401-83341e00-8be3-11eb-8f1f-c725aa6b88b5.png)
 * 
There are 3 places where scripts can contribute to table locator extraction:
* **Document_BeforeExtract**
  * General changes to the OCR layer of the document
    * splitting "FirstName,LastName" into two words, where there is no space after the comma
    * dollar, comma and period repairs in numbers?
    * *This script needs to be aware if it has already run and not run on the same document repeatedly*
* **Document_BeforeLocate**
  * Correct errors in table header words, create table headers, or simplify table headers to make it easier for the table locator 
* **Document_AfterLocate**
 1. Allow many different table algorithms to run. Each algorithm will be passed two parameters (pXDoc as CSCXdocument, Table as CSCXDocTable)
    * *Can we simply add more alternatives to the table locator, and create a table on alternatives (I have never done this)* 
 1. **"Vote"** on results, or perhaps merge results
    * An algorithm should be checking the online-learning samples and using that for our own "manual table locator" algorithms
      * Does someone know how to get the cell coordinates of the manual table locator sample?
 1. **Repair** table structure
    * check for missing rows or whether extrapolation needs to go further down (or up)
    * check for missing cells in rows, because rows above or below have a value here
    * check for misaligned cells and correct them
 1. **Repair table cells**
    * correct misspelled names?
    * correct procedure codes??
    * check (and correct?) running total rows in the tables
 1. **Post Processing**
    * Remove from all tables the rows and columns that are of no interest to HealthLogic. (We may have extracted more than they need)
    * Generate table metadata for benchmarking tables in a locator **SL_TableMetadata**
      * TableRowCount 
      * TableCellCount (ignore empty cells)
      * TablePatientIds
      * TablePatientNames
      * TableProcedureCodes
      * TableCopaySum
      * TableTotalSum
      * TablePayableSum
