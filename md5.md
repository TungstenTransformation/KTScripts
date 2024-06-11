This function calculates the [md5 checksum](https://en.wikipedia.org/wiki/MD5) of an input string.  
example: input **hello** outputs **5D41402ABC4B2A76B9719D911017C592**

```vb6
Public Function String_MD5(value As String) As String
   'Calculate MD5 checksum of a string
   Dim bytes() As Byte, b As Byte, h As String
   bytes = CreateObject("System.Text.UTF8Encoding").GetBytes_4(value) ' Convert unicode string to byte array
   bytes = CreateObject("System.Security.Cryptography.MD5CryptoServiceProvider").ComputeHash_2(bytes) 'calculate md5 checksum
   For Each b In bytes 'Convert binary array to hexadecimal string
      h=Hex(b)
      If Len(h)=1 Then h="0" & h ' pad with 0 to two characters
      String_MD5=String_MD5 & h
   Next
End Function
```
