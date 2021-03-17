' Note that there are two dictionary search functions Search and SearchExpanded. This example is very basic. 
' See https://github.com/KofaxRPA/KTScripts/blob/master/Database_Search.vb for how to retrieve all results.

Private Function Dictionary_Search(DictName As String, SearchValue As String) As String
  'return the first result of a dictionary search.
   Dim Dict As CscDictionary, Results As CscDictionaryResItems
   Set Dict=Project.Dictionaries.ItemByName(DictName)
   Set Results=Dict.Search(SearchValue,CscEvalMatchBoth,1)
   If Results.Count=0 Then Return ""
   Dim part1 As String, part2 As String
   Dict.GetRecordData(Results(0).RecID,part1,part2)
   'Check if the dictionary has substitutions
   If part2<>"" Then Return part2 Else Return part1
End Function
