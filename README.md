# Kofax Transformation Script Library
A collection of mostly very useful scripts containing various algorithms.  
These scripts are provided as-is. There is no guarantee that they will work. You will need to understand them to use them in your projects.  
Requests, fixes, suggestions, and new scripts are welcome. Please use [issues](https://github.com/KofaxRPA/KTScripts/issues) to provide feedback.
# Script Locators
* [Column Locator](Column%20Locator.md) *detects text columns in a document*
* [Dynamic Fuzzy Search Locator](DynamicFuzzySearchLocator.md) **POWERFUL** *fuzzy search a document for values from a previous locator!*
* [Compare 2 documents](Document%20Comparison.md) **POWERFUL** *script that detects all differences between two documents*
* [NLP (Natural Language Prcessing)](NLP%20via%20script.md)
* [Passport MRZ Locator](Passport_MRZ.vb)
* [Run Previous Locators from Script](Run%20Previous%20Locators%20from%20Script.md) **VERY POWERFUL** *your script locators now **know** which locators they are dependent on and run then on-demand only if needed, saving you valuble time. Just press **Test** on the locator and everything is automatically calculated!*
# Field Formatters
* [Scripting Field Formatters](Custom%20Field%20Formatters.md)
* [Fuzzy Field Formatter](Fuzzy%20Formatter%20%26%20Validation%20Rule.md) *useful to make a spellchecker!*
* [Name Suggestor Demo](NameSuggestor.mp4)
# Validation Rules
* [Fuzzy Validation Rule](Fuzzy%20Formatter%20%26%20Validation%20Rule.md) *useful for finding unusual spellings and suggesting potential corrections*
# Zones
* (Move Zones by Script)[Move%20Zone%20by%20Script.md]
* (Perform Zone OCR in script)[OCR.vb]
# Tables
* [How to Use Table Locators](Knowhow%20-%20How%20to%20use%20KT%20Table%20Locators.docx)
* [Copy Zones into to Table](Copy%20Zones%20to%20Table.md)
* [Copy Subfields into a Table](Copy%20a%20Locator's%20Subfields%20into%20a%20Table.md)
* [Fast Table Lassoing](FastTableLassoing.avi) *quickly and interactively select table columns and rows in the Validation Interface*
* [3-way Line Item Matching demo](LIMLocDemo.7z) *a complete project showing Line Item Matching Locator, 3-way matching and interactive SQL database lookup in Validation*
# Locator Customization
* [How to customize any locator](Customize%20Locators.md)
* [Force Format Locator to search across multiple lines](Format%20Locator%20that%20ignores%20line%20wrapping.md) *the format locator only searches within each line of text. This makes it search further..*
# Database & Dictionary Scripts
* [Fuzzy search a database from script](Database_FuzzySearch.vb)
* [Database script functions](Database_Search.vb)
* [Fuzzy search a dictionary](Dictionary%20Search.vb)
* [update database per document](Dynamically%20Change%20Database%20or%20Dictionary.md) **POWERFUL** *changes a fuzzy database instantly per document. If you know who the document is from you can search ONLY for their address, phone number, date of birth - the database will contain no-one else*
* [Fuzzy Dictionary Substitution](Fuzzy%20Dictionary%20Substitution.md) **POWERFUL** *fuzzy search a document for words/phrases and return associated fields for these values*
# Validation Interface Script
* Fast Table Lassoing [demo video](FastTableLassoing.avi) and [script](Interactive%20Fast%20Table%20Lassoing.vbs) *quickly and interactively select table columns and rows in the Validation Interface*
# Classification
* [Page Classification](Page_Classification.md)
* [Page Locators](https://github.com/KofaxTransformation/KTScripts/blob/master/Page_Locators.md) **VERY POWERFUL** * write locators at the page level*
* [Paragraph Classification](Paragraph%20Classification.md)
* 
# Pages
* [Page Classification](Page_Classification.md) *
* [Split a page horizontally or vertically](Split%20a%20Page.md)
# Geometry Functions
* [Find Left Margin of a Page](Find%20Left%20Margin%20of%20Page.md) *very precise and fuzzy with sub-pixel accuracy for the left margin of a page. Useful for comparing two pages and paragraph detection*
# OCR scripts
* [Change_OCR_Characters.md](Change_OCR_Characters.md)
# Functions
* [Field Copy](Field_Copy.vb) **VERY POWERFUL** *This is the most important KT script! intelligently & recursively copy a field, locator, alternative, subfield, cell, row, xdoc into another. This script will dramitically simplify your own scripts and make them much more readable.*
* [File System](File%20System.vb) *Get All files, File_Exists, Dir_Exists, File_NameWithoutExtension etc*
* [Sorting Alternatives](Alternatives%20Sort.md)
* [Fuzzy Match Text](FuzzyMatch.vb) **VERY POWERFUL** *fuzzy match any two pieces of text. 0%=no match, 100%=exact match*
* [IBAN validation](IBAN.md)
* [JSON](JSON.md) *quick and dirty JSON parser*
* [Quicksort](https://github.com/KofaxTransformation/KTScripts/blob/master/QuickSort.vb) **VERY POWERFUL** *sort alternatives fast by confidence, alphabetically, coordinates, page, textline, etc.*
# Output
* [Write Fields to CSV](https://github.com/KofaxTransformation/KTScripts/blob/master/Fields%20to%20CSV.md)
# Integration
* [Kofax Total Agility](20%20-%20Integrating%20Kapow%20with%20Total%20Agility.pdf)
# Benchmarking
* [Character Level Benchmark](Character_Level_Benchmark.md)
# Images
* [Detect Page Size](Detect%20Page%20Size.md) *detects whether a page is A4, A3, US Letter, Foolscap, etc. Landscape vs Portrait. Works well on cropped images too*
# Documents
* [Convert PDF to TIFF](PDFtoTiff.md) **VERY POWRFUL** *convert your PDF samples to TIFF while preserving the Text layer. Speeds locator testing *10 !*
* [Gibberish/Nonsense/Bad OCR Detection](GibberishDetection.md) *check if a document is mostly unreadable OCR or corrupted/encrpyted PDF. Useful for language detection as well*
* [How to read Russian Invoices](How%20to%20Read%20Russian%20Invoices.md)
