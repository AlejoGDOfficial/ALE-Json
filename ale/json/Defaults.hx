package ale.json;

#if sys
import sys.FileSystem;
import sys.io.File;
#end

import haxe.Exception as HaxeException;
import haxe.Log;

class Defaults
{
    public static final FILE_CHECKER:String -> Bool = #if sys FileSystem.exists #else null #end ;
    public static final FILE_READER:String -> String = #if sys File.getContent #else null #end ;

    public static final PATH:String = '';
    public static final EXTENSION:String = '.json';

    public static final ERROR_HANDLER:HaxeException -> Void = (exc:HaxeException) -> {
        var msg:String = exc.message;

        if (exc is Exception)
        {
            final castExc:Exception = cast exc;

            msg = 'Line: ' + castExc.line + ', Column: ' + castExc.column + ' - ' + msg;
        }

        Log.trace('[ ERROR ] ' + msg, null);
    };
}