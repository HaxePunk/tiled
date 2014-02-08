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
#if haxe3
		keys = new Map<String,String>();
#else
		keys = new Hash<String>();
#end
	}

	public function resolve(name:String):String
	{
		return keys.get(name);
	}

	public function has(name:String):Bool
	{
		return keys.exists(name);
	}

	public function extend(source:Fast)
	{
		var prop:Fast;
		for (prop in source.nodes.property)
		{
			keys.set(prop.att.name, prop.att.value);
		}
	}

#if haxe3
	private var keys:Map<String,String>;
#else
	private var keys:Hash<String>;
#end
}
