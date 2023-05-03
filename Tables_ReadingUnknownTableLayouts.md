#Unkown Table Extraction
Some projects include 100s of tables that are similar but different and have far two many variants for them to be trained.
The goal is to read **every line item** from **every client**.
## Algorithm
* Find Names, Amounts and Dates
* Find textlines that contain amounts and dates
* Group those textlines together of the same kind. The "best group" is probably the  largest group with the most numbers should be the line item.
* Break this "best group" into columns to identify the left and right edges of each column
* Classify the columns to identify exactly which is which using a combination of scores from these 4 different metrics.
  * **nature** - numeric, date, amount or text
  * **headers** - using header words above the columns
  * **order** - using the statistical probabilities on the order of columns. Eg *client name* is almost always to left of all. Perhaps using a simplistic form of a [Markov Chain](https://en.wikipedia.org/wiki/Markov_chain)
  * **math** - some columns add together, some are often zero, some are less than or greater than other columns. 
* Insert all words from a row into the table.
* **Repair rows**
  * Find words in the row that did not fit into a column and insert them.
  * Find words that span columns. These are OCR merging errors, and use OCR Zones to split them again.
* Search the textline above. Does it contain client info and client id?
* Search below for subtotal lines
* **Extrapolate** through the entire document matching every row of the document with the table pattern.
*   If there is an irregularity like a missing textline, check if OCR destroyed/merged/truncated textlines and reconstruct them with zones. 
*  **Validation**
  *  *single field* validation rules for amounts dates and numbers.
  *  *multifield* validation rules
  *  *comparator* validation rules. If every client number on the document is 9 characters long, mark as invalid anything with 7 or 8.
  *  "subtotal" validation rules. Add up amounts in subsections and mark valid if they match the subtotals.
  *  "total" validation rule. If the grandtotal is found on a document and it matches all subtotals/tablesums then we have a guarantee of reading every line item.

## Implementation
(![image](https://user-images.githubusercontent.com/47416964/235955542-5ff21d12-5862-4b9a-b14e-87f68e15e3b8.png)
)
### FL_FirstNames
Finds all FirstNames on the document and returns their probability as well, using US Census Data.  135/10000 US Women are called "Sally"
Script Event **Alternatives_SortByWordOrder** sorts all these hundreds of alternatives into their order from the text lines  
![image](https://user-images.githubusercontent.com/47416964/129342859-b9b61827-d1e7-4c9e-9cda-6684d6afc04a.png)
### FL_LastNames
Finds all LastNames on the document.  
![image](https://user-images.githubusercontent.com/47416964/129342997-04fc94d3-51ed-48b6-8a71-5f39b1552572.png)
### SL_LastFirst
This script locator finds all Last+First combos on the document.  These are used later to positively identify the precise location of the "client name" column in the table pattern.  
![image](https://user-images.githubusercontent.com/47416964/129343523-93adbc6e-9570-4ea7-a52c-f631bdf1719c.png)
### FL_Amounts
Finds all amounts on the document
* ```(\$)?\d{1,3}(\,?\d\d\d)*[\.,]\d{2}```
* ```\d{1,5}```
### FL_Dates
Finds all dates on the document
* ```0\d[0-3]\d\d\d```
* ```1[0-2][0-3]\d\d\d```
* ```[01]?\d([\.\-/])[0-3]?\d\1([12]\d{3}|\d{2})```
### SL_Rows
This algorithm only has the job of identifying the main line items on the first 3 pages. It does not need to find them all - it just needs to find enough of them to determine the structure.  Currently it takes under 0.25 seconds to run. In the example below you can see that it has found 12 lines that all match each other. Note that it failed to see the first line item on the document (marked in red). That doesn't matter - it will be recovered later.  
![image](https://user-images.githubusercontent.com/47416964/235956557-5bcdb2b7-53dc-42bd-b3dd-17cf482ca570.png)
)

This is the heart of the algorithm and most complex and has numerous steps. Because of the millions of calculations it makes it restricts itself to the first 3 pages of a document, which is adequate to determine the row and column structure.  
* **XDoc_FindTableRows** Find all the textlines with 4 or more amounts and dates. (this 4 is to reduce computational complexity. 3 or 2 work, but are slower)
* **XDoc_ScoreTableRows**
 * Compare EVERY table row against each other for "similarity" to produce a row "fingerprint". A row is 100% similiar to itself. Similarity gives a bonus reward for numeric similarity. If one row has text where another row has numbers the similarity decreases.  
![image](https://user-images.githubusercontent.com/47416964/129356812-03f1af1a-6e8f-45ac-94f1-0f909fef7e43.png)  
 *blue* spaces match, *green* text matches, *red* no match  
 The length of blue and green are added together and divided by the width of the text line. In the example below you can see that Textline 95 has 100% similarity with itself and 98.2% similarity with line 82. However line 82 has 100% similarity with line 95, because line 82 contains *longer* words that align with the *shorter* words in line 95.
Each row of numbers is the **fingerprint**. In this example 95's fingerprint of 22 numbers is very similar to 82's fingerprint. Both of them have about 40% similarity with line 74.
![image](https://user-images.githubusercontent.com/47416964/129354504-7e5a8f06-6c80-4d09-92b3-a643d5d6fefb.png)

* Calculate the **distance** between the "fingerprints" of every row with every other row. A row has a distance of zero to itself. A row with a very different "fingerprint" has a much larger distance.  The distance is simply the pythagorean distance (a1-b1)^2+(a2-b2)^2+(a3-b3)^2+....   
The distance matrix below shows that similar lines have a distance near zero and unsimilar lines have large distances.  
![image](https://user-images.githubusercontent.com/47416964/129356021-580a12cf-148e-4d04-90bd-07b50eff14b4.png)
 * Find the most common distance by building a histogram. Here the first peak is at distance=0.2 with a height of 204 (204 numbers in that array above are between 0.0 and 0.2). So I set the **clustering cutoff** to the distance (0.4) where it dropped to below 102 (50% of the peak). Here I am using bucket sizes of 0.2 to build the histogram.    
 ![image](https://user-images.githubusercontent.com/47416964/129357213-bc26afeb-b989-470b-b999-977ea98b81d1.png)
 * Cluster rows together based on **distance**
  *  Find the pair with the smallest distance (in this case it is 95 and 82).
  *  if one is already in a cluster add the other
  *  if they are in different clusters merge them
  *  if they are neither in a cluster make a new cluster with them
  *  Repeat until the smallest distance is the **clustering cutoff**. I have an array **Ignore** to keep track of which row pairs I have alreday looked at so they are ignored in later iterations.
  
 * The largest cluster is probably the line items.
 * *TODO* use all "large" clusters as line item candidates and then pick the one that best reads the documents.
  ### SL_Columns
This script locator identifies the columns.  
Each page of the document is shifted horizontally slightly from every other page. The IBML has a top and bottom scanner and they are not perfectly aligned with each other. The script **Page_LeftMargin** calculates the left text margin of each page and stores it in the XDoc as this value is used thousands of times to compare words from different pages with each other. In the example below you see that the first page has a left text margin of 41.00 pixels and the second page has 56 pixels. This means I have to shift every word on the secod page 15 pixels to the left to compare it with words on the first page.
![image](https://user-images.githubusercontent.com/47416964/129357990-a53ca855-0ea3-4a39-af28-8918df824bb5.png)
* all the words in the "best row cluster" are clustered together based on whether they overlap each other.  
*Note: in this example **client[90]** refers to a word that was found in textline 90 on another page of the document and was "moved" to the first for fitting into it's column"  
![image](https://user-images.githubusercontent.com/47416964/235957337-6be4e372-ece6-42bd-8316-c3efb3e691a5.png)
* Columns that only contain the same text, (eg **client** or **#**)  can be deleted because they are meaningless, (They can however serve as **ROW ANCHOR WORDS** to identify rows throughout the rest of the document).  
 * **Words_Narrow** is a script, that repeatedly removes the widest word from each column, only leaving ONE word behind. This solves the problem that the OCR engine can merge some words together to cross columns. Here we are left with ONE example word per column.  
![image](https://user-images.githubusercontent.com/47416964/235957640-4610a99a-2665-4ff2-84e1-0270d8e6877c.png)

Now, since all rows have been found and all columns have been found, it is **trivial** to reconstruct the table!  

But the columns are still unknown and we need to do **Column Classification** to determine the correct **meaning** of each of these columns.
