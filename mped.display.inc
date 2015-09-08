procedure showMenu();
begin
    Window(1,1,80,1);
    TextBackground(Cyan);
    ClrScr;
    PWrite('|09 «MPED» |14[|15O|14]|07pen  |14[|15N|14]|07ew  |14[|15S|14]|07ave  |14[|15C|14]|07lose  |14[|15E|14]|07xit  |14[|15W|14]|07indows  |14[|15F|14]|07iles  |15F1|14=|07HELP');
    Window(1,2,80,24);
end;

procedure showStatus();
var
   OldX,OldY:Word;
   W1,W2,Ws:String;

begin
   OldX:=WhereX;
   OldY:=WhereY;
   Window(1,25,80,25);
   TextColor(White);
   TextBackground(Red);
   ClrScr;
   W1:=IntToStr(OldX);
   W2:=IntToStr(OldY+ActualTopLine);
   If InsertMode then Ws:='INS'
   else Ws:='OVR';
   PWrite(' '+PadLeft(W1,4,' ')+':'+PadLeft(W2,4,' ')+' |14'+Ws+'|07 WIN[|11'+IntToStr(CurrentFile)+'|07] |00'+
      IntToStr(ActualFile.getCount())+' TopLine:'+IntToStr(ActualTopLine));
   Window(1,2,80,24);
   GotoXy(OldX,OldY);
   TextColor(LightGreen);
   TextBackground(Black);
end;

procedure ShowWindows;
var
   OldX,OldY:Word;

begin
   OldX:=WhereX;
   OldY:=WhereY;
   Window(5,10,75,16);
   TextBackground(Magenta);
   ClrScr;
   GotoXy(1,1);
   TextBackground(LightGray);
   ClrEol;
   TextColor(LightBlue);
   Write(' List of available editor windows');
   TextBackground(Magenta);
   GotoXy(1,2);
   PWriteln(' |14Alt-1 |15'+Copy(Files[1].FileName,1,27));
   PWriteln(' |14Alt-2 |15'+Copy(Files[2].FileName,1,27));
   PWriteln(' |14Alt-3 |15'+Copy(Files[3].FileName,1,27));
   PWriteln(' |14Alt-4 |15'+Copy(Files[4].FileName,1,27));
   PWriteln(' |14Alt-5 |15'+Copy(Files[5].FileName,1,27));
   PWriteXY(37,2,' |14Alt-6 |15'+Copy(Files[6].FileName,1,27));
   PWriteXY(37,3,' |14Alt-7 |15'+Copy(Files[7].FileName,1,27));
   PWriteXY(37,4,' |14Alt-8 |15'+Copy(Files[8].FileName,1,27));
   PWriteXY(37,5,' |14Alt-9 |15'+Copy(Files[9].FileName,1,27));
   GotoXy(1,7);
   TextBackground(LightGray);
   ClrEol;
   PWrite('|12 Press any key to continue.');
   ReadKey;
   TextBackground(Black);
   Window(1,2,80,24);
   GotoXy(OldX,OldY);
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
   If HowMany=0 then begin
      For Loop:=1 to 22 do
         if Loop+ActualTopLine<=ActualFile.getCount() then
            ActiveBuffer[Loop]:=ActualFile.getStrings((Loop-1)+ActualTopLine)
         else
            ActiveBuffer[Loop]:='';
   end
   else if HowMany=1 then begin
      For Loop:=1 to 21 do
         ActiveBuffer[Loop]:=ActiveBuffer[Loop+1];
      if 22+ActualTopLine<=ActualFile.getCount() then
         ActiveBuffer[22]:=ActualFile.getStrings(22+ActualTopLine)
      else
         ActiveBuffer[22]:='';
      GotoXy(1,1); DelLine; GotoXy(1,22);
      Write(Copy(ActiveBuffer[22],1,80));
      ClrEol;
      If OldX>Length(ActiveBuffer[OldY]) then GotoXy(Length(ActiveBuffer[OldY])+1,OldY)
      else GotoXy(OldX, OldY);
      Exit;
   end
   else if HowMany=-1 then begin
      For Loop:=22 downto 2 do
         ActiveBuffer[Loop]:=ActiveBuffer[Loop-1];
      ActiveBuffer[1]:=ActualFile.getStrings(ActualTopLine);
      GotoXy(1,1); InsLine; GotoXy(1,23); ClrEol; GotoXy(1,1);
      Write(Copy(ActiveBuffer[1],1,80));
      ClrEol;
      If OldX>Length(ActiveBuffer[OldY]) then GotoXy(Length(ActiveBuffer[OldY])+1,OldY)
      else GotoXy(OldX, OldY);
      Exit;
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

function GotoLine:String;
begin
   Window(1,24,80,24);
   TextBackground(Blue);
   TextColor(White);
   ClrEol;
   Write('Go to line number: ');
   Result:=readstr(5);
   TextBackground(Black);
   GotoXy(1,24);
   ClrEol;
   Window(1,2,80,24);
   TextColor(LightGreen);
end;
