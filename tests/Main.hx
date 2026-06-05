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

            final res:Dynamic = func();
            
            trace((title == null ? '' : title + ' Json: ') + Std.string(Timer.stamp() - start) + ' - ' + res);
        }

        Config.PATH = 'data/';

        final source = Config.FILE_READER(Config.PATH + 'test' + Config.EXTENSION);

        bechmark(() -> Json.parse(source), 'ALE');
    }
}