/*******************************************************************************
 * Copyright (c) 2011 by Matt Tuttle (original by Thomas Jahn)
 * This content is released under the MIT License.
 * For questions mail me at heardtheword@gmail.com
 ******************************************************************************/
package com.haxepunk.tmx;

class TmxPropertySet
{
	public function new(source:Xml)
	{
		extend(source);
	}
	
	public function extend(source:Xml):TmxPropertySet
	{
		var prop:Xml;
		for (prop in source.elementsNamed("property"))
		{
			var key:String = prop.get("name");
			var value:String = prop.get("value");
			Reflect.setField(this, key, value);
		}
		return this;
	}
}