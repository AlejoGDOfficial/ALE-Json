package ale.json;

class Config
{
    public static var FILE_CHECKER:String -> Bool = Defaults.FILE_CHECKER;
    public static var FILE_READER:String -> String = Defaults.FILE_READER;

    public static var PATH:String = Defaults.PATH;
    public static var EXTENSION:String = Defaults.EXTENSION;

    public static var ERROR_HANDLER:String -> Void = Defaults.ERROR_HANDLER;
}