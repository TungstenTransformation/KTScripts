 '#Language "WWB-COM"
Option Explicit

Public Function DataBase_IsStringWithinColumn(dbname As String, column As String, searchString As String,Confidence As Double) As Boolean
   return Database_Search(dbname,"",searchString,5,Confidence).alternatives.count>0
End Function


Public Function DataBase_SearchString(dbname As String, column As String, searchString As String, ByRef Confidence As Double) As String
   'This returns the value in the chosen column based on the searchstring from the best search result.

   'the searchstring does not need to be in the column you want to retrieve. So you could return a first name based on a search for account number
   Dim results As CscXDocFieldAlternatives
   Set results = Database_Search(dbname, column, searchString, 2, Confidence)
   If results.Count = 0 Then
      DataBase_SearchString = ""
      Exit Function
   End If
   Dim a, besta As Integer
   Dim bestScore As Double
   bestScore = 0
   'We cannot assume that the first result is the best
   With results
      For a = 0 To .Count - 1
            'The database locator will return 100% for "ABCDE" when querying "ABC". We need to drop the score
            Dim ratio As Double
            ratio = Len(.ItemByIndex(a).Text) / Len(searchString)
            If ratio<1 Then .ItemByIndex(a).Confidence = .ItemByIndex(a).Confidence * ratio
         If .ItemByIndex(a).Confidence > bestScore Then
            besta = a
            bestScore = .ItemByIndex(a).Confidence
         End If
      Next
      Confidence = bestScore
      Return results(besta).Text
   End With
End Function

Public Function Database_FuzzyQueryLanguage(dbname As String, fuzzyQuery As String, numberHits As Integer, score As Double) As CscXDocField
   'a simple fuzzyQuery in any columns "Vienna", or "Vienna 1040"
   'a fuzzyQuery with conditions "City=Vienna&1040" or "City~Vienna&Zip~1040" to force searching in particular columns
   Dim query As String, searchString As String, columnName As String
   Dim a As Integer
   Dim results As CscXDocField
   'Parse the Query
   For Each query In Split(fuzzyQuery,"&")
      If InStr(query,"=") Then
         query=Split(query,"=")(1)
      ElseIf InStr(query,"~") Then
         query=Split(query,"~")(1)
      End If
      searchString=searchString & " " & query
   Next
   Set results=Database_Search(dbname,"",searchString,numberHits,score,True)
   If results.Alternatives.Count=0 Then Return results
   'Filter out unwanted results
   With results.Alternatives
      For Each query In Split(fuzzyQuery,"&")
         If InStr(query,"=") Then
            columnName=Split(query,"=")(0)
            query=Split(query,"=")(1)
            If Not .ItemByIndex(0).SubFields.Exists(columnName) Then Err.Raise 34588,,"Column '" & columnName & "' does not exist in database '" & dbname & "'."
            For a =.Count-1 To 0 Step -1
               If UCase(.ItemByIndex(a).SubFields.ItemByName(columnName).Text)<>UCase(query) Then .Remove(a)
            Next
         End If
         If results.Alternatives.Count=0 Then Return results
      Next
   End With
   Return results
End Function

'#Language "WWB-COM"
Option Explicit
' Project Script
Private Sub CountryNameFuzzy_FormatField(ByVal FieldText As String, FormattedText As String, ErrDescription As String, ValidFormat As Boolean)
   Dim Results As CscXDocFieldAlternatives
   If Len(FieldText) = 0 Then
      ValidFormat = False
      ErrDescription = "Field must not be empty"
      Exit Sub
   End If
   Set Results =Database_Search("Countries","",FieldText,5,0.7,True)' Find 5 country names that fuzzy match at least 70%
   If Results.Count=0 Then 'no matches better than 70%
      ErrDescription="'" & FieldText & "' doesn't look like a country name"
      ValidFormat = False
   ElseIf Results.Count=1 Then ' only one match and it is good
      FormattedText= Results(0).SubFields.ItemByName("Country").Text
      ValidFormat =True
   ElseIf Results(0).Confidence-Results(1).Confidence>0.15 Then ' one result is much better than others, so take it
      FormattedText= Results(0).Text
      ValidFormat =True
   Else 'two or more results are good
      ErrDescription="'" & Results(0).SubFields.ItemByName("Country").Text & "' or '" & Results(1).SubFields.ItemByName("Country").Text & "' could be correct"
      ValidFormat = False
   End If
End Sub

