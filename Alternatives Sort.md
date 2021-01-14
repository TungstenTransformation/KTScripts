# How to sort Alternatives
This [script](QuickSort.vb) sorts alternatives based an any custom criteria using the [QuickSort](https://en.wikipedia.org/wiki/Quicksort) algorithm, which can sort thousands of alternatives per second.
Kofax Transformation automatically sorts alternatives based on their confidence. You can take advantage of this in script locators and in the the event **Document_AfterLocate** :
any alternatives created will be automatically re-sorted by their confidence before the next locator starts.   
If you need to sort by another criteria, then use the following script.  
After that, if you change all of the confidences to match the new order then your order will be kept.  
A sort algorithm uses **comparers** to perform the sort. The script provides the following comparers (you can also make your own custom comparers)
* Comparer_Left2RightTop2Bottom
* Comparer_TopLeftCorner
* Comparer_AboveOrLeft   *useful for sorting paragraphs on a page*
* Comparer_Confidence

**TopLeftCorner** is suitable for sorting columns on a page.  
You will need to copy the script to your project and make sure that the Delegate line is at the top of your script
```vb
Delegate Function ComparerDelegate(a As Variant, b As Variant) As Boolean ' Delegate definition for sorting comparers
```
You can sort your Alternatives by calling
```vb
Alternatives_Sort(pLocator.Alternatives, AddressOf Comparer_TopLeftCorner)
````

You will need to include [Field_Copy](Field_Copy.vb) script that sorting uses.
