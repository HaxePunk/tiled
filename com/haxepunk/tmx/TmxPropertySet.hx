/*******************************************************************************
 * Copyright (c) 2011 by Matt Tuttle (original by Thomas Jahn)
 * This content is released under the MIT License.
 * For questions mail me at heardtheword@gmail.com
 ******************************************************************************/
package com.haxepunk.tmx;

import haxe.xml.Fast;

class TmxPropertySet implements Dynamic<String>
{
	
	public function new()
	{
		keys = new Hash<String>();
	}
	
	public function resolve(name:String):String
	{
		return keys.get(name);
	}
	
	public function extend(source:Fast)
	{
		var prop:Fast;
		for (prop in source.nodes.property)
		{
			keys.set(prop.att.name, prop.att.value);
		}
	}
	
	private var keys:Hash<String>;
}