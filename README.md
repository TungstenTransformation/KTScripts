# Kofax Transformation Script Library
A collection ofvery useful scripts containing various algorithms.  
These scripts are provided as-is. There is no guarantee that they will work. You will need to understand them to use them in your projects.  
Please use [issues](https://github.com/KofaxRPA/KTScripts/issues) for requests, fixes, suggestions, and new scripts you want to share.
# Index
* [Script Locators](#script-locators)
* [Field Formatters](#field-formatters)
* [Validation Rules](#validation-rules)
* [Zones](#zones)
* [Tables](#tables)
* [Locator Customization](#locator-customization)
* [Text Content Locator](Text%20Content%20Locator%20Training.md)
* [Databases & Dictionaries](#database--dictionary-scripts)
* [Classification](#classification)
* [Page Extraction and Classification](#pages)
* [Geometry](#geometry-functions)
* [OCR](#ocr-scripts)
* [Powerful Functions](#functions)
* [Output](#output)
* [Benchmarking](#benchmarking)
* [Images](#images)
* [Documents](#documents)
* [Project Manipulation](#project-manipulation)
* [File System functions](/File%20System.vb)

# Script Locators
* [Column Locator](Column%20Locator.md) *detects text columns in a document*
* [Dynamic Fuzzy Search Locator](DynamicFuzzySearchLocator.md) **POWERFUL** *fuzzy search a document for values from a previous locator!*
* [Compare 2 documents](Document%20Comparison.md) **POWERFUL** *script that detects all differences between two documents*
* [NLP (Natural Language Prcessing)](NLP%20via%20script.md)
* [Passport MRZ Locator](Passport_MRZ.vb)
* [Run Previous Locators from Script](Run%20Previous%20Locators%20from%20Script.md) **VERY POWERFUL** *your script locators now **know** which locators they are dependent on and run then on-demand only if needed, saving you valuble time. Just press **Test** on the locator and everything is automatically calculated!*
* [UK VAT Locator](UK%20VAT%20Lookup.md) *look up VAT id's online at UK government. Only works inside UK.*
* [Webservice](Webservice.md)
# Field Formatters
* [Scripting Field Formatters](Custom%20Field%20Formatters.md)
* [Fuzzy Field Formatter](Fuzzy%20Formatter%20%26%20Validation%20Rule.md) *useful to make a spellchecker!*
* [Name Suggestor Demo](NameSuggestor.mp4)
* [UK VAT Formatter](UKVAT_Formatter.md)
# Validation Rules
* [Fuzzy Validation Rule](Fuzzy%20Formatter%20%26%20Validation%20Rule.md) *useful for finding unusual spellings and suggesting potential corrections*
# Zones
* [Move Zones by Script](Move%20Zone%20by%20Script.md)
* [Perform Zone OCR in script](OCR.vb)
* [Register Zones on difficult pages](https://github.com/KofaxTransformation/KTScripts/blob/master/Text%20Layout%20Classification%20and%20Registration.md#text-layout-registration).
* [Automatically Generate Zone Locators from external coordinate data](https://github.com/KofaxTransformation/AutoAdvancedZoneLocator)
# Tables
* [How to Use Table Locators](Knowhow%20-%20How%20to%20use%20KT%20Table%20Locators.docx)
* [Table Benchmark Guide](Table_Benchmark.md)
* [Advanced Table Locator Guide]([Tables_AdvancedTableLocatorGuideForKTA.md]) (new locator in 2023)
* [Copy Zones into to Table](Copy%20Zones%20to%20Table.md)
* [Copy Subfields into a Table](Copy%20a%20Locator's%20Subfields%20into%20a%20Table.md)
* [Fast Table Lassoing](FastTableLassoing.avi) *quickly and interactively select table columns and rows in the Validation Interface*
* [3-way Line Item Matching demo](LIMLocDemo.7z) *a complete project showing Line Item Matching Locator, 3-way matching and interactive SQL database lookup in Validation*
* [Table Detection by Gridlines](Table%20Detection%20by%20Table%20Grid%20Lines.vbs)
* [Table Extraction by Regex](Table%20Extraction%20By%20Regex.md)
* [Table Header Pack Parser](Table%20Header%20Pack%20Parser.md)
* [Insert Missing Rows into a Table](Table%20Insert%20Missing%20Rows.md) *automatically finds missing rows that the table locator missed*
* [Force Table Locator to use a particular algorithm](Table%20Locator%20Force%20Algorithm.md) *the table locator has 5 internal algorithms that are all run and voted against. Here you decide which algorithm wins always*
* [Validate Table Rows with a Fuzzy Database](Table%20Validate%20Rows%20with%20Fuzzy%20Database.md)
* [Write Table to CSV](Table%20to%20CSV.md)
* [Table Scripting Framework](TableScriptingFramework.md) *a powerfu&  generic approach to enhance table locators*
* [Reading unknown table layouts and tables in tables](Tables_ReadingUnknownTableLayouts.md) Powerful new algorithms for automatically analyzing unknown tables layouts, including tables in tables.
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
* [Custom Classification](Custom%20Classification.md)  
* [Page Classification](Page_Classification.md)
* [Page Locators](Page_Locators.md) **VERY POWERFUL** * write locators at the page level*
* [Paragraph Classification](Paragraph%20Classification.md)
* [String Classification](String_Classify.vb) **VERY POWERFUL** *classify any string, even a word or phrase!*
* [Text Layout Classification](Text%20Layout%20Classification%20and%20Registration.md) **VERY POWERFUL** *a completely new classification strategy. No configuration required. It classifies a page based on the position of every word on the page. It is very sensitive to subtle changes between similar documents. If your forms only vary slightly, this will detect that!*
# Pages
* [Page Classification](Page_Classification.md)
* [Split a page horizontally or vertically](Split%20a%20Page.md)
# Geometry Functions
* [Calculate Overlaps](Overlap.md) of fields, zones, rows etc. Fundamental to many geometry algorithms and custom table locators.
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
* [Quicksort](QuickSort.vb) **VERY POWERFUL** *sort alternatives fast by confidence, alphabetically, coordinates, page, textline, etc.*
* [String Regex](String_Regex.vb) *Split a string via regex. eg "2004-12-23" into "2004","12","23"
* [Numbers to Text](TurkishNumbers.md) *Convert numbers to text eg "1234" to "one thousand two hundred and thirty four". Useful for checking that numbers match their text form*
# Output
* [Write Fields to CSV](Fields%20to%20CSV.md)
* [Write Table to CSV](Table%20to%20CSV.md)
* [Write Fields to Excel](Write%20to%20Excel.md) *including colors, formats, images and more!*
# Integration
* [Kofax Total Agility](20%20-%20Integrating%20Kapow%20with%20Total%20Agility.pdf)
# Benchmarking
* [Character Level Benchmark](Character_Level_Benchmark.md)
# Images
* [Detect Page Size](Detect%20Page%20Size.md) *detects whether a page is A4, A3, US Letter, Foolscap, etc. Landscape vs Portrait. Works well on cropped images too*
# Documents
* [Text Deskew](Table%20to%20CSV.md) *If a document is not deskewed before or during OCR the textlines can be messed up. This calculates the page skew AFTER OCR and then realigns all the words into their correct text lines.
* [Convert PDF to TIFF](PDFtoTiff.md) **VERY POWERFUL** *convert your PDF samples to TIFF while preserving the Text layer. Speeds locator testing x10 !*
* [Gibberish/Nonsense/Bad OCR Detection](GibberishDetection.md) *check if a document is mostly unreadable OCR or corrupted/encrpyted PDF. Useful for language detection as well*
* [How to read Russian Invoices](How%20to%20Read%20Russian%20Invoices.md)
# Project Manipulation
These are advanced scripting techniques to access to project and locator settings via script. This gives you the power to create, delete and edit classses, fields, locators, and almost any setting in the project. This is very dangerous and can destroy your projects. Also note that the Project Builder will not be updated with changes you make to the project and will cause GUI errors. Tread carefully and  - you are on your own - don't expect support from Tech Support!

* [How to Read Locator Settings](How%20To%20Read%20Locator%20Settings.md)
