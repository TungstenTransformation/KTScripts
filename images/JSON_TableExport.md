# Export Transformation Tables to JSON
This script runs in **Document_AfterExtract** and concatenates every table field into a JSON string and then inserts them into a field in the document class. The script needs to be run here because it needs to run after all tables are copied from locators and all cell formatters have been run, which also set the Confident flag on each cell.

The function **Tables_2JSON** takes two parameters
* The XDocument
* The Field Name of an unused field that will take the JSON String. You should make sure this field is sett to **Always Valid**, has no validation or field formatters and should not be on the validation form. It can then be exported to a TotalAgility Variable.

Below the script is a complete sample JSON output, containing an array of tables containing any array of rows, which contains an array of cells. The cells contain name, text, pixel coordinates from top-left corner and boolean confident flag. *Table Cells do not have confident*. The table also contains an array of columns.

If the pageNumber=-1 then all coordinates should be ignore.

Copy the script into the Class Level of the Project where the table fields are.

```vb
'#Language "WWB-COM"
Option Explicit

' Class script: JSON

Private Sub Document_AfterExtract(ByVal pXDoc As CASCADELib.CscXDocument)
   Tables_2JSON(pXDoc, pXDoc.Fields.ItemByName("TableJSON"))
End Sub

Private Sub Tables_2JSON(pXDoc As CscXDocument, JSON As CscXDocField)
   'This will write all tables to a json string in the field JSON
   Dim F As Long, Field As CscXDocField
   Dim jTable As String, jTables As String
   For F =0 To pXDoc.Fields.Count-1
      Set Field=pXDoc.Fields(F)
      If Field.FieldType= CscExtractionFieldType.CscFieldTypeTable Then
         jTable=Table_2JSON(Field.Table,Field.Name)
         jTables=jTables & "," & jTable
      End If
   Next
   jTables=Mid(jTables,2)
   JSON.Text="{"+tab(1) & """tables"": [" & jTables & tab(1) & "]" & tab(0) & "}"
   JSON.Confidence=1.00
End Sub

Private Function Table_2JSON(Table As CscXDocTable,TableName As String) As String
   Dim C As Long, R As Long, jColumns As String, jRows As String, jTable As String
   For C=0 To Table.Columns.Count-1
      jColumns=jColumns + "," & tab(5) & """" & Table.Columns(C).Name & """"
   Next
   jColumns=Mid(jColumns,2)
   For R=0 To Table.Rows.Count-1
      jRows=jRows &  "," &  Row_2JSON(Table.Rows(R))
   Next
   jRows=Mid(jRows,2)
   jTable= tab(2) & "{" & tab(3) & """table"": {" & tab(4) & """name"": """ & TableName & """," & tab(4) & """columns"": [" & jColumns & tab(4) & "],"
   jTable = jTable & tab(4) & """rows"": [" & jRows & tab(5) & "]" & tab(4) &  "}" & tab(2) & "}"
   Return jTable
End Function

Private Function Row_2JSON(Row As CscXDocTableRow) As String
   Dim C As Long, jCells As String
   For C=0 To Row.Cells.Count-1
      jCells=jCells & "," & Cell_2JSON(Row.Cells(C))
   Next
   jCells=Mid(jCells,2)
   Return tab(5) & "{" & tab(6) & """row"": [" & jCells & tab(6) & "]" & tab (5) & "}"
End Function

Private Function Cell_2JSON(Cell As CscXDocTableCell) As String
   Dim jCell As String
   jCell=tab(7) & "{" & tab(8) & """cell"": {" & tab(8) & """name"": """ & jString(Cell.ColumnName) & ""","& tab(8) & """text"": """ & jString(Cell.Text) & """," & tab(8) & """page"": " & jInt(Cell.PageIndex) & "," & tab(8) & """left"": " & jInt(Cell.Left)& "," & tab(8) & """width"": " & jInt(Cell.Width)
   jCell=jCell & ","& tab(8) & """top"": " & jInt(Cell.PageIndex) & ","& tab(8) & """height"": " & jInt(Cell.PageIndex) & ","& tab(8) & """confidence"": " & jBool(Cell.ExtractionConfident) &  tab(7)&  "}" & tab(6) & "}"
   Return jCell
End Function

Private Function jString(Text As String) As String
   'Escape special characters https://www.json.org
   jString=Replace(Text,"\","\\")
   jString=Replace(jString,"""","\""")
   jString=Replace(jString,vbBack,"\b")
   jString=Replace(jString,vbCr,"\f")
   jString=Replace(jString,vbNewLine,"\n")
   jString=Replace(jString,vbCrLf,"\r\f")
   jString=Replace(jString,vbTab,"\t")
   Return jString
End Function
Private Function jInt(number As Long) As String
   Return Format(number,"0")
End Function

Private Function jNumber(number As Double) As String
   Return Format(number,"0.00")
End Function

Private Function jBool(Bool As Boolean) As String
   If Bool Then Return "true" Else Return "false"
End Function

Private Function tab(length As Long) As String 'return a string of length tabs
   Return vbCrLf & Replace(Space(length)," ",vbTab)
End Function
```
```json
{
	"tables": [
		{
			"table": {
				"name": "Table1",
				"columns": [
					"Position",
					"Description",
					"Unit Price",
					"Quantity",
					"Total Price",
					"Discount",
					"Unit Measure"
				],
				"rows": [
					{
						"row": [
							{
								"cell": {
								"name": "Position",
								"text": "B.7",
								"page": 0,
								"left": 96,
								"width": 44,
								"top": 0,
								"height": 0,
								"confidence": true
							}
						},
							{
								"cell": {
								"name": "Description",
								"text": "Dokumen Referensi :",
								"page": 0,
								"left": 179,
								"width": 297,
								"top": 0,
								"height": 0,
								"confidence": true
							}
						},
							{
								"cell": {
								"name": "Unit Price",
								"text": "Dokumen PDC24",
								"page": 0,
								"left": 652,
								"width": 315,
								"top": 0,
								"height": 0,
								"confidence": true
							}
						},
							{
								"cell": {
								"name": "Quantity",
								"text": "Tanggal",
								"page": 0,
								"left": 1345,
								"width": 110,
								"top": 0,
								"height": 0,
								"confidence": true
							}
						},
							{
								"cell": {
								"name": "Total Price",
								"text": "dd",
								"page": 0,
								"left": 1630,
								"width": 37,
								"top": 0,
								"height": 0,
								"confidence": true
							}
						},
							{
								"cell": {
								"name": "Discount",
								"text": "MM",
								"page": 0,
								"left": 1880,
								"width": 51,
								"top": 0,
								"height": 0,
								"confidence": true
							}
						},
							{
								"cell": {
								"name": "Unit Measure",
								"text": "1",
								"page": -1,
								"left": 0,
								"width": 0,
								"top": -1,
								"height": -1,
								"confidence": true
							}
						}
						]
					},
					{
						"row": [
							{
								"cell": {
								"name": "Position",
								"text": "B.8",
								"page": 0,
								"left": 96,
								"width": 44,
								"top": 0,
								"height": 0,
								"confidence": true
							}
						},
							{
								"cell": {
								"name": "Description",
								"text": "Dokumen Referensi untuk",
								"page": 0,
								"left": 179,
								"width": 360,
								"top": 0,
								"height": 0,
								"confidence": true
							}
						},
							{
								"cell": {
								"name": "Unit Price",
								"text": "apabila ada",
								"page": 0,
								"left": 737,
								"width": 158,
								"top": 0,
								"height": 0,
								"confidence": true
							}
						},
							{
								"cell": {
								"name": "Quantity",
								"text": "Tanggal",
								"page": 0,
								"left": 1345,
								"width": 110,
								"top": 0,
								"height": 0,
								"confidence": true
							}
						},
							{
								"cell": {
								"name": "Total Price",
								"text": "dd",
								"page": 0,
								"left": 1630,
								"width": 37,
								"top": 0,
								"height": 0,
								"confidence": true
							}
						},
							{
								"cell": {
								"name": "Discount",
								"text": "MM",
								"page": 0,
								"left": 1879,
								"width": 52,
								"top": 0,
								"height": 0,
								"confidence": true
							}
						},
							{
								"cell": {
								"name": "Unit Measure",
								"text": "1",
								"page": -1,
								"left": 0,
								"width": 0,
								"top": -1,
								"height": -1,
								"confidence": true
							}
						}
						]
					},
					{
						"row": [
							{
								"cell": {
								"name": "Position",
								"text": "B.9",
								"page": 0,
								"left": 96,
								"width": 44,
								"top": 0,
								"height": 0,
								"confidence": true
							}
						},
							{
								"cell": {
								"name": "Description",
								"text": "PPh dibebankan berdasarkan",
								"page": 0,
								"left": 279,
								"width": 406,
								"top": 0,
								"height": 0,
								"confidence": true
							}
						},
							{
								"cell": {
								"name": "Unit Price",
								"text": "Surat Keterangan",
								"page": 0,
								"left": 695,
								"width": 241,
								"top": 0,
								"height": 0,
								"confidence": true
							}
						},
							{
								"cell": {
								"name": "Quantity",
								"text": "Tanggal",
								"page": 0,
								"left": 1345,
								"width": 110,
								"top": 0,
								"height": 0,
								"confidence": true
							}
						},
							{
								"cell": {
								"name": "Total Price",
								"text": "dd",
								"page": 0,
								"left": 1630,
								"width": 37,
								"top": 0,
								"height": 0,
								"confidence": true
							}
						},
							{
								"cell": {
								"name": "Discount",
								"text": "MM",
								"page": 0,
								"left": 1875,
								"width": 52,
								"top": 0,
								"height": 0,
								"confidence": true
							}
						},
							{
								"cell": {
								"name": "Unit Measure",
								"text": "1",
								"page": -1,
								"left": 0,
								"width": 0,
								"top": -1,
								"height": -1,
								"confidence": true
							}
						}
						]
					}
					]
				}
		},
		{
			"table": {
				"name": "Table2",
				"columns": [
					"Total Price",
					"Supplier Article Code",
					"Order Number",
					"Delivery Note Number",
					"Tax Rate"
				],
				"rows": [
					{
						"row": [
							{
								"cell": {
								"name": "Total Price",
								"text": "B.1",
								"page": 0,
								"left": 234,
								"width": 40,
								"top": 0,
								"height": 0,
								"confidence": true
							}
						},
							{
								"cell": {
								"name": "Supplier Article Code",
								"text": "B.2",
								"page": 0,
								"left": 555,
								"width": 43,
								"top": 0,
								"height": 0,
								"confidence": true
							}
						},
							{
								"cell": {
								"name": "Order Number",
								"text": "B.3",
								"page": 0,
								"left": 1005,
								"width": 43,
								"top": 0,
								"height": 0,
								"confidence": true
							}
						},
							{
								"cell": {
								"name": "Delivery Note Number",
								"text": "B.4",
								"page": 0,
								"left": 1459,
								"width": 44,
								"top": 0,
								"height": 0,
								"confidence": true
							}
						},
							{
								"cell": {
								"name": "Tax Rate",
								"text": "B.5",
								"page": 0,
								"left": 1734,
								"width": 43,
								"top": 0,
								"height": 0,
								"confidence": true
							}
						}
						]
					}
					]
				}
		}
	]
}
``` 

