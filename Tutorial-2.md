My previous article introduced you to the COS based **Custom Class Query.**  
There were some features missing like more lines of the stream displayed  
and numbered.

The basic idea is the same.  
A new input parameter **chunks** is introduced that sets a limit of displayed  
pieces of our stream.

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

*   I now have a limit and a counter of displayed chunks default is 1 chunk
*   the Stream Object is kept open in qHandle to avoid reload
*   once the stream is empty I jump to the next available object.

and it looks like that:  
 

    USER>>call rcc.Q2(1,,,3)
    11.     call rcc.Q2(1,,,3)
    
    Dumping result #1
    ID      chunk   City    Name    Age     Stream
    1       1       Bensonh Kovalev 16      Building shareholder valu
    _       2       _       _       _       e by delivering secure di
    _       3       _       _       _       stributed devices and med
    2       1       Queensb Yeats   15      Spearheading the next gen
    _       2       _       _       _       eration of high-performan
    _       3       _       _       _       ce genetic virtualized in
    4       1       Newton  Evans   61
    5       1       Hialeah Zemaiti 47      Resellers of premise-base
    _       2       _       _       _       d secure XML services for
    _       3       _       _       _        social networks.||TwoToL
    6       1       Elmhurs Jenkins 29      Enabling individuals and
    _       2       _       _       _       businesses to manage ente
    _       3       _       _       _       rprise models for social
    7       1       Islip   Drabek  61      Building shareholder valu
    _       2       _       _       _       e by delivering open crow
    _       3       _       _       _       d-sourced voice-enabled c
    8       1       Islip   Kovalev 88      Experts in standards-base
    _       2       _       _       _       d distributed voice-enabl
    _       3       _       _       _       ed services for social ne
     
    19 Rows(s) Affected
    statement prepare time(s)/globals/lines/disk: 0.0002s/11/761/0ms
              execute time(s)/globals/lines/disk: 0.0024s/48/5457/0ms
                              cached query class: %sqlcq.USER.cls75
    ---------------------------------------------------------------------------

for shortee streams it terminates when stream ends

    USER>>call rcc.Q2(,4,70,20)
    22.     call rcc.Q2(,4,70,20)
     
    Dumping result #1
    ID      chunk   City    Name    Age     Stream
    1       1       Bensonh Kovalev 16      Building shareholder value by delivering secure distributed devices an
    _       2       _       _       _       d media for the Health Care community.||Scope ||An AmAn LoIcA On||Iso|
    _       3       _       _       _       |PlasmA||Atic CoLoIO||IcOpIon An Lo||Re||Ies Tw||Lo Dyna I||Atic To Ly
    _       4       _       _       _       ||Ecto O||AticL||Ism IAn Look||Plasm ||A||A Cop||Two IRe ||Two ||I||Dy
    _       5       _       _       _       na Much LoN||Ion AmQuoAn Ec||OpOc||IcTwoCycl||A ComRe||I||GeoPedeLo ||
    _       6       _       _       _       Pus EndoPyro||IesIsoIsmCom Te||A||Pyro||I On An I Tr||Syn AIcA||Gyro P
    _       7       _       _       _       ho||AmCo UniTe||AScope ComQuo IH||Two A Ect||Graph ||A ||Pyro Heli AnR
    _       8       _       _       _       eAn||Muc||Range IcTri||IonIsoIonAnC||A Wave Lo I||PusAt||To||Able ||Lo
    _       9       _       _       _       Ati||A||Quo||Ly LyIc||***Done***
    2       1       Queensb Yeats   15      Spearheading the next generation of high-performance genetic virtualiz
    _       2       _       _       _       ed instruments for the Fortune 500.||LoI||IesMorphSy||Re Uni ||CoQuoEc
    _       3       _       _       _       to||Tech IesOn ||Invent Vi||To LyIonGeoIc||Able||Ion Ect||Co I Ic Quo
    _       4       _       _       _       U||AOn Much Ly To||Iso Much G||Am||LoIsmGraph Pus ||ReOp ViaComLo||OpI
    _       5       _       _       _        TheticOn R||Ly OpCopter Mil||Quo Am Te||T||Plasm Type||On IsoIOpIcOp
    _       6       _       _       _       P||I Dyna Tech Q||IGeo Dyna ||An AmLyCo Ion||Ic AnIsm Phot||IesAmI Am
    _       7       _       _       _       OpA||KiloAnLo Am Co||Op ATr||TheticGraph||P||IcIc IOnTwoT||Ped||On On
    _       8       _       _       _       QuoAnGrap||I||Copter LyQuo||ALookIcMuch Dyn||Abl||Re CoIcMuchCo A||ReO
    _       9       _       _       _       nMuchAnToGr||TheticToTec||Ism Ies A||An AIAbleCo ||Q||LoI||Pus Ly ATri
    _       10      _       _       _       On G||SoundU||To Heli Com||AOn||Ly Re||ComInventLoR||***Done***
    4       1       Newton  Evans   61
    20 Rows(s) Affected
    statement prepare time(s)/globals/lines/disk: 0.0064s/2019/15408/0ms
              execute time(s)/globals/lines/disk: 0.0021s/33/5021/0ms
                              cached query class: %sqlcq.USER.cls84
    ---------------------------------------------------------------------------

*   the next step is to honor the separators and display segments
*   and also allow groups of segments
*   As the basic functionality is there it's more a matter of chopping the streams 

Follow me on to the [**next chapter**](https://github.com/rcemper/Tutorial-QUERY/blob/main/Tutorial-3.md) for the extension of this example      
will show and control more result lines.

