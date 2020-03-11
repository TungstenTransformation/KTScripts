# Fuzzy Field Formatter and Validation Rule

Use this to spell-check and auto-spell-check field values. Useful for
* correcting OCR errors in names, cities, provinces, job titles, etc

## Example: Canadian Provinces.

1. Create a database in Notepad with Canadian Provinces and all possible abbreviations. You can have as many columns as you like. Put the correct value in the first column

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

1. Save the File in Notepad as **Provinces.txt**, making sure to save as UTF-8 to preserve all non-ASCII characters.
![image](https://user-images.githubusercontent.com/47416964/76402246-713e5f00-6383-11ea-9d7e-59e559953926.png)
1. Create a subfolder called **databases** inside your project folder, right next to the .fpr file. *If you do this then all of your databases will be inside the project and when you move the project to another machine all the databases and dictionaries will be automatically found again.*
1. Create a **Local Fuzzy Database** in ProjectSettings/Databases/Databases/Add
1. Open **Provinces.txt**. Make sure that the file delimiter is correct. Select **First line contains caption*
** *Automatic update from import file* is required if the database updates frequently. This one doesn't so don't select this.**
1. Make sure **Load database in memory** is selected for speed, and make sure **Advanced** is selected for **Database processing**
1. Press **Ok**.
