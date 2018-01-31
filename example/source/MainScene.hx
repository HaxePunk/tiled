import haxepunk.Scene;
import haxepunk.input.Input;
import haxepunk.input.Key;
import haxepunk.graphics.atlas.TileAtlas;
import haxepunk.graphics.Image;
import haxepunk.tmx.TmxEntity;
import haxepunk.utils.Color;

class MainScene extends Scene
{
	var _tileset:TileAtlas;
	var _player:Player;

	override public function begin():Void
	{
		configureInput();
		createGraphics();
		createMap();
	}

	override public function update():Void
	{
		if (Input.check("up")) _player.jump();
		if (Input.check("left")) _player.moveLeft();
		if (Input.check("right")) _player.moveRight();

		super.update(); // Don't forget me!
	}

	@:extern inline function configureInput():Void
	{
		Input.define("up", [Key.W, Key.UP]);
		Input.define("left", [Key.A, Key.LEFT]);
		Input.define("right", [Key.D, Key.RIGHT]);
	}

	@:extern inline function createGraphics():Void
	{
		_tileset = new TileAtlas("graphics/wall.png", 16, 16);
	}

	@:extern inline function createMap():Void
	{
		var e = new TmxEntity("maps/example.tmx");
		this.add(e);

		e.loadGraphic(_tileset, ["background", "foreground"]);
		e.loadMask("foreground", "ground");

		var p = e.map.getObjectGroup("playerSpawn").objects[0];
		createPlayer(p.x, p.y);
	}

	@:extern inline function createPlayer(x:Float, y:Float):Void
	{
		var img = Image.createRect( 16, 16, Color.getColorRGB(255, 0, 0));
		_player = new Player(x, y, img);
		_player.setHitbox( 16, 16 );

		this.add(_player);
	}
}
