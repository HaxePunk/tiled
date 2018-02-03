/*******************************************************************************
 * Copyright (c) 2011 by Matt Tuttle (original by Thomas Jahn)
 * This content is released under the MIT License.
 * For questions mail me at heardtheword@gmail.com
 ******************************************************************************/
package haxepunk.tmx;

import haxe.xml.Fast;

/**
 *  A set of custom properties.
 */
class TmxPropertySet implements Dynamic<String>
{

	/**
	 *  Constructor.
	 */
	public function new()
	{
#if haxe3
		keys = new Map<String, String>();
#else
		keys = new Hash<String>();
#end
	}

	/**
	 *  Resolves a custom property.
	 *  @param name - Name of the property to resolve.
	 *  @return String
	 */
	public function resolve(name:String):String
	{
		return keys.get(name);
	}

	/**
	 *  Checks for the existence of a custom property.
	 *  @param name - The name of the custom property.
	 *  @return Bool
	 */
	public function has(name:String):Bool
	{
		return keys.exists(name);
	}

	/**
	 *  Adds custom properties to this set.
	 *  @param source - The Fast source of the custom properties to add.
	 */
	public function extend(source:Fast)
	{
		var prop:Fast;
		for (prop in source.nodes.property)
		{
			keys.set(prop.att.name, prop.att.value);
		}
	}

#if haxe3
	private var keys:Map<String, String>;
#else
	private var keys:Hash<String>;
#end
}
