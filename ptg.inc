{
TGCOLOR (C) Doug Reynolds.
Additional changes (C) 2014 Sean Dennis.
Optimized for MP (c) 2015 G.E. Ozz Nixon Jr.
}

procedure pwrite(inp:string); // PIPE COLOR WRITE and WRITELN (below)
var
  A : longint;
  b,c:byte;
  IncreaseA, blink:boolean;
  inplen:Longint;

begin
   inplen:=length(inp);
   a:=1;
   while a<=inplen do begin
      blink:=false;
      IncreaseA:=false;
      b:=0;
      if (inp[a] = '`') and (inplen-a >= 2) then
        case inp[a+1] of
          '0'..'9','A'..'F':
          case inp[a+2] of
          '0'..'9','A'..'F':begin {convert loop begin}
              case inp[a+1] of
              '0'..'7':TextColor(StrToInt(inp[a+1])); {SD}
              else begin
                  blink:=true;
                  case inp[a+1] of
                     'A'..'F': b:=ord(inp[a+1])-55;
                  end;
                  b:=b-8;
                  TextBackground(b);
              end;
              end;
              case inp[a+2] of
              '0'..'9':begin
                  b:=StrToInt(inp[a+2]);
                  if blink then b:=b+128;
                  TextColor(b);
              end
              else begin
                  b:=ord(inp[a+2])-55;
                  if blink then b:=b+128;
                  TextColor(b);
              end;
              end;
              IncreaseA:=true;
          end; {convert loop end}
        end;
      end
      else begin
         if (inp[a]='|') and (inplen-a>1) then begin
            b:=StrToInt(inp[a+1]+inp[a+2]);
            if (b>=0) and (b<=31) then begin
               if (b>=0) and (b<=15) and (textattr < 128) then TextColor(b)
               else if (b>=0) and (b<=15) and (textattr >= 128) then TextBackground(b+128)
               else if (b>=16) and (b<=23) then begin
                  if textattr>=128 then textattr:=textattr-128;
                  TextBackground(b-16);
               end
               else if (b>=24) and (b<=31) then begin
                  TextBackground(b-24);
                  c:=textattr;
                  if c<=128 then c:=c-128;
                  if c<=16 then c:=c-16;
                  TextBackground(c+128);
               end;
               IncreaseA:=true;
            end;
         end;
      end;
      if (IncreaseA==True) then A:=A+2
      else Write(inp[a]);
      inc(A);
   end;
end;

procedure pwriteln(inp:string);
begin
   pwrite(inp);
   WriteLn('');
end;

procedure pwriteXY(X,Y:Byte;inp:string);
begin
   GotoXy(X,Y);
   pwrite(inp);
end;
