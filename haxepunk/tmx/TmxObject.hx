/*******************************************************************************
 * Copyright (c) 2011 by Matt Tuttle (original by Thomas Jahn)
 * This content is released under the MIT License.
 * For questions mail me at heardtheword@gmail.com
 ******************************************************************************/
package haxepunk.tmx;

import haxe.xml.Fast;
import haxepunk.masks.Hitbox;

class TmxObject
{
	/**
	 *  The Object Group this object belongs to.
	 */
	public var group:TmxObjectGroup;

	/**
	 *  The name of this object.
	 */
	public var name:String;

	/**
	 *  The type of an object.
	 */
	public var type:String;

	/**
	 *  The x coordinate of the object in pixels.
	 */
	public var x:Int;

	/**
	 *  The y coordinate of the object in pixels.
	 */
	public var y:Int;

	/**
	 *  The width of the object in pixels.
	 */
	public var width:Int;

	/**
	 *  The height of the object in pixels.
	 */
	public var height:Int;

	/**
	 *  [Optional] A referene to a tile.
	 */
	public var gid:Int;

	/**
	 *  The custom properties of this object.
	 */
	public var custom:TmxPropertySet;

	/**
	 *  The shared custom properties of this object.
	 */
	public var shared:TmxPropertySet;

	/**
	 *  The mask of this object.
	 *  
	 *  Possible types are Hitbox and Circle (cannot do ellipses).
	 */
	public var shapeMask:Hitbox;

	#if debug
	public var debug_graphic:haxepunk.graphics.Image;
	#end
	
	/**
	 *  Constructor.
	 *  @param source - The Fast node representing this object.
	 *  @param parent - The parent Object Group.
	 */
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
		if (source.has.gid && source.att.gid.length != 0) //object with tile association?
		{
			gid = Std.parseInt(source.att.gid);
			var set:TmxTileSet;
			for (set in group.map.tilesets)
			{
				shared = set.getPropertiesByGid(gid);
				if (shared != null) break;
			}
		}
		
		//load properties
		var node:Xml;
		custom = new TmxPropertySet();
		for (node in source.nodes.properties)
			custom.extend(node);

		// create shape, cannot do ellipses, only circles
		if (source.hasNode.ellipse)
		{
			var radius = Std.int(((width < height)? width : height) / 2);
			shapeMask = new haxepunk.masks.Circle(radius, x, y);

#if debug
			debug_graphic = haxepunk.graphics.Image.createCircle(radius, 0xff0000, .6);
			debug_graphic.x = x;
			debug_graphic.y = y;
#end
		}
		else
		{ // rect
			shapeMask = new haxepunk.masks.Hitbox(width, height, x, y);

#if debug
			debug_graphic = haxepunk.graphics.Image.createRect(width, height, 0xff0000, .6);
			debug_graphic.x = x;
			debug_graphic.y = y;
#end
		}
	}
}