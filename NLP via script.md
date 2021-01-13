# Natural Language Processing via Script.
The NLP engine in Kofax Transformation is accessible via script.  
The following script enables you to perform NLP on any piece of text.
You will need to do the following
* Create classes in your project for each language that you intend to use for NLP.
* inside these classes set the required NLP language.
* inside these classes add a single unconfigured Sentiment Locator or NLP locator

See [Sentiment Project](https://github.com/KofaxRPA/Sentiment) for a working project

```vb
Function Text_Sentiment(Text As String, pXDoc As CscXDocument, Language As String) As String
   'Calculate the sentiment of a piece of text
   'This works by creating a temporary XDocument and explicitly running the first Locator in the class with the Language name
   Dim Temp As New CscXDocument, LanguageClass As CscClass
   If Not Project_ClassExists(Language) Then Return "0" ' Salience returns 0 if language unknown
   Temp.CopyPages(pXDoc,0,1) 'copy the first page of the document to the temp document. We don't use it, but each xdoc needs at least one page
   While Temp.Words.Count>1 'remove all the words except the first one
      Temp.Words.Remove(1)
   Wend
   Temp.Words(0).Text=Text ' stick the entire text into the first word
   Project.ClassByName(Language).Locate(Temp,0)   'Run the sentiement locator on the chosen language (This is the same as pressing the "Test" Button on the Locator)
   Return Temp.Locators(0).Alternatives(0).Text   'return the sentiment score
End Function
````
