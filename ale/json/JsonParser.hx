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

    function isDigitStart(char:Int):Bool
        return char >= '0'.code && char <= '9'.code;

    function isDigit(char:Int):Bool
        return isDigitStart(char) || char == '.'.code;
    
    function expect(char:Int)
        if (peek() != char)
            unexpected(char);
        else
            advance();

    function unexpected(?expected:Int)
        error('Unexpected Token: ' + peekString() + (expect == null ? '' : ' - Expected: ' + String.fromCharCode(expected)));

    function error(msg:String)
        throw 'Line: ' + line + ' - Column: ' + column + ': ' + msg;

    function conditionalRead(func:Int -> Bool):String
    {
        var res:StringBuf = new StringBuf();

        while (true)
        {
            final cur:Int = peek();

            if (func(cur))
                res.addChar(advance());
            else
                break;
        }

        return res.toString();
    }

    function clearSpaces()
    {
        while (true)
        {
            final cur = peek();

            if (' '.code == cur || '\t'.code == cur || '\n'.code == cur || '\r'.code == cur)
                advance()
            else
                break;
        }
    }

    public function parse():Dynamic
    {
        clearSpaces();

        final result:Dynamic = switch (peek())
        {
            case '"'.code:
                advance();

                final res:String = conditionalRead(val -> val != '"'.code);

                advance();

                res;

            case '['.code:
                final res:Array<Dynamic> = [];

                advance();

                var shouldContinue:Bool = peek() != ']'.code;

                while (shouldContinue)
                {
                    res.push(parse());

                    shouldContinue = switch (peek())
                    {
                        case ','.code:
                            advance();

                            true;
                            
                        case ']'.code:
                            false;

                        default:
                            unexpected(']'.code);

                            false;
                    }
                }

                advance();

                res;

            case '{'.code:
                final res:Dynamic = {};

                advance();

                var shouldContinue:Bool = peek() != '}'.code;

                clearSpaces();

                while (shouldContinue)
                {
                    expect('"'.code);

                    final fieldName:String = conditionalRead(val -> val != '"'.code);

                    advance();

                    expect(':'.code);

                    Reflect.setField(res, fieldName, parse());

                    shouldContinue = switch (peek())
                    {
                        case ','.code:
                            advance();

                            true;

                        case '}'.code:
                            false;

                        default:
                            unexpected('}'.code);

                            false;
                    }
                }

                advance();

                res;

            default:
                if (isDigitStart(peek()))
                    Std.parseFloat(conditionalRead(isDigit))
                else
                    null;
        }

        clearSpaces();

        return result;
    }
}