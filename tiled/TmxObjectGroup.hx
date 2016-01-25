package tiled;

import haxe.xml.Fast;

class TmxObjectGroup extends TmxLayer
{
	public var objects:Array<TmxObject>;

	public function new(source:Fast, parent:TmxMap)
	{
		super(source, parent);
		objects = new Array<TmxObject>();

		map = parent;
		name = source.att.name;
		x = (source.has.x) ? Std.parseInt(source.att.x) : 0;
		y = (source.has.y) ? Std.parseInt(source.att.y) : 0;
		width = map.width;
		height = map.height;
		visible = (source.has.visible && source.att.visible == "1") ? true : false;
		opacity = (source.has.opacity) ? Std.parseFloat(source.att.opacity) : 0;

		// Load properties
		var node:Fast;
		for (node in source.nodes.properties)
		{
			properties.extend(node);
		}

		// Load objects
		for (node in source.nodes.object)
		{
			objects.push(new TmxObject(node, this));
		}
	}
}
