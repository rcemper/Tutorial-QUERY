Class rcc.TU1
{

Query Q1(
	idfrom As %Integer = 1,
	idto As %Integer = 0,
	maxtxt As %Integer = 25) As %Query(CONTAINID = 1, ROWSPEC = "ID:%Integer,City:%String,Name:%String,Age:%Integer,Stream:%String(EXTERNALSQLTYPE = ""LONGVARCHAR"", MAXLEN = """")") [ SqlName = Q1, SqlProc ]
{
}

/// pack all params into qHandle
/// called only once at start
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

/// clean environment
ClassMethod Q1Close(ByRef qHandle As %Binary) As %Status [ PlaceAfter = Q1Execute ]
{
  kill qHandle
  Quit $$$OK
}

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
#;  just for a pretty demo
  set Row=$lb(qHandle.id,$e(qHandle.obj.City,1,7),$e(qHandle.obj.Name,1,7),qHandle.obj.Age,text)
/// row completed
  set qHandle.id=qHandle.id+1
  set qHandle.stream=0
  set qHandle.obj=0
  Quit $$$OK
}

}
