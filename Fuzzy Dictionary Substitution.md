# Fuzzy Dictionary Substitution
This is a powerful script-free technique to find and unique label parts of a document for use in later locators.  
When a dictionary is added to a format locator you retrieve **all occurences including duplicates** of dictionary entries on a document using **fuzzy matching**.  
In comparison, a Fuzzy Database Locator only returns **ONE** occurance of an entry, not **ALL**. 
## Example 1 - Finding more information than is actually on the document
In the example below, Fuzzy Dictionary Substitution was used to find the name **Patricia** on the document.  
![image](https://user-images.githubusercontent.com/47416964/128848989-941a9e6b-49e4-48ba-9112-f869f7c4645b.png)  
But instead of returning **Patricia** as the value, the dictionary returned **Patricia_1077** via **auto replacement**. 1077 out of 100,000 American females are called Patricia ([US Census Data 2010](https://namecensus.com/female_names.htm))
and so I retrieve 5 pieces of information to use in other locators.
* confidence = 95.06% because "Patricia" in the database fuzzy matched "Patricia*" on the document
* **Patricia** as the person's name.
* **1077** as the frequency of the person's name.
* The exact coordinates of **Patricia** on the document, which you can see in the green box. 
* The words from the OCR. Using Alternative.Words.Text I can retrieve **Patricia\***.  

This is achieved using a fuzzy database with **auto replacement values** in it.  
![image](https://user-images.githubusercontent.com/47416964/128849883-b6d5dd0d-c4f4-4964-8159-62e1fd8fcab1.png)  
and inserting the dictionary into a format locator  
![image](https://user-images.githubusercontent.com/47416964/128849585-1d2f3dce-6609-4f7e-abc5-68ded174ebb0.png)  
## Example 2 - Finding Text Anchors for values in large documents.  
This can be useful for parsing large tables with identifying labels or finding checkboxes and OCR fields scattered throughout a large document.  
Consider this example.  
![image](https://user-images.githubusercontent.com/47416964/128855138-93ce459a-657f-4789-ab96-c1b7bfffda82.png)
And say you are interested in extracting these results:

| id | amount |
|----|--------|
| 1 | 10 |
| 3a | 9,4 |
| 12 | 0 |

Note we want *3a*, which is not even on the document, which has *3-a)*
* Make a dictionary to find these important phrases and **auto-replace** them to unique codes. Make sure the phrases are **long** and **unique**.  
![image](https://user-images.githubusercontent.com/47416964/128852949-3edd2ba8-d9e9-4a25-8c4a-683a655f02be.png)
* Add this dictionary to the project with **auto-replace** turned on.  
![image](https://user-images.githubusercontent.com/47416964/128853186-f0859ffa-e06b-48cc-b087-7423bf22cf3f.png)
* Add to a format locator.  
![image](https://user-images.githubusercontent.com/47416964/128853365-fa69f07e-5055-49d6-886c-90fa49d8226e.png)
* Add this script to remove results from the format locator with a confidence less than 80%.
```vb
Private Sub Document_AfterLocate(ByVal pXDoc As CASCADELib.CscXDocument, ByVal LocatorName As String)
   Dim A As Long, Alternatives As CscXDocFieldAlternatives
   Set Alternatives =pXDoc.Locators.ItemByName(LocatorName).Alternatives
   Select Case LocatorName
   Case "FL_Table"
      For A=Alternatives.Count-1 To 0 Step -1 ' Always count backwards if deleting
         If Alternatives(A).Confidence<0.8 Then Alternatives.Remove(A)
      Next
   End Select
End Sub
```
* Test! *The results contain the precise locations and unique labels required by a following locator to process*.
![image](https://user-images.githubusercontent.com/47416964/128853742-a1d92d5e-97b1-4c50-bc23-7f9b3322632a.png)


