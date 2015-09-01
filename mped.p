program mped.v1.0;

/////////////////////////////////////////////////////////////////////////////
// Modern Pascal Editor
// ==========================================================================
//      Author: G.E. Ozz Nixon Jr.
//   Copyright: (c) 2015 by Brain Patchwork DX, LLC.
// Description: An example of developing a full-blown text file editor built
// entirely using Modern Pascal in text mode.
/////////////////////////////////////////////////////////////////////////////

uses
   Display,
   Environment,
   Strings;

{$i readstr.inc}
{$i mped.global.vars.inc}
{$i mped.display.inc}

procedure showHelp;
begin
   Window(1,1,80,25);
   TextColor(White);
   TextBackground(Blue);
   ClrScr;
   Writeln('Modern Pascal Editor v1.0');
   Writeln('');
   Writeln('usage: mped [options] filename');
   Halt(0);
end;

procedure LoadScreen(Which:Byte);
begin
   CurrentFile:=Which;
   Files[Which].Active:=True;
   ActualFile.setText(Files[Which].ActualFile.getText());
   Modified:=Files[Which].Modified;
   InsertMode:=Files[Which].InsertMode;
   ActualTopLine:=Files[Which].ActualTopLine;
   LineDoingOffset:=Files[Which].LineDoingOffset;
   LineOffset:=Files[Which].LineOffset;
   ScrollBuffer(0); // Draw new screen
   If (Files[Which].Filename<>'') then begin
      TextColor(DarkGray);
      GotoXy(1,23);
      ClrEol;
      Write('FILE: ',Files[Which].Filename);
      TextColor(LightGreen);
   End
   else begin
      GotoXy(1,23);
      ClrEol;
   end;
   GotoXy(Files[Which].AtX,Files[Which].AtY);
end;

procedure SaveScreen(Which:Byte);
begin
   Files[Which].Active:=False;
   Files[Which].ActualFile.setText(ActualFile.getText());
   Files[Which].Modified:=Modified;
   Files[Which].InsertMode:=InsertMode;
   Files[Which].ActualTopLine:=ActualTopLine;
   Files[Which].AtX:=WhereX;
   Files[Which].AtY:=WhereY;
   Files[Which].LineDoingOffset:=LineDoingOffset;
   Files[Which].LineOffset:=LineOffset;
end;

procedure openEditor;
var
   Ch:Char;
   AtX,AtY,OldX,OldY:Word;
   Wn,Loop:Word;
   Cmd,Ws:String;

begin
   For Loop:=1 to 9 do begin
      With Files[Loop] do begin
         Active:=False;
         Filename:='';
         ActualFile.Init();
         Modified:=False;
         InsertMode:=False;
         ActualTopLine:=0;
         AtX:=1;
         AtY:=1;
         LineDoingOffset:=0;
         LineOffset:=1;
      End;
   End;
   showMenu;
   TextColor(LightGray);
   TextBackground(Black);
   ClrScr;
   ActualFile.Init();
