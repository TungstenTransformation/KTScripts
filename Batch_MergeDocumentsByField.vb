Private Sub Batch_Close(ByVal pXRootFolder As CASCADELib.CscXFolder, ByVal CloseMode As CASCADELib.CscBatchCloseMode)
   'https://docshield.kofax.com/KTT/en_US/7.0.0-hyanwr9123/help/ScriptDocumentation/ScriptDocumentation/c_RestructureBatches.html#id_c_RestructureBatches
   If Project.ScriptExecutionMode = CscScriptExecutionMode.CscScriptModeValidation Then Exit Sub 'If you don't want this to run in KTM Validation Module
   Batch_MergeDocumentsByField(pXRootFolder, "InvoiceNumber")
End Sub

Public Sub Batch_MergeDocumentsByField(ByVal pXRootFolder As CASCADELib.CscXFolder, FieldName As String)
   Dim X As Long, Y As Long, XDocI As CscXDocInfo, YDocI As CscXDocInfo
   'Because we are going to be merging documents we MUST start at last document and move backwards to first document
   For Y = pXRootFolder.DocInfos.Count-1 To 1 Step -1 'from last to second document
      Set YDocI=pXRootFolder.DocInfos(Y)
      For X= 0 To Y-1 'search through all preceding documents
         Set XDocI =pXRootFolder.DocInfos(X)  'Docinfo contains only metadata from an XDoc - no OCR, fields, locators - they are in the larger XDocument
         If XDocI.XDocument.Fields.ItemByName(FieldName).Text=YDocI.XDocument.Fields.ItemByName(FieldName).Text Then
            'merge second document into first document
            Batch.MergeDocuments(XDocI, YDocI)
            Exit For
         End If
      Next
   Next
End Sub