package;

import haxe.Timer;

import ale.json.*;

class Main
{
    static function main()
    {
        function bechmark(func:Void -> Void, ?title:String)
        {
            final start:Float = Timer.stamp();

            for (i in 0...10000)
                func();

            trace((title == null ? '' : title + ' Json : ') + Std.string(Timer.stamp() - start));
        }

        Config.PATH = 'data/';

        final source = Config.FILE_READER(Config.PATH + 'test' + Config.EXTENSION);

        bechmark(() -> Json.parse(source), 'ALE');

        bechmark(() -> haxe.Json.parse(source), 'Std');

        bechmark(() -> jsonmod.Json.parse(source), 'Mod');
    }
}