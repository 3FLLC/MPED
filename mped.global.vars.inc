var
   Quit:Boolean=False;
   Modified:Boolean=False;
   FilesOpen:Byte=0;
   InsertMode:Boolean=True;

var
   ActualTopLine:Int64;
   ActualFile:TStringList;
   ActiveBuffer:Array[0..22] of String;
