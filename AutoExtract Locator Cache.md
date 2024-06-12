# AutoExtract Locator Cache

The AutoExtract Locator that is new in Total Agility 8.0.1 uses a Large Langugage Model Service to extract fields from a document.  
Calling a LLM is expensive and slow. This script caches resposes from a LLM for testing purposes. Instead of taking 5-10 seconds to run the results are there instantly.  
The script generates a hash of the **text** of the document along with the **subfield names** and **descriptions**. If these remain unchanged then the locator is skipped and filled from the cache.  
If anything changes in the text, field names or descriptions then the locator is executed.  

##Instructions
1. Add an **AutoExtract Locator** to any document class in your project. It can have any name.  
![image](https://github.com/TungstenTransformation/KTScripts/assets/103566874/93974b98-5b36-47b9-b889-528bf4efa8bf)
1. Assign it to any field.
1. Create or edit the **CachePath** on the server that is running Transformation Service, or on the machine where you are running **Transformation Designer**.
1. Paste the script into the document class containing the AutoExtract Locator.
2. Add a reference to **Kofax AutoExtract Locator 4.0** in the Script Editor's Menu **Edit/References..**.
![image](https://github.com/TungstenTransformation/KTScripts/assets/103566874/be7b2058-c79a-499c-94c5-5334202a39e5)
1. Make sure your XDocument is classified and has a **Classification Result** when using Transformation Designer.  
![image](https://github.com/TungstenTransformation/KTScripts/assets/103566874/922cec03-4417-4f57-928a-acee2726e565)
1. Extract the Document by right-clicking and selecting **Extract**. This will run the Cache code and skip calling the LLM if it has already been called for this document and field and description.
![image](https://github.com/TungstenTransformation/KTScripts/assets/103566874/3e6326f7-b2c1-4a24-83b1-eb19a9a82d87)
1. View the field results in the **Extraction Results** Window.  
![image](https://github.com/TungstenTransformation/KTScripts/assets/103566874/987fd188-93ed-4604-8228-1f19ec175ce6)
1. If you press **Test** within the Locator then the LLM will be called. It is not possible to use the cache when testing a locator.

```vb6
Option Explicit

' Class script: LLM
Const CachePath = "c:\temp\cache\"

Private Sub Document_BeforeExtract(ByVal pXDoc As CASCADELib.CscXDocument)
   Dim LocDef As CscLocatorDef, L As Long
   If pXDoc.ExtractionClass="" Then Exit Sub ' This document has not been classified, so we cannot find the locator definition
   With Project.ClassByName(pXDoc.ExtractionClass).Locators
      For L=0 To .Count-1 ' find all the AutoExtract Locators in this document class
         Set LocDef=.ItemByIndex(L)
         'Use Cache on AutoExtract Locators
         If TypeOf LocDef.LocatorMethod Is CscAutoExtractLocator Then AEL_ReadFromCache(pXDoc,.ItemByIndex(L).Name)
      Next
   End With
End Sub

Private Sub AEL_ReadFromCache(ByVal pXDoc As CASCADELib.CscXDocument,LocatorName As String)
   Dim Hash As String,FileName As String, Alt As CscXDocFieldAlternative, Cache As String, Vals() As String
   Dim Locator As CscXDocField
   Dim LocDef As CscLocatorDef, AEL As CscAutoExtractLocator
   Set LocDef = Project.ClassByName(pXDoc.ExtractionClass).Locators.ItemByName(LocatorName)
   Set AEL = LocDef.LocatorMethod
   Set Locator=pXDoc.Locators.ItemByName(LocatorName)
   Hash=AEL_Hash(AEL,pXDoc)
   FileName=CachePath & Hash & ".txt"
   If Dir(FileName)<>"" Then ' if file exists
      Locator.Preserve=True ' Don't run AEL locator
      Open FileName For Input As #1
      With Locator.Alternatives.Create
         Line Input #1, Cache
         Vals=Split(Cache,";",7)
         .PageIndex=CLng(Vals(0))
         .Left=CLng(Vals(1))
         .Top=CLng(Vals(2))
         .Width=CLng(Vals(3))
         .Height=CLng(Vals(4))
         .Confidence=CDbl(Vals(5))
         .Text=Vals(6)
      End With
      Close #1
   Else
      Locator.Preserve=False ' run the AEL locator
   End If
End Sub

Private Sub Document_AfterLocate(ByVal pXDoc As CASCADELib.CscXDocument, ByVal LocatorName As String)
   Dim LocDef As CscLocatorDef
   If pXDoc.ExtractionClass="" Then Exit Sub ' This document has not been classified, so we cannot find the locator definition
   Set LocDef=Project.ClassByName(pXDoc.ExtractionClass).Locators.ItemByName(LocatorName)
   'Use Cache on AutoExtract Locators
   If TypeOf LocDef.LocatorMethod Is CscAutoExtractLocator Then AEL_SaveToCache(pXDoc,LocatorName)
End Sub

Public Sub AEL_SaveToCache(Xdoc As CscXDocument,LocatorName As String)
   Dim Hash As String, S As Long, SF As CscXDocSubField, FileName As String
   Hash=AEL_Hash(Project.ClassByName(Xdoc.ExtractionClass).Locators.ItemByName(LocatorName).LocatorMethod,Xdoc)
   FileName = CachePath & Hash & ".txt"
   If Xdoc.Locators.ItemByName(LocatorName).Alternatives.Count=0 Then Exit Sub ' no results
   Open FileName For Output As #1
      Print #1, vbUTF8BOM ;
      With Xdoc.Locators.ItemByName(LocatorName).Alternatives(0).SubFields
         For S=0 To .Count-1
            Set SF=.ItemByIndex(S)
            Print #1, SF.PageIndex & ";" & SF.Left & ";" & SF.Top & ";" & SF.Width & ";" & SF.Height & ";" & SF.Confidence & ";" & SF.Text
         Next
      End With
   Close #1
End Sub

Public Function AEL_Hash(AEL As CscAutoExtractLocator, Xdoc As CscXDocument) As String
   'Hash the xdoc's text and the AEL's subfields and prompts
   Dim S As Long
   AEL_Hash=Xdoc.TextLines.Text
   For S=0 To AEL.SubFieldCount-1
      With AEL.SubFieldByIndex(S)
               AEL_Hash = AEL_Hash & ":" & .Name & .Description
      End With
   Next
   AEL_Hash=String_MD5(AEL_Hash)
End Function


Public Function String_MD5(value As String) As String
   'Calculate MD5 checksum of a string
   Dim bytes() As Byte, b As Byte, h As String
   bytes = CreateObject("System.Text.UTF8Encoding").GetBytes_4(value) ' Convert unicode string to byte array
   bytes = CreateObject("System.Security.Cryptography.MD5CryptoServiceProvider").ComputeHash_2(bytes) 'calculate md5 checksum
   For Each b In bytes 'Convert binary array to hexadecimal string
      h=Hex(b)
      If Len(h)=1 Then h="0" & h
      String_MD5=String_MD5 & h
   Next
End Function
```
