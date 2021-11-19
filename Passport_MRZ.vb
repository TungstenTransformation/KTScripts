Private Sub SL_MRZ1_LocateAlternatives(ByVal pXDoc As CASCADELib.CscXDocument, ByVal pLocator As CASCADELib.CscXDocField)
   'Reads the first line of MRZ (Machine Readable Zone) on a passport or ID card and validates with the checksum
   'Make sure this script locator has the subfields named exactly as in key(1) below
   MRZ_Parse(pXDoc.Locators.ItemByName("AZL").Alternatives(0).SubFields.ItemByName("MRZ1"),pLocator.Alternatives.Create.SubFields,1)
End Sub

Private Sub SL_MRZ2_LocateAlternatives(ByVal pXDoc As CASCADELib.CscXDocument, ByVal pLocator As CASCADELib.CscXDocField)
   'Reads the second line of MRZ (Machine Readable Zone) on a passport or ID card and validates with the checksum
   'Make sure this script locator has the subfields named exactly as in key(2) below
   MRZ_Parse(pXDoc.Locators.ItemByName("AZL").Alternatives(0).SubFields.ItemByName("MRZ2"),pLocator.Alternatives.Create.SubFields,2)
End Sub

Public Sub MRZ_Parse(MRZ As Object, details As CscXDocSubFields, MRZID As Long)
   'Parse the value of an MRZ (Field, Alternative, Subfield or TableCell) into details. Passport has MRZID 1 & 2.
   'All the details are returned in Subfields details. All details have confidence=11%, if checksum matches then 90% (as there is a 10% that the checksum is wrong! :-))
   'Identity cards have MRZID 3,4,5
   'http://en.wikipedia.org/wiki/Machine-readable_passport
   Dim sf As CscXDocSubField, width As Double
   Dim legend As String, part() As String, pos As Long, length As Long, key(5) As String, field As String
   key(1)="Type:1:1 Country:3:3 LastName:6:<< GivenNames:<<:E"
   key(2)="PassportNumber:1:9 Check_PassportNumber:10:1 Nationality:11:3 DateOfBirth:14:6 Check_DateOfBirth:20:1 Sex:21:1 ExpirationDate:22:6 Check_ExpirationDate:28:1 PersonalNumber:29:14 Check_PersonalNumber:43:1 Check_Checks:44:1"
   key(3)="ID:1:1 Type:2:1 Country:3:3 DocumentNumber:6:9 Check_DocumentNumber:15:1 Optional:16:15,"
   key(4)="DateOfBirth:1:6 Check_DateOfBirth:7:1 Sex:8:1 ExpirationDate:9:6 Check_ExpirationDate:15:1 Nationality:16:3 Optional:19:11" 'Check_COMPLEX:30:1" Check_COMPLEX not implemented
   MRZ.Text=Replace(MRZ.Text,"«","<") 'Finereader often finds «
   MRZ.Text=Replace(MRZ.Text," ","") 'Remove Spaces that OCR engines might insert
   width=CDbl(MRZ.Width/Len(MRZ.Text)) 'find the width of each character as this is a fixed space font
   For Each legend In Split(key(MRZID)) 'Split the key to "Type:1:1" and "Country:3:3", etc.
      part=Split(legend,":")              'Split to "Type" & "1" and "1"
      If Left(part(0),5)="Check" Then
         field=Split(part(0),"_")(1)
         With details.ItemByName(field)
      If MRZ_Checksum(Mid(MRZ.Text,pos,length),.Text) Then .Confidence=0.9 ' This 90% is literally true as the Checksum is 90% accurate and checks the text quality.
         End With
      Else
         Set sf=details.Create(part(0))
         If part(2)="<<" Then
            pos=CInt(part(1))
            length=InStr(MRZ.Text,part(2))-pos
         ElseIf part(2)="E" Then
            pos=InStr(MRZ.Text,part(1))+2
            length=Len(MRZ.Text)-pos
         Else
            pos=CLng(part(1))
            length=CLng(part(2))
         End If
         sf.Text=Mid(MRZ.Text,pos,length)
         sf.Width=CLng(width*Len(sf.Text))
         sf.Left=MRZ.Left+CLng((pos-1)*width)
         sf.PageIndex=MRZ.PageIndex
         sf.Top=MRZ.Top
         sf.Height=MRZ.Height
         sf.Confidence=.11 'Set all confidences to something really low, since we don't trust the OCR engine. The checksum doesn't include the text
         sf.Text=Trim(Replace(sf.Text,"<"," ")) 'Trim "<" after running checksums (Australian ID number has leading "<")
      End If
   Next
   For pos=0 To details.Count-1
      
   Next
End Sub

Public Function MRZ_Checksum(value As String, check As String) As Boolean
   'Validates MRZ values against checksum
   'http://en.wikipedia.org/wiki/Machine-readable_passport
   Dim c As Long, sum As Long, v As Long, multiplier As Long
   If Asc(check)<Asc("0") Or Asc(check)>Asc("9") Then Return False ' invalid check character
   For c =1 To Len(value)
      Select Case c Mod 3
      Case 1
         multiplier=7
      Case 2
         multiplier=3
      Case 0
         multiplier=1
      End Select
      v=Asc(Mid(value,c,1))
      Select Case v
      Case Asc("<")
         v=0
      Case Asc("0") To Asc("9")
         v=CLng(v)-Asc("0")
      Case Asc("A") To Asc("Z")
         v=v-Asc("A")+10
      Case Else
         Return False ' invalid character
      End Select
      sum=sum+multiplier*v
   Next
   Return sum Mod 10 = Asc(check)-Asc("0")
End Function
