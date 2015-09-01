type
   ActiveStruct = Record
      Active:Boolean;
      Filename:String;
      ActualFile:TStringList;
      Modified:Boolean;
      InsertMode:Boolean;
      ActualTopLine:Int64;
      AtX:Word;
      AtY:Word;
      LineDoingOffset:Int64;
      LineOffset:LongWord;
   End;

var
   Quit:Boolean=False;
   Modified:Boolean=False;
   FilesOpen:Byte=0;
   InsertMode:Boolean=True;
   ActualTopLine:Int64;
   ActualFile:TStringList;
   ActiveBuffer:Array[0..22] of String;
   CurrentFile:Byte=1;
   Files:Array[1..9] of ActiveStruct;
   LineDoingOffset:Int64;
   LineOffset:LongWord;
