# UK VAT Lookup
This uses a UK government [webservice](https://developer.service.hmrc.gov.uk/api-documentation/docs/api/service/vat-registered-companies-api/1.0#_get-a-vat-registration_get_accordion) to check a VAT Number. It may not work outside of the UK without a login.

```vb
'#Language "WWB-COM"
Option Explicit

' Class script: Invoice
Private Sub SL_VAT_UK_LocateAlternatives(ByVal pXDoc As CASCADELib.CscXDocument, ByVal pLocator As CASCADELib.CscXDocField)
   'Returns details of a UK VAT Number from the free webservice at https://api.service.hmrc.gov.uk
   Dim URL As String, VAT As String, Key As String, JSON As String, Alt As CscXDocFieldAlternative
   'With pXDoc.Locators.ItemByName("FL_VAT").Alternatives
   '   If .Count=0 Then Exit Sub
   '   VAT=.ItemByIndex(0).Text
   'End With
   VAT = "553557881" ' This is for testing. You should retrieve this VAT from another locator.
   URL ="https://api.service.hmrc.gov.uk//organisations/VAT/check-VAT-number/lookup/"
   JSON=HTTP_GET(URL & VAT)
   Set Alt=pLocator.Alternatives.Create
   Alt.Confidence = 1.0
   For Each Key In Split("name vatNumber line1 line2 postcode countryCode")
      With Alt.SubFields.Create(Key)
         .Confidence =1.0 'we trust the results of the webservice
         .Text = JSON_getValue(JSON,Key)
      End With
   Next
End Sub

Private Function JSON_getValue(JSON As String, Key As String)
   'Add a reference to Microsoft VBScript Regular Expressions 5.5 in the Edit\References... Menu
   'This returns a value from a JSON given the key. It does not work on arrays!
   'no check here for invalid JSON
   Dim Regex As New RegExp, Match As Match, Matches As MatchCollection
   Regex.IgnoreCase = True
   Regex.Global = True
   Regex.Pattern = """" & Key & """\s*:\s*""(.*?)"""
   Set Matches=Regex.Execute(JSON)
   For Each Match In Matches
      Return Match.SubMatches(0) 'no check here for failure
   Next
End Function

Public Function HTTP_GET(URL As String) As String
   'Add reference to Microsoft XML 6.0 in Edit\References... Menu
   Dim XMLHTTP As New MSXML2.XMLHTTP60
   XMLHTTP.Open("GET", URL,False)
   XMLHTTP.send
   If XMLHTTP.status<>200 Then
      'TODO error handling
   Else
      Return XMLHTTP.responseText
   End If
End Function
```
