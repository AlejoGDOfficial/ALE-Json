package ale.json;

#if sys
import sys.FileSystem;
import sys.io.File;
#end

import haxe.Log;

class Defaults
{
    public static final FILE_CHECKER:String -> Bool = #if sys FileSystem.exists #else null #end ;
    public static final FILE_READER:String -> String = #if sys File.getContent #else null #end ;

    public static final PATH:String = '';
    public static final EXTENSION:String = '.json';

    public static final ERROR_HANDLER:String -> Void = (e) -> Log.trace('[ ERROR ] ' + e, null);
}