# Formatting and Validating IBANs in kofax Transformation.

An IBAN is made up of [3 parts](https://en.wikipedia.org/wiki/International_Bank_Account_Number#Structure)  
* 2 character Country Code
* 2 digit Checksum
* Basic Bank Account Number (BBAN) up to 30 digits. It typically contains Bank Number, Branch Number, Account Number and Routing information.

In Kofax Transformation we need to **extract**, **format** and **validate** IBANs.
## Extraction
* **Format Locators** use Regular expressions, but they can fail due to OCR errors.
* **Database Locators** can use fuzzy database containing IBAN and also account owner, bank name, etc is very helpful as it can fuzzy match the document. This works well and fast for even 20 million records
* **Table Locators** can also find IBANS

## Formatting & Validating
Create a script field formatter called **IBAN** and validation rule called **IBAN** with the following script.

```vb
'IBAN VALIDATION
'#Language "WWB-COM" setting
Option Explicit

' Project Script

Private Sub IBAN_FormatField(ByVal FieldText As String, FormattedText As String, ErrDescription As String, ValidFormat As Boolean)
   'Script Formatter
   If Len(FieldText) = 0 Then
      ValidFormat = False
      ErrDescription = "IBAN may not be empty"
      Exit Sub
   End If
   'Remove spaces and dashes
   FormattedText = Replace(FieldText," ","")
   FormattedText = Replace(FormattedText,"-","")
   'Capitalize
   FormattedText = UCase(FormattedText)
   ValidFormat=IBAN_Test(FormattedText,ErrDescription)
End Sub

Private Sub IBAN_Validate(ByVal pValItem As CASCADELib.ICscXDocValidationItem, ByRef ErrDescription As String, ByRef ValidField As Boolean)
   'Script Validation Rule
   pValItem.Text=Replace(pValItem.Text," ","") ' remove spaces
   ValidField=IBAN_Test(pValItem.Text,ErrDescription)
End Sub

Private Function IBAN_Test(IBAN As String, ByRef ErrDescription As String) As Boolean
   Dim CountryCode As String, BBAN As String, CheckDigits As String
   If Len(IBAN)<15 Then
      ErrDescription="An IBAN must have at least 15 digits"
      Return False
   End If
   If Not IBAN_CheckFormat(IBAN) Then
      ErrDescription ="This does not look like an IBAN"
      Return False
   End If
   CountryCode=Left(IBAN,2)
   If Not IBAN_CheckLength(IBAN) Then
       ErrDescription="IBAN has wrong length for country " + CountryCode
       Return False
   End If
   CheckDigits=Mid(IBAN,3,2)
   BBAN=Mid(IBAN,5,50)
   If CheckDigits<>IBAN_CalculateCheckDigits(CountryCode,BBAN,ErrDescription) Then
      ErrDescription="IBAN has invalid check digits " + CheckDigits
      Return False
   End If
   Return True 'Passed all IBAN tests
End Function

Private Function IBAN_CheckFormat(IBAN As String) As Boolean
   'https://en.wikipedia.org/wiki/International_Bank_Account_Number#Structure
   'http://stackoverflow.com/questions/15943037/vbscript-validate-iban-with-mod97-number-is-too-big
   Dim Regex As Object
   Set Regex = CreateObject("vbscript.regexp")
   Regex.IgnoreCase = True
   Regex.Global = True
   Regex.Pattern = "[A-Z]{2}[0-9]{2}[0-9A-Z]{11,27}"
   Return Regex.Test(IBAN)
End Function

Private Function IBAN_CheckLength(IBAN As String) As Boolean
   'Each country has it's own different length for an IBAN
   'https://en.wikipedia.org/wiki/International_Bank_Account_Number#IBAN_formats_by_country
   Const IbanCountryLengths As String = "AL28AD24AT20AZ28BA20BH22BE16BA20BG22BR29BY28CR22HR21CY28CZ24DK18DO28EE20EG29FO18" & _
                                        "FI18FR27GE22DE22GI23GR27GL18GT28HR21HU28IS26IE22IL23IT27KZ20KW30LV21LB28" & _
                                        "LI21LT20LU20MK19MT31MR27MU30MC27MD24ME22NL18NO15PK24PS29PL28PT25RO24" & _
                                        "SM27SA24RS22SK24SI19ES24SE24CH21TL23TN24TR26AE23GB22VG24QA29"
    Dim I As Long, Length As Long, CountryCode As String
    Length=Len(IBAN)
    If Length<15 Then Return False
    CountryCode=Left(IBAN,2)
    For I = 0 To Len(IbanCountryLengths) / 4 - 1
        If Mid(IbanCountryLengths, I * 4 + 1, 2) = CountryCode Then
            Return CLng(Mid(IbanCountryLengths, I * 4 + 3, 2)) = Length
        End If
    Next
    Return False  'change this to true of you want to accept any length from an unknown country
End Function

Private Function IBAN_CalculateCheckDigits(Country As String, BBAN As String, ByRef ErrDescription As String) As String
   'This is the algorithm that is used to calculate the checkdigits, not to validate them
   'https://en.wikipedia.org/wiki/International_Bank_Account_Number#Generating_IBAN_check_digits
   Const key As String = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"
   Dim IBAN As String, C As Long, Sum As String, CH As String,V As Long
   IBAN=BBAN & Country & "00"
   For C =1 To Len(IBAN)
      CH=Mid(IBAN,C,1)
      V= InStr(key,CH)-1
      If V<0 Then ErrDescription= "invalid character " & CH & " in IBAN" : Return "??"
      Sum = Sum & CStr(V)
   Next
   Return Format(98-String_Mod(Sum,97),"00")' pad the modulus to two digits
End Function
```
