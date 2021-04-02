# Calling a Webservice via script
This script can be used to return text, HTML, XML or JSON from a webservice.
```vb
Public Function HTTP_GET(URL As String) As String
   'Add reference to Microsoft XML 6.0 in Edit\References... Menu
   Dim HTTP As New MSXML2.XMLHTTP60
   HTTP.Open("GET", URL, False) 'false = synchronous = wait for response, don't continue
   HTTP.send
   If HTTP.status<>200 Then
      'TODO error handling
   Else
      HTTP_GET=HTTP.responseText
   End If
End Function
```
