Simple and fast JSON parser that converts a JSON file into a hierarchical dictionary and array object.  
### Jan 2024
* rewritten JSON parser with a better & simpler [regular expression](https://regex101.com/r/gtAJps/1) that conforms 100% to [json.org](https://json.org).  
* handles embedded arrays and objects. Empty arrays/objects will give .count=0.
* converts numbers and booleans into Long, Double and true or false and null into Nothing.
* handles unicode characters and \uXXXX encoding.
* builds a dictionary and array structure for easy VB6 reading.

Adapted from [[StackOverflow article](https://stackoverflow.com/questions/6627652/parsing-json-in-excel-vba)] [[description by the original Author](https://medium.com/swlh/excel-vba-parse-json-easily-c2213f4d8e7a)].   
The parser uses a single complex but fast regex to completely tokenize the JSON file.  It then reads the tokens and recurses to build the object structure into dictionaries and SortedLists. 
```json
{"status":"succeeded","createdDateTime":"2023-08-07T13:53:55Z","analyzeResult":{"modelId":"prebuilt-document"}}
```
becomes
|vb6|value|
|---|-----|
|js("status")|succeeded|
|js("analyzeResult")("modelId")|prebuilt-document|
|js("analyzeResult")("modelId")("pages")(0)("words")(43)("content")|address|
|js("analyzeResult")("modelId")("pages")(0)("words").count|245 *(this is a Long, not a String)*|

```vb
'-------------------------------------------------------------------
' VBA JSON Parser https://github.com/KofaxTransformation/KTScripts/blob/master/JSON%20parser%20in%20vb.md
'-------------------------------------------------------------------
Private T As Long, Tokens As Object
Function JSON_Parse(JSON As String, Optional Key As String = "$") As Object
   'This is 100% compliant with ECMA-404 JSON Data Interchange Standard at https://www.json.org/json-en.html
   'the regex pattern finds strings including characters escaped with \ OR numbers OR true/false/null OR \\{}:,[]
   'tested at https://regex101.com/r/YkiVdc/1
   'This script will crash on invalid JSON
   With CreateObject("vbscript.regexp")
      .Global=True
      .Pattern = """(?:[^""\\]|\\.)*""|-?(?:\d+)(?:\.\d*)?(?:[eE][+\-]?\d+)?|(?:true|false|null)|[\[\]{}:,]"
      Set tokens=.Execute(JSON)
   End With
   T=0
   Select Case Tokens(0)
      Case "{"  : Return JSON_ParseObject()
      Case "["  : Return JSON_ParseArray()
      Case Else : Return JSON_Value(tokens(0))  'Yes a JSON may contain just 1 value
   End Select
End Function

Function JSON_ParseObject() As Object
   Dim Obj As Object, n As String 'Objects contained named objects, arrays or values
   Set Obj = CreateObject("Scripting.Dictionary")
   If tokens(t+1)="}" Then  T=T+2 : Return Obj ' empty object
   Do
      T = t + 1
      Select Case tokens(t).Value
         Case "{"  :  Obj.Add(n,JSON_ParseObject())
         Case "["  :  Obj.Add(n,JSON_ParseArray())
         Case ":"  :  n = JSON_Value(tokens(t-1))
         Case ","
         Case "}"  :  Return Obj
         Case Else : If tokens(t - 1) = ":" Then Obj.Add(n, JSON_Value(tokens(t)))
      End Select
   Loop
End Function

Function JSON_ParseArray()
   Dim A As Object 'Declare A as an array of anything - it may contain strings, booleans, numbers, objects and arrays
   Set A=CreateObject("System.Collections.Sortedlist")
   If tokens(t+1)="]" Then : T=T+2 : Return A ' empty array
   Do
      T = t + 1
      Select Case tokens(t)
         Case "{"  : A.Add(A.Count,JSON_ParseObject()) 'it's an object so recurse
         Case "["  : A.Add(A.Count,JSON_ParseArray()) 'start of an array inside an array
         Case ","  :
         Case "]"  : Return A
         Case Else : A.Add(A.Count,JSON_Value(tokens(t)))
      End Select
   Loop
End Function

Function JSON_Value(Value As String) 'JSON values can be string, number, true, false or null
   'Strings start with a " in JSON - everything else is true,false, null or a number
   If Left (Value,1)="""" Then Return JSON_Unescape(Mid(Value,2,Len(Value)-2)) 'strip " from begin and end of string
   Select Case Value
      Case "true"  : Return True
      Case "false" : Return False
      Case "null"  : Return Nothing
      Case Else 'it has to be a number
         Dim Locale As Long, Number As Double
         Locale=GetLocale() 'preserve locale
         SetLocale(1033) 'en_us
         'these are valid JSON numbers: 1 -1 0 -0.1 1111111111 0.1 1.0000 1.0e5 -1e-5 1E5 0e3 0e-3
         'these are invalid JSON numbers, but CDbl converts them correctly: +1 .6 1.e5 -.5 e6
         Number=CDbl(Value) 'CDbl() function luckily correctly converts all allowed JSON number formats
         SetLocale(Locale)
         Return Number
   End Select
End Function

Public Function JSON_Unescape(A As String) As String
   'https://www.json.org/json-en.html
   Dim Hex As String
   A=Replace(A,"\""","""") 'double quote
   A=Replace(A,"\/","/") 'forward slash
   A=Replace(A,"\b",vbBack) 'backspace
   A=Replace(A,"\f",vbLf) 'form feed
   A=Replace(A,"\n",vbCrLf) 'new line
   A=Replace(A,"\r",vbCr) 'carraige return
   A=Replace(A,"\t",vbTab) 'tab
   A=Replace(A,"\\","\") 'backslash
   While InStr(A,"\u")  'hex encoded Unicode characters
      Hex=Mid(A,InStr(A,"\u")+2,4)
      A=Replace(A,"\u" & Hex, ChrW(Val("&H" & Hex)))
   Wend
   Return A
End Function```
