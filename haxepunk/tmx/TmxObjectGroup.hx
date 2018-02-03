/*******************************************************************************
 * Copyright (c) 2011 by Matt Tuttle (original by Thomas Jahn)
 * This content is released under the MIT License.
 * For questions mail me at heardtheword@gmail.com
 ******************************************************************************/
package haxepunk.tmx;

import haxe.xml.Fast;

class TmxObjectGroup
{
	/**
	 *  The parent map of this group.
	 */
	public var map:TmxMap;

	/**
	 *  The name of this group.
	 */
	public var name:String;

	/**
	 *  The x coordinate of the object group in tiles. Defaults to 0 and can no longer be changed in Tiled.
	 */
	public var x:Int;

	/**
	 *  The y coordinate of the object group in tiles. Defaults to 0 and can no longer be changed in Tiled.
	 */
	public var y:Int;

	/**
	 *  The width of the object group in tiles. Meaningless.
	 */
	public var width:Int;

	/**
	 *  The height of the object group in tiles. Meaningless.
	 */
	public var height:Int;

	/**
	 *  The opacity of the layer as a value from 0 to 1. Defaults to 1.
	 */
	public var opacity:Float;

	/**
	 *  Whether to group is shown or hiddin.
	 */
	public var visible:Bool;

	/**
	 *  The custom properties of this group.
	 */
	public var properties:TmxPropertySet;

	/**
	 *  The objects in this group.
	 */
	public var objects:Array<TmxObject>;
	
	/**
	 *  Constructor.
	 *  @param source - The Fast source representing this group.
	 *  @param parent - The parent Map of this group.
	 */
	public function new(source:Fast, parent:TmxMap)
	{
		properties = new TmxPropertySet();
		objects = new Array<TmxObject>();
		
		map = parent;
		name = source.att.name;
		x = (source.has.x) ? Std.parseInt(source.att.x) : 0;
		y = (source.has.y) ? Std.parseInt(source.att.y) : 0;
		width = map.width;
		height = map.height;
		visible = (source.has.visible && source.att.visible == "1") ? true : false;
		opacity = (source.has.opacity) ? Std.parseFloat(source.att.opacity) : 0;
		
		//load properties
		var node:Fast;
		for (node in source.nodes.properties)
			properties.extend(node);
			
		//load objects
		for (node in source.nodes.object)
			objects.push(new TmxObject(node, this));
	}
}
