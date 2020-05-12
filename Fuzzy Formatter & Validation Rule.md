# Fuzzy Field Formatter and Validation Method

Use this to spell-check and auto-spell-check field values. Useful for correcting OCR errors in names, cities, provinces, job titles, etc

Formatters **can** change a field value, Validation Methods **cannot**.    
The Fuzzy Field Formatter uses a fuzzy database to find matches and can auto-correct a field or make suggestions to the user.  
The Validation Method does a non-fuzzy search in the fuzzy database to check that the value is perfect.

## Example: Canadian Provinces.

### Create Database
1. Create a database in Notepad with Canadian Province names and all possible abbreviations. You can have as many columns as you like. Put the correct value in the first column. *it doesn't matter if you have duplicates in the abbreviations. If they are ambiguous they will produce options for the user*.

Province|Post|English|French
--------|----|--|--
Alberta|AB|Alta|
British Columbia|BC||CB
Manitoba|MB|Man|
New Brunswick|NB||
Nova Scotia|NS||NE
Prince Edward Island|PE|PEI|ÎPÉ
Quebec|QC|Que|PQ
Saskatchewan|SK|Sask|
Northwest Territories|NT|NWT|TNO
Nunavut|NU|Nvt|Nt
Yukon|YT|Yuk|Yn
2. Save the File in Notepad as **Provinces.txt**, making sure to save as UTF-8 to preserve all non-ASCII characters.
![image](https://user-images.githubusercontent.com/47416964/76402246-713e5f00-6383-11ea-9d7e-59e559953926.png)
2. Create a subfolder called **databases** inside your project folder, right next to the .fpr file. *If you do this then all of your databases will be inside the project and when you move the project to another machine all the databases and dictionaries will be automatically found again.*
1. Create a **Local Fuzzy Database** in ProjectSettings/Databases/Databases/Add
1. Open **Provinces.txt**. Make sure that the file delimiter is correct. Select **First line contains caption**
 *Automatic update from import file* is required if the database updates frequently. This one doesn't, so don't select this.
1. Make sure **Load database in memory** is selected for speed, and make sure **Advanced** is selected for **Database processing**
1. Press **Ok**.
### Create Fuzzy Field Formatter
1. Create a Field Formatter called **Provinces** in **ProjectSettings/Formatting/Add..**  
    ![image](https://user-images.githubusercontent.com/47416964/76403678-8c11d300-6385-11ea-92ba-446a5ea5be9f.png)
1. **Select**, **Copy** and **Show Script**  
    ![image](https://user-images.githubusercontent.com/47416964/76403778-b82d5400-6385-11ea-98fe-e61151a44dad.png)
1. Paste the script at the end of the script window.
1. Make sure that the first **two** lines of the script are as shown. **Explict** forces you to define variables and the  [Language Comment](https://www.winwrap.com/web2/basic/#!/ref/WWB-doc_language_def.htm) supports extra keywords like **return** and **andalso**.
```VBA
Option Explicit
'#Language "WWB-COM"
````
2. Replace the script with the following
```VBA
Private Sub Province_FormatField(ByVal FieldText As String, FormattedText As String, ErrDescription As String, ValidFormat As Boolean)
   Dim results As CscXDocFieldAlternatives, R As Long
   ValidFormat = False
   If Len(FieldText) = 0 Then
      ErrDescription = "Province Field may not be empty"
   Else
      FormattedText = Replace(FieldText, "-", "")
      FormattedText = Replace(FormattedText, ".", "")
      Set results=Database_FuzzySearch("Provinces","",FormattedText,5,0.5,True) 'Return up to 5 results with 50% or better score and return all columns, because we want to retrieve a particular column
      Select Case results.Count
      Case 0
         ErrDescription= FieldText & " is not a Province"
      Case 1
         If results(0).Confidence>0.8 Then 'there was a single match with over 80%. the next best match is under 50%, so we auto-accept this
            ValidFormat = True
            FormattedText=results(0).SubFields.ItemByName("Province").Text
         Else
            ErrDescription = results(0).Text & "?" ' there was 1 match but the score is not high enough, so just show it to the user in the error description
         End If
      Case Else ' we found more than 1 result
         'if the best result is over 80% and is more than 20% better than the second result then auto-accept ot
         If results(0).Confidence-results(1).Confidence >0.2 And results(0).Confidence Then
            ValidFormat = True
            FormattedText=results(0).SubFields.ItemByName("Province").Text
         Else 'show the whole list to the user
            ErrDescription=""
            For R=0 To results.Count-1
               ErrDescription= ErrDescription & results(R).Text & ", "
            Next
            ErrDescription=Left(ErrDescription,Len(ErrDescription)-2) & "?" 'remove training comma and replace with "?"
         End If
      End Select
   End If
End Sub
```
2. You will need to add the script for [Database_FuzzySearch](https://github.com/KofaxRPA/KTScripts/blob/master/Database_FuzzySearch.vb)
2. Test the Field Formatter with various options  
![image](https://user-images.githubusercontent.com/47416964/76406397-f0369600-6389-11ea-9d7e-64136be9feee.png)

### Create Fuzzy Validation Rule
*Validation Rules are not called directly from Total Agilty, but they are still available for use in scripts and locators.*
1. Add a new Validation Method in **ProjectSettings/Validation/SingleFieldScriptValidation** and call it **Province**
1. **Select**, **Copy** and **Show Script**.
1. Paste the script into the script window underneath your field formatter.
1. Replace the script with
```VBA
Private Sub Province_Validate(ByVal pValItem As CASCADELib.ICscXDocValidationItem, ByRef ErrDescription As String, ByRef ValidField As Boolean)
   Dim results As CscXDocFieldAlternatives
   'A Validation Rule CANNOT change a fieldl value, it only checks if it is valid or not
   If pValItem.Text="" Then ValidField=True : Exit Sub
   'Perform a fuzzy search, but require 100% match and return only one result.
   Set results=Database_FuzzySearch("Provinces","Province",pValItem.Text,1,1.00,True)
   If results.Count>0 AndAlso pValItem.Text=results(0).SubFields.ItemByName("Province").Text Then ValidField=True : Exit Sub
   ErrDescription = pValItem.Text & " is not a valid province"
   ValidField=False
End Sub
```
2. test your Validation Rule  
![image](https://user-images.githubusercontent.com/47416964/76409371-91bfe680-638e-11ea-99eb-f78f36b5ad06.png)
