{an example of pascal code}
program example ( input, output );
var value1 : integer;
    value2 : integer;
begin
   (* this is a
    * multiline comment *)
   value1:=10;
   value2:=3*value1 DIV (1+1)-4;

   write('Value1 is: ');
   writeln(value1);
   write('Value2 is: ');
   writeln(value2);

   if value1<>value2 then
   begin
      writeln('Values were not same.');
      value1:=value2;
   end;

   while value1>1 do
   begin
      value1:=value1-1;
      writeln(value1)
   end;

   repeat
      value2:=value2-1;
      writeln(value2)
   until value1=value2;

   if value1=value2 then
      writeln('Values are same.')
   else
      writeln('Values are not same.');

end.
