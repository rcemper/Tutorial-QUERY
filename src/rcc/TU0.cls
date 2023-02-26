Class rcc.TU0
{

Query Q0(maxrows As %Integer = 1) As %SQLQuery(CONTAINID = 1) [ SqlName = Q0, SqlProc ]
{
      SELECT top :maxrows %ID,Age,City,Name,Stream FROM TU
}

}
