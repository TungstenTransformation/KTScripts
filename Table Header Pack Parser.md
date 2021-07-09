Table header packs are binary files without an API to read them. This is an attempt to read a table header pack.  
Currently it can read the headerpack name and extract the header lines and negative lines.  
it partially reads the header phrases.


```vb
Private Sub HeaderPack_Read(HeaderPackName As String, Alts As CscXDocFieldAlternatives)
   'This is a work in progress. It is incomplete and does not work 8/7/2021
   'Long Values are little endian. Strings have a 4 byte unsigned length followed by two-byte characters, ending in 00 00.
   Dim P As ULong, Headers() As String, Negatives() As String,I As Long, ColId As Long, Alt As CscXDocFieldAlternative
   Open Left(Project.FileName,InStrRev(Project.FileName,"\")) & HeaderPackName & ".llp" For Binary Access Read As #1
   ByteStream_SkipBytes(1,4) 'skip first 4 bytes = 03 00 00 00
   HeaderPackName=ByteStream_ReadString(1)
   P=ByteStream_ReadLong(1)   'Get number of headers
   ReDim Headers(P-1)
   For I=0 To UBound(Headers)
      Headers(I)=ByteStream_ReadString(1)
   Next
   ByteStream_SkipBytes(1,18) 'I still don't understand these.
   P=ByteStream_ReadLong(1)   'Get number of columns in headerpack
   ByteStream_SkipBytes(1,4)
   For I=0 To Project.GlobalColumns.Count-1
      Set Alt=Alts.Create
      Alt.Confidence=1.00
      ColId=ByteStream_ReadLong(1)
      With Alt.SubFields.Create("Name")
         .Text=Project.GlobalColumns(ColId).DisplayName
         .Confidence=1
      End With
      P=ByteStream_ReadLong(1)
      With Alt.SubFields.Create("Phrases")
         For I=0 To P-1
            .Text = .Text & ByteStream_ReadString(1) & ";"
         Next
      End With
   Next
   Close #1
End Sub

Sub ByteStream_SkipBytes(streamid As Long, number As Long)
   Dim Bytes() As Byte
   ReDim Bytes(number-1)
   Get streamid, , Bytes
End Sub

Function ByteStream_ReadLong(streamid As Long) As Long
   Dim L As ULong
   Get streamid, , L
   Return L
End Function

Function ByteStream_ReadString(streamid As Long) As String
   Dim Bytes() As Byte, P As ULong, Skip As UInteger
   Get streamid, ,P  'Read String length
   ReDim Bytes(P-3) 'how many bytes to read
   Get streamid, , Bytes 'read the string into a byte array, stripping off the two empty bytes at the end
   Get streamid, , Skip 'skip the 2 empty bytes at the end of a string
   Return StrConv(Bytes,vbFromANSI)
End Function
```
