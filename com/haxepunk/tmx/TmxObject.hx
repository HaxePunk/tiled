/*******************************************************************************
 * Copyright (c) 2011 by Matt Tuttle (original by Thomas Jahn)
 * This content is released under the MIT License.
 * For questions mail me at heardtheword@gmail.com
 ******************************************************************************/
package com.haxepunk.tmx;

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
	
	public function new(source:Xml, parent:TmxObjectGroup)
	{
		group = parent;
		name = source.get("name");
		type = source.get("type");
		x = Std.parseInt(source.get("x"));
		y = Std.parseInt(source.get("y"));
		width = Std.parseInt(source.get("width"));
		height = Std.parseInt(source.get("height"));
		//resolve inheritence
		shared = null;
		gid = -1;
		if(source.get("gid").length != 0) //object with tile association?
		{
			gid = Std.parseInt(source.get("gid"));
			var tileSet:TmxTileSet;
			for (tileSet in group.map.tileSets)
			{
				shared = tileSet.getPropertiesByGid(gid);
				if(shared != null)
					break;
			}
		}
		
		//load properties
		var node:Xml;
		for (node in source.elementsNamed("properties"))
			custom = (custom != null) ? custom.extend(node) : new TmxPropertySet(node);
	}
}