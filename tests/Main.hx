package;

import haxe.Timer;

import ale.json.*;

class Main
{
    static function main()
    {
        function bechmark(func:Void -> Dynamic, ?title:String)
        {
            final start:Float = Timer.stamp();

            var res:Dynamic = null;
            
                res = func();

            trace((title == null ? '' : title + ' Json: ') + Std.string(Timer.stamp() - start) + ' - ' + res);
        }

        Config.PATH = 'data/';

        final source = Config.FILE_READER(Config.PATH + 'test' + Config.EXTENSION);

        bechmark(() -> Json.parse(source), 'ALE');
    }
}