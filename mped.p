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

procedure openEditor;
var
   Ch:Char;
   AtX,AtY,OldX,OldY:Word;
   Wn,Loop:Word;
   Cmd,Ws:String;

begin
   showMenu;
   TextColor(LightGray);
   TextBackground(Black);
   ClrScr;
   ActualFile.Init();
   ActualTopLine:=0;
   loadBuffer();
   While not quit do begin
      showStatus;
      Ch:=ReadKey;
      If Ch=#0 then begin
         Ch:=ReadKey;
         If Ord(ch)=132 then Begin // Ctrl-PgUp
            ScrollBuffer(-11);
            Continue;
         End; // CASE is not trapping #132! switched to ORD
         Case Ch of
            #77:Begin // Right Arrow
               AtX:=WhereX;
               Wn:=Length(ActiveBuffer[WhereY]);
               If (AtX<=Wn) then begin
                  If AtX=80 then begin // scroll line

                  End
                  Else GotoXy(AtX+1,WhereY);
               end
               else Write(#7);
            End;
            #75:Begin // Left Arrow
               AtX:=WhereX;
               If (AtX>1) then begin
                  GotoXy(AtX-1,WhereY);
               end
               else Write(#7);
            End;
            #72:Begin // Up Arrow
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
            End;
            #116:Begin // Ctrl-Right Arrow
            End;
            #132:Begin // Ctrl-PgUp
               ScrollBuffer(-11);
            End;
            #118:Begin // Ctrl-PgDn
               ScrollBuffer(11);
            End;
////////////////////////////////////
            #70:Begin // BREAK
            End;
            #71:Begin // HOME
               GotoXy(1, WhereY);
            End;
            #79:Begin // END
               Wn:=Length(ActiveBuffer[WhereY]);
               If Wn<80 then GotoXy(Wn+1, WhereY);
            End;
            #73:Begin // PGUP
               ScrollBuffer(-22);
            End;
            #81:Begin // PGDN
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
// Alt-C
// Save
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
// Alt-Z
            #120:Begin // Alt-1
            End;
            #121:Begin // Alt-2
            End;
            #122:Begin // Alt-3
            End;
            #123:Begin // Alt-4
            End;
            #124:Begin // Alt-5
            End;
            #125:Begin // Alt-6
            End;
            #126:Begin // Alt-7
            End;
            #127:Begin // Alt-8
            End;
            #128:Begin // Alt-9
            End;
            #129:Begin // Alt-0
            End;
            #130:Begin // Alt+-
            End;
            #131:Begin // Alt+=
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
            #14:Begin // CTRL-N
// NEW
            End;
            #15:Begin // CTRL-O
// OPEN
               Cmd:=CommandLine('Filename: ',70);
               ActualTopLine:=0;
               ActualFile.LoadFromFile(Cmd);
               loadBuffer();
            End;
            #16:Begin // CTRL-P
            End;
            #18:Begin // CTRL-R
            End;
            #19:Begin // CTRL-S
            End;
            #21:Begin // CTRL-U
            End;
            #23:Begin // CTRL-X
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
