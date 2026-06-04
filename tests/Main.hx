package;

import ale.json.*;

class Main
{
    static function main()
    {
        Config.PATH = 'data/';

        trace(Json.parse('test') is Float);
    }
}