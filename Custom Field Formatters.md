# Custom Field Formatters
## Custom Amount Formatter
This example deals with numbers that contain "D" after the number to mark "debit". The "D" will be removed and make the number negative, and then it calls the default amount formatter.

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
