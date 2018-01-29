import haxepunk.Scene;
import haxepunk.tmx.TmxEntity;
import haxepunk.graphics.atlas.TileAtlas;

class MainScene extends Scene
{
	var _tileset:TileAtlas;

	override public function begin()
	{
		createGraphics();
		createMap();
	}

	function createGraphics():Void
	{
		_tileset = new TileAtlas("graphics/wall.png", 16, 16);
	}

	function createMap():Void
	{
		var e = new TmxEntity("maps/example.tmx");
		this.add(e);

		e.loadGraphic(_tileset, ["background", "foreground"]);
	}
}
