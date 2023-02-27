My previous article introduced you to SQL based **Basic Class Query**  
where a clever wizard created all the required code for you and your essential  
contribution was an SQL statement. 

Now we enter the real **Custom Class Query** that provides more freedom but  
requires a deeper understanding of the mechanic behind the scene.  
The full code example is again on [**GitHub**](https://github.com/rcemper/Tutorial-QUERY)

Some things haven't changed:

*   demo data are the same
*   consumption of the query is also unchanged
*   all handling of ODBC / JDBC protocol is still generated.

So what is different?

*   You need a header statement to declare your input parameters but also the record layout for your output. ROWSPEC
*   you have to provide an Execute method to initialize your query and consume your input parameters
*   a Close method to clean up your environment
*   and a Fetch method that does the Job.
    *   it is called row by row until you set AtEnd=1. (it is passed by reference)
    *   and you return variable Row (also passed by reference) as $LB() structure
    *   so it is obvious that the resulting Row is shorter than MAXSTRING
    *   and this is our challenge to present your stream

so we take our choice:   
as before we use the Studio's Query Wizard  
![](https://community.intersystems.com/sites/default/files/inline/images/images/image(5659).png)

we have 3 parameters: idfrom (first ID), isto (last ID), maxtxt (maxim text from stream)  
![](https://community.intersystems.com/sites/default/files/inline/images/images/image(5660).png)  
and **new** the layout of our output (ROWSPEC), similar to above  
![](https://community.intersystems.com/sites/default/files/inline/images/images/image(5662).png)  
for our Stream, we need to overwrite %String defaults to match ODBC / JDBC  
The type needs to be `%String(EXTERNALSQLTYPE = "LONGVARCHAR", MAXLEN = "")`​​​  
This is the generated code framework:

    Query Q1(
        idfrom As %Integer = 1,
        idto As %Integer = 0,
        maxtxt As %Integer = 25) As %Query
        (ROWSPEC = "ID:%Integer,City:%String,
                   Name:%String,Age:%Integer,
                   Stream:%String(EXTERNALSQLTYPE=""LONGVARCHAR"", MAXLEN = """")")
    {
    }
    ClassMethod Q1Execute(
        ByRef qHandle As %Binary,
        idfrom As %Integer = 1,
        idto As %Integer = 0,
        maxtxt As %Integer = 25) As %Status
    {
        Quit $$$OK
    }
    ClassMethod Q1Close(ByRef qHandle As %Binary) As %Status [ PlaceAfter = Q1Execute ]
    {
        Quit $$$OK
    }
    ClassMethod Q1Fetch(
        ByRef qHandle As %Binary,
        ByRef Row As %List,
        ByRef AtEnd As %Integer = 0) As %Status [ PlaceAfter = Q1Execute ]
    {
        Quit $$$OK
    }

we still need to add `CONTAINID=1` and   `[ SqlName = Q1, SqlProc ]`

*   **Query Q1()** is the descriptor used by the interface support
*   **qHandle** is the common data structure for all 3 methods whatever you pass along to the next row processing needs to be stored there. e.g. first ID, last ID, actual ID, ......  In past this was typically a subscripted variable or some oref As a personal experiment, I tried a JSON object and it worked fine.
    
        ClassMethod Q1Execute(
            ByRef qHandle As %Binary,
            idfrom As %Integer = 1,
            idto As %Integer = 0,
            maxtxt As %Integer = 25) As %Status
        {
          set qHandle={}
          set qHandle.id=0
          set qHandle.idfrom=idfrom
          set qHandle.idto=idto
          set qHandle.obj=0
          set qHandle.stream=0
          set qHandle.maxtxt=maxtxt
          Quit $$$OK
        }
    
*   **Q1Fetch** is the biggest working  bloc  I used object access in this example to keep it more readable Accessing the Globals for Date and Stream directly was remarkable faster but really hard to read and to follow, The more important point is that you can do whatever you like, not just collect or select data. Many management routines use it to display Processes, actual Users,  ... whatever can be presented as a table.  The point is to compose the $LB() for Row and return it and once you are done, Set AtEnd=1, and the query terminates. In this example, the major challenge is to skip nonexisting objects and to skip no existing streams to avoid empty result lines.
    
        /// that's where the music plays
        /// called for evey row delivered
        ClassMethod Q1Fetch(
        	ByRef qHandle As %Binary,
        	ByRef Row As %List,
        	ByRef AtEnd As %Integer = 0) As %Status [ PlaceAfter = Q1Execute ]
        {
          /// first access
          if qHandle.id<qHandle.idfrom set qHandle.id=qHandle.idfrom
          ///
        nextrec
          if qHandle.idto,qHandle.idto<qHandle.id set AtEnd=1
          if qHandle.id>^rcc.TUD set AtEnd=1
          if AtEnd quit $$$OK
          if 'qHandle.obj {
            set obj=##class(rcc.TU).%OpenId(qHandle.id)
              ,qHandle.obj=obj
              ,qHandle.stream=0
          } 
          if 'obj set qHandle.id=qHandle.id+1 goto nextrec
          if 'qHandle.stream set qHandle.stream=qHandle.obj.Stream
          set text=qHandle.stream.Read(qHandle.maxtxt)
          set Row=$lb(qHandle.id,qHandle.obj.City,qHandle.obj.Name,qHandle.obj.Age,text)
        /// row completed
          set qHandle.id=qHandle.id+1
          set qHandle.stream=0
          set qHandle.obj=0
          Quit $$$OK
        }
    
*   and here a short test
    
        USER>>call rcc.Q1(4,7)
        8.      call rcc.Q1(4,7)
        
        Dumping result #1
        ID      City    Name    Age     Stream
        4       Newton  Evans   61
        5       Hialeah Zemaitis        47      Resellers of premise-base
        6       Elmhurst        Jenkins 29      Enabling individuals and
        7       Islip   Drabek  61      Building shareholder valu
         
        4 Rows(s) Affected
        statement prepare time(s)/globals/lines/disk: 0.0065s/1982/14324/0ms
                  execute time(s)/globals/lines/disk: 0.0010s/31/2120/0ms
                                  cached query class: %sqlcq.SAMPLES.cls66
        ---------------------------------------------------------------------------
    
Getting just begin of our stream is not always sufficient.

Follow me on to the [**next chapter**](https://github.com/rcemper/Tutorial-QUERY/blob/main/Tutorial-2.md) for the extension of this example  
will show and control more result lines.  
