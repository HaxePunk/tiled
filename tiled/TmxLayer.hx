package tiled;

class TmxLayer
{
	/** The name of the layer. */
	public var name(default, null):String;
	/** The opacity of the layer as a value from 0 to 1. */
	public var opacity(default, null):Float;
	/** Whether the layer is shown or hidden. */
	public var visible(default, null):Bool;
	/** Horizontal rendering offset for this layer in pixels. */
	public var offsetX(default, null):Int;
	/** Vertical offset for this layer in pixels. */
	public var offsetY(default, null):Int;
	/** The map containing the layer. */
	public var map(default, null):TmxMap;
	/** The custom properties of the layer. */
	public var properties(default, null):Map<String, String>;

	public function new(source:Fast, map:TmxMap)
	{
		properties = new Map<String, String>();
		this.map = map;

		name = source.att.name;
		if (name == null) throw TmxError.MISSING_LAYER_NAME;

		opacity = Std.parseFloat(source.att.opacity);
		if (opacity == null) opacity = 1.0;

		visible = switch (source.att.visible) {
			case "0": false;
			case "1", null: true;
			default: throw TmxError.INVALID_LAYER_VISIBLE;
		};

		offsetX = Std.parseInt(source.att.offsetX);
		if (offsetX == null) offsetX = 0;

		offsetY = Std.parseInt(source.att.offsetY);
		if (offsetY == null) offsetY = 0;

		for (node in source.nodes.properties)
		{
			for (property in node.nodes.property)
			{
				properties.set(property.att.name, property.att.value);
			}
		}
	}
}
