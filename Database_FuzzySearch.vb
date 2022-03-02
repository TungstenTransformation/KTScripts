Public Function Database_FuzzySearch(dbname As String, column As String, Searchstring As String, numberHits As Integer, minimimConfidence As Double, Results As CSCXDocFieldAlternatives, Optional allColumns As Boolean=False)
   'Searches inside a fuzzy database for the searchstring and stores the results in the Alternatives of the existing Results object 
   'Call this script from a Script locator and pass pLocator.Alternatives as the 6th parameter
   'if column="" then all columns are returned as subfields, otherwise returns only the chosen column in the alternatives.
   'Set minimimConfidence=1.0 for exact match search.
   Dim DB As CscDatabase, Fields() As String,FieldIDs() As Long
   Dim col As Integer,c As Integer,i As Integer
   Dim hits As CscDatabaseResItems, alt As CscXDocFieldAlternative
   Dim value As String, substitute As String
   If Searchstring="" Then Exit Function
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
         Set alt= results.Create()
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
