# Thai Date Formatter
The Thai Calendar is 543 years earlier than the [Gregorian Calendar](https://en.wikipedia.org/wiki/Thai_solar_calendar).  
 the Thai Date Formatter needs to be configured with Gregorian Dates and use a Thai Month Dictionary.
```vb
Public Sub DateFormatterThai_FormatField(DateFormatterThai As ICscFieldFormatter, Field As CscXDocField, Optional ConvertToGregorianCalendar As Boolean=True)
   'This works around the KTM Date Formatter limit of dates between 1800 and 2200 AD
   'The Thai Calendar is 543 years ahead of the Gregorian Calendar https://en.wikipedia.org/wiki/Thai_solar_calendar
   'the Thai Date Formatter needs to be configured with Gregorian Dates and use a Thai Month Dictionary.
   Const BuddhistEra=-543
   Dim DFDef As CscDateFormatter, d As Date, DateFormatType As String, Dict As CscDictionary, l As String, values() As String
   Set DFDef=DateFormatterThai
   'Workaround for DateFormatters not working with Thai dictionaries.
   If DFDef.MonthDictionaryName<>"" Then
      Set Dict=Project.Dictionaries.ItemByName(DFDef.MonthDictionaryName)
      Open Dict.TextFilename For Input As #1
      While Not EOF(1)
         Line Input #1, l
         values=Split(l,Left(Dict.DelimiterChars,1))
         Field.Text=Replace(Field.Text,values(0),values(1))
      Wend
      Close #1
   End If
   'Switch to Buddhist Calendar and Find Date
   DFDef.MaxAcceptableYear=DFDef.MaxAcceptableYear-BuddhistEra
   DFDef.MinAcceptableYear=DFDef.MinAcceptableYear-BuddhistEra
   DateFormatterThai.FormatField(Field)
   'Switch back to Gregorian Calendar
   DFDef.MaxAcceptableYear=DFDef.MaxAcceptableYear+BuddhistEra
   DFDef.MinAcceptableYear=DFDef.MinAcceptableYear+BuddhistEra
   'Only convert to Gregorian if a valid Thai date was found
   If ConvertToGregorianCalendar And Field.DateFormatted Then
      Select Case DFDef.DateFormatType
      Case CscDateFormatType.DateFormatDDMMYYYY
         DateFormatType="dd-mm-yyyy"
      Case CscDateFormatType.DateFormatMMDDYYYY
         DateFormatType="mm-dd-yyyy"
      Case CscDateFormatType.DateFormatYYYYMMDD
         DateFormatType="yyyy-mm-dd"
      End Select
      d=DateAdd("yyyy",BuddhistEra,Field.DateValue)
      Field.Text=Format(d,DateFormatType)
      DateFormatterThai.FormatField(Field)
   End If
End Sub
```
