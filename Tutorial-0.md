The title of the contest subject is not quite precise but addresses the %Library.classes involved.  
What is meant is officially named [**Class Query**](https://docs.intersystems.com/iris20223/csp/docbook/DocBook.UI.Page.cls?KEY=GOBJ_queries) and is dating back to the early days of Caché.  
_CLASS_ is used because it is embedded in a COS class.  
Though there is a precise description in the official documentation it remains rather abstract.  
My tutorial should guide you step-by-step through a simple example in COS to make it tangible to you

*   All code examples are available on [**GitHub**](https://github.com/rcemper/Tutorial-QUERY)
*   All examples can be exercised from Terminal, Console, or WebTerminal.
*   I use a personal command **ZZQ** homed in %ZLANGC00.INT for test and demo which runs the SQL Shell  >>>  "DO $system.SQL.Shell()"
*   SQL Shell runs interactive and allows simple debugging of your code
*   Finally, I use Studio as it includes a very comfortable wizard for ClassQueries

**_Intro_**

For any demo or tutorial, some test data are required.  
My simple table/class design just has 4 columns:

*   Id
*   City
*   Name
*   Age
*   Stream

While the first 4 are rather normal data types easily mapped to SQL  
Stream provides the challenge to use a Class Query for display.  
The idea in background: If this is a patient record then some big  
stream documents might be directly attached to it.  
The class is defined as \[Final\] to keep the Global more readable.

The demo content is generated using %Populate Utility.   
Therefore your data will look differenet than here.  
Except for the Stream that is not serviced by %Populate.  
Here I generate some text that is randomly split into sections  
using || (double pipe) as a segment separator.    
(! it is not a tutoriral on %Populate Utility!)

It's simply USER>**Do ##class(rcc.TU).Populate(8)**
````
    USER>kill ^rcc.TUD(3)           ;; make aa gap
    USER>set $LI(^rcc.TUD(4),4)=""  ;; no stream
    USER>zw ^rcc.TUD
    ^rcc.TUD=8
    ^rcc.TUD(1)=$lb("Bensonhurst","Kovalev",16,"1")
    ^rcc.TUD(2)=$lb("Queensbury","Yeats",15,"2")
    ^rcc.TUD(4)=$lb("Newton","Evans",61,"")
    ^rcc.TUD(5)=$lb("Hialeah","Zemaitis",47,"5")
    ^rcc.TUD(6)=$lb("Elmhurst","Jenkins",29,"6")
    ^rcc.TUD(7)=$lb("Islip","Drabek",61,"7")
    ^rcc.TUD(8)=$lb("Islip","Kovalev",88,"8")
````
You see that I remove the stream for ID=4  
and also the whole ID=3 to simulate missing content.

**The case %SQLquery**

You create an empty class frame  (**rcc.TU0**) and let the wizard add a Query  
![](https://community.intersystems.com/sites/default/files/inline/images/images/image(5652).png)

And it guides you through all the required parameters:  
We first create a **Basic Class Query**   
![](https://community.intersystems.com/sites/default/files/inline/images/images/image(5653).png)  
and add our input parameters  (I have just 1)  
![](https://community.intersystems.com/sites/default/files/inline/images/images/image(5654).png)  
and  
![](https://community.intersystems.com/sites/default/files/inline/images/images/image(5655).png)  
that is the result  
![](https://community.intersystems.com/sites/default/files/inline/images/images/image(5656).png)

That's not so impressive yet and you need to add some more parameters + your Query!  
you may do it just by typing or using Studio's Inspector which knows all quotes and brackets

*    CONTAINID defines the column of your ID in the resulting row
*   SqlProc indicates that your query may be used as Procedure  (which we will do)
*   SqlName \= Q0  assigns a name within your class package (mostly simpler)
*   **most important:** your SQL statement applying your input parameters as host variables

so it looks like this:   
     
![](https://community.intersystems.com/sites/default/files/inline/images/images/image(5657).png)

### WHAT IS THIS GOOD FOR ?

*   This is, of course, the most simple statement. Normally  you would use it for rather complex SQL statements that are frozen now and as SQLprocedure available anywhere internal or from some external ODBC or JDBC client 
*   all ODBC/JDBC protocol is precompiled for your query. 
*   It looks like embedded SQL but you are not caught in your classmethod.
*   internal it is available for %ResultSet, or  %SQL.Statement or $system.SQL.Shell()
*   either direct using `CALL rcc.Q0(4)`  or as sub-select  `SELECT Id, name FROM rcc.Q0(99) where AGE > 21` 

And it looks like this:

*       
        USER>DO $system.SQL.Shell()
        SQL Command Line Shell
        ----------------------------------------------------
        The command prefix is currently set to: <<nothing>>.
        Enter q to quit, ? for help.
        [SQL]USER>>call rcc.q0(4)
        3.      call rcc.q0(4)
        
        Dumping result #1
        ID      Age     City    Name    Stream
        1       16      Bensonhurst     Kovalev "1%Stream.GlobalCharacter
                                                                           ^rcc.TUS"
        2       15      Queensbury      Yeats   "2%Stream.GlobalCharacter
                                                                           ^rcc.TUS"
        4       61      Newton  Evans
        5       47      Hialeah Zemaitis        "5%Stream.GlobalCharacter
                                                           ^rcc.TUS"
        4 Rows(s) Affected
        statement prepare time(s)/globals/lines/disk: 0.0003s/11/583/0ms
                  execute time(s)/globals/lines/disk: 0.0006s/4/1515/0ms
                                  cached query class: %sqlcq.USER.cls77
        ---------------------------------------------------------------------------
    
*       [SQL]USER>>SELECT Id, age, name FROM rcc.Q0(99) where AGE > 21 
        6.      SELECT Id, age, name FROM rcc.Q0(99) where AGE > 21 
         
        ID      Age     Name
        4       61      Evans
        5       47      Zemaitis
        6       29      Jenkins
        7       61      Drabek
        8       88      Kovalev
         
        5 Rows(s) Affected
        statement prepare time(s)/globals/lines/disk: 0.0726s/45969/214801/0ms
                  execute time(s)/globals/lines/disk: 0.0016s/123/2486/0ms
                                  cached query class: %sqlcq.USER.cls81
        ---------------------------------------------------------------------------
    

It's immediately obvious to you that instead of the Stream content you get a mystic StreamReference

Follow me on to the [**next chapter**](https://github.com/rcemper/Tutorial-QUERY/blob/main/Tutorial-1.md) of a custom code based Query. 

Just a reminder:   
All test data are generated using the System method %Populate    
So your output will be different . I suggest you run your tests also with other parameters   
than the shown examples to get the full power of this tool.  
    
