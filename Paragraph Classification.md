# Paragraph Classification
Sometimes it is useful to classify individual paragraphs in a document
* You are looking for paragraphs in a document with a particular vocab or sentiment.
* You want to calculate the sentiment of each paragraph separately 
* You want to classify a document based on a particular paragraph, ignoring all others.
The default text classifier returns the classification result of the entire page or document. This *can* dilute results that come from paragraphs.

## How to Detect Paragraphs
*This will become a standard feature in Kofax Transformation in a future release (today is August 2020)*.  
This Table Locator detects paragraphs. I create a new paragraph when the first word of a line is more than 30 pixels from the left edge of text (see script down below). Simple and effective – and it doesn’t matter if it’s not perfect! Perfection is not a goal, productivity is a goal.
The example below copies each paragraph into a table cell, and also classifies each paragraph (I have classes “p”, “v”, and “h”) and the 3rd column shows the score of text classification.  
In this project the customer wanted to know if this legal document was about "p", "v" or "h" or a combination. In the example below, the first page of this document is clearly about "p" only.
![image](https://user-images.githubusercontent.com/47416964/91288142-ec100080-e790-11ea-9565-1e6bc443513a.png)
## How to classify any text.
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
1. Simply delete paragraphs you don’t like and start classifying the rest. In the image below I manually classified paragraph 1 as 'p' and paragraph 2 as '' and  selected paragraphs 3-7 in orange and will delete them.  
![image](https://user-images.githubusercontent.com/47416964/91289232-5d9c7e80-e792-11ea-8190-a1f32576f618.png)
