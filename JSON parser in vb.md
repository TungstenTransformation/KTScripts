Simple and fast JSON parser that converts a JSON file into a dictionary.  
[source](https://stackoverflow.com/questions/6627652/parsing-json-in-excel-vba)  
[description](https://medium.com/swlh/excel-vba-parse-json-easily-c2213f4d8e7a)

```vb
'-------------------------------------------------------------------
' VBA JSON Parser
'-------------------------------------------------------------------
Option Explicit
Private p&, token, dic
Function ParseJSON(json$, Optional key$ = "obj") As Object
    p = 1
    token = Tokenize(json)
    Set dic = CreateObject("Scripting.Dictionary")
    If token(p) = "{" Then ParseObj key Else ParseArr key
    Set ParseJSON = dic
End Function
Function ParseObj(key$)
    Do: p = p + 1
        Select Case token(p)
            Case "]"
            Case "[":  ParseArr key
            Case "{"
                       If token(p + 1) = "}" Then
                           p = p + 1
                           dic.Add key, "null"
                       Else
                           ParseObj key
                       End If
            
            Case "}":  key = ReducePath(key): Exit Do
            Case ":":  key = key & "." & token(p - 1)
            Case ",":  key = ReducePath(key)
            Case Else: If token(p + 1) <> ":" Then dic.Add key, token(p)
        End Select
    Loop
End Function
Function ParseArr(key$)
    Dim e&
    Do: p = p + 1
        Select Case token(p)
            Case "}"
            Case "{":  ParseObj key & ArrayID(e)
            Case "[":  ParseArr key
            Case "]":  Exit Do
            Case ":":  key = key & ArrayID(e)
            Case ",":  e = e + 1
            Case Else: dic.Add key & ArrayID(e), token(p)
        End Select
    Loop
End Function
'-------------------------------------------------------------------
' Support Functions
'-------------------------------------------------------------------
Function Tokenize(s$)
    Const Pattern = """(([^""\\]|\\.)*)""|[+\-]?(?:0|[1-9]\d*)(?:\.\d*)?(?:[eE][+\-]?\d+)?|\w+|[^\s""']+?"
    Tokenize = RExtract(s, Pattern, True)
End Function
Function RExtract(s$, Pattern, Optional bGroup1Bias As Boolean, Optional bGlobal As Boolean = True)
  Dim c&, m, n, v
  With CreateObject("vbscript.regexp")
    .Global = bGlobal
    .MultiLine = False
    .IgnoreCase = True
    .Pattern = Pattern
    If .TEST(s) Then
      Set m = .Execute(s)
      ReDim v(1 To m.Count)
      For Each n In m
        c = c + 1
        v(c) = n.value
        If bGroup1Bias Then If Len(n.submatches(0)) Or n.value = """""" Then v(c) = n.submatches(0)
      Next
    End If
  End With
  RExtract = v
End Function
Function ArrayID$(e)
    ArrayID = "(" & e & ")"
End Function
Function ReducePath$(key$)
    If InStr(key, ".") Then ReducePath = Left(key, InStrRev(key, ".") - 1)
End Function
Function ListPaths(dic)
    Dim s$, v
    For Each v In dic
        s = s & v & " --> " & dic(v) & vbLf
    Next
    Debug.Print s
End Function
Function GetFilteredValues(dic, match)
    Dim c&, i&, v, w
    v = dic.keys
    ReDim w(1 To dic.Count)
    For i = 0 To UBound(v)
        If v(i) Like match Then
            c = c + 1
            w(c) = dic(v(i))
        End If
    Next
    ReDim Preserve w(1 To c)
    GetFilteredValues = w
End Function
Function GetFilteredTable(dic, cols)
    Dim c&, i&, j&, v, w, z
    v = dic.keys
    z = GetFilteredValues(dic, cols(0))
    ReDim w(1 To UBound(z), 1 To UBound(cols) + 1)
    For j = 1 To UBound(cols) + 1
         z = GetFilteredValues(dic, cols(j - 1))
         For i = 1 To UBound(z)
            w(i, j) = z(i)
         Next
    Next
    GetFilteredTable = w
End Function
Function OpenTextFile$(f)
    With CreateObject("ADODB.Stream")
        .Charset = "utf-8"
        .Open
        .LoadFromFile f
        OpenTextFile = .ReadText
    End With
End Function
```
