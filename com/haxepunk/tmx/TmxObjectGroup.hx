/*******************************************************************************
 * Copyright (c) 2011 by Matt Tuttle (original by Thomas Jahn)
 * This content is released under the MIT License.
 * For questions mail me at heardtheword@gmail.com
 ******************************************************************************/
package com.haxepunk.tmx;

class TmxObjectGroup
{
	public var map:TmxMap;
	public var name:String;
	public var x:Int;
	public var y:Int;
	public var width:Int;
	public var height:Int;
	public var opacity:Float;
	public var visible:Bool;
	public var properties:TmxPropertySet;
	public var objects:Array<TmxObject>;
	
	public function new(source:Xml, parent:TmxMap)
	{
		objects = new Array<TmxObject>();
		
		map = parent;
		name = source.get("name");
		x = Std.parseInt(source.get("x"));
		y = Std.parseInt(source.get("y"));
		width = Std.parseInt(source.get("width"));
		height = Std.parseInt(source.get("height"));
		visible = source.get("visible") == "1" ? true : false;
		opacity = Std.parseFloat(source.get("opacity"));
		
		//load properties
		var node:Xml;
		for (node in source.elementsNamed("properties"))
			properties = (properties != null) ? properties.extend(node) : new TmxPropertySet(node);
			
		//load objects
		for (node in source.elementsNamed("objects"))
			objects.push(new TmxObject(node, this));
	}
}