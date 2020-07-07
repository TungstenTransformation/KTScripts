# How to Dynamically Change Database or Dictionary 
Sometimes it is useful to create a fuzzy dictionary or fuzzy database that is unique for a document, so we need to change the database on demand.  
**Fuzzy Dictionaries** are a powerful but mostly unknown feature of Kofax Transformation. A **Format Locator** normally uses a regex or a pattern, but if it is given a Dictionary instead of a regex then it becomes a **Fuzzy Dictionary Locator**, which has the advantage over a Database Locator that it finds **ALL** references to a word, whereas a Database Locator only finds **ONE** reference (and that may not be the first one in the document)

In Kofax Transformation Dictionary and Database files are static. There are two ways that they are designed to be changable
* Update the import text file. Kofax Transformation Modules Recognition Server, and KTA Extraction Activity and RPA's Document Transformation Server DTS will all check upon opening a new batch whether the database import files have changed - they will then be imported before the batch is processed.
* Search and Match Server has a setting to regularly update a remote fuzzy from it's SQL or text file source.  

This guide will show you how the safely make a dictionary or database dynamic. It will describe the steps for a database, but the dictionary uses exactly the same approach.
You also need to consider that documents could be processed in parallel and so you need to ensure that the database for one document cannot leak to another document.  
# Steps to make a dynamic database
1. Create a fuzzy database with sample entries or even empty entries.
2. Add a Database Locator that uses this fuzzy database. Test that it works.
3. Add a Script Locator **before** the Databaselocator called **SL_CreateDynamicDatabase**. The script does the following
   * Create a GUID for this document (This ensures no conflict between this document and another document in parallel processing)
   * Create a databasefile right next to the original import file.
   * Create a new temporary database.
   * Imports the temporary database.
   * Alters the project to point to the new database. **This is a potentially dangerous step, because the project is altering itself. Make sure that you do not save your project in an invalid state.**

4. After the Database Locator has finished running the locator is pointed back to the original database and the temporary database file is deleted.

```vb
```


