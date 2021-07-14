# Validating and Spell-checking Table Rows with databases

You can use a fuzzy database of  correct values to correct the values in Rows of a Table.

Imagine the following table which has OCR errors in both column 1 and column 2.
| Code | Type | Amount |
|------|------|--------|
| 00I | Incorne | 456.70 |
| 002 | Expenditure | 567.40 |
| 0o4 | Intere5t | 56.60 |
| O06 | Tax | 34.56 |
| 00/ | Inhentence | 56.43 |

But we know what should be in those cells.  
| Code | Type |
|------|------|
| 001 | Income |
| 002 | Expenditure |
| 004 | Interest |
| 006 | Tax |
| 007 | Inheritence |

We can use this truth database to validate the table cells and also to correct OCR errors.
| Code | Type | Amount |
|------|------|--------|
| 001 | Income | 456.70 |
| 002 | Expenditure | 567.40 |
| 004 | Interest | 56.60 |
| 006 | Tax | 34.56 |
| 007 | Inheritence | 56.43 |


1. Create a text file with the truth data inside it. It can have any number of columns, but the column names MUST exactly match the table column names (order is not important)
2. Make sure that the first line of the text file contains the Column Names  
![image](https://user-images.githubusercontent.com/47416964/125620173-d50622d7-9297-4596-a06d-e95749df7fbf.png)
3. Save the File into a subfolder **Databases** within your Kofax Transformation Project.
4. Add a Database to your Project in ProjectBuilder/ProjectSettings/Databases/Databases/Add  
![image](https://user-images.githubusercontent.com/47416964/125621033-e7eaa1c1-e1d3-4f6c-8d09-d47c7d8182a9.png)
5. Give your Database a name (you will need the name later in the script) and select **Local Fuzzy Database**
6. Import your text file, select the correct column delimeter, and select **First line contains captions** (This is crucial so that the script knows which columns in the database match the columns in the table)  
7. Select **Automatic update from import file** and click **OK**.
![image](https://user-images.githubusercontent.com/47416964/125621568-850fae70-8ca4-4233-a86e-18747db8206d.png)
8. Add the script below to your project. Make sure you set the databasename correctly.
9. The script contains two constants **AcceptMatchThreshold** and **DistanceSecondMatch**. These are the percentage thresholds for accepting fuzzy matches.  
* **DistanceSecondMatch** ensures that no change is made if the fuzzy search finds **two or more good** matches.  
* You will need to adjust these constants to your own data.
10. The script will be called from **Document_AfterLocate** so that it runs within the Table Locator. 

**Note**. This script uses the keywords **return**, **orelse** and **andalso** which requires your script to start with **'#Language "WWB-COM"**

```vb
'#Language "WWB-COM"
Option Explicit
Private Sub Document_AfterLocate(ByVal pXDoc As CASCADELib.CscXDocument, ByVal LocatorName As String)
   Select Case LocatorName
   Case "TL"
      Table_ValidateWithDatabase(LocatorName,"MoneyCodes",pXDoc)
   End Select
End Sub

Private Sub Table_ValidateWithDatabase(TableLocatorName As String, DatabaseName As String, pXDoc As CscXDocument)
   'Validate table columns with a database. The database column names MUST MATCH exactly columns in the table
   Dim Table As CscXDocTable, Cells As CscXDocTableCells, C As Long, R As Long
   Dim Results As CscXDocFieldAlternatives, Database As CscDatabase, SearchText As String
   Set Table=pXDoc.Locators.ItemByName(TableLocatorName).Alternatives(0).Table
   Set Database=Project.Databases.ItemByName(DatabaseName)
   Const AcceptMatchThreshold = 0.50
   Const DistanceSecondMatch = 0.1
   For R=0 To Table.Rows.Count-1
      Set Cells=Table.Rows(R).Cells
      SearchText=""
      'Add all the cell values together into a string
      For C=0 To Database.FieldCount-1
         SearchText = Trim(SearchText & " " & Cells.ItemByName(Database.FieldName(C)).Text)
      Next
      'Search in the database for the cell values
      Set Results= Database_FuzzySearch(DatabaseName,"",SearchText,2,0.01,True ) 'return 2 fuzzy results with scores >1%
      'If the first result >80% match AND the second match is >10% points worse than the best match then accept the match
      'ie if there are two good matches do NOTHING - leave it to the human
      If (Results.Count>0 AndAlso Results(0).Confidence>AcceptMatchThreshold) AndAlso (Results.Count=1 OrElse Results(0).Confidence-Results(1).Confidence>DistanceSecondMatch) Then
         For C=0 To Database.FieldCount-1
            With Cells.ItemByName(Results(0).SubFields(C).Name)
               .Text=Results(0).SubFields(C).Text
               .ExtractionConfident=True
            End With
         Next
      End If
   Next
End Sub

Public Function Database_FuzzySearch(dbname As String, column As String, Searchstring As String, numberHits As Integer, minimimConfidence As Double, Optional allColumns As Boolean=False) As CscXDocFieldAlternatives
   'Searches inside a fuzzy database for the searchstring and returns the results in the alternatives of a new CSCField Object.
   'if column="" then all columns are returned as subfields, otherwise returns only the chosen column in the alternatives.
   'Set minimimConfidence=1.0 for exact match search.
   Dim DB As CscDatabase, Fields() As String,FieldIDs() As Long
   Dim col As Integer,C As Integer,i As Integer
   Dim hits As CscDatabaseResItems, alt As CscXDocFieldAlternative
   Dim results As New CscXDocField  'You are allowed to create a standalone field
   Dim value As String, substitute As String
   If Searchstring="" Then Return results.Alternatives
   Set DB=Project.Databases.ItemByName(dbname)
   ' Replace all delimiters by blank
   For i = 1 To Len(DB.AdditionalDelimiterChars)
      Searchstring = Replace(Searchstring, Mid(DB.AdditionalDelimiterChars, i, 1), " ")
   Next
   ' Replace all ignore characters by blank
   For i = 1 To Len(DB.RemoveChars)
      Searchstring = Replace(Searchstring, Mid(DB.RemoveChars, i , 1), " ")
   Next
   ' Substitution pairs define which texts to be replaced by what.
   For i = 0 To DB.SubstitutionPairCount - 1
      DB.GetSubstitutionPair(i, value, substitute)
      Searchstring = Replace(Searchstring, value, substitute)
   Next
   Fields = Split(Searchstring, " ")
   ReDim FieldIDs(UBound(Fields))
   'Find the column we are looking for
   col=-1
   For i =0 To DB.FieldCount-1
      If DB.FieldName(i)=column Then col=i
   Next
   If col=-1 And column<>"" Then Err.Raise 34589,,"Column '" & column & "' does not exist in database '" & dbname & "'."
   If col<>-1 Then 'Force query in this column
      For c=0 To UBound(FieldIDs)
         FieldIDs(c)=col
      Next
   End If
   Set hits = DB.Search(Fields, FieldIDs, CscEvalMatchQuery, numberHits)

   For i = 0 To hits.Count-1
      If hits(i).Score>= minimimConfidence Then
         Set alt= results.Alternatives.Create()
         alt.Confidence=hits(i).Score
         If allColumns Then  'the column is "", so we return all fields
            For c = 0 To DB.FieldCount-1
               alt.SubFields.Create(DB.FieldName(c))
               alt.SubFields(c).Index=c
               alt.SubFields(c).Text=DB.GetRecordData(hits(i).RecID)(c)
               alt.SubFields(c).Confidence=hits(i).Score
            Next
            alt.Text=""
         Else
            alt.Text=DB.GetRecordData(hits(i).RecID)(col)
         End If
      End If
   Next
   Return results.Alternatives
End Function

```

