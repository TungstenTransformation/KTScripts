# Custom Field Formatters
A good custom Field Formatter uses the standard field formatters instead of trying to replace them. When formatting amounts or dates, use the Default Amount Formatter or Default Date Formatter  - they are very powerful and robust. This example shows how to *extend* the default formatters to make them do more. 

You can use this script to correct OCR errors in amounts before running the DefaultAmountFormatter. 

## Custom Amount Formatter
This example deals with numbers that contain "D" after the number to mark "debit". The "D" will be removed and a "-" will be added before the number, and then it calls the default amount formatter.  
![image](https://user-images.githubusercontent.com/47416964/87158143-8ee2ed00-c2bf-11ea-977b-9974abd9729b.png)

This example also converts any "B" in an number to an "8", and any "S" into a "5", correcting typical OCR errors.

1. Make a **Custom Script Formatter**  
![image](https://user-images.githubusercontent.com/47416964/87157009-dff1e180-c2bd-11ea-9837-e68d7fa39285.png)
1. Select the Field data Type as **Double / Amount**    
![image](https://user-images.githubusercontent.com/47416964/87157793-10864b00-c2bf-11ea-8a64-6e309620b127.png)
1. Click **Show Script..**
1. Add the following script to the Project Level Script
```vb
Private Sub NumberDebit_FormatDoubleField(ByVal FieldText As String, FormattedText As String, ErrDescription As String, ValidFormat As Boolean, ByRef DoubleVal As Double, ByRef DoubleFormatted As Boolean)
   Dim Field As New CscXDocField
   If Len(FieldText) = 0 Then
      ValidFormat = False
      ErrDescription = "Field must not be empty"
      Exit Sub
   End If
   Field.Text=FieldText
   If Right(FieldText,1)="D" Then Field.Text="-"& Left(FieldText,Len(FieldText)-1) ' Replace final "D" with initial "-"
   FieldText=Replace(FieldText,"B","8")
   FieldText=Replace(FieldText,"S","5")
   Project.FieldFormatters.ItemByName(Project.DefaultAmountFormatter).FormatField(Field)
   FormattedText=Field.Text
   ErrDescription=Field.ErrorDescription
   ValidFormat=Field.Valid
   DoubleVal=Field.DoubleValue
   DoubleFormatted=Field.DoubleFormatted
End Sub
```
1. Close the Script Window and test the Formatter.  
![image](https://user-images.githubusercontent.com/47416964/87158143-8ee2ed00-c2bf-11ea-977b-9974abd9729b.png)
