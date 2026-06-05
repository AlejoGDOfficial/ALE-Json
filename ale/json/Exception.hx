package ale.json;

import haxe.Exception as HaxeException;

class Exception extends HaxeException
{
    public final line:Int;
    
    public final column:Int;

    public function new(message:String, line:Int, column:Int)
    {
        super(message);

        this.line = line;
        this.column = column;
    }
}