Class rcc.TU Extends (%Persistent, %Populate) [ Final ]
{

Property City As %String;

Property Name As %String(POPSPEC = "LastName()");

Property Age As %Integer(MAXVAL = 110, MINVAL = 10);

Property Stream As %Stream.GlobalCharacter;

/// do what %Populate is unable to do
Method OnPopulate() As %Status [ ServerOnly = 1 ]
{
  #Dim st as %Stream.GlobalCharacter
  set st=..Stream
  set st.LineTerminator="||"
  do st.WriteLine(##class(%PopulateUtils).Mission())
  for i=1:1:$R(50)+3 {
      do st.WriteLine(##class(%PopulateUtils).Syllable(..Age))
  }
  do st.Write("***Done***")
  do st.%Save()
  quit $$$OK
}

Storage Default
{
<Data name="TUDefaultData">
<Value name="1">
<Value>City</Value>
</Value>
<Value name="2">
<Value>Name</Value>
</Value>
<Value name="3">
<Value>Age</Value>
</Value>
<Value name="4">
<Value>Stream</Value>
</Value>
</Data>
<DataLocation>^rcc.TUD</DataLocation>
<DefaultData>TUDefaultData</DefaultData>
<IdLocation>^rcc.TUD</IdLocation>
<IndexLocation>^rcc.TUI</IndexLocation>
<StreamLocation>^rcc.TUS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}
