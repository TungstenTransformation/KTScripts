# Formatting and Validating UK VAT numbers
based on https://library.croneri.co.uk/cch_uk/bvr/43-600

* Paste the script into the project level Script
* Add a Script Field Formatter named **UKVAT** to the project

*This script is written in such a way that it can be called by either a Field Formatter or A singlefield Validation Rule.*  
It tests both the "old" and the "new" algorithm and succeeds if either of them succeed.

```vb
Private Sub UKVAT_FormatField(ByVal FieldText As String, FormattedText As String, ErrDescription As String, ValidFormat As Boolean)
   FormattedText = Replace(FieldText, "-", "") 'remove dashes
   FormattedText=Replace(FormattedText,"GB","") 'VAT number may start with "GB"
   FormattedText = Replace(FormattedText, " ", "") ' remove spaces
   FormattedText = Replace(FormattedText, ".", "")
   ValidFormat = UKVAT_Check(FormattedText,ErrDescription)
End Sub

Function UKVAT_Check(VAT As String, ByRef ErrDescription) As Boolean
   'This checks if the UK VAT number has a valid checksum
   'https://library.croneri.co.uk/cch_uk/bvr/43-600
   Const key As String = "0123456789"
   Dim C As Long, Sum As Long, CH As String, CheckSum As String, Minus As Long
   If Len(VAT)<>9 Then ErrDescription = "UK VAT is always 9 digits" : Return False
   If Left(VAT,1)="0" Then ErrDescription = "UK VAT cannot start with 0" : Return False
   For Minus =0 To 55 Step 55 ' we have to test the older "0" algorithm and the newer "55" algorithm
      Sum=Minus
      For C = 1 To 7 ' loop through the first 7 characters
         CH=Mid(VAT,C,1)
         If InStr(key,CH)<0 Then ErrDescription= "invalid character " & CH & " in UK VAT" : Return False
         Sum = Sum + CLng(CH)* (9-C)
      Next
      Sum =Sum Mod 97
      If Sum>0 Then Sum=Abs(Sum-97)
      CheckSum=Format(Sum,"00")' pad the modulus to two digits
      If CheckSum= Right(VAT,2) Then Return True
   Next
   ErrDescription= "The checksum (" & CheckSum & ") does not match the last two digits (" & Right(VAT,2) & ")  of the number."
End Function
```
