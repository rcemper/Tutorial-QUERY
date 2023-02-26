Class rcc.TU2
{

Query Q2(
	idfrom As %Integer = 1,
	idto As %Integer = 0,
	maxtxt As %Integer = 25,
	chunks As %Integer = 1) As %Query(CONTAINID = 1, ROWSPEC = "ID:%Integer,chunk:%Integer,City:%String,Name:%String,Age:%Integer,Stream:%String(EXTERNALSQLTYPE = ""LONGVARCHAR"", MAXLEN = """")") [ SqlName = Q2, SqlProc ]
{
}

/// pack all params into qHandle
/// called only once at start
ClassMethod Q2Execute(
	ByRef qHandle As %Binary,
	idfrom As %Integer = 1,
	idto As %Integer = 0,
	maxtxt As %Integer = 25,
	chunks As %Integer = 1) As %Status
{
  set qHandle={}
  set qHandle.id=0
  set qHandle.idfrom=idfrom
  set qHandle.idto=idto
  set qHandle.obj=0
  set qHandle.stream=0
  set qHandle.maxtxt=maxtxt
  set qHandle.chunks=chunks
  set qHandle.chcnt=1
  Quit $$$OK
}

/// clean environment
ClassMethod Q2Close(ByRef qHandle As %Binary) As %Status [ PlaceAfter = Q1Execute ]
{
  kill qHandle
  Quit $$$OK
}

/// that's where the music plays
/// called for evey row delivered
ClassMethod Q2Fetch(
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
  set obj=qHandle.obj
  if 'obj {
    set obj=##class(rcc.TU).%OpenId(qHandle.id)
      ,qHandle.obj=obj
      ,qHandle.stream=0
      ,qHandle.chcnt=qHandle.chunks
  } 
  if 'obj set qHandle.id=qHandle.id+1 goto nextrec
  if 'qHandle.stream set qHandle.stream=qHandle.obj.Stream
  set text=qHandle.stream.Read(qHandle.maxtxt)
  if qHandle.chcnt=qHandle.chunks {
    set Row=$lb(qHandle.id,1,qHandle.obj.City,qHandle.obj.Name,qHandle.obj.Age,text)
    if qHandle.stream.AtEnd set qHandle.chcnt=0
  } else  {
    set Row=$lb("_",qHandle.chunks-qHandle.chcnt+1,"_","_","_",text)
  }
  set qHandle.chcnt=qHandle.chcnt-1
  if 'qHandle.stream.AtEnd,qHandle.chcnt>0 quit $$$OK
    
/// row completed
  set qHandle.id=qHandle.id+1
  set qHandle.stream=0
  set qHandle.obj=0

  Quit $$$OK
}

}
