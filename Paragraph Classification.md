# Paragraph Classification
Sometimes it is useful to classify individual paragraphs in a document
* You are looking for paragraphs in a document with a particular vocab or sentiment.
* You want to calculate the sentiment of each paragraph separately 
* You want to classify a document based on a particular paragraph, ignoring all others.
The default text classifier returns the classification result of the entire page or document. This *can* dilute results that come from paragraphs.

## How to Detect Paragraphs
*Paragraph Detection using page geometry will become a standard feature in Kofax Transformation in a future release (today is August 2020)*.  
This Table Locator detects paragraphs. I create a new paragraph when the first word of a line is more than 30 pixels from the left edge of text (see script down below). Simple and effective – and it doesn’t matter if it’s not perfect! Perfection is not a goal, productivity is a goal.
The example below copies each paragraph into a table cell, and also classifies each paragraph (I have classes “p”, “v”, and “h”) and the 3rd column shows the score of text classification.  
In this project the customer wanted to know if this legal document was about "p", "v" or "h" or a combination. In the example below, the first page of this document is clearly about "p" only.
![image](https://user-images.githubusercontent.com/47416964/91288142-ec100080-e790-11ea-9565-1e6bc443513a.png)
## How to classify any text
There is a script below that takes any text as input and returns a Classification Result object (CscResult), which contains the information you see below.  
![image](https://user-images.githubusercontent.com/47416964/91288210-02b65780-e791-11ea-88d5-23055adb0913.png)
## How to classify paragraphs
The String classification code was run inside the table locator and the best classification result was put into column 2 and the classification scores where put into column 3. This can help you and your customer understand how well classification is working and know what to train or not.  
![image](https://user-images.githubusercontent.com/47416964/91288282-1b267200-e791-11ea-8340-e2c0874b94b3.png)
## How to train paragraph classification
Now we need to put things together. This is where you work together with a document expert **from the business unit** to carefully train their documents.  
1. Open a representative document set (Read page 16 of [Best Practices in Kofax Transformation](https://github.com/KofaxRPA/Kofax-Transformation-Best-Practices/releases) for what “representative” means) in Project Builder. 
1. Select the Class with your paragraph table locator in the project tree. Select the documents and **Extract**. You should now have all the paragraphs in the table locators – they won’t be classified yet.  
1. Open Validation Screen (F8)   (Sorry KTA users, you’ll have to do this the long way by creating jobs…)
1. Paragraph one I manually classified as “p” and Paragraph two I classified as “”, because I want this trained as a Null paragraph.  
*You need negative examples and lots of them. Without any null examples then everything will be put into another class. You don't want to rely just on them getting low scores. If you are training an AI to recognize dogs in photos, then you should also give it lots of examples of cats and things that are not dogs. Negative training is important.*
1. Simply delete paragraphs you don’t like and start classifying the rest. In the image below I manually classified paragraph 1 as 'p' and paragraph 2 as '' and  selected paragraphs 3-7 in orange and will delete them.  
![image](https://user-images.githubusercontent.com/47416964/91289232-5d9c7e80-e792-11ea-8190-a1f32576f618.png)
1. Make the class names single characters so it’s fast to type. Press ENTER to confirm the class name.
1. Create a Validation Rule to enforce that the class names can only be “p”, “h”, “v” or “”.  *(KTA users have to do this the KTA way…)*  
![image](https://user-images.githubusercontent.com/47416964/91293593-8f184880-e798-11ea-8f29-d486e4869301.png)
1. Process 10 or more documents and then close Validation. *(In KTA retrieve your validated XDoc files with the Repository Browser)*
1. You will see that your files have an asterisk, meaning that they haven’t been saved. Save them by pressing the save icon ![image](https://user-images.githubusercontent.com/47416964/91293824-e4ecf080-e798-11ea-97d1-490e81eac44a.png)
 above the documents and the asterisk will disappear.  
 ![image](https://user-images.githubusercontent.com/47416964/91293885-fa621a80-e798-11ea-949b-efe9e0958807.png)
1. **WARNING. Be careful here to avoid loss of data!!** You just spent a long time creating valuable training files (also called "perfect" files or "golden files"). These are incredibly precious! Do not lose or overwrite them!!
1. Backup your files by selecting all the files.
1. Right-click on on the files and select "Open in Windows Explorer"  
![image](https://user-images.githubusercontent.com/47416964/91294096-4d3bd200-e799-11ea-80e9-39f75a630978.png)
1. Add them to a zip file.  
![image](https://user-images.githubusercontent.com/47416964/91294315-9db32f80-e799-11ea-9454-6cf5bec04d83.png)
1. Put the zip file somewhere safe.
1. Now you need to split all of those paragraphs into individual text files. Switch the document Viewer into Hierarchy Mode.  
![image](https://user-images.githubusercontent.com/47416964/91294417-c1767580-e799-11ea-8322-40f36fdab7e3.png)
1. You can now configure **Runtime Script Events**. Click the tiny triangle next to the yellow lightning icon.  
![image](https://user-images.githubusercontent.com/47416964/91294482-e23ecb00-e799-11ea-87f4-7cedf297aa0e.png)
1. Select **Batch_Close** and close this window. This feature is for testing batch and application level scripts – we will MISUSE 😊 this feature to write LOTS of text files.  
*In production you can put the script into the event Document_Validated if you want to creatae new training files at runtime, or in Kofax RPA, your robot can write these training files..*
*KTA users don’t have access to script event **Batch_Close**. They will have to create another temp class in the project and pack this script into Document_AfterExtract without the document loop – select all docs, extract all and then delete the script. (Ask if you need help!)*

