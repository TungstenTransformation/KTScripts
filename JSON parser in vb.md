Simple and fast JSON parser that converts a JSON file into a dictionary.   
**to do**:  improve this 
* better & simpler [regex](https://regex101.com/r/gtAJps/1) that conforms to [json.org](https://json.org). "(?:[^"\\]|\\.)*"|-?(?:\d+)(?:\.\d*)?(?:[eE][+\-]?\d+)?|(?<d>true|false|null)|[\[\]{}:,]  
* Handle embedded arrays and empty arrays/objects.
* Handle unicode codes.
* Correct number, boolean and null handling.
* Support both json path and dictionary embedding for simpler usage and iteration.


Adapted from [[StackOverflow article](https://stackoverflow.com/questions/6627652/parsing-json-in-excel-vba)] [[description by the original Author](https://medium.com/swlh/excel-vba-parse-json-easily-c2213f4d8e7a)].   
The parser uses a single complex but fast regex to completely tokenize the JSON file, stripping out all structural whitespace and double quotes around strings.  It then uses select statements and recursion to parse objects and arrays. It creates a unique key for every element in the JSON and adds it to a dictionary.  
```json
{"status":"succeeded","createdDateTime":"2023-08-07T13:53:55Z","analyzeResult":{"modelId":"prebuilt-document"}}
```
becomes
|key|value|
|---|-----|
|js.status|succeeded|
|js.createdDateTime|2023-08-07T13:53:55Z|
|js.analyzeResult.modelId|prebuilt-document|
|js.analyzeResult.modelId.pages(0).words(43).content|address|
|js.analyzeResult.modelId.pages(0).words._count|245 *(this is a Long, not a String)*|

*Note that the parser leaves everything as strings. It is your responsibility to convert to number, boolean and null.*
## new features
* Added Unescape function for strings
* the dictionary now contains a **_count** key for every array that contains the length of the array as a long. useful for looping over arrays.  For Example:  
```vb
For P=0 To JS("js.analyzeResult.pages._count")-1
```
```vb
'-------------------------------------------------------------------
' VBA JSON Parser https://github.com/KofaxTransformation/KTScripts/blob/master/JSON%20parser%20in%20vb.md
'-------------------------------------------------------------------
Private t As Long, tokens() As String, dic As Object
Function JSON_Parse(JSON$, Optional Key$ = "js") As Object
    t = 1
    tokens = JSON_Tokenize(JSON)
    Set dic = CreateObject("Scripting.Dictionary")
    If tokens(t) = "{" Then JSON_ParseObj(Key) Else JSON_ParseArr(Key)
    Return dic
End Function
Function JSON_ParseObj(Key$)
    Do
      t = t + 1
     Select Case tokens(t)
         Case "]"
         Case "[":  JSON_ParseArr(Key)
         Case "{"
                    If tokens(t + 1) = "}" Then
                        t = t + 1
                        dic.Add(Key, "null")
                    Else
                        JSON_ParseObj(Key)
                    End If

         Case "}":  Key = JSON_ParentPath(Key): Exit Do
         Case ":":  Key = Key & "." & tokens(t - 1) 'previous token was a key - remember it
         Case ",":  Key = JSON_ParentPath(Key)
         Case Else 'we are in a string. if next is not ":" then we are value - so add to dict!
            If tokens(t + 1) <> ":" Then dic.Add(Key, tokens(t))
     End Select
    Loop
End Function
Function JSON_ParseArr(Key$)
   Dim A As Long
   Do
      t = t + 1
      Select Case tokens(t)
         Case "}"
         Case "{":  JSON_ParseObj(Key & JSON_ArrayID(A))
         Case "[":  JSON_ParseArr(Key)
         Case "]":  Exit Do
         Case ":":  Key = Key & JSON_ArrayID(A)
         Case ",":  A = A + 1
         Case Else: dic.Add(Key & JSON_ArrayID(A), tokens(t))
      End Select
   Loop
   dic.Add(Key & "._count",A+1) 'store array length in dictionary
End Function

Function JSON_Tokenize(S As String) 'completely split the JSON string fast into an array of tokens for the parsers
   Dim C As Long, m As Object, n As Object, tokens() As String
   Const Pattern = """(([^""\\]|\\.)*)""|[+\-]?(?:0|[1-9]\d*)(?:\.\d*)?(?:[eE][+\-]?\d+)?|\w+|[^\s""']+?"
   With CreateObject("vbscript.regexp")
      .Global = True
      .Multiline = False
      .IgnoreCase = True
      .Pattern = Pattern
      Set m = .Execute(S)
      ReDim tokens(1 To m.Count)
      For Each n In m
        C = C + 1
        tokens(C) = n.Value
        If True Then ' bGroup1Bias=?? when is this needed
           If Len(n.SubMatches(0)) Or n.Value = """""" Then
              tokens(C) = n.SubMatches(0)
           End If
        End If
      Next
  End With
  Return tokens
End Function

Function JSON_ArrayID(e) As String
    Return "(" & e & ")"
End Function

Function JSON_ParentPath(Key As String) As String 'go to the parent key
    If InStr(Key, ".") Then Return Left(Key, InStrRev(Key, ".") - 1)
    'else?
End Function

Public Function JSON_Unescape(A As String) As String
   'https://www.json.org/json-en.html
   A=Replace(A,"\""","""") 'double quote
   A=Replace(A,"\\","\") 'backslash
   A=Replace(A,"\/","/") 'forward slash
   A=Replace(A,"\b","") 'backspace
   A=Replace(A,"\f","") 'form feed
   A=Replace(A,"\n","") 'new line
   A=Replace(A,"\r","") 'carraige return
   A=Replace(A,"\t","") 'tab
   Return A
End Function
```