Public Function Database_Search(DBname As String, Column As String, SearchString As String, NumberHits As Long, MinimimConfidence As Double, Optional AllColumns As Boolean=False) As CscXDocFieldAlternatives
   'Searches inside a fuzzy database for the searchstring and returns the results in the alternatives of a new CSCField Object.
   'if column="" then all columns are returned as subfields, otherwise returns only the chosen column in the alternatives.
   'Set minimimConfidence=1.0 for exact match search.
   Dim DB As CscDatabase, Fields() As String,FieldIDs() As Long
   Dim Col As Long, C As Long, I As Long
   Dim Hits As CscDatabaseResItems, Alt As CscXDocFieldAlternative
   Dim Results As New CscXDocField  'You are allowed to create a standalone field
   Dim Value As String, Substitute As String
   Set DB=Project.Databases.ItemByName(DBname)
   ' Replace all delimiters by blank
   For I = 1 To Len(DB.AdditionalDelimiterChars)
      SearchString = Replace(SearchString, Mid(DB.AdditionalDelimiterChars, I, 1), " ")
   Next
   ' Replace all ignore characters by blank
   For I = 1 To Len(DB.RemoveChars)
      SearchString = Replace(SearchString, Mid(DB.RemoveChars, I , 1), " ")
   Next
   ' Substitution pairs define which texts to be replaced by what.
   For I = 0 To DB.SubstitutionPairCount - 1
      DB.GetSubstitutionPair(I, Value, Substitute)
      SearchString = Replace(SearchString, Value, Substitute)
   Next
   Fields = Split(SearchString, " ")
   ReDim FieldIDs(UBound(Fields))
   'Find the column we are looking for
   Col=-1
   For I =0 To DB.FieldCount-1
      If DB.FieldName(I)=Column Then Col=I
   Next
   If Col=-1 And Column<>"" Then Err.Raise 34589,,"Column '" & Column & "' does not exist in database '" & DBname & "'."
   If Col<>-1 Then 'Force query in this column
      For C=0 To UBound(FieldIDs)
         FieldIDs(C)=Col
      Next
   End If
   Set Hits = DB.Search(Fields, FieldIDs, CscEvalMatchQuery, NumberHits)
   For I = 0 To Hits.Count-1
      If Hits(I).Score>= MinimimConfidence Then
         Set Alt= Results.Alternatives.Create()
         Alt.Confidence=Hits(I).Score
         If AllColumns Then  'the column is "", so we return all fields
            For C = 0 To DB.FieldCount-1
               Alt.SubFields.Create(DB.FieldName(C))
               Alt.SubFields(C).Index=C
               Alt.SubFields(C).Text=DB.GetRecordData(Hits(I).RecID)(C)
               Alt.SubFields(C).Confidence=Hits(I).Score
            Next
            Alt.Text=""
         Else
            Alt.Text=DB.GetRecordData(Hits(I).RecID)(Col)
         End If
      End If
   Next
   Return Results.Alternatives
End Function

Public Sub Database_RefreshFromSQL(fuzzyDatabaseName As String, SQLDatabaseName As String, whereField As String, whereValue As String, dateFormatter As ICscFieldFormatter, Optional fuzzyDateFormat As String="MM/DD/YYYY")
   'This forces an updates of fuzzy database from an SQL database.
   'This is a workaround until Search & Match Server supports triggered updates
   Dim fuzzy As CscDatabase, sql As CscDatabase, f As Long, r As Long, textLine As String,delim As String
   Dim value As String, d As CscXDocField
 
   Dim table As CscSQLDataTable,query As CscSQLQuery, rs As CscSQLRecordset
   If Not Project.Databases.ItemExists(fuzzyDatabaseName) Then Err.Raise 4567,, "Database " & fuzzyDatabaseName & " doesn't exist!"
   If Not Project.Databases.ItemExists(SQLDatabaseName) Then Err.Raise 4567,, "Database " & fuzzyDatabaseName & " doesn't exist!"
   Set fuzzy=Project.Databases.ItemByName(fuzzyDatabaseName)
   If fuzzy.DatabaseType=CscDatabaseType.CscSQLType Then Err.Raise 4568,,"Database " & fuzzyDatabaseName & " should be fuzzy and not SQL!"
   Set sql=Project.Databases.ItemByName(SQLDatabaseName)
   If sql.DatabaseType<>CscDatabaseType.CscSQLType Then Err.Raise 4569,,"Database " & SQLDatabaseName & " should be SQL and not fuzzy!"
 
   'Build a SQL query that gets all the fuzzy databases fields
   Set table = sql.SQLTable
   Set query = table.CreateQuery()
   For f = 0 To fuzzy.FieldCount-1
      query.AddSelectField(table.FieldByName(fuzzy.FieldName(f)))
   Next
   If whereValue<>"" Then query.AddWhereField(table.FieldByName(whereField),CscEqual,whereValue)
   Open fuzzy.ImportFilename & ".new" For Output As #1
   delim=Left(fuzzy.DelimiterChars(),1)
   textLine=vbUTF8BOM
   For f = 0 To fuzzy.FieldCount-1
      textLine=textLine & fuzzy.FieldName(f) & delim
   Next
   Print #1, Left(textLine,Len(textLine)-1) ' trim last delim and write to database file
   Set rs=query.ExecuteQuery()
   textLine=""
   For r=0 To rs.RecordCount-1
      textLine=""
      For f = 0 To fuzzy.FieldCount-1
         value=rs.Rows(r).CellByName(fuzzy.FieldName(f)).Value
         If InStr(fuzzy.FieldName(f),"Date") Then
            Set d = New CscXDocField
            d.Text=value 'convert an SQL data string format of type, eg, "DD/MM/YYYY hh:mm" to, eg, "MM/DD/YYYY"
            dateFormatter.FormatField(d)
            If d.DateFormatted Then value=Format(d.DateValue,fuzzyDateFormat)
         End If
         textLine=textLine & value & delim
      Next
      Print #1, Left(textLine,Len(textLine)-1) ' trim last delim and write to database file
   Next
   Close #1
   Kill fuzzy.ImportFilename
   Name fuzzy.ImportFilename & ".new" As fuzzy.ImportFilename
   fuzzy.ImportDatabase(True)
