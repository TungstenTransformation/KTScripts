**Table of Contents**

<!-- toc -->

- [How to Read Russian Invoices in Kofax Transformation](#how-to-read-russian-invoices-in-kofax-transformation)
  * [How to read Russian Tables](#how-to-read-russian-tables)
    + [Detecting Table Headers](#detecting-table-headers)
    + [Correcting Table Values](#correcting-table-values)
  * [Amount formatter for - and =](#amount-formatter-for---and-)
  * [Locating INN & KPP](#locating-inn--kpp)
  * [Split INN and KPP](#split-inn-and-kpp)
  * [INN Checksum Algorithm](#inn-checksum-algorithm)
  * [Quick-Correct of Numerical fields.](#quick-correct-of-numerical-fields)
  * [Check that the net, tax and total under the table actually match the sum of the table columns](#check-that-the-net-tax-and-total-under-the-table-actually-match-the-sum-of-the-table-columns)
  * [Useful functions](#useful-functions)
  * [Format Invoice Number](#format-invoice-number)
  * [Spell Check Country Names](#spell-check-country-names)
  * [Units Formatting](#units-formatting)

<!-- tocstop -->

# How to Read Russian Invoices in Kofax Transformation
Russian invoice have some unique components, that are different from a typical European or American invoice.
* [INN](https://www.nalog.ru/eng/exchinf/inn/) (10 or 12 digit Taxpayer Personal Identification Number, with checksum)  
* KPP (9 digit Tax Registration Event Code) Numbers for both vendor and customer.
* very wide tables  for line items that have between 11 and 15 columns. These columns are very regular and well defined. The last row of the table header contains the column number.  
![image](https://user-images.githubusercontent.com/47416964/80201852-0f7d4000-8625-11ea-96f6-e1343728dead.png)  
* The table total and tax information is embedded inside the last row of the table
* Russian invoices can use **-** as a decimal separator and **=** as a negative sign. eg "=101-00" = "-100.00"

## How to read Russian Tables
Russian Table headers have lots of words with considerable word wrapping. This is a challenge to the table locator.
The following script detects accuractely the Table header. It uses fuzzy logic to avoid OCR errors.
1. Detect the textline containing ""1 2 3 4 5 6 7 8 9 10 11 12" using fuzzy logic
1. Assign the columns based on the words above the columns, using fuzzy logic.
1. Detect the end of table with a dictionary fuzzily looking for *всего к оплате* (Total Payable) and it's variants.
```
Итого
Всего к оплате
Итого по НДС
Итого по листу
Итого по ставке 
Всего
ВСЕГО ПО 
```
4. Cluster textlines within the table into table rows to deal with line wrapping.
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

```vbscript
'#Language "WWB-COM"
Option Explicit
'Add reference to Microsoft Scripting Runtime for Dictionary Class
      Type alt
        id As Long
        conf As Double
    End Type

   Public Function Compare(ByVal a As alt, ByVal b As alt) As Long
         Return a.Conf > b.Conf
     End Function

' Class script: del
    Const TABLEHEADERTEXT As String = "1 2 3 4 5 6 7 8 9 10 11 12"
    'the following is a typical pattern of a Russian table line - it doesn't need to be perfect, just provide a fuzzy baseline match-
    'the lines that most resemble this will be the main line items.
    Const LINEITEMPATTERN = "c c n c n d d p d d"  ' c=cyrrilic, a=latin, n=number, d=decimal, p = percentage
    Const PUNCTUATION = ",;{}[]()|~=»>!™'*.¦"
    Const ROWCONFIDENCE  = 0.9
    Const MAXROWSINHEADER =12
    Const DECIMALSYMBOL =","
    Dim VerticalLines As CscXDocField
    Dim HorizontalLines As CscXDocField
    Dim Headers As CscXDocField
    Dim TableEnd As CscXDocField
    Dim EndOfTablePage As Long
    Dim  EndOfTablePixel As Long
    Dim HeaderDataBaseName As String
    Dim tableModelName As String

    Public Sub DetectLines(ByVal pXDoc As CscXDocLib.CscXDocument)
        VerticalLines = New CscXDocLib.CscXDocField
        HorizontalLines = New CscXDocLib.CscXDocField
        Lines_FindBestCluster(pXDoc.Representations.ItemByName("TableLinesRep").Lines, CscXDocLib.CscXDocLineDirections.CscXDocLineDirectionVertical, VerticalLines.Alternatives)
        Lines_FindBestCluster(pXDoc.Representations.ItemByName("TableLinesRep").Lines, CscXDocLib.CscXDocLineDirections.CscXDocLineDirectionHorizontal, HorizontalLines.Alternatives)
    End Sub

    Public Sub DetectHeader(ByVal pXDoc As CscXDocLib.CscXDocument, ByVal table As CscXDocTable)
      Headers = New CscXDocLib.CscXDocField
      FindHeaderWords(pXDoc, table, Headers)
      WidenHeaders(pXDoc, table, Headers.Alternatives)
    End Sub

    Public Sub DetectRows(ByVal pXDoc As CscXDocLib.CscXDocument, ByVal EndOfTableLoc As CscXDocLib.CscXDocField, ByVal table As CscXDocTable)
        TableEnd = New CscXDocField
        If Headers.Alternatives.Count = 0 Then
            Exit Sub
        End If
        EndOfTable(pXDoc, EndOfTableLoc, TableEnd)
        RowDetection(pXDoc, table)
    End Sub

    Public Sub DetectTotals(ByVal pXDoc As CscXDocLib.CscXDocument, ByVal table As CscXDocTable, ByVal pLocator As CscXDocLib.CscXDocField, ByVal agl As CscXDocLib.CscXDocField)
        TableSum(pXDoc, table, pLocator, agl)
    End Sub

    Private Sub TableSum(ByVal pXDoc As CscXDocLib.CscXDocument, ByVal table As CscXDocTable, ByVal pLocator As CscXDocLib.CscXDocField, ByVal agl As CscXDocLib.CscXDocField)
        'we are looking For the Total And tax sums underneath the tables
        Dim l, w As Long
        Dim row As CscXDocTableRow
        Dim cellTax As CscXDocLib.CscXDocTableCell
        Dim cellTotal As CscXDocLib.CscXDocTableCell
        Dim words As CscXDocWords

        If table.Rows.Count = 0 Then Exit Sub

        row = table.Rows(table.Rows.Count - 1)
        cellTax = row.Cells.ItemByName("Tax Amount") 'find the cell in the bottom row
        While cellTax.Text = "" And cellTax.RowIndex > 0
            cellTax = table.Rows(cellTax.RowIndex - 1).Cells(cellTax.ColumnIndex)
        Wend
        cellTotal = row.Cells.ItemByName("Total Price") 'find the cell in the bottom row
        While cellTotal.Text = "" And cellTotal.RowIndex > 0
            cellTotal = table.Rows(cellTotal.RowIndex - 1).Cells(cellTotal.ColumnIndex)
        Wend
        Dim n, x, t As Double
        Dim valid As Boolean
        Dim daf As CASCADELib.ICscFieldFormatter
        daf = Project.FieldFormatters(Project.DefaultAmountFormatter)
        n = Table_SumColumn(table, table.Columns.ItemByName("Net Amount").IndexInTable, daf, valid)
        x = Table_SumColumn(table, table.Columns.ItemByName("Tax Amount").IndexInTable, daf, valid)
        t = Table_SumColumn(table, table.Columns.ItemByName("Total Price").IndexInTable, daf, valid)

        If x > 0 And t > 0 And n = 0 Then
            n = x - t
        ElseIf x = 0 And t > 0 And n > 0 Then
            x = n - t
        ElseIf x = 0 And t > 0 And n > 0 Then
            x = n - t
        End If

        Dim h As CscXDocFieldAlternatives
        h = Headers.Alternatives
        Dim taxheader, totalheader As Long
        taxheader = -1
        totalheader = -1
        For l = 0 To h.Count - 1
            Dim headername As String
            headername = Trim(Split(h(l).Text, ";")(0))
            If headername = "Total Price" Then totalheader = l
            If headername = "Tax Amount" Then taxheader = l
        Next
        For l = row.TextlineIndexEnd + 1 To row.TextlineIndexEnd + 4
            If l >= pXDoc.TextLines.Count Then Exit For
            With pLocator.Alternatives.Create
                .SubFields.Create("Tax")
                .SubFields.Create("Total")
                .SubFields.Create("NetAmount")
                If cellTax.PageIndex > -1 Then
                    words = pXDoc.GetWordsInRect(cellTax.PageIndex, h(taxheader).Left, pXDoc.TextLines(l).Top, h(taxheader).Width, pXDoc.TextLines(l).Height)
                    For w = 0 To words.Count - 1
                        If words(w).LineIndex = l Then
                            .SubFields(0).Words.Append(words(w))
                            .SubFields(0).Confidence = 0.5 'it gets 50% for existing
                        End If
                    Next
                    If String_FormatAsDouble(.SubFields(0).Text) = x And x > 0 Then .SubFields(0).Confidence = 1
                End If
                If cellTotal.PageIndex > -1 Then
                    words = pXDoc.GetWordsInRect(cellTotal.PageIndex, h(totalheader).Left, pXDoc.TextLines(l).Top, h(totalheader).Width, pXDoc.TextLines(l).Height)
                    For w = 0 To words.Count - 1
                        If words(w).LineIndex = l Then
                            .SubFields(1).Words.Append(words(w))
                            .SubFields(1).Confidence = 0.5 'it gets 50% for existing
                        End If
                    Next
                    If String_FormatAsDouble(.SubFields(1).Text) = t And t > 0 Then .SubFields(0).Confidence = 1
                End If
            End With
        Next
        For l = pLocator.Alternatives.Count - 1 To 0 Step -1
            With pLocator.Alternatives(l)
                pLocator.Alternatives(l).Confidence = (.SubFields(0).Confidence + .SubFields(1).Confidence) / 2
                If pLocator.Alternatives(l).Confidence = 0 Then pLocator.Alternatives.Remove(l)
            End With
        Next
        For l = agl.Alternatives.Count - 1 To 0 Step -1
            If Table_Overlap(table, agl.Alternatives(l).SubFields.ItemByName("Total")) Then
                agl.Alternatives.Remove(l)
            ElseIf Table_Overlap(table, agl.Alternatives(l).SubFields.ItemByName("TaxAmount1")) Then
                agl.Alternatives.Remove(l)
            End If
        Next
        If agl.Alternatives.Count = 0 Then
            With pLocator.Alternatives.Create
                .SubFields.Create("Tax")
                .SubFields.Create("Total")
                .SubFields.Create("NetAmount")
                .SubFields(0).Text = Replace(Format(x, "0.00"), ".", DECIMALSYMBOL)
                .SubFields(1).Text = Replace(Format(t, "0.00"), ".", DECIMALSYMBOL)
                .SubFields(2).Text = Replace(Format(n, "0.00"), ".", DECIMALSYMBOL)
            End With
        End If
    End Sub

    Private Sub RowDetection(ByVal pXDoc As CscXDocLib.CscXDocument, ByVal table As CscXDocTable)
        'This inserts All the words In the table into the correct cells
        'TODO - handle widow words with no headers above them
        Dim p As Long
        Dim r As Long
        Dim firstpageoffset As Long
        Dim offset As Long
        Dim bestclusterIndexes() As Long
        Dim stopLineIndex As Long
        Dim startLineIndex As Long
        Dim clusters As CscXDocLib.CscXDocField
        Dim firstRowIndex As Long
        Dim lastRowIndex As Long

        clusters = New CscXDocLib.CscXDocField
        table.Rows.Clear()
        firstpageoffset = XDocument_FindLeftTextMargin(pXDoc, 0)

        For p = 0 To pXDoc.Pages.Count - 1
            stopLineIndex = pXDoc.Pages(p).TextLines(pXDoc.Pages(p).TextLines.Count - 1).IndexOnDocument
            If EndOfTablePage > -1 Then 'we know where the end of table is
                If p > EndOfTablePage Then 'We are on a page after the table
                    stopLineIndex = 0
                ElseIf p = EndOfTablePage Then
                    'go back up the page to the line before endoftablepixel
                    While pXDoc.TextLines(stopLineIndex).Top + pXDoc.TextLines(stopLineIndex).Height > EndOfTablePixel And stopLineIndex > startLineIndex
                        stopLineIndex = stopLineIndex - 1
                    Wend
                End If
            End If
            If p = 0 Then 'I am assuming that the table starts on the first page
                startLineIndex = Headers.Alternatives(p).LongTag + 1
            Else 'I am assuming that the top of middle pages are in the table
                startLineIndex = pXDoc.Pages(p).TextLines(0).IndexOnDocument
            End If
            ''dl.WriteLine("KTM: startlineindex=" & startLineIndex)
            ''dl.WriteLine("KTM: stoplineindex=" & stopLineIndex)

            'group by similarity all the textlines on the page underneath the table header. The largest group SHOULD be the table rows
            Page_GroupTextLinesBySimilarity(pXDoc.TextLines, startLineIndex, stopLineIndex, ROWCONFIDENCE, clusters, IIf(p = 0, True, False))
            ''dl.WriteLine("clustercount=" & clusters.Alternatives.Count)
            bestclusterIndexes = Alternatives_GetSortOrder(clusters.Alternatives)
            ''dl.WriteLine("BCL=" & bestclusterIndexes.Count)
            'Now we need to count for table registration horizontal shifting on following pages
            If p = 0 Then offset = 0 Else offset = XDocument_FindLeftTextMargin(pXDoc, p) - firstpageoffset
            If UBound(bestclusterIndexes) > -1 Then 'we found some similar lines, and assume the the best similar group are the main table lines
                'Now go and find where the best cluster ends, this should be near the bottom of the table
                With clusters.Alternatives(bestclusterIndexes(0)).SubFields
                    r = 0
                    Do While r < .Count - 1
                        If pXDoc.TextLines(.ItemByIndex(r).LongTag).PageIndex >= p Then Exit Do
                        r = r + 1
                    Loop
                    firstRowIndex = .ItemByIndex(r).LongTag
                    lastRowIndex = .ItemByIndex(.Count - 1).LongTag
                End With
                ' check for some trailing lines that appear above the end_of_table
                If EndOfTablePage > -1 Then lastRowIndex = Max(lastRowIndex, stopLineIndex)
                'dl.WriteLine("firstrowindex " & firstRowIndex)
                'dl.WriteLine("lastrowindex " & lastRowIndex)
                If p = 0 Then firstRowIndex = startLineIndex 'sometimes the first line of a table doesn't cluster - we need to include it anyway
                'dl.WriteLine("firstrowindex " & firstRowIndex)
                For r = firstRowIndex To lastRowIndex
                    'Only insert a table line into a table if we cannot find the end of table, or if we are BEFORE the end of table
                    If EndOfTablePage = -1 Then
                        Table_InsertRow(pXDoc, Headers.Alternatives, r, table, offset)
                    ElseIf p < EndOfTablePage Then
                        Table_InsertRow(pXDoc, Headers.Alternatives, r, table, offset)
                    ElseIf (p = EndOfTablePage And EndOfTablePixel > pXDoc.TextLines(r).Top) Then
                        Table_InsertRow(pXDoc, Headers.Alternatives, r, table, offset)
                    End If
                Next
            End If
        Next
    End Sub

    Private Sub WidenHeaders(ByVal pXDoc As CscXDocLib.CscXDocument, ByVal table As CscXDocTable, ByVal headers As CscXDocFieldAlternatives)
        Dim i As Long
        Dim r As Long
        Dim lineIndex As Long

        For i = headers.Count - 1 To 0 Step -1
            If headers(i).Confidence = 0 Then headers.Remove(i)
        Next
        For i = 0 To headers.Count - 1
            If i < headers.Count - 1 Then
                r = headers(i + 1).Left
            Else
                r = pXDoc.CDoc.Pages(0).Width
            End If
            lineIndex = Alternatives_FindBetween(VerticalLines.Alternatives, headers(i).Left + headers(i).Width, r)
            If lineIndex > -1 Then
                headers(i).Width = VerticalLines.Alternatives(lineIndex).Left - 20 - headers(i).Left
            End If
        Next
        'make the first column go to edge of page
        If headers.Count > 0 Then
            headers(0).Width = headers(0).Left + headers(0).Width
            headers(0).Left = 0
        End If
    End Sub

    Private Function Alternatives_FindBetween(ByVal alts As CscXDocFieldAlternatives, ByVal l As Long, ByVal r As Long) As Long
        'Find the first alternative which is horizontally between the pixels l and r
        Dim i As Long
        For i = 0 To alts.Count - 1
            If alts(i).Left > l And alts(i).Left + alts(i).Width < r Then Alternatives_FindBetween = i : Exit Function
        Next
        Alternatives_FindBetween = -1
    End Function

    Private Sub FindHeaderWords(ByVal pXDoc As CscXDocLib.CscXDocument, ByVal table As CscXDocTable, ByVal pLocator As CscXDocLib.CscXDocField)

        'we are only looking for table header on page 1
        Dim p As Long
        Dim headerLineIndex As Long
        Dim conf As Double
        Dim score As Double
        Dim inHeader As Boolean
        Dim tablemodel As CASCADELib.CscTableModel
        Dim headerwords As New CscXDocLib.CscXDocField
        Dim sortOrder() As Long
        Dim out As CscXDocLib.CscXDocField
        Dim db As CASCADELib.CscDatabase
        db = Project.Databases.ItemByName(HeaderDataBaseName)
        While pLocator.Alternatives.Count > 0
            pLocator.Alternatives.Remove(0)
        Wend
        inHeader = False
         headerLineIndex = XDocument_SearchLineFuzzy(pXDoc, 0, TABLEHEADERTEXT, conf)

        If conf < 0.8 Then
            For p = 0 To pXDoc.Pages(0).TextLines.Count - 1
                score = TextLine_IsTableHeader(pXDoc.TextLines(p), db)
                If score > 0.7 Then inHeader = True
                If inHeader And score < 0.5 Then Exit For 'we left the header
            Next
            If inHeader = False Then Exit Sub 'No Table header found!!
            headerLineIndex = Max(p - 1, 0)
        End If
        tablemodel = Project.TableModels.ItemByName(tableModelName)
            XDocument_AnalyzeTableHeader(pXDoc, headerLineIndex, db, tablemodel, headerwords.Alternatives)
            sortOrder = Alternatives_GetSortOrder(headerwords.Alternatives)
        out = pLocator
        XDocument_FindTableColumns(pXDoc, headerLineIndex, tablemodel, sortOrder, headerwords.Alternatives, out.Alternatives)
        'we need to store the headerindex in every row, because the rows will get sorted later and we won't find it again!!
        For p = 0 To pLocator.Alternatives.Count - 1
            pLocator.Alternatives(p).LongTag = headerLineIndex
        Next
        pLocator.LongTag = 0
    End Sub

    Private Sub XDocument_AnalyzeTableHeader(ByVal pXDoc As CscXDocLib.CscXDocument, ByVal lineIndex As Long, _
                                              ByVal db As CASCADELib.CscDatabase, _
                                              ByVal tablemodel As CASCADELib.CscTableModel, ByVal results As CscXDocFieldAlternatives)
        Dim pageIndex As Long
        pageIndex = pXDoc.TextLines(lineIndex).PageIndex
        If pXDoc.Pages(pageIndex).TextLines.Count = 0 Then Exit Sub ' This page has no OCR text
        If pXDoc.Pages(pageIndex).TextLines(lineIndex).Words.Count = 0 Then Exit Sub ' This page has no OCR text
        'Build an index of column names to global column id's
        Dim COLUMNIDS As New Dictionary
        Dim i, w, cols As Long
        cols = tablemodel.ModelColumns.Count
        For i = 0 To cols - 1
            Dim colName As String
            colName = Project.GlobalColumns.ItemByID(tablemodel.ModelColumns(i).GlobalColumnID).DisplayNameLocalizations.Default
            COLUMNIDS.Add(colName, i)
            With results.Create
                .Text = colName
            End With
        Next

        Dim startindex As Long
        'Find a line above the start of table
        startindex = lineIndex - MAXROWSINHEADER
        If startindex < pXDoc.Pages(pageIndex).TextLines(0).IndexOnDocument Then startindex = pXDoc.Pages(pageIndex).TextLines(0).IndexOnDocument
        Dim wordsInLine, startWordIndex As Long
        wordsInLine = pXDoc.TextLines(lineIndex).Words.Count - 1
        startWordIndex = pXDoc.TextLines(lineIndex).Words(0).IndexOnDocument

        Dim word As CscXDocWord
        For i = startindex To lineIndex - 1
            If TextLine_IsTableHeader(pXDoc.TextLines(i), db) > 0.5 Then 'check if this line contains at least 50% header words
                For w = 0 To pXDoc.TextLines(i).Words.Count - 1
                    word = pXDoc.TextLines(i).Words(w)
                    Dim column, columns As String
                    Dim conf As Double
                    conf = 0.75
                    columns = DataBase_SearchString(db, "columns", Trim(LCase(String_RemoveCharacters(word.Text, PUNCTUATION))), conf)
                    If columns <> "" Then
                        columns = Replace(columns, "_", " ")
                        For Each column In Split(columns, ",")
                            If Not COLUMNIDS.ContainsKey(column) Then Err.Raise(356,,column & " from database " & db.Name & " doesn't exist in table model " & tablemodel.Name & "!")
                            With results.ItemByIndex(COLUMNIDS(column))
                                Dim sf As New CscXDocSubField
                                sf = .SubFields.Create(column)
                                sf.Words.Append(word)
                                sf.Confidence = 1
                                Dim c As Double
                                c = Subfields_Conflate(.SubFields, True, 10)
                                If c > .Confidence Then .Confidence = c
                            End With
                        Next
                    End If
                Next
            End If
        Next
    End Sub

    Private Sub XDocument_FindTableColumns(ByVal pXDoc As CscXDocLib.CscXDocument, ByVal lineIndex As Long, ByVal tablemodel As CASCADELib.CscTableModel, ByVal sortOrder() As Long, ByRef headerwords As CscXDocFieldAlternatives, ByRef results As CscXDocFieldAlternatives)
        Dim i, j, s, bestS, pageIndex As Long
        pageIndex = pXDoc.TextLines(lineIndex).PageIndex
        For s = pXDoc.TextLines(lineIndex).Words.Count - 1 To 0 Step -1
            'pXdoc.TextLines(lineIndex).Words(s).Top=0
            'pXDoc.Words.Remove(pXDoc.TextLines(lineIndex).Words(0).IndexOnDocument)
        Next
        Dim word As CscXDocWord
        For i = 0 To headerwords.Count - 1
            results.Create()
        Next
        For Each i In sortOrder
            'remove any header candidates that overlap with already found headers
            For j = 0 To results.Count - 1
                For s = headerwords(i).SubFields.Count - 1 To 0 Step -1
                    If Field_HorizontalOverlap(results(j), headerwords(i).SubFields(s)) > 0 Then headerwords(i).SubFields.Remove(s)
                Next
            Next
            'Find the best cluster of header words
            Dim bestConf As Double
            bestConf = 0
            bestS = -1
            For s = 0 To headerwords(i).SubFields.Count - 1
                If headerwords(i).SubFields(s).Confidence > bestConf Then
                    bestConf = headerwords(i).SubFields(s).Confidence
                    bestS = s
                End If
            Next
            If bestS > -1 Then
                Dim alt As CscXDocFieldAlternative
                alt = results(i)
                alt.Confidence = headerwords.Count - i 'so they sort in order
                With headerwords(i).SubFields(bestS)
                    For s = 0 To .Words.Count - 1
                        alt.Words.Append(.Words(s))
                    Next
                End With
                alt.Text = headerwords(i).Text & ";" & alt.Text
                word = New CscXDocWord
                Field_Copy(alt, word)
                word.Text = headerwords(I).Text
                word.PageIndex = pageIndex
                word.Top = pXDoc.TextLines(lineIndex).Top
                word.Height = pXDoc.TextLines(lineIndex).Height
                'pXdoc.Representations.ItemByName("FR").Pages(pXdoc.TextLines(lineIndex).PageIndex).AddWord(word)
            End If
        Next
        For I = results.Count - 1 To 0
            If results(I).Confidence = 0 Then results.Remove(I)
        Next
        'pXdoc.Representations.ItemByName("FR").qaLines
    End Sub

    Private Function XDocument_SearchLineFuzzy(ByVal pXDoc As CscXDocLib.CscXDocument, ByVal pageIndex As Long, ByVal compareText As String, ByRef confidence As Double) As Long
        Dim I, bestIndex As Long
        Dim conf, bestConf As Double
        bestConf = 0
        For I = 0 To pXDoc.Pages(pageIndex).TextLines.Count - 1
            Dim Text As String
             Text = pXDoc.Pages(pageIndex).TextLines(I).Text
                conf = String_FuzzyMatch(compareText, Text, True)
            If conf > bestConf Then bestConf = conf : bestIndex = I
        Next
        confidence = bestConf
        XDocument_SearchLineFuzzy = bestIndex
    End Function

    Private Function TextLine_IsTableHeader(ByVal textline As CscXDocTextLine, ByVal db As CASCADELib.CscDatabase) As Double
        Dim w As Long
        Dim conf As Double
        Dim score As Double
        Dim word As String
        Dim match As String
        For w = 0 To textline.Words.Count - 1
            word = LCase(Trim(textline.Words(w).Text))
            match = DataBase_SearchString(db, "headerword", word, conf)
            score = score + String_FuzzyMatch(match, word, True) * Len(word)
        Next
        score = score / (Len(textline.Text) - textline.Words.Count + 1)
        TextLine_IsTableHeader = score
    End Function

    Private Function String_RemoveCharacters(ByVal A As String, ByVal replaceChars As String) As String
        A = LCase(Trim(A))
        Dim I As Long
        For I = 1 To Len(replaceChars)
            A = Replace(A, Mid(replaceChars,I,1), "")
        Next
        Return A
    End Function

    Private Function DataBase_SearchExactInColumn(ByVal db As CASCADELib.CscDatabase, ByVal column As String, ByVal searchstring As String) As CscXDocLib.CscXDocField
        'This does an exact match for the searchstring in a specific column, no fuzziness at all
        'it returns ONLY 1 value. so if your database has more than one entry with this value, it could return the wrong one
        Dim results As CscXDocLib.CscXDocField
        results = Database_Search(db, column, searchstring, 1, 1.0#)
        If results.Alternatives.Count > 0 Then
            If results.Alternatives(0).SubFields.Exists(column) Then
                If results.Alternatives(0).SubFields.ItemByName(column).Text = searchstring Then
                    DataBase_SearchExactInColumn = results
                Else 'the searchstring is NOT in the correct column, so ignore all results
                    results = New CscXDocLib.CscXDocField
                End If
            Else 'the column doesn't exist in the database, so ignore all results
                results = New CscXDocLib.CscXDocField
            End If
        End If
        DataBase_SearchExactInColumn = results
    End Function

    Private Function DataBase_IsStringWithinColumn(ByVal db As CASCADELib.CscDatabase, ByVal column As String, ByVal searchstring As String, ByVal confidence As Double) As Boolean
        Dim results As CscXDocLib.CscXDocField
        results = Database_Search(db, "", searchstring, 5, confidence)
        Dim A As Long
        For A = 0 To results.Alternatives.Count - 1
            If Not results.Alternatives(A).SubFields.Exists(column) Then
                DataBase_IsStringWithinColumn = False
                Exit Function
            End If
            If results.Alternatives(A).SubFields.ItemByName(column).Text = searchstring Then
                DataBase_IsStringWithinColumn = True
                Exit Function
            End If
        Next
        DataBase_IsStringWithinColumn = False
    End Function


    Private Function DataBase_SearchString(ByVal db As CASCADELib.CscDatabase, ByVal column As String, ByVal searchstring As String, ByRef confidence As Double) As String
        'This returns the value in the chosen column based on the searchstring from the best search result.
        'the searchstring does not need to be in the column you want to retrieve. So you could return a first name based on a search for account number
        Dim results As CscXDocLib.CscXDocField
        results = Database_Search(db, column, searchstring, 2, confidence)
        If results.Alternatives.Count = 0 Then
            DataBase_SearchString = ""
            Exit Function
        End If
        Dim A, besta As Long
        Dim bestScore As Double
        bestScore = 0
        'We cannot assume that the first result is the best
        With results.Alternatives
            For A = 0 To .Count - 1
                'The database locator will return 100% for "ABCDE" when querying "ABC". We need to drop the score
                Dim ratio As Double
                ratio = Len(.ItemByIndex(A).Text) / Len(searchstring)
                If ratio < 1 Then .ItemByIndex(A).Confidence = .ItemByIndex(A).Confidence * ratio
                If .ItemByIndex(A).Confidence > bestScore Then
                    besta = A
                    bestScore = .ItemByIndex(A).Confidence
                End If
            Next
            confidence = bestScore
            DataBase_SearchString = results.Alternatives(besta).Text
        End With
    End Function

    Private Function Database_Search(ByVal db As CASCADELib.CscDatabase, ByVal column As String, ByVal searchstring As String, ByVal numberHits As Long, ByVal score As Double) As CscXDocLib.CscXDocField
        'if column i="" then all columns are returned as subfields
        'Set score=1.0 for exact match
        Dim Fields() As String
        Dim FieldIDs() As Long
        ReDim Fields(db.FieldCount)
        ReDim fieldisd(db.FieldCount)
        Fields(0) = searchstring
        FieldIDs(0) = 0
        'Find the column we are looking for
        Dim col As Long
        col = -1
        Dim i As Long
        For i = 0 To db.FieldCount - 1
            If db.FieldName(i) = column Then col = i
        Next
        If col = -1 And column <> "" Then Err.Raise(34589, , "Column '" & column & "' does not exist in database '" & db.Name & "'.")
        Dim hits As CASCADELib.CscDatabaseResItems
        hits = db.Search(Fields, FieldIDs, CASCADELib.CscQueryEvalMode.CscEvalMatchQuery, numberHits)
        Dim results As CscXDocLib.CscXDocField
        results = New CscXDocLib.CscXDocField  'You are allowed to create a standalone field
        For i = 0 To hits.Count - 1
            If hits(i).Score >= score Then
                Dim alt As CscXDocFieldAlternative
                alt = results.Alternatives.Create()
                alt.Confidence = hits(i).Score
                If col = -1 Then 'the column is "", so we return all fields
                    Dim c As Long
                    For c = 0 To db.FieldCount - 1
                        alt.SubFields.Create(db.FieldName(c))
                        alt.SubFields(c).Text = db.GetRecordData(hits(i).RecID)(c)
                        alt.SubFields(c).Confidence = hits(i).Score
                    Next
                    alt.Text = ""
                Else
                    alt.Text = db.GetRecordData(hits(i).RecID)(col)
                End If
            End If
        Next
        Database_Search = results
    End Function

    Private Function Subfields_Conflate(ByRef clusters As CscXDocSubFields, ByVal horizontalOnly As Boolean, ByVal maxDistance As Long) As Double
        'This merges subfields that are within maxDistance pixels of each other
        'returns the best confidence of the conflated fields
        Dim c As Long
        Dim d As Long
        c = 0
        Dim conf As Double
        conf = 0
        While c < clusters.Count - 1
            d = c + 1
            While d < clusters.Count
                Dim distance As Long
                If horizontalOnly Then
                    distance = HorizontalDistance(clusters(c), clusters(d))
                Else
                    distance = Rectangle_Distance(clusters(c), clusters(d))
                End If
                If distance < maxDistance Then
                    Field_Append(clusters(c), clusters(d))
                    clusters.Remove(d)
                    If clusters(c).Confidence > conf Then conf = clusters(c).Confidence
                Else
                    d = d + 1
                End If
            Wend
            c = c + 1
        Wend
        Subfields_Conflate = conf
    End Function

    Private Sub Field_Append(ByRef A As CscXDocSubField, ByRef b As CscXDocSubField)
        'Appends all words from a to b, and adds their confidence
        Dim w As Long
        For w = 0 To b.Words.Count - 1
            A.Words.Append(b.Words(w))
        Next
        Dim conf As Double
        conf = A.Confidence + b.Confidence 'we are using confidence to count members
        A.Confidence = conf
    End Sub

    Private Function Field_HorizontalOverlap2D(ByVal A As Object, ByVal b As Object, Optional ByVal offset As Long = 0) As Double
        'returns percentage overlap of two fields, subfields or alternatives (0.0 if no overlap, 1.0 if perfect overlap)
        'Check if fields are on the same page and that both exist
        'the offset is how many pixels object b needs to be shifted horizontally - used for page registration
        If A.PageIndex <> b.PageIndex Or A.PageIndex = -1 Then Return 0
        Dim overlapArea As Double
        overlapArea = Max((Min(A.Left + A.Width, b.Left + b.Width + offset) - Max(A.Left, b.Left + offset)), 0) * _
                    Max((Min(A.Top + A.Height, b.Top + b.Height) - Max(A.Top, b.Top)), 0)
        Return overlapArea / Max(A.Width * A.Height, b.Width * b.Height)
    End Function

    Private Function Field_HorizontalOverlap(ByVal A As Object, ByVal b As Object, Optional ByVal offset As Long = 0, Optional ByVal ignorePage As Boolean = False) As Double
        'Calculates the horizontal overlap of two fields and returns 0<=overlap<=1
        'Overlap=1 is also returned if one field is inside the other
        If (Not ignorePage And (A.PageIndex <> b.PageIndex)) Or A.PageIndex = -1 Then Return 0
        If A.Width = 0 Or b.Width = 0 Then Return 0
        Dim o As Double
        o = Max((Min(A.Left + A.Width, b.Left + b.Width + offset) - Max(A.Left, b.Left + offset)), 0)
        Return o / Min(A.Width, b.Width)
    End Function

    Private Function Field_VerticalOverlap(ByVal A As Object, ByVal b As Object, Optional ByVal ignorePage As Boolean = False) As Double
        'Calculates the horizontal overlap of two fields and returns 0<=overlap<=1
        'Overlap=1 is also returned if one field is inside the other
        Dim o As Double
        If (Not ignorePage And (A.PageIndex <> b.PageIndex)) Or A.PageIndex = -1 Then Return 0
        If A.Height = 0 Or b.Height = 0 Then Return 0
        o = Max((Min(A.Top + A.Height, b.Top + b.Height) - Max(A.Top, b.Top)), 0)
        Field_VerticalOverlap = o / Min(A.Height, b.Height)
    End Function

    Private Function Field_HasConfidence(ByVal A As Object) As Boolean
        Field_HasConfidence = TypeOf A Is CscXDocLib.CscXDocField Or TypeOf A Is CscXDocFieldAlternative Or TypeOf A Is CscXDocSubField
    End Function

    Private Function Field_HasWords(ByVal A As Object) As Boolean
        If Not (TypeOf A Is CscXDocLib.CscXDocField Or TypeOf A Is CscXDocSubField Or TypeOf A Is CscXDocFieldAlternative) Then Field_HasWords = False : Exit Function
        Return A.Words.Count > 0
    End Function

    Private Function Field_HasSubFields(ByVal A As Object) As Boolean
        Field_HasSubFields = TypeOf A Is CscXDocLib.CscXDocField Or TypeOf A Is CscXDocFieldAlternative
    End Function

    Private Sub Field_Copy(ByVal A As Object, ByVal b As Object, Optional ByVal Append As Boolean = False)
        Dim i As Long
        If Not Append Then
            If TypeOf b Is CscXDocLib.CscXDocField Then
                While b.Alternatives.Count > 0
                    b.Alternatives.Remove(0)
                Wend
            ElseIf TypeOf b Is CscXDocFieldAlternative Then
                b.SubFields.Clear()
            ElseIf TypeOf b Is CscXDocTable Then
                b.Rows.Clear()
            End If
            If Field_HasWords(b) Then
                While b.Words.Count > 0
                    b.Words.Remove(0)
                Wend
            End If
            b.Text = ""
        End If
        If Field_HasWords(A) And Field_HasWords(b) Then
            For i = 0 To A.Words.Count - 1
                b.Words.Append(A.Words(i))
            Next
        ElseIf TypeOf A Is CscXDocLib.ICscXDocLine And Not TypeOf B Is CscXDocLib.ICscXDocLine Then
            B.Top = A.StartY
            B.Left = A.StartX
            B.Width = A.EndX - A.StartX
            B.Height = A.EndY - A.StartY
            B.Confidence = 1
        Else
            B.Top = A.Top
            B.Left = A.Left
            B.Width = A.Width
            B.Height = A.Height
            If Append Then B.Text = Replace(B.Text & " " & A.Text, " ", "  ") Else B.Text = Trim(A.Text)
        End If
        B.PageIndex = A.PageIndex
        If Field_HasConfidence(A) And Field_HasConfidence(B) Then B.Confidence = A.Confidence
        If Field_HasSubFields(A) And Field_HasSubFields(B) Then
            For i = 0 To A.SubFields.Count - 1
                Field_Copy(A.SubFields(i), B.SubFields.Create(A.SubFields(i).Name))
            Next
        End If
        If TypeOf A Is CscXDocLib.CscXDocField Or TypeOf B Is CscXDocLib.CscXDocField Then
            For i = 0 To A.Alternatives.Count - 1
                Field_Copy(A.Alternatives(i), B.Alternatives.Create())
            Next
        End If
    End Sub


    Private Function String_FuzzyMatch(ByVal A As String, ByVal B As String, ByVal RemoveSpaces As Boolean) As Double
        If RemoveSpaces Then
            A = Replace(A, " ", "")
            B = Replace(B, " ", "")
        End If
        Dim length As Long
        length = Max(Len(A), Len(B))
        If length = 0 Then String_FuzzyMatch = 0 : Exit Function
        Dim distance As Long
        distance = String_LevenshteinDistance(A, B)
        String_FuzzyMatch = CDbl(1.0# - (distance / length) ^ 2)
    End Function

    Private Function String_LevenshteinDistance(ByVal A As String, ByVal B As String)
        'http://en.wikipedia.org/wiki/Levenshtein_distance
        'Levenshtein distance between two strings, used for fuzzy matching
        Dim i As Long, j As Long, cost As Long, subs As Long
        Dim ins As Long
        Dim dels As Long
        Dim d() As Long
        If Len(A) = 0 Then String_LevenshteinDistance = Len(B) : Exit Function
        If Len(B) = 0 Then String_LevenshteinDistance = Len(A) : Exit Function
        ReDim d(Len(A), Len(B))
        For i = 0 To Len(A)
            d(i, 0) = i
        Next
        For j = 0 To Len(B)
            d(0, j) = j
        Next
        For i = 1 To Len(A)
            For j = 1 To Len(B)
                If Mid(A, i, 1) = Mid(B, j, 1) Then cost = 0 Else cost = 1 ' cost of substitution
                dels = (d(i - 1, j) + 1)     ' cost of deletion
                ins = (d(i, j - 1) + 1)     ' cost of insertion
                subs = (d(i - 1, j - 1) + cost)     'cost of substition or match
                d(i, j) = Min(ins, Min(dels, subs))
            Next
        Next
        String_LevenshteinDistance = d(Len(A), Len(b))
    End Function


    Private Sub Lines_FindBestCluster(ByVal Lines As CscXDocLines, ByVal direction As CscXDocLib.CscXDocLineDirections, ByRef clusteredLines As CscXDocFieldAlternatives)
        Dim clusters As CscXDocField
        clusters = New CscXDocField
        Dim bestclusters() As Long
        Dim overlap, bestoverlap As Double
        Dim sf As CscXDocSubField
        Dim i, j, bestC As Long

        For i = 0 To Lines.Count - 1
            If Lines(i).Direction = direction Then
                bestC = 0
                bestoverlap = 0
                For j = 0 To clusters.Alternatives.Count - 1
                    Select Case direction
                        Case CscXDocLib.CscXDocLineDirections.CscXDocLineDirectionHorizontal
                            overlap = Line_HorizontalOverlap(Lines(i), clusters.Alternatives(j).SubFields(0))
                        Case CscXDocLib.CscXDocLineDirections.CscXDocLineDirectionVertical
                            overlap = Line_VerticalOverlap(Lines(i), clusters.Alternatives(j).SubFields(0))
                    End Select
                    If overlap > bestoverlap Then
                        bestoverlap = overlap
                        bestC = j
                    End If
                Next
                If bestoverlap > 0.8 Then
                    sf = clusters.Alternatives(bestC).SubFields.Create("a")
                Else
                    sf = clusters.Alternatives.Create.SubFields.Create("a")
                End If
                Field_Copy(Lines(i), sf)
            End If
        Next
        For i = 0 To clusters.Alternatives.Count - 1
            clusters.Alternatives(i).Confidence = clusters.Alternatives(i).SubFields.Count
        Next
        If clusters.Alternatives.Count = 0 Then Exit Sub
        bestclusters = Alternatives_GetSortOrder(clusters.Alternatives)
        If UBound(bestclusters) > -1 Then
            With clusters.Alternatives(bestclusters(0))
                For i = 0 To .SubFields.Count - 1
                    Field_Copy(.SubFields(i), clusteredLines.Create)
                Next
            End With
        End If
    End Sub


    Private Function Table_Overlap(ByVal table As CscXDocTable, ByVal f As Object) As Boolean
        Dim t As New CscXDocLib.CscXDocField
        t.PageIndex = f.PageIndex
        t.Top = table.Top(f.PageIndex)
        t.Height = table.Height(f.PageIndex)
        Table_Overlap = Field_VerticalOverlap(f, t) > 0
        Exit Function
        'this code below is wrong
        'If f.pageIndex < 0 Then Exit Function
        'Dim tabletop As Long
        'Dim tablebottom As Long
        'tabletop = table.Top(f.pageIndex)
        'tablebottom = tabletop + table.Height(f.pageIndex)
        'Table_Overlap = (f.Top + f.Height > tabletop And f.Top < tablebottom)
    End Function

    Private Function XDocument_FindLeftTextMargin(ByVal pXDoc As CscXDocLib.CscXDocument, ByVal p As Long) As Long
        'Assuming that most of each page is left aligned, we find the left text margin on each page
        Dim clusters As New CscXDocLib.CscXDocField
        Dim textline As CscXDocTextLine
        Dim bestclusterIndexes() As Long
        Dim l, c As Long
        Dim found As Boolean
        For l = 0 To pXDoc.Pages(p).TextLines.Count - 1
            found = False
            textline = pXDoc.Pages(p).TextLines(l)
            For c = 0 To clusters.Alternatives.Count - 1
                If Abs(clusters.Alternatives(c).SubFields(0).Left - textline.Left) < 30 Then
                    With clusters.Alternatives(c).SubFields().Create(CStr(l))
                        .Left = textline.Left
                    End With
                    found = True
                    Exit For
                End If
            Next
            If Not found Then
                With clusters.Alternatives.Create.SubFields().Create(CStr(l))
                    .Left = textline.Left
                End With
            End If
        Next
        'Store subfield.count into alt.conf because the sort return sorts best confidence of alts
        For l = 0 To clusters.Alternatives.Count - 1
            clusters.Alternatives(l).Confidence = clusters.Alternatives(l).SubFields.Count
        Next
        bestclusterIndexes = Alternatives_GetSortOrder(clusters.Alternatives)
        If UBound(bestclusterIndexes) < 0 Then XDocument_FindLeftTextMargin = -1 : Exit Function
        l = 0
        'return the average left margin coordinate of this largest cluster of lines
        With clusters.Alternatives(bestclusterIndexes(0))
            For c = 0 To .SubFields.Count - 1
                l = l + .SubFields(c).Left
            Next
            XDocument_FindLeftTextMargin = l / .SubFields.Count
        End With
    End Function

    Private Function Table_SumColumn(ByVal table As CscXDocTable, ByVal colID As Long, ByVal amountFormatter As CASCADELib.ICscFieldFormatter, ByRef valid As Boolean) As Double
        'Sums a column in a database and returns false if any cell is invalid
        Table_SumColumn = table.GetColumnSum(colID, valid) : Exit Function
        'Dim sum As Double
        'Dim r As Long
        'Dim cell As CscXDocLib.CscXDocTableCell
        'sum = 0
        'For r = 0 To table.Rows.Count - 1
        '    cell = table.Rows(r).Cells(colID)
        '    amountFormatter.FormatTableCell(cell)
        '    If Not cell.DoubleFormatted Then valid = False : Table_SumColumn = 0 : Exit Function
        '    sum = sum + cell.DoubleValue
        'Next
        'valid = True
        'Table_SumColumn = sum
    End Function

    Private Function Page_GroupTextLinesBySimilarity(ByVal textLines As CscXDocTextLines, ByVal startLineIndex As Long, ByVal stopLineIndex As Long, ByVal clusterFuzzyMatch As Double, ByRef clusters As CscXDocLib.CscXDocField, ByVal createNewClusters As Boolean) As CscXDocLib.CscXDocField
        'This starts on page p at line lineindex and looks downward grouping text lines together that are "fuzzily similar". It returns a collection of all textlines on the page grouped together.
        'rows of a table will cluster together because they are "fuzzily similar"
        Dim l, c, s As Long
        Dim sf As CscXDocSubField
        Dim score As Double
        Dim found As Boolean
        Dim textline As String
        Dim textlinePattern As String
        'Convert the user friendly pattern to the confidential & internal fuzzy match pattern
        textlinePattern = Replace(LINEITEMPATTERN, "c", "Ж")
        textlinePattern = Replace(textlinePattern, "n", "00")
        textlinePattern = Replace(textlinePattern, "d", "00,00")
        textlinePattern = Replace(textlinePattern, "p", "18%")
        textlinePattern = String_StrongNormalize(textlinePattern)
        ''TODO the best cluster is not the largest, but the one that best matches textlinepattern

        For l = startLineIndex To stopLineIndex 'todo - only go as far as end of table to save CPU time, not to end of page
            textline = String_StrongNormalize(textLines(l).Text)
            found = False
            For c = 0 To clusters.Alternatives.Count - 1
                With clusters.Alternatives(c)
                    For s = 0 To .SubFields.Count - 1
                        score = String_FuzzyMatch(textline, .SubFields(s).Text, False)
                        'dl.WriteLine(score.ToString("0.00%") & textLines(l).Text)
                        If score > clusterFuzzyMatch Then
                            found = True
                            sf = .SubFields.Create(CStr(s))
                            sf.LongTag = l
                            sf.Text = textline
                            sf.Confidence = score
                            Exit For
                        End If
                    Next
                End With
                If found Then Exit For
            Next
            If Not found And createNewClusters Then
                With clusters.Alternatives.Create.SubFields.Create("0")
                    .Words.Append(textLines(l).Words(0))
                    .Text = textline
                    .Confidence = score
                    .LongTag = l
                End With
            End If
        Next
        For l = 0 To clusters.Alternatives.Count - 1
            With clusters.Alternatives(l)
                'The best cluster is the largest cluster (works for long tables with varying wordwrap)
                .Confidence = .SubFields.Count
                'the best cluster is the cluster that looks most like a typical line pattern (works also for single line tables)
                'TODO TODAY .Confidence = String_FuzzyMatch(textlinePattern, String_StrongNormalize(.SubFields(0).Text), False)
            End With

        Next
        Return clusters
    End Function

    Private Function Object_Compare(ByVal A As Object, ByVal b As Object) As Boolean
        Return A.Conf > b.Conf
    End Function

    Private Sub Table_InsertRow(ByVal pXDoc As CscXDocLib.CscXDocument, ByVal headers As CscXDocFieldAlternatives, ByVal lineIndex As Long, ByVal table As CscXDocTable, ByVal offset As Long)
        Dim w, r, colIndex As Long
        Dim word As CscXDocWord
        Dim row As CscXDocTableRow
        If table.Rows.Count = 0 Or TextLine_IsGraphicalLineAbove(pXDoc, lineIndex, HorizontalLines.Alternatives) Then
            'dl.WriteLine("Appended new row")
            row = table.Rows.Append()
        Else
            'dl.WriteLine("inserted to existing row")
            row = table.Rows(table.Rows.Count - 1)
        End If
        'If we have wrapped to a second page then start a new row
        'TODO we should also check that if the net,total,tax columns already have values in them, we MUST START A NEW ROW, irrespective of line detection.
        If row.IndexInTable > 0 Then
            If (pXDoc.TextLines(lineIndex).PageIndex <> table.Rows(row.IndexInTable - 1).StartPage) Then row = table.Rows.Append
        End If
        If (row.Cells.ItemByName("Total Price").Text <> "" Or row.Cells.ItemByName("Quantity").Text <> "") And String_CountDigits(pXDoc.TextLines(lineIndex).Text) > 12 Then row = table.Rows.Append
        For w = 0 To pXDoc.TextLines(lineIndex).Words.Count - 1
            word = pXDoc.TextLines(lineIndex).Words(w)
            For r = 0 To headers.Count - 1
                If Field_HorizontalOverlap(word, headers(r), offset, True) > 0 Then
                    Dim colName As String
                    colName = Trim(Split(headers(r).Text, ";")(0))
                    colIndex = table.Columns.ItemByName(colName).IndexInTable
                    row.Cells(colIndex).AddWordData(word)
                    Exit For
                End If
            Next
        Next
        'dl.WriteLine("table-row: " & msg)
    End Sub

    Private Function TextLine_IsGraphicalLineAbove(ByVal pXDoc As CscXDocLib.CscXDocument, ByVal lineIndex As Long, ByVal graphicalLines As CscXDocFieldAlternatives) As Boolean
        Dim pixelabove, pixelbelow, g As Long
        pixelbelow = pXDoc.TextLines(lineIndex).Top + pXDoc.TextLines(lineIndex).Height / 2
        If lineIndex > 1 Then pixelabove = pXDoc.TextLines(lineIndex - 1).Top + pXDoc.TextLines(lineIndex - 1).Height / 2 Else pixelabove = 0 'check page as well
        For g = 0 To graphicalLines.Count - 1
            If pXDoc.TextLines(lineIndex).PageIndex = graphicalLines(g).PageIndex And graphicalLines(g).Top >= pixelabove And graphicalLines(g).Top <= pixelbelow Then Return True
        Next
        Return False
    End Function

    Private Function String_StrongNormalize(ByVal t As String) As String
        'reduces every character to string to character set. eg "aBc $123.56" ->"a ?000.00"
        Dim ch, out As String
        out = ""
        Dim i As Long
        For i = 1 To Len(t)
            ch = Mid(t, i, 1)
            Select Case AscW(ch)
                Case Is > &H4F9  'beyond Cyrillic
                    out = out & "?"
                Case Is > &H400  'Cyrillic
                    out = out & "c"
                Case Is > &HBF   'Page 2 utf-8
                    out = out & "a"
                Case Is > &H7A
                    'ignore strange characters
                Case Is > &H40   'Alphabetic
                    out = out & "a"
                Case Is > &H39    ':;<=>?@
                    out = out & " "
                Case Is > &H2F   ' numeric
                    out = out & "0"
                Case &H25, &H2C, &H2D, &H2E      ' %,-.
                    out = out & ch
                Case Is > &H19   ' keep spaces
                    out = out & " "
                Case Else
                    'ignore lower ASCII
            End Select
        Next
        While InStr(out, "cc")
            out = Replace(out, "cc", "c")
        Wend
        While InStr(out, "aa")
            out = Replace(out, "aa", "a")
        Wend
        While InStr(out, "c c ")
            out = Replace(out, "c c ", "c ")
        Wend
        While InStr(out, "a a ")
            out = Replace(out, "a a ", "a ")
        Wend
        While InStr(out, "  ")
            out = Replace(out, "  ", " ")
        Wend
        Return out
    End Function

    Private Function Alternatives_GetSortOrder(ByVal alts As Object) As Long()
        Dim i, sortOrder() As Long
        ReDim sortOrder(alts.Count - 1)
        If alts.Count = 0 Then Return sortOrder
        Dim refs As New List(Of alt)
        For i = 0 To alts.Count - 1
            Dim alt As New alt
            alt.ID = i
            alt.Conf = alts(i).Confidence
            refs.Add(alt)
        Next
        refs.Sort(New AltComparer)
        '        Objects_Sort(refs)
        For i = 0 To refs.Count - 1
            sortOrder(i) = refs(i).ID
        Next
        Return sortOrder
    End Function



    Private Function Rectangle_Distance(ByVal a As Object, ByVal b As Object) As Long
        Dim vertDistance As Long
        vertDistance = Abs(b.Top + b.Height / 2 - a.Top - a.Height / 2) - b.Height / 2 - a.Height / 2
        Dim horDistance As Long
        horDistance = Abs(b.Left + b.Width / 2 - a.Left - a.Width / 2) - b.Width / 2 - a.Width / 2
        Return Max(Max(vertDistance, horDistance), 0)
    End Function

    Private Function HorizontalDistance(ByVal a As Object, ByVal b As Object) As Long
        Dim horDistance As Long
        horDistance = Abs(b.Left + b.Width / 2 - a.Left - a.Width / 2) - b.Width / 2 - a.Width / 2
        Return Max(horDistance, 0)
    End Function

    Private Sub Objects_Sort(ByRef a As Object)
        Quicksort(a, 0, UBound(a))
    End Sub

    Private Sub Quicksort(ByRef a As Object, ByVal Left As Long, ByVal Right As Long)
        Dim pivot As Long
        If Right > Left Then
            pivot = Quicksort_GetPivot(Left, Right)
            pivot = Quicksort_Partition(a, Left, Right, pivot)
            Quicksort(a, Left, pivot)
            Quicksort(a, pivot + 1, Right)
        End If
    End Sub

    Private Function Quicksort_GetPivot(ByVal Left As Long, ByVal Right As Long) As Long
        'Return a random Long between Left and Right
        Return (Rnd() * (Right - Left + 1) * 1000) Mod (Right - Left + 1) + Left
    End Function

    Private Function Quicksort_Partition(ByRef a As Object, ByVal l As Long, ByVal r As Long, ByRef pivot As Long) As Long
        Dim i, store As Long
        Dim piv As Object
        piv = a(pivot)
        Object_Swap(a(r), a(pivot))
        store = l
        For i = l To r - 1
            If Object_Compare(a(i), piv) Then
                Object_Swap(a(store), a(i))
                store = store + 1
            End If
        Next
        Object_Swap(a(r), a(store))
        Return store
    End Function

    Private Sub Object_Swap(ByRef v1, ByRef v2)
        Dim tmp As Object
        tmp = v1
        v1 = v2
        v2 = tmp
    End Sub

    Function TableModel_CreateColumnIndex(ByVal TABLEMODELNAME As String) As Dictionary
        Dim colIDs As New Dictionary
        Dim i As Long, cols As Long
        Dim tablemodel As CASCADELib.CscTableModel
        tablemodel = Project.TableModels.ItemByName(TABLEMODELNAME)
        cols = tablemodel.ModelColumns.Count
        For i = 0 To cols - 1
            Dim colName As String
            colName = Project.GlobalColumns.ItemByID(tablemodel.ModelColumns(i).GlobalColumnID).DisplayName
            colIDs.Add(colName, i)
        Next
        Return colIDs
    End Function

    Private Function Line_HorizontalOverlap(ByVal a As Object, ByVal b As Object) As Double
        'Calculates the horizontal overlap of two fields and returns 0<=overlap<=1
        Dim o As Double
        If TypeOf A Is CscXDocLib.ICscXDocLine Then
            If A.StartX = A.EndX Or b.Width = 0 Then Return 0
            o = Max((Min(A.EndX, b.Left + b.Width) - Max(A.StartX, b.Left)), 0)
            Return o / Max(A.EndX - A.StartX, b.Width)
        Else
            If A.Width = 0 Or b.Width = 0 Then Return 0
            o = Max((Min(A.Left + A.Width, b.Left + b.Width) - Max(A.Left, b.Left)), 0)
            Return o / Max(A.Width, b.Width)
        End If
    End Function

    Private Function Line_VerticalOverlap(ByVal a As Object, ByVal b As Object) As Double
        'Calculates the vertical overlap of two fields and returns 0<=overlap<=1
        Dim o As Double
        If TypeOf a Is CscXDocLib.ICscXDocLine Then
            If a.EndY = a.StartY Or b.Height = 0 Then Return 0
            o = Max((Min(a.EndY, b.Top + b.Height) - Max(a.StartY, b.Top)), 0)
            Return o / Max(a.EndY - a.StartY, b.Height)
        Else
            o = Max((Min(a.Top + a.Height, b.Top + b.Height) - Max(a.Top, b.Top)), 0)
            Return o / Max(a.Height, b.Height)
        End If
    End Function


    Private Sub EndOfTable(ByVal pXDoc As CASCADELib.CscXDocument, ByVal DBLoc As CscXDocLib.CscXDocField, ByVal pLocator As CASCADELib.CscXDocField)
        'This looks for the endOfTable, by checking DB_EndOfTable results
        'TODO: This is buggy because I need to check the page of the endof table. if it is not on the same page as the header i should not remove the alt
        'TODO: I think this will fail if DB_EndOfTable finds nothing
        Dim startLineIndex, startLinePixel As Long
        startLineIndex = Headers.Alternatives(0).LongTag + 1
        startLinePixel = pXDoc.TextLines(startLineIndex).Top + pXDoc.TextLines(startLineIndex).Height
        Dim pageWidth As Long
        pageWidth = pXDoc.CDoc.Pages(0).Width
        EndOfTablePixel = 2000000
        Dim i As Long
        For i = DBLoc.Alternatives.Count - 1 To 0 Step -1
            With DBLoc.Alternatives(i).SubFields(0)
                'We don't trust the confidences coming from DBLocator because a search for "ABC DEF" in "DEFx sf ABCfgdf" will return 100%, so we recalculate the scores
                Dim words As CscXDocWords
                words = pXDoc.GetWordsInRect(.PageIndex, .Left, .Top, .Width, .Height)
                If words.Count > 0 Then .Confidence = String_FuzzyMatch(.Text, words.Text, True)
                If (.PageIndex = 0 And .Top <= startLinePixel) Or .Left > pageWidth * 0.5 Or .Confidence < 0.7 Then
                    DBLoc.Alternatives.Remove(i)
                Else
                    If .Top < EndOfTablePixel Then EndOfTablePixel = .Top : EndOfTablePage = .PageIndex
                End If
            End With
        Next
        Field_Copy(DBLoc, pLocator)
    End Sub

    Private Function String_FormatAsDouble(ByVal a As String, Optional ByVal amountFormatter As String = "") As Double
        Dim f As New CscXDocLib.CscXDocField
        If amountFormatter = "" Then amountFormatter = Project.DefaultAmountFormatter
        f.Text = a
        Project.FieldFormatters.ItemByName(amountFormatter).FormatField(f)
        Return f.DoubleValue
    End Function

    Private Function String_CountDigits(ByVal a As String) As Long
        Dim r, c As Long
        For r = 1 To Len(a)
            Select Case AscW(Mid(a, r, 1))
                Case &H30 To &H39
                    c = c + 1
            End Select
        Next
        Return c
    End Function

Function Max (a,b)
   Return If(a>b,a,b)
End Function
Function Min (a,b)
   Return If(a<b,a,b)
End Function

```

### Detecting Table Headers
Add the following to a dictionary file with substitutions and add it to a format locator, and in place of a regex add the dictionary reference. This locator will identify all the words in the headers and label them. The file below was generated by automatic analysis of many Russian invoices - any OCR errors appearing were common.
```
headerword;columns
^дрда^сапр;Net_Amount
^единица;Unit_Measure
^имущественных;Net_Amount
^налога;Total_Price
«нш1ы«е;Unit_Measure
•л;Total_Price
1мущсствс1пых;Net_Amount
1рав;Description
1том;Total_Price
1х;Total_Price
1ца;Unit_Measure
1циф;Country_Of_Origin_Code
1чество;Quantity
1я;Unit_Measure
6м;Total_Price
i;Unit_Price,Net_Amount,Description,Customs_Declaration,Unit_Measure
№;Description,Position
а;Description
аединицу;Unit_Price
азанных;Description
ак-;Excise
акц;Excise
акци;Excise
акциз;Excise
акциза;Excise
акциэ;Excise
акш13;Excise
акшрз;Excise
аможей-•;Customs_Declaration
ана;Country_Of_Origin,Country_Of_Origin_Code
арти-;Article_Code
артикула;Article_Code
аьтполиенних;Description
ая;Tax_Amount,Tax_Rate
б;Excise
без;Net_Amount
бот;Total_Price
в;Excise
в5;Unit_Measure
валю;Currency
валюты;Currency
вание;Currency
вара;Article_Code
вая;Tax_Rate
венных;Net_Amount,Total_Price
веного;Description
во;Quantity
вой;Country_Of_Origin_Code
всего;Net_Amount,Total_Price
всогосучетои;Total_Price
вщика;Article_Code
вы;Description
вылолненных;Description
вып;Description
выполненных;Description
выполнены;Description
выполненых;Description
вьшолненшх;Description
г;Description,Country_Of_Origin
-г";Quantity
говая;Tax_Rate
говея;Tax_Rate
гроиосож-;Country_Of_Origin
гроисхож;Country_Of_Origin
д;Country_Of_Origin
дек;Customs_Declaration
декла;Customs_Declaration
деклар;Customs_Declaration
деклара-ц;Customs_Declaration
декларации;Customs_Declaration
декларацик;Customs_Declaration
декпарач;Customs_Declaration
дения;Country_Of_Origin
дех;Customs_Declaration
е;Excise
е^е^иницу;Unit_Price
ед;Unit_Measure,Unit_Price
еди;Unit_Measure
еди-;Unit_Measure
един;Unit_Price,Unit_Measure
едини;Unit_Measure
единиц;Unit_Price
единица;Unit_Measure,Unit_Of_Measure_Code
единицу;Unit_Price
единицу-;Unit_Price
ел;Unit_Price
енных;Net_Amount
ждения;Country_Of_Origin
женной;Customs_Declaration
за;Unit_Price
зава;Description
заед;Unit_Price
зая;Tax_Rate
и2мераньц1;Unit_Price
йалогом;Total_Price
иаме-;Unit_Measure
иг;Description
ие;Country_Of_Origin
из;Unit_Measure
из-;Unit_Measure
изм;Unit_Price,Unit_Measure
изме;Unit_Measure
изме-;Unit_Price,Unit_Measure
измер;Unit_Price
измере;Unit_Price
измере-;Unit_Price
измёре-;Unit_Measure
измерен;Unit_Price
изме-рен;Unit_Measure
измерения;Unit_Price,Unit_Of_Measure_Code,Unit_Measure
измс-;Unit_Measure
ии;Customs_Declaration,Country_Of_Origin
ииущипвенньи;Net_Amount
йия;Unit_Measure
ику-;Total_Price
именование;Description
иму-;Net_Amount
иму1цествен;Total_Price
имуирственных;Total_Price
имуцеотвен-;Total_Price
имущ;Net_Amount,Total_Price
имущвстаеквого;Description
имущесгцо1л10п;Description
имущест;Net_Amount,Total_Price
имущест-;Description,Net_Amount,Total_Price
имуществ;Total_Price,Net_Amount
имуществе;Description
имуществен;Net_Amount,Total_Price
имущественн;Net_Amount,Total_Price
имущественно;Description
имущественного;Description
имущественною;Description
имущественные;Description
имущественных;Total_Price,Net_Amount,Description
имуще-ственных;Net_Amount
имуществправ;Net_Amount
имуществрогр;Description
имущостбонньп;Total_Price
имущправ;Net_Amount,Total_Price
иниэм;Unit_Price
иного;Description
инуществен-;Total_Price
исх;Country_Of_Origin
исхождения;Country_Of_Origin
ица;Unit_Measure
иэ;Unit_Measure
иэм;Unit_Measure
ия;Unit_Measure,Unit_Price
к<к;Unit_Of_Measure_Code
ка;Tax_Rate
казанных;Description
каименовавие;Description
канмбнова1ие;Description
кие;Currency
кипа;Unit_Measure
код;Unit_Of_Measure_Code,Country_Of_Origin_Code,Article_Code
кож-;Country_Of_Origin
кол-;Quantity
кол-во;Quantity
коли;Quantity
коли-;Quantity
количе;Quantity
количество;Quantity
коп;Quantity
коп-;Quantity
копи-;Quantity
краткое;Country_Of_Origin
кула1покупа-;Article_Code
л;Description
лё;Excise
лекпараши;Customs_Declaration
лого^;Tax_Rate
локупа;Tax_Amount
лрав;Total_Price
лрава;Description
лрвдьяв;Tax_Amount
лссго;Total_Price
луг;Net_Amount,Total_Price,Description
ля;Article_Code
ляеман;Tax_Amount
ляемая;Tax_Amount
малого;Tax_Rate
ме;Unit_Measure
меженной;Customs_Declaration
мма;Tax_Amount
на-;Description
над;Unit_Measure
надо-;Tax_Rate
наиманоыание;Description
наиме;Currency
найме;Currency
найме-;Currency
наимен;Currency
наименаваяиет&вара;Description
наимено;Currency
наиме-но;Currency
наименова;Country_Of_Origin
наименован;Country_Of_Origin
наименование;Description,Country_Of_Origin
наименований;Description
наименоеание;Description
нал;Net_Amount,Tax_Rate,Total_Price
нало;Tax_Rate
нало-;Tax_Rate
налог;Tax_Rate
налога;Net_Amount,Tax_Amount,Total_Price
налога";Net_Amount
налоге;Total_Price
налого;Tax_Rate
налого-;Tax_Rate
нало-го;Tax_Rate
налогов;Tax_Rate
налоговая;Tax_Rate
налогом;Total_Price
нальное;Unit_Measure
нацио;Unit_Measure
национально;Unit_Measure
национальное;Unit_Measure
не-;Unit_Measure
нелогом-;Total_Price
ни;Customs_Declaration
ние;Country_Of_Origin,Currency
нил;Country_Of_Origin
нио;Country_Of_Origin
них;Net_Amount
ница;Unit_Measure
ния;Unit_Measure,Country_Of_Origin,Unit_Price
ннца;Unit_Measure
нова;Currency
нование;Currency
нойкетарации;Customs_Declaration
ном;Customs_Declaration
номер;Customs_Declaration,Article_Code
номфр;Article_Code
нрава;Description
нчвс1ъеного;Description
ных;Net_Amount,Total_Price
ньгх;Total_Price
нэп;Tax_Rate
о;Total_Price,Description,Tax_Rate
оаание;Currency
обоза;Unit_Measure
обозна;Unit_Measure
обозначение;Unit_Measure
объем;Quantity
объём;Quantity
ов;Total_Price
огаэанныкуслуг;Description
ого;Tax_Rate
огоикость;Net_Amount
огоимость;Total_Price
ождени;Country_Of_Origin
ой;Customs_Declaration
оказанных;Description
оказе^нных;Description
окезашшх;Description
олнсюгис;Description
опи-;Description
описание;Description
описаний;Description
описаяие;Description
орав;Total_Price
от;Country_Of_Origin
п;Description,Position
пало-;Tax_Rate
пмушёствеилых;Total_Price
по4агелю;Tax_Amount
покупа;Tax_Amount
покупате;Article_Code
покупатели;Tax_Amount
покупателю;Tax_Amount
покупателя;Article_Code
поливных;Description
полненньа;Description
полога;Tax_Amount
пра;Total_Price
праа;Net_Amount,Total_Price
прав;Net_Amount,Total_Price,Description
права;Description
праввсего;Total_Price
праэ;Total_Price
предъяв;Tax_Amount
предъявляв;Tax_Amount
предъявляем;Tax_Amount
предъявляемая;Tax_Amount
про;Country_Of_Origin
про1;Country_Of_Origin
проиохож;Country_Of_Origin
проис;Country_Of_Origin,Country_Of_Origin_Code
проис-;Country_Of_Origin
происх;Country_Of_Origin
происхо;Country_Of_Origin
происхож;Country_Of_Origin
происхож-;Country_Of_Origin
происхожден;Country_Of_Origin_Code,Country_Of_Origin
происхождения;Country_Of_Origin_Code,Country_Of_Origin
происхозденяя;Country_Of_Origin_Code,Country_Of_Origin
пронсхож-;Country_Of_Origin
псста-;Article_Code
р-;Total_Price
р^бот;Net_Amount
ра;Total_Price
ра5ог;Description
ра6от;Net_Amount
ра6отуспуг;Total_Price
раб;Total_Price
работ;Description,Net_Amount,Total_Price
работ^ока;Description
работоказанных;Description
работус-;Total_Price
работуслуг;Net_Amount,Total_Price
работуспуг;Total_Price
рабст;Net_Amount
рабуо;Net_Amount
рации;Customs_Declaration
ре-;Unit_Measure
реи;Unit_Measure
рен;Unit_Measure
рени;Unit_Measure
рения;Unit_Measure,Unit_Price
реп;Unit_Measure
риф;Unit_Price
ров;Net_Amount,Total_Price
роисхож-;Country_Of_Origin
ртрана;Country_Of_Origin
с;Total_Price,Description
с^мма;Tax_Amount
сание;Description
спуг;Total_Price
ст;Tax_Rate
ста4;Tax_Rate
став;Tax_Rate
став-;Tax_Rate
ставка;Tax_Rate
ство;Quantity
—стижшстб—;Total_Price
стйиыйсть;Net_Amount
стойкость;Total_Price
стоимосп;Total_Price
стоймост;Net_Amount
стоимость;Net_Amount,Total_Price
стоимтова;Net_Amount,Total_Price
стоимтоваров;Net_Amount,Total_Price
стокмтоваров-;Total_Price
стр;Country_Of_Origin,Country_Of_Origin_Code
страна;Country_Of_Origin,Country_Of_Origin_Code
страна-;Country_Of_Origin
страну;Country_Of_Origin
ст-ть;Net_Amount,Total_Price
стцигапстб;Net_Amount
сумма;Tax_Amount,Excise
сучетнал;Total_Price
схож-;Country_Of_Origin
та;Customs_Declaration,Unit_Price
та-;Unit_Price
таиожойной;Customs_Declaration
там;Customs_Declaration
тамо;Customs_Declaration
тамож;Customs_Declaration
таможенно;Customs_Declaration
таможенной;Customs_Declaration
таможсшюг;Customs_Declaration
таножен-н;Customs_Declaration
тараф;Unit_Price
тариф;Unit_Price
тел;Tax_Amount
телю;Tax_Amount
теля;Article_Code
тнагп;Tax_Rate
тоаара;Description
тоааров;Total_Price
тов;Net_Amount
това;Description,Total_Price
това-;Article_Code
товар;Total_Price
товара;Description,Country_Of_Origin_Code,Country_Of_Origin
товаров;Net_Amount,Total_Price
товврог;Total_Price
тои;Excise
той;Excise
том;Excise,Total_Price
тон;Excise
трф^ёг;Description
туг;Description
тч;Excise
тч^;Excise
ты;Currency
тэможевн;Customs_Declaration
у;Description,Unit_Price
уепуг;Total_Price
унетом;Total_Price
ус;Unit_Measure,Net_Amount
ус-i;Net_Amount
усл;Unit_Measure,Net_Amount,Total_Price
условное;Unit_Measure
услуг;Description,Net_Amount,Total_Price
успимущ;Net_Amount
успуг;Description
успуп;Total_Price
успцг;Net_Amount
уч;Total_Price
уче;Total_Price
уче-;Total_Price
учет;Total_Price
учетом;Total_Price
учётом;Total_Price
хожде-;Country_Of_Origin
хождения;Country_Of_Origin_Code,Country_Of_Origin
ца;Unit_Measure
цбка;Unit_Price
це1и;Unit_Price
цена;Unit_Price
ценз;Unit_Price
цера;Unit_Price
цеяа;Unit_Price
циз;Excise
цифр;Country_Of_Origin_Code
цйфро?;Country_Of_Origin_Code
цифровой;Country_Of_Origin_Code
цче-;Total_Price
ч;Total_Price
ч^ймтогтаой-;Net_Amount
чение;Unit_Measure
чеотао;Quantity
чест;Quantity
чество;Quantity
честео;Quantity
чис;Excise
чйс;Excise
числ;Excise
числд;Excise
числе;Excise
чисре;Excise
чсегво;Quantity
шалото-;Tax_Rate
щественых;Net_Amount
щестеенных;Total_Price
щуг;Description
ых;Description
ь;Net_Amount
ь1х;Net_Amount
эа;Unit_Price
элкеных;Description
эписание;Description
юна;Country_Of_Origin
я;Country_Of_Origin_Code,Country_Of_Origin,Unit_Measure
```
### Correcting Table Values
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

## Check that the net, tax and total under the table actually match the sum of the table columns
```vbscript
Private Sub CheckTaxAndTotal_Validate(ByVal ValItems As CASCADELib.CscXDocValidationItems, ByVal pXDoc As CASCADELib.CscXDocument, ByRef ErrDescription As String, ByRef ValidField As Boolean)
   Dim oTax As ICscXDocValidationItem
   Dim oTot As ICscXDocValidationItem

   'you have to assign an amount formatter for each field where you want to use the .DoubleValue property
   Set oTax = ValItems.Item("Tax")
   If oTax.DoubleFormatted = False Then
      ValidField = False
      ErrDescription = oTax.Text & " is not formatted"
      Exit Sub
   End If
   Set oTot = ValItems.Item("Total")
   If oTot.DoubleFormatted = False Then
      ValidField = False
      ErrDescription = oTot.Text & " is not formatted"
      Exit Sub
   End If

   Dim sumNet, sumTax, sumTot As Double
   Dim table As CscXDocTable
   Set table=pXDoc.Fields.ItemByName("Table").Table
   If table.Rows.Count=0 Then
      ValidField=True
      Exit Sub
   End If
   Dim daf As ICscFieldFormatter
   Set daf=Project.FieldFormatters.ItemByName(Project.DefaultAmountFormatter)
   Table_SumColumn(table,table.Columns.ItemByName("Net Amount").IndexInTable,daf,sumNet)
   Table_SumColumn(table,table.Columns.ItemByName("Tax Amount").IndexInTable,daf,sumTax)
   Table_SumColumn(table,table.Columns.ItemByName("Total Price").IndexInTable,daf,sumTot)

   If Abs(sumTax-oTax.DoubleValue)>TOLERANCE Then
      ValidField=False
      ErrDescription="Table Tax " & Format(sumTax,"0.00") & " ≠ " & oTax.Text & " Total Tax"
      Exit Sub
   End If
   If Abs(sumTot-oTot.DoubleValue)>TOLERANCE Then
      ValidField=False
      ErrDescription="Table Total " & Format(sumTot,"0.00") & " ≠ " & oTot.Text & " Total"
      Exit Sub
   End If
   If sumNet>0 And Abs(sumNet+oTax.DoubleValue-oTot.DoubleValue)>TOLERANCE Then
      ValidField=False
      ErrDescription="Table Net + Table Tax = " & Format(sumNet,"0.00") & " + " & oTax.Text & " = " & Format(sumTot+oTax.DoubleValue,"0.00") & " ≠ " & oTot.Text & " Total"
      Exit Sub
   End If
   pXDoc.Fields.ItemByName("NetAmount1").Text=Replace(Format(oTot.DoubleValue-oTax.DoubleValue,"0.00"),".",",")
   ValidField=True
End Sub
```
## Useful functions
```vbscript
Private Function Table_SumColumn(table As CscXDocTable, colID As Integer,amountFormatter As ICscFieldFormatter,ByRef sum As Double) As Boolean
   'Sums a column in a database and returns false if any cell is invalid
   Dim r As Integer
   Dim cell As CscXDocTableCell
   For r = 0 To table.Rows.Count-1
      Set cell= table.Rows(r).Cells(colID)
      amountFormatter.FormatTableCell(cell)
      If Not cell.DoubleFormatted Then Return False
      sum=sum+cell.DoubleValue
   Next
   Return True
End Function

Private Sub AisB_Validate(ByVal ValItems As CASCADELib.CscXDocValidationItems, ByVal pXDoc As CASCADELib.CscXDocument, ByRef ErrDescription As String, ByRef ValidField As Boolean)
   Dim oA As ICscXDocValidationItem
   Dim oB As ICscXDocValidationItem

   'you have to assign an amount formatter for each field where you want to use the .DoubleValue property
   Set oA = ValItems.Item("A")
   If oA.DoubleFormatted = False Then
      ValidField = False
      ErrDescription = oA.Text & " not formatted"
      Exit Sub
   End If
   Set oB = ValItems.Item("B")
   If oB.DoubleFormatted = False Then
      ValidField = False
      ErrDescription = oB.Text & " not formatted"
      Exit Sub
   End If

   ' enter your own validation rule here
   ' Due to rounding of floating point numbers, it is recommended to compare double numbers as follows,
   ' using e.g. "abs(a + b - c) < 0.01" instead of "a + b = c"
   If (Abs(oA.DoubleValue - oB.DoubleValue) < 0.01) Then
      ValidField = True
   Else
      ValidField = False
      ErrDescription = "Table " & oA.Text & " ≠ " & oB.Text
   End If
End Sub
```
## Format Invoice Number
```vbscrpt
Private Sub InvoiceNumber_FormatField(ByVal FieldText As String, FormattedText As String, ErrDescription As String, ValidFormat As Boolean)
   If Len(FieldText) = 0 Then
      ValidFormat = False
      ErrDescription = "Invoice Number must not be empty"
   Else
      ' remove special characters "-/." from string
      FormattedText = Replace(FieldText, "от", "")
      FormattedText = Replace(FormattedText, "№", "")
      FormattedText = Replace(FormattedText, " ", "")
      ValidFormat = True
   End If
End Sub
```
## Spell Check Country Names
Load the country names into a database locator, and put the script into to a script field formatter called **CountryNameFormatter**
```
Австралия
Австрия
Азербайджан
Акротири
Албания
Алжир
Американское Самоа
Ангилья
Ангола
Андорра
Антарктида
Антигуа и Барбуда
Аргентина
Армения
Аруба
Афганистан
Ашмор и Картье острова
Багамские острова,
Бангладеш
Барбадос
Бассас-да-Индия
Бахрейн
Беларусь
Белиз
Бельгия
Бенин
Берег Слоновой Кости
Бермудские острова
Бирма
Болгария
Боливия
Босния и Герцеговина
Ботсвана
Бразилия
Британская территория Индийского океана
Британские Виргинские острова
Бруней
Буве
Буркина-Фасо
Бурунди
Бутан
Вануату
Великобритания
Венгрия
Венесуэла
Виргинские о-ва
Воссоединение
Вьетнам
Габон
Гайана
Гаити
Гамбии
Гана
Гваделупа
Гватемала
Гвинея
Гвинея-Бисау
Германия
Гибралтар
Гондурас
Гонконг
Гренада
Гренландия
Греция
Грузия
Гуам
Дания
Декелия
Джерси
Джибути
Доминика
Доминиканская Республика
Европа остров
Египет
Замбия
Западная Сахара
Западный берег реки Иордан
Зимбабве
Йемен
Израиль
Индия
Индонезия
Иордания
Ирак
Иран
Ирландия
Исландия
Испания
Италия
Кабо-Верде
Казахстан
Каймановы острова
Камбоджа
Камерун
Канада
Катар
Кения
Кипр
Киргизия
Кирибати
Китай
Кокосовые (Килинг) острова
Колумбия
Коморские острова
Конго, Демократическая Республика
Корея, Северный
Коста-Рика
Куба
Кувейт
Лаос
Латвия
Лесото
Либерия
Ливан
Ливия
Литва
Лихтенштейн
Люксембург
Маврикий
Мавритания
Мадагаскар
Майотта
Макао
Македонии
Малави
Малайзия
Мали
Мальдивы
Мальта
Марокко
Мартиника
Маршалловы острова
Мексика
Микронезия, Федеративные Штаты
Мозамбик
Молдова
Монако
Монголия
Монтсеррат
Навасса
Намибия
Науру
Непал
Нигер
Нигерия
Нидерландские Антильские острова
Нидерланды
Никарагуа
Ниуэ
Новая Зеландия
Новая Каледония
Норвегия
Объединенные Арабские Эмираты
Оман
Остров Клиппертон
Остров Мэн
Остров Норфолк
Остров Рождества
Остров Святой Елены
Остров Херд и острова Макдональд
Острова Кука
Острова Теркс и Кайкос
Островов Кораллового моря
Пакистан
Палау
Панама
Папуа-Новая Гвинея
Парагвай
Парасельские острова
Перу
Питкэрн
Польша
Португалия
Пуэрто-Рико
Республика Конго
Россия
Руанда
Румыния
Сальвадор
Самоа
Сан - Марино
Сан-Томе и Принсипи
Саудовская Аравия
Свазиленд
Святой Престол (Ватикан)
Северные Марианские острова
Сейшельские острова
Сектор Газа
Сенегал
Сен-Пьер и Микелон
Сент-Винсент и Гренадины
Сент-Китс и Невис
Сент-Люсия
Сербия и Черногория
Сингапур
Сирия
Словакия
Словения
Соединенные Штаты
Соломоновы Острова
Сомали
Спратли острова
Судан
Суринам
Сьерра-Леоне
Таджикистан
Тайвань
Таиланд
Танзания
Тимор-Лешти
Того
Токелау
Тонга
Тринидад и Тобаго
Тромлен острова
Тувалу
Тунис
Туркменистан
Турция
Уганда
Узбекистан
Украина
Уоллис и Футуна
Уругвай
Фарерские острова
Фиджи
Филиппины
Финляндия
Фолклендские (Мальвинские) острова
Франция
Французская Гвиана
Французская Полинезия
Французские Южные и Антарктические земли
Хорватия
Хуан де Нова Остров
Центрально-Африканская Республика
Чад
Чешская республика
Чили
Швейцария
Швеция
Шерстяная фуфайка
Шпицберген
Шри Ланка
Эквадор
Экваториальная Гвинея
Эритрея
Эстония
Эфиопия
ЮАР
Южная Джорджия и Южные Сандвичевы острова
Южная Корея
Ямайка
Ян-Майен
Япония
```
```vbscript
Private Sub CountryNameFormatter_FormatField(ByVal FieldText As String, FormattedText As String, ErrDescription As String, ValidFormat As Boolean)
   If Len(FieldText) = 0 Then
      ValidFormat = True
      Exit Sub
   End If
   Dim results As CscXDocField
   Set results=Database_Search("countries","",FieldText,2,0.5)
   If results.Alternatives.Count=0 Then
      ValidFormat=False
      ErrDescription="неизвестной стране"
      Exit Sub
   End If
   If results.Alternatives.Count=1 AndAlso results.Alternatives(0).Confidence>0.5 Then
      FormattedText=results.Alternatives(0).SubFields(0).Text
      ValidFormat=True
      Exit Sub
   End If
   If results.Alternatives.Count>1 AndAlso results.Alternatives(0).Confidence-results.Alternatives(1).Confidence> 0.25 Then
      FormattedText=results.Alternatives(0).SubFields(0).Text
      ValidFormat=True
      Exit Sub
   End If
   ValidFormat = False
   ErrDescription="неизвестной стране"
End Sub
```
## Units Formatting
Fuzzy match units and auto-correct them with a Script field Formatter
```vbscript
Const UNITS="БУТ,БУТЫЛК,БУТЫЛКА,ШТ,КГ,КОР,КОР.20,ВЕДРО,ПАЧ,УПАК,УПАК.8,УПАК.12,УП,БАНКА,БЛК,УПК"
Private Sub UnitsFormatter_FormatField(ByVal FieldText As String, FormattedText As String, ErrDescription As String, ValidFormat As Boolean)
   FormattedText=Replace(FieldText,".","")
   FormattedText=UCase(Replace(FormattedText,"|",""))
   If Len(FormattedText) = 0 Then
      ValidFormat = True
      Exit Sub
   End If
   Dim unit As String
   Dim bestId,bestScore,score,i As Integer
   bestScore=100
   For Each unit In Split(UNITS,",")
      score=String_LevenshteinDistance(unit,FormattedText)
      If score<bestScore Then bestScore=score:bestId=i
      i=i+1
   Next
   If bestScore<2 Then
      ValidFormat=True
      FormattedText=Split(UNITS,",")(bestId)
   Else
      ValidFormat=False
      ErrDescription="неизвестной Единица измерения"
   End If
End Sub

Private Function String_LevenshteinDistance(a As String , b As String)
   'http://en.wikipedia.org/wiki/Levenshtein_distance
   'Levenshtein distance between two strings, used for fuzzy matching
   Dim i,j,cost,d,ins,del,subs As Integer
   If Len(a) = 0 Then Return 0
   If Len(b) = 0 Then Return 0
   ReDim d(Len(a), Len(b))
   For i = 0 To Len(a)
      d(i, 0) = i
   Next
   For j = 0 To Len(b)
      d(0, j) = j
   Next
   For i = 1 To Len(a)
     For j = 1 To Len(b)
         If Mid(a, i, 1) = Mid(b, j, 1) Then cost = 0 Else cost = 1   ' cost of substitution
         del = ( d( i - 1, j ) + 1 ) ' cost of deletion
         ins = ( d( i, j - 1 ) + 1 ) ' cost of insertion
         subs = ( d( i - 1, j - 1 ) + cost ) 'cost of substition or match
         d(i,j)=Min(ins,Min(del,subs))
      Next
   Next
   Return d(Len(a), Len(b))
End Function

Private Function Max(v1 As Long, v2 As Long) As Long
   If v1 > v2 Then Return v1 Else Return v2
End Function

Private Function Min(v1 As Long, v2 As Long) As Long
   If v1 < v2 Then Return v1 Else Return v2
End Function


```
