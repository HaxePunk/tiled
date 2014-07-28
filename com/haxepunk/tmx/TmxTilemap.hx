package com.haxepunk.tmx;

import com.haxepunk.Graphic.TileType;
import com.haxepunk.graphics.Tilemap;
import flash.display.BitmapData;
import flash.geom.Point;

/**
 * ...
 * @author Jero
 */
class TmxTilemap extends Tilemap
{
	public var offsetX:Int;
	public var offsetY:Int;

	public function new(tileset:TileType, width:Int, height:Int, tileWidth:Int, tileHeight:Int, ?tileSpacingWidth:Int=0, ?tileSpacingHeight:Int=0, offsetX:Int=0, offsetY:Int=0)
	{
		this.offsetX = offsetX;
		this.offsetY = offsetY;
		super(tileset, width, height, tileWidth, tileHeight, tileSpacingWidth, tileSpacingHeight);
	}

	override public function render(target:BitmapData, point:Point, camera:Point)
	{
		var p:Point = new Point(offsetX + point.x, offsetY + point.y);
		super.render(target, p, camera);
	}

	override public function renderAtlas(layer:Int, point:Point, camera:Point)
	{
		var p:Point = new Point(offsetX + point.x, offsetY + point.y);
		super.renderAtlas(layer, p, camera);
	}
}