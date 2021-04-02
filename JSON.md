# Reading JSON in script
VB Scipt has no inbuilt support for JSON. The following code is very simple and reads values out of a JSON without concerning itself with the structure.

```vb
Private Function JSON_getValue(JSON As String, Key As String, Optional Index as Long=0)
   'Add a reference to Microsoft VBScript Regular Expressions 5.5 in the Edit\References... Menu
  'This returns a value from a JSON given the key.for the third element in an array set index=2
   Dim Regex As New RegExp, Match As Match
   Regex.IgnoreCase = True
   Regex.Global = True
   Regex.Pattern = """" & Key & """\s*:\s*""(.*?)"""
   For Each Match In Regex.Execute(JSON)
  Return Match.SubMatches(Index) 'no check here for failure
   Next
  Return "" 'if nothing found or invalid JSON.
End Function
```
