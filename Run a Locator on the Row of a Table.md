# Running a locator in the Rows of a Table
If you want to run a locator(s) on the row of a table you will need to create another class in the project to hold those locators.  
It is recommended to put it into another hierarchy and mark the class as **not available** for classification.  
![image](https://user-images.githubusercontent.com/47416964/124617917-9f4c8a00-de77-11eb-9889-a1ca910d4d15.png)

You can then customize the Table Locator in the event **Document_AfterLocate** to do the following

* create a new temporary XDocument and copy into it the words/pages you want to locate on. This has no page count license cost.
* Extract that new XDocument on the special Class you created.
* Copy the results back into the table
* Delete the temporary document.

```vb

```
