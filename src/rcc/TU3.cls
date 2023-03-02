Class rcc.TU3
{

Query Q3(
	idfrom As %Integer = 1,
	idto As %Integer = 0,
	maxtxt As %Integer = 25,
	separator As %String = ",",
	startpiece As %Integer = 1,
	endpiece As %Integer = "",
	grouped As %Integer = 0,
	before As %Integer = 0) As %Query(CONTAINID = 1, ROWSPEC = "ID:%Integer,City:%String,Name:%String,Age:%Integer,pcCnt:%Integer,PieceId:%Integer,PieceTxt:%String(EXTERNALSQLTYPE = ""LONGVARCHAR"", MAXLEN = """")") [ SqlName = Q3, SqlProc ]
{
}

/// pack all params into qj
/// called only once at start
ClassMethod Q3Execute(
	ByRef qj As %Binary,
	idfrom As %Integer = 1,
	idto As %Integer = 0,
	maxtxt As %Integer = 25,
	separator As %String = ",",
	startpiece As %Integer = 1,
	endpiece As %Integer = "",
	grouped As %Integer = 0,
	before As %Integer = 0) As %Status
{
  set qj={}
  set qj.id=0
  set qj.idfrom=idfrom
  set qj.idto=idto
  set qj.obj=0
  set qj.stream=0
  set qj.maxtxt=maxtxt
  set qj.pcsep=separator
  set qj.pcnt=0
  set qj.pcpos=$lb(1)
  set qj.startpc=startpiece
  set qj.endpc=endpiece
  set qj.before=before
  set qj.grp=grouped
  set qj.grpstart=startpiece
  set qj.grpend=endpiece
  set qj.text=""
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
  } 
  if 'obj set qj.id=qj.id+1 goto nextrec
  if 'qj.stream set qj.stream=qj.obj.Stream
  if qj.grp {
    set qj.endpc=qj.startpc+qj.grp-1
   if qj.endpc>qj.grpend set qj.endpc=qj.grpend 
  }
  if qj.stream,'qj.stream.AtEnd do ..Piece(.qj)
  if qj.grpstart=qj.startpc {
    set Row=$lb(qj.id,qj.obj.City,qj.obj.Name,qj.obj.Age,qj.pcnt,qj.startpc,qj.text)
#; just for pretty demo
    set Row=$lb(qj.id,$e(qj.obj.City,1,7),$e(qj.obj.Name,1,7),qj.obj.Age,qj.pcnt,qj.startpc,qj.text)
  } else  {
      set Row=$lb("_","_","_","_",qj.grp,qj.startpc,qj.text)
  }
  set qj.startpc=qj.endpc+1  
  if qj.grp,'qj.stream.AtEnd,qj.endpc<qj.grpend,qj.startpc<qj.pcnt quit $$$OK
/// row completed
  set qj.id=qj.id+1
  set qj.stream=0
/// clear pieces
  set qj.startpc=qj.grpstart
  set qj.endps=qj.grpend
  set qj.pcnt=0
  set qj.text=""  
  set qj.obj=0

  Quit $$$OK
}

ClassMethod Piece(ByRef qj) As %Status
{
  if 'qj.pcnt {
#; find piece count and piece start first
    set last=0
    set pcpos=$lb(1)
    for pcnt=1:1 
      { set last=qj.stream.FindAt(last+1,qj.pcsep) quit:last<0
        set pcpos=pcpos_$lb(last)
      }
    set qj.pcnt=pcnt
    set qj.pcpos=pcpos_$lb(qj.stream.Size+1)  ; after last char
    do qj.stream.Rewind()
  }
  set start=$lg(qj.pcpos,qj.startpc)-qj.before
  if start <1 set start=1
  if qj.endpc>$ll(qj.pcpos) set qj.endpc=qj.pcnt
  if qj.endpc="" set qj.endpc=qj.startpc 
  set stop=$lg(qj.pcpos,qj.endpc+1)-1
  if qj.endpc<qj.startpc set stop=0
  if (stop-start)>qj.maxtxt set stop=start+qj.maxtxt 
  set qj.text=qj.stream.ReadSQL(start,stop)
  quit $$$OK
}

}
