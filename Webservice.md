# Calling a Webservice via script
This script can be used to return text, HTML, XML or JSON from a webservice.
```vb
Public Function HTTP_GET(URL As String) As String
   'Add reference to Microsoft XML 6.0 in Edit\References... Menu
   Dim XMLHTTP As New MSXML2.XMLHTTP60
   XMLHTTP.Open("GET", URL, False) 'false = synchronous = wait for response, don't continue
   XMLHTTP.send
   If XMLHTTP.status<>200 Then
      'TODO error handling
   Else
      HTTP_GET=XMLHTTP.responseText
   End If
End Function
```
