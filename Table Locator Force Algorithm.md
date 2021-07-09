The Automatic Table Locator has [4 algorithms](https://docshield.kofax.com/KTT/en_US/6.3.0-v15o2fs281/help/PB/ProjectBuilder/450_Extraction/TableLocator/t_UsingExpertModeforTestingTables.html?h=algorithm)  
This script forces the Table Locator to use a particular algorithm.  The table locator is reset automatically after it is called, so there is no need to "reset" the table locator for the next document.

```vb
Enum TableAlgorithm
   AmountBased =1 'Looks for A*B=C in each table row
   PositionBased ' Looks for a column containing the position numbers 1,2,3,4,5
   HeaderBased 'Uses Table Header Pack
   LinesBased ' Uses vertical and horizontal lines inside the table
   LayoutBased ' looks at white space between columns to identify columns
End Enum

Private Sub Document_BeforeLocate(ByVal pXDoc As CASCADELib.CscXDocument, ByVal LocatorName As String)
   Select Case LocatorName
   Case "TL"
      Table_SetAlgorithm(LocatorName, TableAlgorithm.HeaderBased, pXDoc)
   End Select
End Sub

Private Sub Table_SetAlgorithm(ByVal LocatorName As String, Algorithm As TableAlgorithm,ByVal pXDoc As CASCADELib.CscXDocument)
   XDocument_GetClass(pXDoc).Locators.ItemByName(LocatorName).LocatorMethod.Algorithm=Algorithm
End Sub

Function XDocument_GetClass(pXDoc As CscXDocument) As CscClass
   'This is useful in designer. returns the ClassificationResult of an XDoc. If it has none then returns the DefaultClassificationResult
   If pXDoc.ExtractionClass<>"" Then Return Project.ClassByName(pXDoc.ExtractionClass)
   Return Project.ClassByID(Project.DefaultClassId)
End Function

```
