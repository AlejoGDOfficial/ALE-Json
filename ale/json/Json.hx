package ale.json;

class Json
{
    public static function parse(id:String):Dynamic
    {
        try 
        {
            var source:String = id;

            if (Config.FILE_CHECKER != null && Config.FILE_READER != null)
            {
                final path:String = Config.PATH + id + Config.EXTENSION;

                if (Config.FILE_CHECKER(path))
                    source = Config.FILE_READER(path);
            }

            return new Parser(source).parse();
        } catch (e) {
            Config.ERROR_HANDLER(e);

            return null;
        }
    }
}