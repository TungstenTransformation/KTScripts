Public Function String_Classify(t As String, pXDoc As CscXDocument) As CscResult
   Dim Node As New CscDocNode, DocSet As New CscFileDocSet
   Dim TextRep As New CscTextRepresentation
   TextRep.Text=t
   Node.Representations.Append(TextRep)
   Set DocSet.RootDoc = Node
   Project.ClassifyDocSet(DocSet)
   Return Node.GetResult(Project.ClsResultRepTag)
End Function
