/*******************************************************************************
 * Copyright (c) 2011 by Matt Tuttle (original by Thomas Jahn)
 * This content is released under the MIT License.
 * For questions mail me at heardtheword@gmail.com
 ******************************************************************************/
package com.haxepunk.tmx;
import haxe.xml.Fast;

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
	
	public function new(source:Fast, parent:TmxObjectGroup)
	{
		group = parent;
		name = source.att.name;
		type = source.att.type;
		x = Std.parseInt(source.att.x);
		y = Std.parseInt(source.att.y);
		width = Std.parseInt(source.att.width);
		height = Std.parseInt(source.att.height);
		//resolve inheritence
		shared = null;
		gid = -1;
		if(source.has.gid && source.att.gid.length != 0) //object with tile association?
		{
			gid = Std.parseInt(source.att.gid);
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
		custom = new TmxPropertySet();
		for (node in source.nodes.properties)
			custom.extend(node);
	}
}