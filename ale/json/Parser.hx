package ale.json;

using StringTools;

class Parser
{
    final source:String;

    public function new(src:String)
        source = src;

    var index:Int = 0;
    var line:Int = 1;
    var column:Int = 1;

    function eof():Bool
        return index >= source.length;

    function peek():Int
        return eof() ? -1 : source.fastCodeAt(index);

    function peekNext():Int
        return index + 1 >= source.length ? -1 : source.fastCodeAt(index + 1);

    function peekString():String
        return eof() ? '<EOF>' : source.charAt(index);

    function advance():Int
    {
        if (eof())
            error('Unexpected EOF');

        final char:Int = peek();

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
        return (char >= '0'.code && char <= '9'.code) || char == '-'.code;

    function isDigit(char:Int):Bool
        return char >= '0'.code && char <= '9'.code;

    function expect(char:Int)
    {
        if (peek() != char)
            unexpected(char);

        advance();
    }

    function unexpected(?expected:Int)
        error('Unexpected Token: ' + peekString() + (expected == null ? '' : ' - Expected: ' + String.fromCharCode(expected)));

    function error(msg:String)
        throw new Exception(msg, line, column);

    function readNumber():Float
    {
        var buf:StringBuf = new StringBuf();

        if (peek() == '-'.code)
            buf.addChar(advance());

        if (!isDigit(peek()))
            error('Invalid number');

        while (isDigit(peek()))
            buf.addChar(advance());

        if (peek() == '.'.code)
        {
            buf.addChar(advance());

            if (!isDigit(peek()))
                error('Invalid decimal number');

            while (isDigit(peek()))
                buf.addChar(advance());
        }

        if (peek() == 'e'.code || peek() == 'E'.code)
        {
            buf.addChar(advance());

            if (peek() == '+'.code || peek() == '-'.code)
                buf.addChar(advance());

            if (!isDigit(peek()))
                error('Invalid scientific notation');

            while (isDigit(peek()))
                buf.addChar(advance());
        }

        return Std.parseFloat(buf.toString());
    }

    function conditionalRead(func:Int -> Bool):String
    {
        var res:StringBuf = new StringBuf();

        while (true)
        {
            if (eof())
                error('Unterminated string');

            final cur:Int = peek();

            if (!func(cur))
                break;

            switch (cur)
            {
                case '\\'.code:
                    advance();

                    final escape:Int = advance();

                    switch (escape)
                    {
                        case 't'.code:
                            res.add('\t');

                        case 'n'.code:
                            res.add('\n');

                        case 'r'.code:
                            res.add('\r');

                        case '"'.code:
                            res.add('"');

                        case '\\'.code:
                            res.add('\\');

                        case '/'.code:
                            res.add('/');

                        case 'u'.code:
                            var hex:StringBuf = new StringBuf();

                            for (_ in 0...4)
                            {
                                if (eof())
                                    error('Incomplete unicode escape');

                                hex.addChar(advance());
                            }

                            res.addChar(Std.parseInt('0x' + hex.toString()));

                        default:
                            unexpected();
                    }

                default:
                    res.addChar(advance());
            }
        }

        return res.toString();
    }

    function clearSpaces()
    {
        while (true)
        {
            if (eof())
                return;

            final cur:Int = peek();

            switch (cur)
            {
                case ' '.code, '\t'.code, '\n'.code, '\r'.code:
                    advance();

                case '/'.code:
                    switch (peekNext())
                    {
                        case '/'.code:
                            advance();
                            advance();

                            while (!eof() && peek() != '\n'.code)
                                advance();

                        case '*'.code:
                            advance();
                            advance();

                            var closed:Bool = false;

                            while (!eof())
                            {
                                if (peek() == '*'.code && peekNext() == '/'.code)
                                {
                                    advance();
                                    advance();

                                    closed = true;
                                    
                                    break;
                                }

                                advance();
                            }

                            if (!closed)
                                error('Unterminated block comment');

                        default:
                            return;
                    }

                default:
                    return;
            }
        }
    }

    public function parse():Dynamic
    {
        clearSpaces();

        if (eof())
            error('Unexpected EOF');

        final result:Dynamic = switch (peek())
        {
            case 't'.code:
                expect('t'.code);
                expect('r'.code);
                expect('u'.code);
                expect('e'.code);

                true;

            case 'f'.code:
                expect('f'.code);
                expect('a'.code);
                expect('l'.code);
                expect('s'.code);
                expect('e'.code);

                false;

            case 'n'.code:
                expect('n'.code);
                expect('u'.code);
                expect('l'.code);
                expect('l'.code);

                null;

            case '"'.code:
                advance();

                final res:String = conditionalRead(char -> char != '"'.code);

                expect('"'.code);

                res;

            case '['.code:
                final res:Array<Dynamic> = [];

                advance();

                clearSpaces();

                var shouldContinue:Bool = peek() != ']'.code;

                while (shouldContinue)
                {
                    res.push(parse());

                    clearSpaces();

                    shouldContinue = switch (peek())
                    {
                        case ','.code:
                            advance();

                            clearSpaces();

                            true;

                        case ']'.code:
                            false;

                        default:
                            unexpected(']'.code);

                            false;
                    }
                }

                expect(']'.code);

                res;

            case '{'.code:
                final res:Dynamic = {};

                advance();

                clearSpaces();

                var shouldContinue:Bool = peek() != '}'.code;

                while (shouldContinue)
                {
                    clearSpaces();

                    expect('"'.code);

                    final fieldName:String = conditionalRead(char -> char != '"'.code);

                    expect('"'.code);

                    clearSpaces();

                    expect(':'.code);

                    clearSpaces();

                    Reflect.setField(res, fieldName, parse());

                    clearSpaces();

                    shouldContinue = switch (peek())
                    {
                        case ','.code:
                            advance();

                            clearSpaces();

                            true;

                        case '}'.code:
                            false;

                        default:
                            unexpected('}'.code);

                            false;
                    }
                }

                expect('}'.code);

                res;

            default:
                if (isDigitStart(peek()))
                {
                    readNumber();
                } else {
                    unexpected();

                    null;
                }
        }

        clearSpaces();

        return result;
    }
}