/*******************************************************************************
 * Copyright (c) 2011 by Matt Tuttle (original by Thomas Jahn)
 * This content is released under the MIT License.
 * For questions mail me at heardtheword@gmail.com
 ******************************************************************************/
package com.haxepunk.tmx;
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
		}else{ // rect
			shapeMask = new com.haxepunk.masks.Hitbox(width, height, x, y);

#if debug
			debug_graphic = com.haxepunk.graphics.Image.createRect(width, height, 0xff0000, .6);
			debug_graphic.x = x;
			debug_graphic.y = y;
#end
		}
	}
}