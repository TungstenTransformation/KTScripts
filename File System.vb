Private Sub Folder_SortXDocsByFieldValue(pFolder As CASCADELib.CscXFolder,fieldname As String,path As String,Optional moveDontCopy As Boolean=False)
   Dim value,FileName As String
   Dim x As Integer
   For x = 0 To pFolder.DocInfos.Count-1
      Dim xdoc As CscXDocument
      Set xdoc=pFolder.DocInfos(x).XDocument
      If xdoc.Fields.Exists(fieldname) Then
         value = xdoc.Fields.ItemByName(fieldname).Text
         If value<>"" Then
            value=path & "\" & value
            If Not Dir_Exists(value) Then MkDir(value)
            Dim names() As String
            names=XDocument_GetAllFiles(xdoc,True,True,True,True)
            For Each FileName In names
               If FileName<>"" Then
                  FileCopy (FileName, value & "\" & File_NameWithExtension(FileName))
                  If moveDontCopy Then Kill FileName
               End If
            Next
         End If
      End If
   Next
End Sub

Private Function XDocument_GetAllFiles(pXDoc As CscXDocument,xdoc As Boolean,tiff As Boolean,txt As Boolean,oll As Boolean) As String()
   'returns a string with all documents belonging to the xdocument
   Dim files() As String
   ReDim files(0)
   With pXDoc
         If xdoc Then ReDim Preserve files(UBound(files)+1):files(UBound(files)) =.FileName
         Dim oldtiff As String
         If tiff Then
            Dim p As Integer
            For p = 0 To .CDoc.Pages.Count-1
               Dim t As String
               t=.CDoc.Pages(p).SourceFileName
               If oldtiff <>t Then  ReDim Preserve files(UBound(files)+1):files(UBound(files)) =t
               oldtiff=t
            Next
         End If
         If txt Then
            Dim textfile As String
            textfile = Replace(.FileName,".xdc",".txt")
            If File_Exists(textfile) Then ReDim Preserve files(UBound(files)+1):files(UBound(files)) =textfile
         End If
         If oll Then
            Dim ollfile As String
            ollfile = Replace(.FileName,".xdc",".oll")
            If File_Exists(ollfile) Then ReDim Preserve files(UBound(files)+1):files(UBound(files)) =ollfile
         End If
   End With
   Return files
End Function

Function File_Path(ByRef FileName As String) As String
   Dim pos As Integer
   pos=InStrRev(FileName,"\")
   If pos=0 Then Return "" Else Return Left(FileName,pos-1)
End Function

Function File_Exists(FileName As String) As Boolean
   Return Dir(FileName) <> ""
End Function

Function File_NameWithExtension(ByRef FileName As String) As String
   Dim pos As Integer
   pos=InStrRev(FileName,"\")
   If pos=0 Then Return FileName Else Return Mid(FileName,pos+1)
End Function

Function Dir_Exists(DirName As String) As Boolean
    On Error GoTo ErrorHandler
    Return GetAttr(DirName) And vbDirectory
ErrorHandler:
End Function
  
Function File_NameWithoutExtension(ByRef FileName As String) As String
   Dim pos As Integer
   pos=InStrRev(FileName,"\")
   If pos>0 Then FileName=Mid(FileName,pos+1)
   pos=InStrRev(FileName,".")
   If pos>0 Then return Left(FileName,pos-1) else return FileName
End Function

Function Path_GetParentFolder(PathName As String) As String
   'Return the ParentFolder
   If Right(PathName,1)="\" Then PathName=Left(PathName,Len(PathName)-1)
   Return Left(PathName,InStrRev(PathName,"\"))
End Function