End Sub


'=================================================================
Private Sub SL_OnDemandFuzzyDatabase_LocateAlternatives(ByVal pXDoc As CASCADELib.CscXDocument, ByVal pLocator As CASCADELib.CscXDocField)
   Dim DB As CscDatabase, DBname As String, Filename As String
   Randomize   'Seed Random number generator with current time
   DBname= Format(Rnd()*1e7,"0000000")&Format(Rnd()*1e7,"0000000") 'random 14 digit number
   Filename=Environ("TEMP") & "\" & DBname & ".txt"  
   Open Filename For Output As #1
   Print #1, vbUTF8BOM;   'Write the UTF-8 BOM so that the file is interpreted by KT as Unicode. Semicolon is important to suppress newline
   Print #1, "ContractNumber;FirstName;LastName;City"
   Print #1, "32409235;Laura;Wilson;London"
   Close #1
   Set DB=New CscDatabase
   DB.Name=DBname
   DB.DatabaseType=CscFUZZYLocalType
   DB.ImportFilename=Filename
   Project.Databases.Add(DB)
   DB.ImportDatabase(True)
   'Search the database for "32409235". Return max 3 results with fuzzy match score >=85%
   'Put the results into the script locator alternatives
   Database_Search(DBname,"","32409235",3,pLocator,0.85)
   'clean up the temp database files
   Project.Databases.RemoveByName(DBname)
   Kill DB.TextFilename
   Kill DB.DatabasePath
   Kill Filename
End Sub

Public Sub Database_Search(DBname As String, column As String, searchString As String, numberHits As Integer, ByRef results As CscXDocField, minimimConfidence As Double, Optional allColumns As Boolean=False)
   'Searches inside a fuzzy database for the searchstring and returns the results in the alternatives of a new CSCField Object.
   'if column="" then all columns are returned as subfields, otherwise returns only the chosen column in the alternatives.
   'Set minimimConfidence=1.0 for exact match search.
   Dim DB As CscDatabase, Fields() As String,FieldIDs() As Long
   Dim col As Integer,c As Integer,i As Integer
   Dim hits As CscDatabaseResItems, alt As CscXDocFieldAlternative
   Dim value As String, substitute As String
   Set DB=Project.Databases.ItemByName(DBname)
   ' Replace all delimiters by blank
   For i = 1 To Len(DB.AdditionalDelimiterChars)
      searchString = Replace(searchString, Mid(DB.AdditionalDelimiterChars, i, 1), " ")
   Next
   ' Replace all ignore characters by blank
   For i = 1 To Len(DB.RemoveChars)
      searchString = Replace(searchString, Mid(DB.RemoveChars, i , 1), " ")
   Next
   ' Substitution pairs define which texts to be replaced by what.
   For i = 0 To DB.SubstitutionPairCount - 1
      DB.GetSubstitutionPair(i, value, substitute)
      searchString = Replace(searchString, value, substitute)
   Next
   Fields = Split(searchString, " ")
   ReDim FieldIDs(UBound(Fields))
   'Find the column we are looking for
   col=-1
   For i =0 To DB.FieldCount-1
      If DB.FieldName(i)=column Then col=i
   Next
   If col=-1 And column<>"" Then Err.Raise 34589,,"Column '" & column & "' does not exist in database '" & DBname & "'."
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
End Function

