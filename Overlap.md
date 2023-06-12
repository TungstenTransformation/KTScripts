## Overlap functions
These functions are core to many geometry algorithms calculating whether objects overlap each other.  
Typically they look at two rectangles. If they are identical they return 1.00=%100, if they don't touch each other they return 0.00 = 0%.  
They all use the functions **min** and **max** that need to be defined (see bottom of script).  
They all use the keyword [**return**](https://www.winwrap.com/web2/basic/#!/ref/WWB-doc_return_instr.htm) and so require **'#Language "WWB-COM"** as the first line of the script. See [WinWrap Documentation](https://www.winwrap.com/web2/basic/#!/ref/WWB-doc_language_def.htm) for further details.


```vb
Public Function Object_OverlapHorizontal( a As Object, b As Object,Optional PixelShift As Long=0,Optional ignorePageIndex As Boolean=False) As Double
   'Calculates the horizontal overlap of two fields and returns 0<=overlap<=1
   'Overlap=1 is also returned if one field is inside the other
   'offset has the number of pixels of horizontal shift between the two objects
   'PixelShift is the horizontal difference between two pages (perhaps the second page was shifted left by the scanner...)
   If (Not ignorePageIndex And (a.PageIndex <> b.PageIndex)) Or a.PageIndex=-1 Or a.Width = 0 Or b.Width=0 Then Return 0
   If a.Width=0 Or b.Width=0 Then Exit Function
   Return Max((Min(a.Left+a.Width,b.Left+b.Width+PixelShift)-Max(a.Left,b.Left+PixelShift)),0)/Min(a.Width,b.Width)
End Function

Public Function Object_OverlapVertical( a As Object, b As Object,Optional ignorePageIndex As Boolean=False) As Double
   'Calculates the vertical overlap of two fields and returns 0<=overlap<=1
   'Overlap=1 is also returned if one field is inside the other
   'offset has the number of pixels of vertical shift between the two objects
   If (Not ignorePageIndex And (a.PageIndex <> b.PageIndex)) Or a.PageIndex=-1 Then Return 0
   If a.Height = 0 Or b.Height=0 Then Exit Function
   Return Max((Min(a.Top+a.Height,b.Top+b.Height)-Max(a.Top,b.Top)),0)/Min(a.Height,b.Height)
End Function
            
Public Function Line_HorizontalOverlap( a As Object, b As Object) As Double
   'Calculates the horizontal overlap of two fields and returns 0<=overlap<=1
   Dim o As Double
   If TypeOf a Is ICscXDocLine Then
      If a.StartX = a.EndX Or b.Width=0 Then Exit Function
      o=Max((Min(a.EndX,b.Left+b.Width)-Max(a.StartX,b.Left)),0)
      Return o/Max(a.EndX-a.StartX,b.Width)
   Else
      If a.Width = 0 Or b.Width=0 Then Exit Function
      o=Long_Max((Min(a.Left+a.Width,b.Left+b.Width)-Max(a.Left,b.Left)),0)
      Return o/_Max(a.Width,b.Width)
   End If
End Function            

Public Function Line_VerticalOverlap( a As Object, b As Object) As Double
   'Calculates the vertical overlap of two fields and returns 0<=overlap<=1
   Dim o As Double
   If TypeOf a Is ICscXDocLine Then
      If a.EndY = a.StartY Or b.Height=0 Then Exit Function
      o=Long_Max((Long(a.EndY,b.Top+b.Height)-Long(a.StartY,b.Top)),0)
      Return o/Long(a.EndY-a.StartY,b.Height)
   Else
      o=Long_Max((Long(a.Top+a.Height,b.Top+b.Height)-Long(a.Top,b.Top)),0)
      Return o/Long(a.Height,b.Height)
   End If
End Function
                        
Public Function Object_Overlap2D( a As Object, b As Object) As Double
   'returns percentage overlap of two fields, subfields or alternatives (0.0 if no overlap, 1.0 if perfect overlap)
   'Check if fields are on the same page and that both exist
   If a.PageIndex <> b.PageIndex Or a.PageIndex=-1 Then  Return 0
   Dim overlapArea As Double
   overlapArea=Max((Min(a.Left+a.Width,b.Left+b.Width)-Max(a.Left,b.Left)),0) * Max((Min(a.Top+a.Height,b.Top+b.Height)-Max(a.Top,b.Top)),0)
   Return overlapArea/Max(a.Width*a.Height,b.Width*b.Height)
End Function

Public Function Max(v1, v2)
   return IIf( v1 > v2, v1, v2)
End Function

Public Function Min(v1, v2)
   return IIf( v1 < v2, v1, v2)
End Function
```
