/*******************************************************************************
 * Copyright (c) 2011 by Matt Tuttle (original by Thomas Jahn)
 * This content is released under the MIT License.
 * For questions mail me at heardtheword@gmail.com
 ******************************************************************************/
package com.haxepunk.tmx;
import com.haxepunk.Graphic;
import com.haxepunk.graphics.atlas.Atlas;
import com.haxepunk.graphics.Image;
import com.haxepunk.masks.Polygon;
import flash.display.BitmapData;
import flash.geom.Matrix;
import flash.geom.Point;
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
		width = (source.has.width) ? Std.parseInt(source.att.width) : 0;
		height = (source.has.height) ? Std.parseInt(source.att.height) : 0;
		//resolve inheritence
		shared = null;
		gid = -1;
		if(source.has.gid && source.att.gid.length != 0) //object with tile association?
		{
			gid = Std.parseInt(source.att.gid);
			var set:TmxTileSet;
			for (set in group.map.tilesets)
			{
				shared = set.getPropertiesByGid(gid);
				if(shared != null)
					break;
			}
		}
		
		//load properties
		var node:Xml;
		custom = new TmxPropertySet();
		for (node in source.nodes.properties)
			custom.extend(node);

		// create shape, cannot do ellipses, only circles
		if(source.hasNode.ellipse){
			var radius = Std.int(((width < height)? width : height)/2);
			shapeMask = new com.haxepunk.masks.Circle(radius, x, y);

#if debug
			debug_graphic = com.haxepunk.graphics.Image.createCircle(radius, 0xff0000, .6);
			debug_graphic.x = x;
			debug_graphic.y = y;
#end
		}else if (source.hasNode.polygon) {
			var polygon_node:Fast = source.node.polygon;
						
			var pointsString:String = polygon_node.att.points;
			var pairStrings:Array<String> = pointsString.split(' ');
			
			var maskPoints:Array<Point> = new Array<Point>();
			
			for (pair in pairStrings)
			{
				var pointStrings:Array<String> = pair.split(',');
				maskPoints.push(new Point(Std.parseFloat(pointStrings[0]), Std.parseFloat(pointStrings[1])));
			}
			
			shapeMask = new Polygon(maskPoints);

#if debug
			var graphicPoints:flash.Vector<Float> = new flash.Vector<Float>();
			
			for (point in maskPoints)
			{
				graphicPoints.push(point.x);
				graphicPoints.push(point.y);
			}
			
			debug_graphic = createPolygon(graphicPoints);
			
			debug_graphic.x += x;
			debug_graphic.y += y;
#end
		}else{ // rect
			shapeMask = new com.haxepunk.masks.Hitbox(width, height, x, y);

#if debug
			debug_graphic = com.haxepunk.graphics.Image.createRect(width, height, 0xff0000, .6);
			debug_graphic.x = x;
			debug_graphic.y = y;
#end
		}
	}
	
	function createPolygon(points:flash.Vector<Float>)
	{	
		//Find limits for image
		var minX:Float = 0, maxX:Float = 0, minY:Float = 0, maxY:Float = 0;
		for (i in 0 ... Std.int(points.length / 2))
		{
			var x:Float = points[i * 2];
			var y:Float = points[(i * 2) + 1];
			
			if (x < minX) { minX = x; }
			if (x > maxX) { maxX = x; }
			if (y < minY) { minY = y; }
			if (y > maxY) { maxY = y; }
		}
		
		var commands:flash.Vector<Int> = new flash.Vector<Int>();
		
		commands.push(1); //Move to
		for (i in 0 ... Std.int(points.length / 2))
		{
			commands.push(2); //Line to
		}
		
		HXP.sprite.graphics.clear();

		HXP.sprite.graphics.beginFill(0xFFFFFF);
		HXP.sprite.graphics.drawPath(commands, points);
		
		var data:BitmapData = HXP.createBitmap(Std.int(maxX - minX), Std.int(maxY - minY), true, 0);
		var transform:Matrix = new Matrix( 1, 0, 0, 1, -minX, -minY );
		data.draw(HXP.sprite, transform);
		
		var image:Image;
		if (HXP.renderMode == RenderMode.HARDWARE)
		{
			image = new Image(Atlas.loadImageAsRegion(data));
		}
		else
		{
			image = new Image(data);
		}

		image.color = 0xff0000;
		image.alpha = 0.6;
		
		image.x = minX;
		image.y = minY;

		return image;
	}
}