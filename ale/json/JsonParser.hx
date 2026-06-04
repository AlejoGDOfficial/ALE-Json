package ale.json;

using StringTools;

class JsonParser
{
    final source:String;

    public function new(src:String)
        source = src;

    var index:Int = 0;
    var line:Int = 1;
    var column:Int = 1;
        
    function peek():Int
        return source.fastCodeAt(index);

    function peekString():String
        return source.charAt(index);

    function advance():Int
    {
        final char = peek();

        index++;

        if (char == '\n'.code)
        {
            line++;

            column = 1;
        } else {
            column++;
        }

        return char;
    }

    function advanceString():String
        return String.fromCharCode(advance());
    
    function isDigitStart(char:Int):Bool
        return char >= '0'.code && char <= '9'.code;

    function isDigit(char:Int):Bool
        return isDigitStart(char) || char == '.'.code;
    
    function error()
        throw 'Line: ' + line + ' - Column: ' + column;

    public function parse():Dynamic
    {
        var result = switch (peek())
        {
            default:
                if (isDigitStart(peek()))
                    Std.parseFloat(conditionalRead(isDigit))
                else
                    null;
        }

        return result;
    }

    function conditionalRead(func:Int -> Bool)
    {
        var res:String = '';

        while (func(peek()))
            res += advanceString();

        return res;
    }
}