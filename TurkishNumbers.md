# Turkish Numbers
This script Field Formatter converts any number from 1 to 999,000,000,000,000,000 into Turkish words. This is useful for validating amounts on Turkish money transfers.  
![image](https://user-images.githubusercontent.com/47416964/112871877-01029880-90c0-11eb-922d-3fc1ecf51188.png)  
In the **Document_BeforeLocate** event of a format locator, you can run this on the output of a previous locator and insert the Turkish string dynamically into the Levensthein format, which will then fuzzy-search for the number on the document.


```vb
'#Language "WWB-COM"
Option Explicit

' Project Script

Private Sub TurkishNumbers_FormatDoubleField(ByVal FieldText As String, FormattedText As String, ErrDescription As String, ValidFormat As Boolean, ByRef DoubleVal As Double, ByRef DoubleFormatted As Boolean)
   'This converts a number from 1 to 999,000,000,000,000,000 into Turkish words.
   '    1->"bir"
   '    30454->otuzbindörtyüzellidört

   'Add reference to Microsoft Scripting Runtime for Dictionary object
   Dim P As Long, Field As New CscXDocField, Group As String, Order As String, parts() As String, Dict As New Dictionary
   Dim Digit As String, Tens As String, Hundreds As String
   Field.Text=FieldText
   'Check that the number is a valid number - no OCR errors, etc
   'Make sure your DefaultAmountFormatter has "requires decimal point"=false
   ValidFormat=DefaultAmountFormatter.FormatField(Field)
   If Not ValidFormat Then
      ErrDescription=Field.ErrorDescription
      Exit Sub
   End If
   If Len(FieldText)=0 Then
      ErrDescription="field cannot be empty"
      ValidFormat=False
      Exit Sub
   End If

   DoubleVal=Field.DoubleValue
   DoubleFormatted=Field.DoubleFormatted
   'Start with the number that the Number Formatter found
   FieldText=Format(Field.DoubleValue,"000")
   If Len(FieldText)>18 Then
      ErrDescription="number is too long to convert"
      ValidFormat=False
      Exit Sub
   End If
   While Len(FieldText) Mod 3<>0
      FieldText="0" & FieldText ' pad number to 3 zeros
   Wend
   FormattedText=""
   'Build a dictionary to convert each number into Turkish
   For Each Digit In Split("0-sıfır 1-bir 2-iki 3-üç 4-dört 5-beş 6-altı 7-yedi 8-sekiz 9-dokuz 10-on 20-yirmi 30-otuz 40-kırk 50-elli 60-altmış 70-yetmiş 80-seksen 90-doksan 100-yüz 1000-bin 1000000-milyon 1000000000-milyar 1000000000000-trilyon 1000000000000000-katrilyon")
      parts=Split(Digit,"-")
      Dict.Add(parts(0),parts(1))
   Next

   'Loop through each group of three digits
   For P= Len(FieldText)-2 To 1 Step -3
      Group=Mid(FieldText,P,3) ' group of 3 digits
      Digit=Right(Group,1)
      Tens=Mid(Group,2,1)
      Hundreds=Left(Group,1)
      Order="1" & Replace(Space(((Len(FieldText)-P-1) \3) *3)," ","0") ' 1, 1000, 1000000, 1000000000, 1000000000000, 1000000000000000, 1000000000000000000
      If (Order<>"1" And Group<>"000")Then FormattedText=Dict(Order) & FormattedText  'bin, milyon, milyar
      Select Case Digit
         Case "0"  'ignore sıfır
         Case "1"
            If Order="1" Or Tens & Hundreds <>"00" Then FormattedText=Dict(Digit) & FormattedText 'bir    prevents "birbin"
         Case Else
            FormattedText=Dict(Digit) & FormattedText 'iki...dokuz
      End Select
      If Tens<>"0" Then FormattedText=Dict(Tens & "0") & FormattedText ' on...doksan
      Select Case Hundreds
         Case "0"
         Case "1"
            FormattedText=Dict("100") & FormattedText 'yüz.    prevents "biryüz"
         Case Else
            FormattedText=Dict(Hundreds) & Dict("100") & FormattedText  'ikiyüz...dokuzyüz
      End Select
   Next
End Sub
```
