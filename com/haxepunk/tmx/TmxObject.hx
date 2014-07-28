/*******************************************************************************
 * Copyright (c) 2011 by Matt Tuttle (original by Thomas Jahn)
 * This content is released under the MIT License.
 * For questions mail me at heardtheword@gmail.com
 ******************************************************************************/
package com.haxepunk.tmx;
import com.haxepunk.graphics.Image;
import com.haxepunk.graphics.TiledImage;
import com.haxepunk.masks.Masklist;
import com.haxepunk.masks.Polygon;
import com.haxepunk.math.Vector;
import flash.display.BitmapData;
import flash.geom.Point;
import flash.geom.Rectangle;
import haxe.xml.Fast;
import com.haxepunk.masks.Hitbox;

class TmxObject
{
	public var group:TmxObjectGroup;
	public var name:String;
	public var type:String;
	public var x:Int;
	public var y:Int;
	public var width:Int;
	public var height:Int;
	public var gid:Int;
	public var custom:TmxPropertySet;
	public var shared:TmxPropertySet;
	public var shapeMask:Hitbox;
	public var image:BitmapData;

	#if debug
	public var debug_graphic:com.haxepunk.graphics.Image;
	#end

	public function new(source:Fast, parent:TmxObjectGroup)
	{
		group = parent;
		name = (source.has.name) ? source.att.name : "[object]";
		type = (source.has.type) ? source.att.type : "";
		x = Std.parseInt(source.att.x);
		y = Std.parseInt(source.att.y);
		width = (source.has.width) ? Std.parseInt(source.att.width) : parent.map.tileWidth; //When object hast tile association width/height are not set by Tiled
		height = (source.has.height) ? Std.parseInt(source.att.height) : parent.map.tileHeight; //When object hast tile association width/height are not set by Tiled
		//resolve inheritance
		shared = null;
		gid = -1;
		if(source.has.gid && source.att.gid.length != 0) //object with tile association?
		{
			y -= parent.map.tileHeight; //BUG: Tiled uses wrong row number when object is graphic
			gid = Std.parseInt(source.att.gid);
			var set:TmxTileSet;
			for (set in group.map.tilesets)
			{
				shared = set.getPropertiesByGid(gid);
				if (shared != null)
				{
					if (set.image != null)
					{
						var r:Rectangle = set.getRect(set.fromGid(gid));
						r.x = HXP.round(r.x, 0);
						r.y = HXP.round(r.y, 0);
						image = new BitmapData(set.tileWidth, set.tileHeight);
						image.setVector(new Rectangle(0, 0, set.tileWidth, set.tileHeight), set.image.getVector(r));
					}
					break;
				}
			}
		}
		if (shared != null && type == "" && shared.resolve("type") != null)
		{
			type = shared.resolve("type");
		}

		//load properties
		var node:Xml;
		custom = new TmxPropertySet();
		for (node in source.nodes.properties)
			custom.extend(node);

		// create shape, cannot do ellipses, only circles
		if (source.hasNode.polygon)
		{
			var points:Array<String> = source.node.polygon.att.points.split(" ");
			var pArr:Array<Float> = new Array<Float>();
			for (pS in points) {
				pArr.push( x + Std.parseFloat(pS.split(",")[0]));
				pArr.push( y + Std.parseFloat(pS.split(",")[1]));
			}
			shapeMask = com.haxepunk.masks.Polygon.createFromArray(pArr);
#if debug
			var p = com.haxepunk.masks.Polygon.createFromArray(pArr);
			p.x = x;
			p.y = y;
			debug_graphic = com.haxepunk.graphics.Image.createPolygon(p, 0xff0000, .6);
			debug_graphic.x = x;
			debug_graphic.y = y;
#end

		}
		else if(source.hasNode.ellipse){
			var radius = Std.int(((width < height)? width : height)/2);
			shapeMask = new com.haxepunk.masks.Circle(radius, x, y);

#if debug
			debug_graphic = com.haxepunk.graphics.Image.createCircle(radius, 0xff0000, .6);
			debug_graphic.x = x;
			debug_graphic.y = y;
#end
		}else { // rect
			shapeMask = new com.haxepunk.masks.Hitbox(width, height, x, y);
#if debug
			debug_graphic = com.haxepunk.graphics.Image.createRect(width, height, 0xff0000, .6);
			debug_graphic.x = x;
			debug_graphic.y = y;
#end
		}
	}
}