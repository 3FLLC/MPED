function readstr(maxch:longint=80;escexit:boolean=false;tabadvance:boolean=false):string;
var
   len:longint;
   ch:char;

begin
   Result:='';
   Ch:=#0;
   len:=0;
   while ch<>#13 do begin
      if keypressed then begin
         ch:=readkey;
         if ch=#0 then ch:=readkey // function key, read 2nd byte and ignore.
         else begin
            case ch of
               #8:begin
                  if len>0 then begin
                     write(#8#32#8);
                     Delete(Result,Len,1);
                     dec(len);
                  end
                  else write(#7);
               end;
               #9:if tabadvance then break
               else begin
                  if len<maxch then begin
                     inc(len);
                     write(ch);
                     Result:=Result+Ch;
                  end
                  else write(#7);
               end;
               #27:if escexit then break
               else write(#7);
               #13:begin
                  writeln();
                  break;
               end;
               #1,#2,#3,#4,#5,#6,#7,#10,#11,#12,#14,#15,#16,#17,#18,#19,#20,#21,#22,#23,#24,#25,#26,#28,#29,#30,#31:write(#7);
               else begin
                  if len<maxch then begin
                     inc(len);
                     write(ch);
                     Result:=Result+Ch;
                  end
                  else write(#7);
               end;
            end;
         end;
      end
      else yield(1);
   end;
end;
