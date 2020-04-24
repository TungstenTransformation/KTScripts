# How to Read Russian Invoices in Kofax Transformation
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

## Correcting Table Values
This corrects all numerical values according to formuale above, along with spellchecking and correcting country names.
```vbscript
Private Sub CorrectCells(ByVal pXDoc As CscXDocument, ByVal Table As CscXDocTable)
   Dim r As Integer
   Dim c As Integer
   Dim cf As ICscFieldFormatter
   Dim uf As ICscFieldFormatter

   Set cf = Project.FieldFormatters.ItemByName("CountryNameFormatter")
   Set uf = Project.FieldFormatters.Item("UnitsFormatter")
   For r = 0 To Table.Rows.Count - 1
      TableRow_CorrectAmounts (Table.Rows(r), tolerance)
      With Table.Rows(r)
         uf.FormatTableCell (.Cells.ItemByName("Unit Measure"))
         cf.FormatTableCell (.Cells.ItemByName("Country Of Origin"))
         'Set all empty cells and error-free cells to valid
         For c = 0 To Table.Columns.Count - 1
            If Table.Rows(r).Cells(c).Text = "" Or Table.Rows(r).Cells(c).ErrorDescription = "" Then Table.Rows(r).Cells(c).ExtractionConfident = True
         Next
      End With
   Next
End Sub

Public Sub TableRow_CorrectAmounts(row As CscXDocTableRow,tol As Double)
   Dim afl As ICscFieldFormatter 'Amount Formatter
   Dim pfl As ICscFieldFormatter 'Percent Formatter
   Set afl=Project.FieldFormatters.ItemByName(Project.DefaultAmountFormatter)
   Set pfl=Project.FieldFormatters.ItemByName("PercentageFormatter")
   Dim q,u,n,r,x,t As CscXDocTableCell
   Set q=row.Cells.ItemByName("Quantity")
   Set u=row.Cells.ItemByName("Unit Price")
   Set n=row.Cells.ItemByName("Net Amount")
   Set r=row.Cells.ItemByName("Tax Rate")
   Set x=row.Cells.ItemByName("Tax Amount")
   Set t=row.Cells.ItemByName("Total Price")
   afl.FormatTableCell(q)
   afl.FormatTableCell(u)
   afl.FormatTableCell(n)
   pfl.FormatTableCell(r)
   afl.FormatTableCell(x)
   afl.FormatTableCell(t)
   Dim qun,nxt,nrt,rxt,nxr,quxt,validTaxRate As Boolean
   validTaxRate=(r.DoubleValue=10 Or r.DoubleValue=18)
   If q.DoubleValue>0 And u.DoubleValue>0 And n.DoubleValue>0                     AndAlso Abs(q.DoubleValue*u.DoubleValue              -n.DoubleValue)<tol Then qun =True
   If n.DoubleValue>0 And x.DoubleValue>0 And t.DoubleValue>0                     AndAlso Abs(n.DoubleValue+x.DoubleValue              -t.DoubleValue)<tol Then nxt =True
   If n.DoubleValue>0 And validTaxRate    And t.DoubleValue>0                     AndAlso Abs(n.DoubleValue*(1+r.DoubleValue/100)      -t.DoubleValue)<tol Then nrt =True
   If validTaxRate    And x.DoubleValue>0 And t.DoubleValue>0                     AndAlso Abs(x.DoubleValue*(1+100/r.DoubleValue)      -t.DoubleValue)<tol Then rxt =True
   If n.DoubleValue>0 And x.DoubleValue>0 And validTaxRate                        AndAlso Abs(n.DoubleValue*r.DoubleValue/100          -x.DoubleValue)<tol Then nxr =True
   If q.DoubleValue>0 And u.DoubleValue>0 And x.DoubleValue>0 And t.DoubleValue>0 AndAlso Abs(q.DoubleValue*u.DoubleValue+x.DoubleValue-t.DoubleValue)<tol Then quxt=True
   If nxt And Not nxr Then
      Dim rate As Double
      rate=Round(x.DoubleValue/n.DoubleValue)
      If rate=10 Or rate=18 Then
         r.Text=Format(x.DoubleValue/n.DoubleValue,"00")
         pfl.FormatTableCell(r)
      End If
   End If
   If nrt And Not nxt Then
      x.Text=Format(n.DoubleValue*r.DoubleValue/100,"0.00")
      afl.FormatTableCell(x)
   End If
   If rxt And Not nrt Then
      n.Text=Format(t.DoubleValue-x.DoubleValue,"0.00")
      afl.FormatTableCell(n)
   End If
   If nxr And Not nrt Then
      t.Text=Format(n.DoubleValue+x.DoubleValue,"0.00")
      afl.FormatTableCell(t)
   End If
   If quxt And Not nrt Then
       n.Text=Format(t.DoubleValue-x.DoubleValue,"0.00")
       afl.FormatTableCell(n)
   End If
End Sub
```

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
## Locating INN & KPP
The following database contains INN anchors. Make it a fuzzy database locator with substituion values
```
КПП покупателя;buyer
КПП продавца;vendor
Идентификационный номер покупателя;buyer 
Идентификационный номер продавца;vendor
```
Create a multifield Script locator that finds the INN/KPP after these anchor words. It has two subfields **VendorINNKPP** and **BuyerINNKPP**. they will be split later
```vbscript
Private Sub SL_INNKPPfromAnchors_LocateAlternatives(ByVal pXDoc As CASCADELib.CscXDocument, ByVal pLocator As CASCADELib.CscXDocField)
   Dim Anchors As CscXDocFieldAlternatives
   Set Anchors=pXDoc.Locators.ItemByName("DB_INNKPPAnchors").Alternatives
   Dim Buyer As Long, Vendor As Long,A As Long,I As Long,W As Long,Digits As Long
   Dim INNKPP As CscXDocWords
   Dim Number As Boolean
   Buyer=-1
   Vendor=-1
   For A = 0 To Anchors.Count-1
      Select Case Anchors(A).SubFields(1).Text
      Case "buyer"
         If Buyer=-1 Then Buyer=A
      Case "vendor"
         If Vendor=-1 Then Vendor=A
      End Select
   Next
   With pLocator.Alternatives.Create
      .Confidence=1
      .SubFields.Create("VendorINNKPP")
      .SubFields.Create("BuyerINNKPP")
      If Vendor>-1 Then
         Set INNKPP =XDocument_GetNextPhrase(pXDoc,Anchors(Vendor).SubFields(0),400) ' 400 pixels max gap
         Number = False
         For W = 0 To INNKPP.Count-1
            If Not Number AndAlso String_CountDigits(INNKPP(W).Text)/Len(INNKPP(W).Text)>0.5 Then Number=True
            If Number Then .SubFields(0).Words.Append(INNKPP(W))
         Next
      End If
      If Buyer>-1 Then
         Set INNKPP =XDocument_GetNextPhrase(pXDoc,Anchors(Buyer).SubFields(0),400)
         Number = False
         For W = 0 To INNKPP.Count-1
            If Not Number AndAlso String_CountDigits(INNKPP(W).Text)/Len(INNKPP(W).Text)>0.5 Then Number=True
            If Number Then .SubFields(1).Words.Append(INNKPP(W))
         Next
      End If
      For W = 0 To 1
         If Len(.SubFields(W).Text)>5 Then .SubFields(W).Confidence=1
      Next
   End With
End Sub

Private Function String_CountDigits(A As String) As Integer
   'Returns the number of digits in a word
   Dim R As Long, C As Long
   For R = 1 To Len(A)
      Select Case AscW(Mid(A, R, 1))
      Case &H30 To &H39
         C = C + 1
      End Select
   Next
   String_CountDigits = C
End Function

Public Function XDocument_GetNextPhrase(ByVal pXDoc As CASCADELib.CscXDocument,Subfield As CscXDocSubField,Pixels As Long) As CscXDocWords
   'returns the words following the region subfield that are within so many pixels
   Dim Result As CscXDocField
   Dim Phrase As CscXDocWords, Anchor As CscXDocWords
   Dim L As Long, X As Long,W As Long
   Dim word As CscXDocWord
   Set Result= New CscXDocField
   Set Phrase=Result.Words
   With Subfield
      Set Anchor=pXDoc.GetWordsInRect(.PageIndex,.Left,.Top+.Height/2,.Width,2)
      If Anchor.Count=0 Then Return Nothing
      L=Anchor(0).LineIndex
      X= Anchor(Anchor.Count-1).Left+Anchor(Anchor.Count-1).Width
      For W = Anchor(Anchor.Count-1).IndexInTextLine+1  To pXDoc.TextLines(L).Words.Count-1
         Set word=pXDoc.TextLines(L).Words(W)
         If word.Left-X>Pixels And Phrase.Count>0 Then Exit For 'gap in line too big
         Phrase.Append(word)
         X=word.Left+word.Width
      Next
   End With
   Return Phrase
End Function
```
## Split INN and KPP
```vbscript
Private Sub splitfield(pXDoc As CscXDocument,innName As String, kppName As String)
   Dim inn,kpp As CscXDocField
   Set inn=pXDoc.Fields.ItemByName(innName)
   inn.Text=Trim(Replace(inn.Text," ",""))
   Set kpp=pXDoc.Fields.ItemByName(kppName)
   kpp.Text=Trim(Replace(kpp.Text," ",""))
   Dim i,r As Long
   Dim found As Boolean
   For i = 6 To Len(inn.Text)
      Select Case AscW(Mid(inn.Text,i,1))
         Case &h030 To &h039
         Case Else
            found=True
            Exit For
      End Select
   Next
   If found AndAlso i>8 AndAlso Len(inn.Text)>15 AndAlso i<Len(inn.Text) Then
         kpp.Text=Mid(inn.Text,i+1)
         r=inn.Left+inn.Width
         kpp.Left=inn.Left+inn.Width*((i+0)/Len(inn.Text))
         kpp.Width=r-kpp.Left
         inn.Width=inn.Width*(i-1)/Len(inn.Text)
         kpp.Top=inn.Top
         kpp.Height=inn.Height
         kpp.PageIndex=inn.PageIndex
         inn.Text=Left(inn.Text,i-1)
         kpp.Confidence=inn.Confidence
   End If
End Sub
```
## INN Checksum Algorithm
This script is an INN validation rule - it checks that the checksum is valid. Add it to a **Script Validation Method**.
```vbscript
Private Sub INNChecksum_Validate(ByVal pValItem As CASCADELib.ICscXDocValidationItem, ByRef ErrDescription As String, ByRef ValidField As Boolean)
   Dim inn As String
   Const INNweights10 = "2,4,10,3,5,9,4,6,8,0"
   Const INNweights11 = "2,4,10,3,5,9,4,6,8,0" 'todo
   Const INNweights12 = "2,4,10,3,5,9,4,6,8,0" 'todo
   Dim weights10() As String
   weights10=Split(INNweights10,",")
   inn=pValItem.Text
   Dim r,x,sum,checksum As Integer
   Dim ch As String
   sum=0
   Select Case Len(inn)
      Case 10
         For r = 1 To 9
            ch=Mid(inn,r,1)
            If InStr(ch,"0123456789")<0 Then
               ValidField = False
               ErrDescription = "INN must be 10 or 12 digits"
               Exit Sub
            End If
            sum=sum+Val(ch)*Val(weights10(r-1))
         Next
         checksum=(sum Mod 11) Mod 10
         If checksum=Val(Mid(inn,r,10)) Then
            ValidField=True
         Else
            ValidField = False
            ErrDescription = "invalid INN checksum"
         End If
   Case 12
   'TODO
      Case Else
         ValidField = False
         ErrDescription = "INN must be 10 or 12 digits"
   End Select
End Sub
```
## Quick-Correct of Numerical fields.
Press "?" in a numerical field to quickly correct it with a single key stroke buy calculating it from two other vlaues. This is quicker than correcting an OCR error.
```vbscript
Private Sub ValidationForm_AfterFieldChanged(ByVal pXDoc As CASCADELib.CscXDocument, ByVal pField As CASCADELib.CscXDocField)
   If InStr(pField.Text,"?")=0 Then Exit Sub
   Dim afl As ICscFieldFormatter
   Set afl=Project.FieldFormatters.ItemByName(Project.DefaultAmountFormatter)
   Dim n,x,t As CscXDocField
   Set n = pXDoc.Fields.ItemByName("NetAmount1")
   Set x = pXDoc.Fields.ItemByName("TaxAmount1")
   Set t = pXDoc.Fields.ItemByName("Total")
   afl.FormatField(n)
   afl.FormatField(x)
   afl.FormatField(t)
   Select Case pField.Name
   Case "NetAmount1"
      If x.DoubleValue>0 And t.DoubleValue>0 Then n.Text=Replace(Format(t.DoubleValue-x.DoubleValue,"0.00"),".",",")
   Case "TaxAmount1"
      If n.DoubleValue>0 And t.DoubleValue>0 Then x.Text=Replace(Format(t.DoubleValue-n.DoubleValue,"0.00"),".",",")
   Case "Total"
      If n.DoubleValue>0 And x.DoubleValue>0 Then t.Text=Replace(Format(n.DoubleValue+x.DoubleValue,"0.00"),".",",")
   End Select
End Sub
```
