# How to Read Russian Invoices
Russian invoice have some unique components, that are different from a typical European or American invoice.
* INN and KPP Numbers for both vendor and customer.
* very wide tables  for line items that have between 11 and 15 columns. These columns are very regular and well defined. The last row of the table header contains the column number.  
![image](https://user-images.githubusercontent.com/47416964/80201852-0f7d4000-8625-11ea-96f6-e1343728dead.png)  
* The table total and tax information is embedded inside the lat row of the table
* Russian invoices can use **-** as a decimal separator and **=** as a negative sign. eg "=101-00" = "-100.00"

## How to read Russian Tables.
Russian Table headers have lots of words with considerable word wrapping. This is a challenge to the table locator.
The following script detects accuractely the Table header. It uses fuzzy logic to avoid OCR errors.
1. Detect the textline containing ""1 2 3 4 5 6 7 8 9 10 11 12" using fuzzy logic
1. Assign the columns based on the words above the columns, using fuzzy logic.
1. Detect the end of table with a dictionary fuzzily looking for *всего к оплате* (Total Payable) and it's variants.
    * Итого
    * Всего к оплате
    * Итого по НДС
    * Итого по листу
    * Итого по ставке 
    * Всего
    * ВСЕГО ПО 
2. Cluster textlines within the table into table rows to deal with line wrapping.
1. Insert all words in the table into the correct cells
1. Repair OCR errors in numbers using the mathematical relationships
  * **Quantity** * **Unit Price** = **Net Price** (q*u=n)
  * **Net** * **TaxRate** = **TaxAmount** (n*r=x)
  * **Net** + **TaxAmount** = **Total** (n+x=t)
  if one amount is has an OCR error then it can be reconstructed using the above three rules  
  
| q | u | n | r | x | t |              |
| - | - | - | - | - | - | -----------  |
| * | * | * |   |   |   | q*u=n        |
|   |   | * |   | * | * | n+x=t        |
| * | * |   |   | * | * | q*u+x=t      |
| * | * |   | * |   |   | q\*u*(1+r)=t  |
|   |   | * | * |   | * | n*(1+r)=t    |
|   |   |   | * | * | * | x(1+1/r)=t   |

## Amount formatter for - and =



```vbscript
Private Sub SL_Table_Rows_LocateAlternatives(ByVal pXDoc As CASCADELib.CscXDocument, ByVal pLocator As CASCADELib.CscXDocField)
   Dim lineIndex As Long, words As CscXDocWords, word As CscXDocWord, c As Long,row As CscXDocTableRow,match As Boolean
   Dim Table As CscXDocTable
   Dim tl As CscTableLocLib.CscTableLocator, MasterCells As CscXDocTableCells, cell As CscXDocTableCell
   Dim l As Long, w As Long, t As Long, h As Long, x As New CscXDocument
   x.Load(pXDoc.FileName)
   pXDoc.Fields.ItemByName("StartTime").Text=CStr(Timer)
   Set MasterCells=x.Fields.ItemByName("Table").Table.Rows(0).Cells
   Open "c:\temp\table.txt" For Output As #1
   Set Table=pXDoc.Fields.ItemByName("Table").Table
   For c = 0 To Table.Columns.Count-1
      Print #1, Table.Columns(c).Name & ";" ;
   Next
   Print #1,
   For lineIndex=0 To pXDoc.TextLines.Count-1
      Set row=Table.Rows.Append()
      Set words = pXDoc.TextLines(lineIndex).Words
      c=0
      For w =0 To words.Count-1
         Set word=words(w)
         match=False
         While c<MasterCells.Count
            If Object_OverlapHorizontal2D(word,MasterCells(c)) Then
               match=True
               Exit While
            End If
            c=c+1
            Print #1,";";
         Wend
         If match Then
            Print #1, " " & word.Text ;
            row.Cells(c).AddWordData(word)
         End If
         If c>=MasterCells.Count Then Exit For
      Next
      Print #1,
   Next
   Close #1
End Sub

Public Function Object_OverlapHorizontal2D( a As Object, b As Object,Optional offset As Long=0) As Double
   Return Max((Min(a.Left+a.Width,b.Left+b.Width+offset)-Max(a.Left,b.Left+offset)),0)>0
End Function

Public Function Max(a,b)
   Return IIf(a>b,a,b)
End Function

Public Function Min(a,b)
   Return IIf(a<b,a,b)
End Function
```

## INN Checksum Algorithm
TODO: This is poor quality code - clean it up and make it fit for a validation rule. Use Array v(12). get rid of On ERROR
```vbscript
'
' INN Control Sum Check
' http://kontragent.info/articles/view/id/1
'
Private Function CheckInnControlSum(ByVal inn As String) As Boolean

On Error GoTo Err

   If (Not IsNumeric(inn)) Or (Len(inn) < 10) Then
      CheckInnControlSum = False
      Exit Function
   End If

   Dim v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, ch As Integer
   v1  = CInt(Mid(inn, Len(inn) - 0, 1))
   v2  = CInt(Mid(inn, Len(inn) - 1, 1))
   v3  = CInt(Mid(inn, Len(inn) - 2, 1))
   v4  = CInt(Mid(inn, Len(inn) - 3, 1))
   v5  = CInt(Mid(inn, Len(inn) - 4, 1))
   v6  = CInt(Mid(inn, Len(inn) - 5, 1))
   v7  = CInt(Mid(inn, Len(inn) - 6, 1))
   v8  = CInt(Mid(inn, Len(inn) - 7, 1))
   v9  = CInt(Mid(inn, Len(inn) - 8, 1))
   v10 = CInt(Mid(inn, Len(inn) - 9, 1))
   If (Len(inn) > 10) Then
      v11 = CInt(Mid(inn, Len(inn) - 10, 1))
      v12 = CInt(Mid(inn, Len(inn) - 11, 1))
   End If

   If (Len(inn) = 10) Then
      ' 10 digits INN
      ch = (v2 * 8 + v3 * 6 + v4 * 4 + v5 * 9 + v6 * 5 + v7 * 3 + v8 * 10 + v9 * 4 + v10 * 2) Mod 11
      CheckInnControlSum = (ch = v1)

   ElseIf (Len(inn) = 12) Then
      ' 12 digits INN
      ch = (v3 * 8 + v4 * 6 + v5 * 4 + v6 * 9 + v7 * 5 + v8 * 3 + v9 * 10 + v10 * 4 + v11 * 2 + v12 * 7) Mod 11
      CheckInnControlSum = (ch = v2)
      If (ch = v2) Then
         ch = (v2 * 8 + v3 * 6 + v4 * 4 + v5 * 9 + v6 * 5 + v7 * 3 + v8 * 10 + v9 * 4 + v10 * 2 + v11 * 7 + v12 * 3) Mod 11
         CheckInnControlSum = (ch = v1)
      End If
   End If

Exit Function
Err:
   CheckInnControlSum = False

End Function
```
