# How to Dynamically Change a Database or Dictionary 
Sometimes it is useful to create a fuzzy dictionary or fuzzy database that is unique for a document, so we need to change the database on demand.  
**Fuzzy Dictionaries** are a powerful but mostly unknown feature of Kofax Transformation. A **Format Locator** normally uses a regex or a pattern, but if it is given a Dictionary instead of a regex then it becomes a **Fuzzy Dictionary Locator**, which has the advantage over a Database Locator that it finds **ALL** references to a word, whereas a Database Locator only finds **ONE** reference (and that may not be the first one in the document)

In Kofax Transformation Dictionary and Database files are static. There are two ways that they are designed to be changable
* Update the import text file. Kofax Transformation Modules Recognition Server, and KTA Extraction Activity and RPA's Document Transformation Server DTS will all check upon opening a new batch whether the database import files have changed - they will then be imported before the batch is processed.
* Search and Match Server has a setting to regularly update a remote fuzzy from it's SQL or text file source.  

This guide will show you how the safely make a dictionary or database dynamic. It will describe the steps for a database, but the dictionary uses exactly the same approach.
You also need to consider that documents could be processed in parallel and so you need to ensure that the database for one document cannot leak to another document - the script below is safe for parallel processing because each database has a GUID in its name, and the project file is **NEVER** saved.    
# Steps to make a dynamic database
1. Create a fuzzy database with sample entries or even empty entries.
2. Add a Database Locator that uses this fuzzy database. Test that it works.  
![image](https://user-images.githubusercontent.com/47416964/86799502-4be00a00-c072-11ea-9600-1d38594002a5.png)
3. Add a Script Locator **before** the Databaselocator called **SL_CreateTempDatabase** and one after called **SL_DeleteTempDatabase**  
![image](https://user-images.githubusercontent.com/47416964/86799350-23f0a680-c072-11ea-844e-88049549d62a.png)  
The script does the following
   * Create a GUID for this document (This ensures no conflict between this document and another document in parallel processing)
   * Create a databasefile right next to the original import file.  
![image](https://user-images.githubusercontent.com/47416964/86799639-75009a80-c072-11ea-9216-0980f960f124.png)  
   * Create a new temporary database.  
   ![image](https://user-images.githubusercontent.com/47416964/86799707-85b11080-c072-11ea-98a4-59997f11e663.png)  
   * Imports the temporary database.  
   ![image](https://user-images.githubusercontent.com/47416964/86799768-96fa1d00-c072-11ea-810a-aa7cab72b928.png)  
   * Alters the Database Locator to point to the new database. **This is a potentially dangerous step, because the project is altering itself. Make sure that you do not save your project in an invalid state. You can corrupt your project file if you make a mistake here.**  
   ![image](https://user-images.githubusercontent.com/47416964/86799829-a8432980-c072-11ea-9def-81964c59a260.png)

4. After the Database Locator has finished running, the locator is pointed back to the original database and the temporary database files are deleted.  
![image](https://user-images.githubusercontent.com/47416964/86799873-b5f8af00-c072-11ea-9818-6010fe4418d6.png)

**MAKE SURE THAT YOUR DOCUMENTS ARE CLASSIFIED (hotkey F5) BEFORE TESTING!!** *pXDoc.ExtractionClass* is needed to find the Database Locator Definition.
```vb
Option Explicit

' Class script: NewClass1

Private Sub SL_CreateTempDatabase_LocateAlternatives(ByVal pXDoc As CASCADELib.CscXDocument, ByVal pLocator As CASCADELib.CscXDocField)
   Dim TempName As String
   TempName=Database_CreateTemp("Items","Windows 7;10;190.00") 'copy the format of a database, but give it new content
   DatabaseLocator_SetDatabase(pXDoc.ExtractionClass, "DL_Items",TempName) 'Point the database locator at the new database
End Sub

Private Sub SL_DeleteTempDatabase_LocateAlternatives(ByVal pXDoc As CASCADELib.CscXDocument, ByVal pLocator As CASCADELib.CscXDocField)
   DatabaseLocator_SetDatabase(pXDoc.ExtractionClass,"DL_Items", "Items") 'point the database locator back to the default database
   Database_DeleteTemp("Items_Temp")
End Sub

Private Function Database_CreateTemp(DatabaseName As String, Values As String) As String
   'This function copies a database with new values
   Dim Database As CscDatabase, TempDatabase As New CscDatabase, F As Long, TypeLib As Object, GUID As String
   Set TypeLib = CreateObject("Scriptlet.TypeLib") ' this library can create GUIDs
   GUID=Mid(TypeLib.GUID,2,36) ' remove { and }
   If Project.Databases.ItemExists(DatabaseName+ "_TEMP") Then Database_DeleteTemp(DatabaseName) 'clean up old temp database if it's there
   Set Database=Project.Databases.ItemByName(DatabaseName)
   If Not Database.DatabaseType=CscDatabaseType.CscFUZZYLocalType Then Err.Raise(487,,"Database '" & Database.Name & "' must be a fuzzy local database!")
   TempDatabase.Name= Database.Name & "_TEMP"
   TempDatabase.DatabaseType=CscDatabaseType.CscFUZZYLocalType
   TempDatabase.ImportFilename = Replace(Database.ImportFilename, ".txt", "_" & GUID & ".txt")
   TempDatabase.DelimiterChars=Database.DelimiterChars
   Open TempDatabase.ImportFilename For Output As #1
   Print #1, vbUTF8BOM;  'make the database file UTF-8 compatible
   'Write the captions to the new database if they are there
   If Database.FirstLineIsCaption Then
      For F = 0 To Database.FieldCount-1
         Print #1, Database.FieldName(F);   'The final ";" prevents a newline being printed
         If F<Database.FieldCount-1 Then  Print #1, Database.DelimiterChars ; 'print a delimiter between the columns
      Next
      Print #1, "" ' New line
      Print #1, Values
      Close #1
   End If
   TempDatabase.FirstLineIsCaption=Database.FirstLineIsCaption
   TempDatabase.DelimiterChars=Database.DelimiterChars
   TempDatabase.AutoUpdate=False
   TempDatabase.DetectFieldCount(TempDatabase.DelimiterChars)
   Project.Databases.Add(TempDatabase)
   TempDatabase.ImportDatabase(True)
   Database_CreateTemp=TempDatabase.Name 'This generates the database file (just a copy of the import file) and the fuzzy index file (.crp2)
End Function

Sub DatabaseLocator_SetDatabase(ClassName As String, LocatorName As String, DatabaseName As String)
   'Add reference to Kofax Cascade DatabaseLocator
   Dim DLMethod As CscDatabaseLocator
   If Not Project.Databases.ItemExists(DatabaseName) Then Err.Raise(456,,"Database '" & DatabaseName & "' doesn't exist!")
   Set DLMethod=Project.ClassByName(ClassName).Locators.ItemByName(LocatorName).LocatorMethod
   DLMethod.DatabaseName=DatabaseName  'setting to the new database
End Sub

Private Sub Database_DeleteTemp(DatabaseName As String)
   Dim Database As CscDatabase
   Set Database=Project.Databases.ItemByName(DatabaseName)
   Kill Database.ImportFilename 'Delete the import file
   Kill Database.DatabasePath 'delete the fuzzy index file .crp2
   Kill Database.TextFilename 'delete the copy of the text file
   Project.Databases.RemoveByName(Database.Name)
End Sub

Function FormatLocator_ReplaceDict(ByVal pXDoc As CASCADELib.CscXDocument,LocatorName As String,DictFileName As String) As String
   'Kofax Cascade FormatLocator
   Dim FLMethod As CscRegExpLocator, Dict As CscDictionary
   Set FLMethod=Project.ClassByName(pXDoc.ExtractionClass).Locators.ItemByName(LocatorName).LocatorMethod
   FLMethod.RegularExpressions(0).RegularExpression="§"& DictFileName & "§"
End Function
```


