## STREAM in PIECES

This tutorial is a follow on to Working with **%Query**  
It was displaying the content of the input stream chopped in fixed-size chunks.  
But often those streams are structured and have well-defined separators (e.g HL7)  
So as a side subject of this tutorial, this chapter shows how to break a stream into PIECES.

It is exactly the same idea as the **$PIECE(**) function for strings with some add-ons.

  
The query takes these input parameters:

*   **idfrom** = first ID to show
*   **idto** = last ID to show - missing shos al higher IDs available
*   **maxtxt** \= maximum size of output text from the stream. Default = 25
*   **separator** = characters as know from $Piece function 
*   **startpiece** = first piece to display
*   **endpiece** = last piece to display - if missing only the first is displayed
*   **grouped** = number of pieces in output text.  limited by **maxtxt** - default = 1
*   **before** = number of characters before the limiter from the previous piece

### Implementation

The base for the Query was shown in the previous chapters.  
Again the Source Object is kept local while processing the related Stream.  
And as for the fixed-sized chunks also the Stream Object is kept while  
processing the resulting output lines.

To find the pieces and count them method FindAt() scans the whole Stream  
as a first action and builds a list of start points. It is used when the pieces  
are collected into their groups by line.  
The Stremfunction used is ReadSQL(start, end). It is a somewhat sensitive  
and honors unprecise values with no result.  
It is all packaged the method Piece() of the example code 

To enable multiple reentrances in the Fetch method all parameters are kept a in  
the common JSON object of the customized Query.

Here are some examples

*   Record #3 was deleted
*   Record#4 has no stream
*   PieceCnt shows the total pieces in the first row and number of pieces folowing
*   PieceId shows the number of the first Piece displayed

* The first example shows object **1..5** with max **33** chars  
separated by **||** pieces **2..4**  grouped by **2**  with **3** previous characters
````
    USER>>call rcc.Q3(1,5,33,'||',2,4,2,3)
    7.     call rcc.Q3(1,5,33,'||',2,4,2,3)
    
    Dumping result #1
    ID      City    Name    Age     pcCnt   PieceId PieceTxt
    1       Bensonh Kovalev 16      52      2       ty.||Scope ||An AmAn LoIcA On
    _       _       _       _       2       4        On||Iso
    2       Queensb Yeats   15      52      2       00.||LoI||IesMorphSy
    _       _       _       _       2       4       hSy||Re Uni
    4       Newton  Evans   61      0       2
    5       Hialeah Zemaiti 47      52      2       ks.||TwoToLy Wa||LoGraphIc Theti
    _       _       _       _       2       4       eti||Ism LoToTri AticViaOpOp
     
    7 Rows(s) Affected
    statement prepare time(s)/globals/lines/disk: 0.0064s/2159/18029/0ms
              execute time(s)/globals/lines/disk: 0.0060s/186/21480/0ms
                              cached query class: %sqlcq.USER.cls86
    ---------------------------------------------------------------------------
````
*  Next example:     
All records from **5** to **end**, only **33** characters, separated with **||** pieces **50 ..55** and **1** by line
````
    USER>>call rcc.Q3(5,,33,'||',50,55,1)
    9.     call rcc.Q3(5,,33,'||',50,55,1)
    
    Dumping result #1
    ID      City    Name    Age     pcCnt   PieceId PieceTxt
    5       Hialeah Zemaiti 47      52      50      ||LoOp Am TriAmGeo LookMuch ReAble
    _       _       _       _       1       51      ||AnIAn I GeoIc Ly Copter A IcA
    _       _       _       _       1       52      ||***Done***
    6       Elmhurs Jenkins 29      52      50      ||Re PhotoTech Ies
    _       _       _       _       1       51      ||A
    _       _       _       _       1       52      ||***Done***
    7       Islip   Drabek  61      52      50      ||Thetic Status Cycle AmAm To Tech
    _       _       _       _       1       51      ||Ly SoundCo CoCo AmCo Am ToRePus
    _       _       _       _       1       52      ||***Done***
    8       Islip   Kovalev 88      52      50      ||IcGeoType PhysicalLyIsm Ies To T
    _       _       _       _       1       51      ||ComI An GeoRange On AnOnTo Two P
    _       _       _       _       1       52      ||***Done***
     
    12 Rows(s) Affected
    statement prepare time(s)/globals/lines/disk: 0.0065s/2158/18091/0ms
              execute time(s)/globals/lines/disk: 0.0082s/245/28753/0ms
                              cached query class: %sqlcq.USER.cls103
    ---------------------------------------------------------------------------
````    

I hope you liked it so far and I count on your votes
