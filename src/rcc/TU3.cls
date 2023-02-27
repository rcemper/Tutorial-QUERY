Class rcc.TU3
{

Query Q3(
	idfrom As %Integer = 1,
	idto As %Integer = 0,
	maxtxt As %Integer = 25,
	chunks As %Integer = 1) As %Query(CONTAINID = 1, ROWSPEC = "ID:%Integer,chunk:%Integer,City:%String,Name:%String,Age:%Integer,Stream:%String(EXTERNALSQLTYPE = ""LONGVARCHAR"", MAXLEN = """")") [ SqlName = Q3, SqlProc ]
{
}

/// pack all params into qj
/// called only once at start
ClassMethod Q3Execute(
	ByRef qj As %Binary,
	idfrom As %Integer = 1,
	idto As %Integer = 0,
	maxtxt As %Integer = 25,
	chunks As %Integer = 1) As %Status
{
  set qj={}
  set qj.id=0
  set qj.idfrom=idfrom
  set qj.idto=idto
  set qj.obj=0
  set qj.stream=0
  set qj.maxtxt=maxtxt
  set qj.chunks=chunks
  set qj.chcnt=1
  Quit $$$OK
}

/// clean environment
ClassMethod Q3Close(ByRef qj As %Binary) As %Status [ PlaceAfter = Q3Execute ]
{
  kill qj
  Quit $$$OK
}

/// that's where the music plays
/// called for evey row delivered
ClassMethod Q3Fetch(
	ByRef qj As %Binary,
	ByRef Row As %List,
	ByRef AtEnd As %Integer = 0) As %Status [ PlaceAfter = Q3Execute ]
{
  /// first access
  if qj.id<qj.idfrom set qj.id=qj.idfrom
  ///
nextrec
  if qj.idto,qj.idto<qj.id set AtEnd=1
  if qj.id>^rcc.TUD set AtEnd=1
  if AtEnd quit $$$OK
  set obj=qj.obj
  if 'obj {
    set obj=##class(rcc.TU).%OpenId(qj.id)
      ,qj.obj=obj
      ,qj.stream=0
      ,qj.chcnt=qj.chunks
  } 
  if 'obj set qj.id=qj.id+1 goto nextrec
  if 'qj.stream set qj.stream=qj.obj.Stream
  set text=qj.stream.Read(qj.maxtxt)
  if qj.chcnt=qj.chunks {
    set Row=$lb(qj.id,1,qj.obj.City,qj.obj.Name,qj.obj.Age,text)
    if qj.stream.AtEnd set qj.chcnt=0
  } else  {
    set Row=$lb("_",qj.chunks-qj.chcnt+1,"_","_","_",text)
  }
  set qj.chcnt=qj.chcnt-1
  if 'qj.stream.AtEnd,qj.chcnt>0 quit $$$OK
    
/// row completed
  set qj.id=qj.id+1
  set qj.stream=0
  set qj.obj=0

  Quit $$$OK
}

}
