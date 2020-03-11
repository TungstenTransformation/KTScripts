# Copy Zones into a Table
This is useful on documents where text is handwritten into a grid on the page. You need to use the Advanced Zone Locator to read the cells of the table, but you want the results put into a table locator.  
The subfields in the Advanced Zone Locator need to be of the form **SF_R05C25** (for row 5, column 25).  

This script customizes the Table Locator, so that you can use the **Test** button in the Locator to test it.
* Make a Advanced Zone Locator called **AZL**
* Give it Zones called **R01C01**, etc.
* Make a Table Locator called **TL**
* Give the Table Locator a table model that matches the "Columns" in the AZL.
* Copy the Script into the Class Script
* Test the AZL.
* Test the Table Locator. *if you don't **directly** test the Table Locator after the AZL, the designer my "forget" the AZL results.*

*Note: Both the Table Locator and the Advanced Zone Locator store their results within Alternatives(0)*

```VBA
Private Sub Document_AfterLocate(ByVal pXDoc As CASCADELib.CscXDocument, ByVal LocatorName As String)
   If LocatorName = "TL" Then Table_CopySubfields(pXDoc.Locators.ItemByName(LocatorName).Alternatives(0).Table,pXDoc.Locators.ItemByName("AZL").Alternatives(0).SubFields)
End Sub

Public Sub Table_CopySubfields(Table As CscXDocTable, Zones As CscXDocSubFields)
   'Copy Subfields into a table. The subfields need to be of format SF_R0xC0y, where x=row number, c=column number
   Dim R As Long, C As Long, Row As CscXDocTableRow, Zone As CscXDocSubField, Word As CscXDocWord, Blank As Boolean
   Dim ZoneName As String
   Table.Rows.Clear ' delete anything in the table from automatic or manual table learning
   While True
      R=R+1:C=1
      ZoneName="SF_R" & Format(R,"00") &  "C" & Format(C,"00")
      If Not Zones.Exists(ZoneName) Then Exit While
      Set Row=Table.Rows.Append
      While True
         If Not Zones.Exists(ZoneName) Then Exit While
         Set Zone=Zones.ItemByName(ZoneName)
         Set Word=New CscXDocWord ' The only way to add coordinates to a table cell is to append a Word.
         Word.PageIndex=Zone.PageIndex
         Word.Left=Zone.Left
         Word.Width=Zone.Width
         Word.Top=Zone.Top
         Word.Height=Zone.Height
         Word.Text=Zone.Text
         Row.Cells(C-1).AddWordData(Word)
         Row.Cells(C-1).ExtractionConfident= Zone.ExtractionConfident
         C=C+1
         ZoneName="SF_R" & Format(R,"0") &  "C" & Format(C,"0")
      Wend
   Wend
   'Delete Blank Rows
   For R=Table.Rows.Count To 0 Step -1 ' you need to count backwards when deleting 
      Blank=True
      For C=0 To Table.Rows(R).Cells.Count-1
         If Table.Rows(R).Cells(C).Text<>"" Then Blank =False :Exit For
      Next
      If Empty Then Table.Rows.Remove(R)
   Next
End Sub
````
