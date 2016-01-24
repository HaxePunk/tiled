package tiled;

import haxe.xml.Fast;

class TmxPropertySet implements Dynamic<String>
{
	public function new()
	{
		keys = new Map<String,String>();
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

	private var keys:Map<String,String>;
}
