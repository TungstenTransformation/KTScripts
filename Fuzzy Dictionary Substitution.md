# Fuzzy Dictionary Substitution
This is a powerful script-free technique to find and unique label parts of a document for use in later locators.  
When a dictionary is added to a format locator you retrieve **all occurences including duplicates** of dictionary entries on a document using **fuzzy matching**.  
In comparison, a Fuzzy Database Locator only returns **ONE** occurance of an entry, not **ALL**. 
## Example 1 - Finding more information than is actually on the document
In the example below Fuzzy Dictionary Substitution was used to find the name **Patricia** on the document.  
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
 
and inserting a dictionary into a format locator  
![image](https://user-images.githubusercontent.com/47416964/128849585-1d2f3dce-6609-4f7e-abc5-68ded174ebb0.png)  
## Example 2
Finding Anchors for zones in large documents.
