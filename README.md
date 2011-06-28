HaxePunk Tiled
==============

To use this as a background image simply create a new instance of TmxEntity.

> public function createMap(mapData:String)
> {
>     var map:TmxMap = new TmxMap(new XML(mapData));
>     var order:Array<String> = ["background", "main"]; // layer order (back-to-front)
>     var tmx:TmxEntity = new TmxEntity(map, bitmapData, checkTiles, order);
>
>     tmx.setCollidable(checkTiles, "collidable"); // Set collidable function and layer name
>     add(new TmxEntity(map, bitmapData));
> }
>
> public function checkTiles(tile:Int, col:Int, row:Int):Bool
> {
>     if (tile != 0) return true;
>     return false;
> }