//   loadBuffer();
   LoadScreen(1);
   While not quit do begin
      showStatus;
      Ch:=ReadKey;
      If Ch=#0 then begin
         Ch:=ReadKey;
         If Ord(ch)=132 then Begin // Ctrl-PgUp
            ScrollBuffer(-11);
            Continue;
         End // CASE is not trapping #132! switched to ORD
         else if Ord(Ch)=130 then Begin // Alt+-
            SaveScreen(CurrentFile);
            Dec(CurrentFile);
            If CurrentFile<1 then CurrentFile:=9;
            LoadScreen(CurrentFile);
            Continue;
         End
         else If Ord(Ch)=131 then Begin // Alt+=
            SaveScreen(CurrentFile);
            Inc(CurrentFile);
            If CurrentFile>9 then CurrentFile:=1;
            LoadScreen(CurrentFile);
            Continue;
         End;
         Case Ch of
            #77:Begin // Right Arrow
               AtX:=WhereX;
               AtY:=WhereY;
               Wn:=Length(ActiveBuffer[AtY]);
               If (AtX<=Wn) then begin
                  If AtX=80 then begin // scroll line
                     LineDoingOffset:=ActualTopLine+AtY;
                     If (LineOffset+79<Length(ActiveBuffer[AtY])+1) then begin
                        Inc(LineOffset);
                        GotoXy(1,AtY);
                        Write(Copy(ActiveBuffer[AtY],LineOffset,80));
                        GotoXy(80,AtY);
                        If (LineOffset+79>Length(ActiveBuffer[AtY])) then ClrEol;
                     End;
                  End
                  Else GotoXy(AtX+1,AtY);
               end
               else Write(#7);
            End;
            #75:Begin // Left Arrow
               AtX:=WhereX;
               AtY:=WhereY;
               If (AtX>1) then begin
                  GotoXy(AtX-1,AtY);
               end
               else begin
                  if (LineDoingOffset<>0) then begin
                     If LineOffset>1 then begin
                        Dec(Lineoffset);
                        GotoXy(1,AtY);
                        Write(Copy(ActiveBuffer[WhereY],LineOffset,80));
                        GotoXy(1,AtY);
                     End
                     Else LineDoingOffset:=0;
                  end
                  else Write(#7);
               end;
            End;
            #72:Begin // Up Arrow
               If (LineDoingOffset<>0) then ScrollBuffer(0); // optimize later!
               LineDoingOffset:=0;
               LineOffset:=1;
               AtY:=WhereY;
               If AtY+ActualTopLine<=ActualFile.getCount() then begin
                  If AtY=1 then ScrollBuffer(-1)
                  else begin
                     If WhereX>Length(ActiveBuffer[WhereY-1]) then GotoXy(Length(ActiveBuffer[WhereY-1])+1,WhereY-1)
                     else GotoXy(WhereX,WhereY-1);
                  end;
               End;
            End;
            #80:Begin // Down Arrow
               If (LineDoingOffset<>0) then ScrollBuffer(0); // optimize later!
               LineDoingOffset:=0;
               LineOffset:=1;
               AtY:=WhereY;
               If AtY+ActualTopLine+1<=ActualFile.getCount() then begin
                  If AtY=22 then ScrollBuffer(1)
                  else begin
                     If WhereX>Length(ActiveBuffer[WhereY+1]) then GotoXy(Length(ActiveBuffer[WhereY+1])+1,WhereY+1)
                     else GotoXy(WhereX,WhereY+1);
                  end;
               End;
            End;
////////////////////////////////////
            #115:Begin // Ctrl-Left Arrow
               AtX:=WhereX;
               If AtX>1 then begin
                  Loop:=AtX;
                  While Loop>1 do begin
                     Dec(Loop);
                     Ws:=Copy(ActiveBuffer[WhereY],Loop,1);
                     If (Ws=#32) or
                        Pos(Ws,'!@#$%^&*:=-+<>/?.')>0 then break;
                  End;
                  If Loop<2 then Loop:=2;
                  GotoXy(Loop-1,WhereY);
               End;
            End;
            #116:Begin // Ctrl-Right Arrow
               AtX:=WhereX;
               If AtX<Length(ActiveBuffer[WhereY]) then begin
                  Loop:=AtX;
                  if copy(ActiveBuffer[WhereY],Loop,1)=#32 then begin
                     while (Loop<=Length(ActiveBuffer[WhereY])) and
                        (copy(ActiveBuffer[WhereY],Loop,1)=#32) do Inc(Loop);
                     Dec(Loop);
                  end
                  else begin
                     While Loop<=Length(ActiveBuffer[WhereY]) do begin
                        Inc(Loop);
                        Ws:=Copy(ActiveBuffer[WhereY],Loop,1);
                        If (Ws=#32) or
                           Pos(Ws,'!@#$%^&*,:=-+<>/?.()[]{}')>0 then break;
                     End;
                  end;
                  If Loop>Length(ActiveBuffer[WhereY]) then Loop:=Length(ActiveBuffer[WhereY]);
                  GotoXy(Loop+1,WhereY);
               End;
            End;
            #132:Begin // Ctrl-PgUp
               LineDoingOffset:=0;
               LineOffset:=1;
               ScrollBuffer(-11);
            End;
            #118:Begin // Ctrl-PgDn
               LineDoingOffset:=0;
               LineOffset:=1;
               ScrollBuffer(11);
            End;
            #117:Begin // Ctrl-End
               If ActualFile.getCount()>22 then begin
                  ActualTopLine:=ActualFile.getCount()-22;
                  GotoXy(Length(ActiveBuffer[22])+1,22);
               end
               Else begin
                  ActualTopLine:=0;
                  GotoXy(Length(ActiveBuffer[ActualFile.getCount()])+1,ActualFile.getCount());
               End;
               ScrollBuffer(0);
            End;
            #119:Begin // Ctrl-Home
               ActualTopLine:=0;
               ScrollBuffer(0);
               GotoXy(1,1);
            End;
////////////////////////////////////
            #70:Begin // BREAK
            End;
            #71:Begin // HOME
               AtY:=WhereY;
               GotoXy(1, AtY);
               Write(Copy(ActiveBuffer[AtY],1,80));
               If AtY=WhereY then ClrEol;
               GotoXy(1, AtY);
            End;
            #79:Begin // END
               AtY:=WhereY;
               Wn:=Length(ActiveBuffer[AtY]);
               If Wn<80 then GotoXy(Wn+1, AtY)
               else begin
                  LineDoingOffset:=ActualTopLine+AtY;
                  If (LineOffset+79<Length(ActiveBuffer[AtY])+1) then begin
                     LineOffset:=Length(ActiveBuffer[AtY])-78;
                     GotoXy(1,AtY);
                     Write(Copy(ActiveBuffer[AtY],LineOffset,80));
                     GotoXy(80,AtY);
                     If (LineOffset+79>Length(ActiveBuffer[AtY])) then ClrEol;
                  End;
               End;
            End;
            #73:Begin // PGUP
               LineDoingOffset:=0;
               LineOffset:=1;
               ScrollBuffer(-22);
            End;
            #81:Begin // PGDN
               LineDoingOffset:=0;
               LineOffset:=1;
               ScrollBuffer(22);
            End;
////////////////////////////////////
            #82:Begin // INS
               InsertMode:=Not InsertMode;
            End;
            #83:Begin // DEL
               AtX:=WhereX;
               If Copy(ActiveBuffer[WhereY],AtX,1)<>'' then begin
                  Delete(ActiveBuffer[WhereY],AtX,1);
                  GotoXy(1,WhereY);
                  Write(Copy(ActiveBuffer[WhereY],1,80));
                  ClrEol;
                  GotoXy(Atx,WhereY);
                  ActualFile.setStrings((ActualTopLine+WhereY)-1, ActiveBuffer[WhereY]);
               End;
            End;
            #15:Begin // Shift Tab
               AtX:=WhereX;
               If InsertMode then begin
                  If Atx>3 then begin
                     If Copy(ActiveBuffer[WhereY],AtX-2,3)='   ' then begin
                        Delete(ActiveBuffer[WhereY],AtX-2,3);
                        GotoXy(1,WhereY);
                        Write(Copy(ActiveBuffer[WhereY],1,80));
                        ClrEol;
                        GotoXy(Atx-3,WhereY);
                     End
                     Else GotoXy(AtX-3,WhereY);
                  End
                  else GotoXy(1,WhereY);
               end
               else begin
                  If Atx>3 then GotoXy(AtX-3,WhereY)
                  else GotoXy(1,WhereY);
               end;
               ActualFile.setStrings((ActualTopLine+WhereY)-1, ActiveBuffer[WhereY]);
            End;
////////////////////////////////////
            #59:Begin // F1

            End;
            #68:Begin // F10

            End;
            #134:Begin // F12

            End;
////////////////////////////////////
            #30:Begin // Alt-A
            End;
            #48:Begin // Alt-B
            End;
            #46:Begin // Alt-C
            End;
            #32:Begin // Alt-D
            End;
            #18:Begin // Alt-E
// Exit
               Quit:=True;
            End;
            #33:Begin // Alt-F
            End;
            #34:Begin // Alt-G
            End;
            #35:Begin // Alt-H
            End;
            #23:Begin // Alt-I
            End;
            #36:Begin // Alt-J
            End;
            #37:Begin // Alt-K
            End;
            #38:Begin // Alt-L
            End;
            #50:Begin // Alt-M
            End;
            #49:Begin // Alt-N
// New File
            End;
            #24:Begin // Alt-O
// Open File
               Cmd:=CommandLine('Filename: ',70);
               if (cmd<>'') then begin
                  If not FileExists(Cmd) then begin
                     GotoXy(1,23);
                     TextBackground(Red);
                     ClrEol;
                     TextColor(Yellow);
                     Write('File not found: '+Cmd);
                  End
                  Else Begin
                     Files[CurrentFile].Filename:=Cmd;
                     ActualTopLine:=0;
                     ActualFile.LoadFromFile(Cmd);
                     loadBuffer();
                     SaveScreen(CurrentFile);
                  End;
               end;
            End;
            #25:Begin // Alt-P
            End;
            #16:Begin // Alt-Q
            End;
            #19:Begin // Alt-R
            End;
            #31:Begin // Alt-S
// Save File
            End;
            #20:Begin // Alt-T
            End;
            #22:Begin // Alt-U
            End;
            #47:Begin // Alt-V
            End;
            #17:Begin // Alt-W
            End;
            #45:Begin // Alt-X
// Exit
               Quit:=True;
            End;
            #21:Begin // Alt-Y
            End;
            #44:Begin // Alt-Z
            End;
            #120:Begin // Alt-1
               If CurrentFile<>1 then begin
                  SaveScreen(CurrentFile);
                  LoadScreen(1);
               End;
            End;
            #121:Begin // Alt-2
               If CurrentFile<>2 then begin
                  SaveScreen(CurrentFile);
                  LoadScreen(2);
               End;
            End;
            #122:Begin // Alt-3
               If CurrentFile<>3 then begin
                  SaveScreen(CurrentFile);
                  LoadScreen(3);
               End;
            End;
            #123:Begin // Alt-4
               If CurrentFile<>4 then begin
                  SaveScreen(CurrentFile);
                  LoadScreen(4);
               End;
            End;
            #124:Begin // Alt-5
               If CurrentFile<>5 then begin
                  SaveScreen(CurrentFile);
                  LoadScreen(5);
               End;
            End;
            #125:Begin // Alt-6
               If CurrentFile<>6 then begin
                  SaveScreen(CurrentFile);
                  LoadScreen(6);
               End;
            End;
            #126:Begin // Alt-7
               If CurrentFile<>7 then begin
                  SaveScreen(CurrentFile);
                  LoadScreen(7);
               End;
            End;
            #127:Begin // Alt-8
               If CurrentFile<>8 then begin
                  SaveScreen(CurrentFile);
                  LoadScreen(8);
               End;
            End;
            #128:Begin // Alt-9
               If CurrentFile<>9 then begin
                  SaveScreen(CurrentFile);
                  LoadScreen(9);
               End;
            End;
            #129:Begin // Alt-0
            End;
////////////////////////////////////
            #2:Begin // Ctrl-1
            End;
            Else Writeln('#0 + #',Ord(Ch));
         End;
         Continue;
      End
      Else Begin
         Case Ch of
            #8:Begin // Backspace
               AtX:=WhereX;
               If (AtX>1) then begin
                  Delete(ActiveBuffer[WhereY],AtX-1,1);
                  GotoXy(1,WhereY);
                  Write(Copy(ActiveBuffer[WhereY],1,80));
                  ClrEol;
                  GotoXy(AtX-1,WhereY);
                  ActualFile.setStrings((ActualTopLine+WhereY)-1, ActiveBuffer[WhereY]);
               End;
            End;
            #9:Begin // Tab
               AtX:=WhereX;
               If InsertMode then begin
                  If (AtX<Length(ActiveBuffer[WhereY])) then begin
                     Insert(#32, ActiveBuffer[WhereY], AtX);
                     Insert(#32, ActiveBuffer[WhereY], AtX);
                     Insert(#32, ActiveBuffer[WhereY], AtX);
                  end
                  else begin
                     ActiveBuffer[WhereY]:=ActiveBuffer[WhereY]+#32;
                     ActiveBuffer[WhereY]:=ActiveBuffer[WhereY]+#32;
                     ActiveBuffer[WhereY]:=ActiveBuffer[WhereY]+#32;
                  end;
                  GotoXy(AtX+3,WhereY);
               end
               else
                  If (AtX+3<Length(ActiveBuffer[WhereY])) then GotoXy(AtX+3,WhereY)
                  else GotoXy(Length(ActiveBuffer[WhereY])+1,WhereY);
               ActualFile.setStrings((ActualTopLine+WhereY)-1, ActiveBuffer[WhereY]);
            End;
            #13:Begin // ENTER
               If InsertMode then begin
                  if WhereY<22 then begin
                     AtY:=WhereY;
                     If AtY+ActualTopLine+1<=ActualFile.getCount() then begin
                        ActualFile.Insert((AtY+ActualTopLine),'');
                        For Loop:=22 downto AtY+2 do begin
                           GotoXy(1,Loop);
                           ActiveBuffer[Loop]:=ActiveBuffer[Loop-1];
                           Write(Copy(ActiveBuffer[Loop],1,80));
                           ClrEol;
                        End;
                        ActiveBuffer[AtY+1]:='';
                        GotoXy(1,AtY+1);
                        ClrEol;
                     end
                     else ActualFile.Add('');
                     GotoXy(1,AtY+1);
                  end;
               end
               else begin
                  If WhereY<22 then begin
                     If WhereY<ActualFile.getCount() then GotoXy(1,WhereY+1);
                  end
                  else begin
                     ScrollBuffer(1);
                     GotoXy(1,22);
                  end;
                  continue;
               end;
// PASCAL AUTO-INDENT
               if (copy(trimright(ActiveBuffer[WhereY-1]), length(trimright(ActiveBuffer[WhereY-1])),1)<>';') and
                  (length(trimright(ActiveBuffer[WhereY-1]))>0) then begin
                  Wn:=Length(TrimRight(ActiveBuffer[WhereY-1]))-Length(Trim(ActiveBuffer[WhereY-1]));
                  For Loop:=1 to Wn+3 do
                      ActiveBuffer[WhereY]:=ActiveBuffer[WhereY]+#32;
                  GotoXy(Wn+4,WhereY);
                  ActualFile.setStrings((ActualTopLine+WhereY)-1, ActiveBuffer[WhereY]);
               End;
            End;
            #27:Begin // ESC
            End;
            #1:Begin // CTRL-A
            End;
            #5:Begin // CTRL-E
// EXIT
               Quit:=True;
            End;
            #6:Begin // CTRL-F
            End;
            #7:Begin // CTRL-G
               Cmd:=GotoLine;
               If (Cmd<>'') then begin
                  Wn:=StrToIntDef(Cmd,ActualTopLine);
                  If (Wn<>ActualTopLine) then begin
                     If Wn>ActualTopLine+11 then begin
                        If (Wn>ActualFile.getCount()) then Wn:=ActualFile.getCount();
                        ActualTopLine:=Wn-11;
                        If ActualTopLine<0 then ActualTopLine:=0;
                        ScrollBuffer(0);
                        GotoXy(1,11);
                     End
                     Else Begin
                        If (Wn>ActualFile.getCount()) then Wn:=ActualFile.getCount();
                        GotoXy(1,Wn);
                     End;
                  End;
               End;
            End;
            #14:Begin // CTRL-N
// NEW
            End;
            #15:Begin // CTRL-O
// OPEN
               Cmd:=CommandLine('Filename: ',70);
               if (cmd<>'') then begin
                  If not FileExists(Cmd) then begin
                     GotoXy(1,23);
                     TextBackground(Red);
                     ClrEol;
                     TextColor(Yellow);
                     Write('File not found: '+Cmd);
                  End
                  Else Begin
                     Files[CurrentFile].Filename:=Cmd;
                     ActualTopLine:=0;
                     ActualFile.LoadFromFile(Cmd);
                     loadBuffer();
                     SaveScreen(CurrentFile);
                  End;
               end;
            End;
            #16:Begin // CTRL-P
            End;
            #18:Begin // CTRL-R
            End;
            #19:Begin // CTRL-S
            End;
            #21:Begin // CTRL-U
            End;
            #22:Begin // CTRL-V
            End;
            #23:Begin // CTRL-W
               TextColor(Green);
               ScrollBuffer(0);
               ShowWindows;
               TextColor(LightGreen);
               ScrollBuffer(0);
            End;
            #24:Begin // CTRL-X
// EXIT
               Quit:=True;
            End;
            #26:Begin // CTRL-Z
            End;
            #32..#255:Begin
               AtX:=WhereX;
               If InsertMode then begin
                  If (AtX<=Length(ActiveBuffer[WhereY])) then
                     Insert(Ch, ActiveBuffer[WhereY], AtX)
                  else
                     ActiveBuffer[WhereY]:=ActiveBuffer[WhereY]+Ch;
               End
               else Begin
                  If (AtX<=Length(ActiveBuffer[WhereY])) then
                     ActiveBuffer[WhereY][AtX]:=Ch
                  else
                     ActiveBuffer[WhereY]:=ActiveBuffer[WhereY]+Ch;
               end;
               Write(Copy(ActiveBuffer[WhereY], AtX, (80-AtX)-1));
               Inc(AtX);
               GotoXy(AtX,WhereY);
               If ActualFile.getCount()<ActualTopLine+WhereY then ActualFile.Add('');
               ActualFile.setStrings((ActualTopLine+WhereY)-1, ActiveBuffer[WhereY]);
ActualFile.SaveToFile('tmp.$$');
            End;
            Else Write('#',Ord(Ch));
         End;
      End;
   End;
end;

begin
   If paramcount<1 then showHelp
   else openEditor;
end.
