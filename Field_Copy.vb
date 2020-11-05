Sub Field_Copy(A As Object, B As Object,Optional Append As Boolean=False)
   'Intelligently and recursively copies from A to B most KTM objects into any other
   'CSCXDocField(s), CSCXDocFieldAlternatives, CSCXDocFieldAlternative, CSCXDocSubField
   'CSCXDocWord(s), CSCXDocTable, CSCXDocTableRow, CSCXDocTableCell, ICscXDocLine
   Dim I As Long, J As Long, Word As CscXDocWord , Name As String
   If TypeOf B Is CscXDocFieldAlternatives Then
      If Not Append Then Alternatives_Clear(B)
      If TypeOf A Is CscXDocFieldAlternatives Then
         For I =0 To A.Count-1
            Field_Copy(A(I),B,True)
         Next
      Else
         Field_Copy(A,B.Create(),True)
      End If
      Exit Sub
   End If   If TypeOf A Is CscXDocFieldAlternative And TypeOf B Is CscXDocField Then
      If Not Append Then Alternatives_Clear(B.Alternatives)
      Field_Copy(A,B.Alternatives.Create,False) 'Recurse
      Exit Sub
   End If
   If TypeOf A Is CscXDocSubFields Then
      For I =0 To A.Count-1
         Field_Copy(A(I),B,IIf(TypeOf B Is CscXDocSubFields,True,Append))
      Next
      Exit Sub
   End If
   If TypeOf B Is CscXDocSubFields Then
      If Not Append Then B.Clear
      If TypeOf a Is CscXDocSubField Then
         Name=a.Name
      Else
         Randomize
         Name=Format(Rnd()*100000000,"0000000000") ' give it a random unique name
      End If
      Field_Copy(A,B.Create(Name),False)
      Exit Sub
   End If
   If TypeOf A Is CscXDocFields Then
      If Not TypeOf B Is CscXDocFields Then Exit Sub 'we only copy a Fields object into a Fields object
      For I = 0 To A.Count-1
         If B.Exists(A(I).Name) Then Field_Copy(A(I),B.ItemByName(A(I).Name),Append)
      Next
      Exit Sub
   End If

   If Field_HasTable(A) And Field_HasTable(B) Then
      If Not Append Then B.Table.Rows.Clear
      For I = 0 To A.Table.Rows.Count-1
         Field_Copy(A.Table.Rows(I),B.Table.Rows.Append)
      Next
   End If

   If TypeOf A Is CscXDocTableRow And TypeOf B Is CscXDocTableRow Then
      For I = 0 To A.Cells.Count-1
         For J =0 To B.Cells.Count-1
            If A.Cells(I).ColumnName=B.Cells(J).ColumnName Then
               Field_Copy(A.Cells(I), B.Cells(J))
               Exit For
            End If
         Next
      Next
      Exit Sub
   End If

   If TypeOf B Is CscXDocTableCell Then
      Set Word=New CscXDocWord
      Field_Copy(A,Word)
      B.AddWordData(Word)
      Set Word=Nothing
      Exit Sub
   End If

   If Not Append Then
      If TypeOf B Is CscXDocField Then
         Alternatives_Clear(B.Alternatives)
      ElseIf TypeOf B Is CscXDocFieldAlternative Then
         B.SubFields.Clear
      ElseIf TypeOf B Is CscXDocTable Then
         B.Rows.Clear
      End If
      If Field_HasWords(B) Then
         While B.Words.Count>0
            B.Words.Remove(0)
         Wend
      End If
      B.Text=""
   End If

   If Field_HasWords(A) And Field_HasWords(B) Then
      For I = 0 To A.Words.Count-1
         B.Words.Append(A.Words(I))
      Next
   End If

   If TypeOf A Is ICscXDocLine And Not TypeOf B Is ICscXDocLine Then
      B.Top=A.StartY
      B.Left=A.StartX
      B.Width=A.EndX-A.StartX
      B.Height=A.EndY-A.StartY
      B.PageIndex=A.PageIndex
   Else
      B.Top=A.Top
      B.Left=A.Left
      B.Width=A.Width
      B.Height=A.Height
      B.PageIndex=A.PageIndex
      If Append AndAlso Not (TypeOf A Is CscXDocFieldAlternative And TypeOf B Is CscXDocFieldAlternative) Then 
         B.Text=Trim(Replace(B.Text & " " & A.Text,"  "," ")) 
      Else 
         B.Text=Trim(A.Text) 
      End If 

   End If
   If TypeOf A Is CscXDocFieldAlternative AndAlso TypeOf B Is CscXDocFieldAlternative Then
       B.Source=A.Source 'Copy knowledgebase source info
       Field_Copy(A.SubFields,B.SubFields)
   End If
   If Field_HasConfidence(A) And Field_HasConfidence(B) Then
      B.Confidence=A.Confidence
      B.StringTag=A.StringTag
      B.LongTag=A.LongTag
      If Not(TypeOf A Is ICscXDocFieldAlternative) Then
         B.ExtractionConfident=A.ExtractionConfident
         B.SuppressTraining=A.SuppressTraining
         B.TrainingNeeded=A.TrainingNeeded
      End If
      Dim c As CscXDocFieldAlternative
      Dim d As CscXDocField
      Dim s As CscXDocSubField
   End If
   If TypeOf A Is CscXDocField And TypeOf B Is CscXDocField Then
      B.Modified=A.Modified
      B.ValidatedText=A.ValidatedText
      B.FieldType=A.FieldType
      B.ErrorDescription = A.ErrorDescription
      B.ForcedInCorrection=A.ForcedInCorrection
      B.ForcedValid=A.ForcedValid
      B.ForcedValidDescription=A.ForcedValidDescription
      B.Verified=A.Verified
      B.DoubleValue=A.DoubleValue
      B.DateValue=A.DateValue
      B.DateFormatted=A.DateFormatted
      B.DoubleFormatted=A.DoubleFormatted
      B.FormattingFailed=A.FormattingFailed
      B.Preserve=A.Preserve
      B.Valid=A.Valid
      For I = 0 To A.Alternatives.Count-1
         Field_Copy(A.Alternatives(I),B.Alternatives.Create(),Append) 'Recurse
      Next
   End If
End Sub

Public Function Field_HasTable(a As Object) As Boolean
   If Not(TypeOf a Is CscXDocField Or TypeOf a Is CscXDocFieldAlternative )Then Return False
   Return a.Table.Columns.Count<>0
End Function

Public Function Field_HasConfidence(a As Object) As Boolean
   Return TypeOf a Is CscXDocField Or TypeOf a Is CscXDocFieldAlternative Or TypeOf a Is CscXDocSubField
End Function
Public Function Field_HasWords(a As Object) As Boolean
   Return (TypeOf a Is CscXDocField Or TypeOf a Is CscXDocSubField Or TypeOf a Is CscXDocFieldAlternative Or TypeOf a Is CscXDocTextLine)
End Function

Sub Alternatives_Clear(alts As CscXDocFieldAlternatives)
   While alts.Count>0
      alts.Remove(0)
   Wend
End Sub
