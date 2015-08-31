procedure showMenu();
begin
    Window(1,1,80,1);
    TextBackground(Cyan);
    ClrScr;
    TextColor(LightBlue);
    Write('«MPED» ');
// [O]pen
    TextColor(Yellow);
    Write('[');
    TextColor(White);
    Write('O');
    TextColor(Yellow);
    Write(']');
    TextColor(LightGray);
    Write('pen  ');
// [N]ew
    TextColor(Yellow);
    Write('[');
    TextColor(White);
    Write('N');
    TextColor(Yellow);
    Write(']');
    TextColor(LightGray);
    Write('ew  ');
// [S]ave
    TextColor(Yellow);
    Write('[');
    TextColor(White);
    Write('S');
    TextColor(Yellow);
    Write(']');
    TextColor(LightGray);
    Write('ave  ');
// [C]lose
    TextColor(Yellow);
    Write('[');
    TextColor(White);
    Write('C');
    TextColor(Yellow);
    Write(']');
    TextColor(LightGray);
    Write('lose  ');
// [E]xit
    TextColor(Yellow);
    Write('[');
    TextColor(White);
    Write('E');
    TextColor(Yellow);
    Write(']');
    TextColor(LightGray);
    Write('xit  ');
    Window(1,2,80,24);
end;

procedure showStatus();
var
   OldX,OldY:Word;
   Ws:String;

begin
   OldX:=WhereX;
   OldY:=WhereY;
   Window(1,25,80,25);
   TextColor(White);
   TextBackground(Red);
   ClrScr;
   Write(' ');
   Ws:=IntToStr(OldX);
   Write(PadLeft(Ws,4,' '),'|');
   Ws:=IntToStr(OldY+ActualTopLine);
   Write(PadLeft(Ws,4,' '),' ');
   TextColor(Yellow);
   If InsertMode then Write('INS')
   else Write('OVR');
   TextColor(LightGray);
   write(' ',ActualFile.getCount(),' TopLine:',ActualTopLine);
   Window(1,2,80,24);
   GotoXy(OldX,OldY);
//   TextColor(LightGray);
   TextColor(LightGreen);
   TextBackground(Black);
end;

procedure LoadBuffer;
Begin
   TextColor(LightGreen);
   TextBackground(Black);
   For var Loop:=1 to 22 do begin
      if Loop<=ActualFile.getCount() then
         ActiveBuffer[loop]:=ActualFile.getStrings(Loop-1)
      else
         ActiveBuffer[loop]:='';
      GotoXy(1,Loop);
      Write(Copy(ActiveBuffer[Loop],1,80));
      ClrEol;
   End;
   GotoXy(1,1);
End;

procedure ScrollBuffer(HowMany:ShortInt);
var
   Loop:Byte;
   OldX,OldY:Word;

begin
   If (ActualTopLine=0) and (HowMany<0) then Exit;
   OldX:=WhereX;
   OldY:=WhereY;
   Inc(ActualTopLine, HowMany);
   If ActualTopLine>ActualFile.getCount() then ActualTopLine:=ActualFile.getCount()-1
   else if ActualTopLine<0 then begin
      ActualTopLine:=0;
      If HowMany<-1 then loadBuffer;
      exit;
   end;
   If HowMany=1 then begin
      For Loop:=1 to 21 do
         ActiveBuffer[Loop]:=ActiveBuffer[Loop+1];
      if 22+ActualTopLine<=ActualFile.getCount() then
         ActiveBuffer[22]:=ActualFile.getStrings(22+ActualTopLine)
      else
         ActiveBuffer[22]:='';
   end
   else if HowMany=-1 then begin
      For Loop:=22 downto 2 do
         ActiveBuffer[Loop]:=ActiveBuffer[Loop-1];
      ActiveBuffer[1]:=ActualFile.getStrings(ActualTopLine);
   end
   else if HowMany=11 then begin // Ctrl-PgDn
      For Loop:=1 to 11 do begin
         ActiveBuffer[loop]:=ActiveBuffer[loop+11];
         if 11+ActualTopLine<=ActualFile.getCount() then
            ActiveBuffer[Loop+11]:=ActualFile.getStrings(10+ActualTopLine+Loop)
         else
            ActiveBuffer[Loop+11]:='';
      end;
   end
   else if HowMany=-11 then begin // Ctrl-PgUp
      For Loop:=11 downto 1 do begin
         ActiveBuffer[loop+11]:=ActiveBuffer[loop];
         ActiveBuffer[Loop]:=ActualFile.getStrings(ActualTopLine+(Loop-1));
      end;
   end
   else if (HowMany=22) or (HowMany=-22) then begin // PgDn & PgDn
      For Loop:=1 to 22 do
      if Loop+ActualTopLine<=ActualFile.getCount() then
         ActiveBuffer[Loop]:=ActualFile.getStrings((Loop-1)+ActualTopLine)
      else
         ActiveBuffer[Loop]:='';
   end;
// re-write screen:
   For Loop:=1 to 22 do begin
      GotoXy(1,Loop);
      Write(Copy(ActiveBuffer[Loop],1,80));
      ClrEol;
   End;
   If OldX>Length(ActiveBuffer[OldY]) then GotoXy(Length(ActiveBuffer[OldY])+1,OldY)
   else GotoXy(OldX, OldY);
end;

function CommandLine(Prompt:String;MaxLen:Word):String;
var
   OldX,OldY:Word;

begin
   OldX:=WhereX;
   OldY:=WhereY;
   Window(1,24,80,24);
   TextBackground(Green);
   TextColor(LightGray);
   ClrEol;
   Write(Prompt);
   Result:=readstr(MaxLen);
   TextBackground(Black);
   GotoXy(1,24);
   ClrEol;
   Window(1,2,80,24);
   GotoXy(OldX,OldY);
end;
