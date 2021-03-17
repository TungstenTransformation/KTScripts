Private Function String_RegexSearch(txt As String, pattern As String,byRef results() As String) as Long
   'This function is the simplest way to split strings
   'Add refence to "Microsoft VBScript Regular Expressions 5.5"
   'Returns as an array of regex matches and the number of result-sets found, however only the first result-set is returned
   'e.g. Searching for pattern "(\d).(\d)(\d+)" in text "4/5460" will return "4","5","460"
   'Failed searches will return an empty array and zero
   Dim regex As VBScript_RegExp_55.IRegExp2
   Dim matches As VBScript_RegExp_55.IMatchCollection2
   Dim a As Long
   Set regex = New VBScript_RegExp_55.RegExp
   regex.Pattern=pattern
   Set matches = regex.Execute(txt)
   If matches.Count>0 Then
      With matches(0)
         ReDim results(.SubMatches.Count)
         For a = 0 To .SubMatches.Count-1
            results(a)=.SubMatches(a)
         Next
      End With
   End If
   Return matches.count
End Function
