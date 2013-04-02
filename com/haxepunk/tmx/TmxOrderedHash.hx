package com.haxepunk.tmx;

class TmxOrderedHash<T>
{
	var _keys:Array<String>;
#if haxe3
	var _map:Map<String,T>;
#else
	var _map:Hash<T>;
#end

	public function new()
	{
		_keys = new Array<String>();
#if haxe3
		_map = new Map<String,T>();
#else
		_map = new Hash<T>();
#end
	}

	public inline function set(key:String, value:T)
	{
		if (!_map.exists(key)) _keys.push(key);
		_map.set(key,value);
	}

	public inline function remove(key:String) : Bool
	{
		_keys.remove(key);
		return _map.remove(key);
	}

	public inline function exists(key:String) { return _map.exists(key); }
	public inline function get(key:String) { return _map.get(key); }

	public function iterator():Iterator<T>
	{
		var _keys_itr = _keys.iterator();
		var __map = _map;
		return {
			next: function() { return __map.get(_keys_itr.next()); },
			hasNext: _keys_itr.hasNext
		}
	}

	public function keys()
	{
		return _keys.iterator();
	}

	public function toString()
	{
		var __map = _map;
		var pairs = Lambda.map(_keys, function(x:String) { return x + ' => ' + __map.get(x); });
		return  "{"+ pairs.join(', ') + "}";
	}
}
