package com.haxepunk.tmx;

class TmxOrderedHash<T>
{
	var _keys:Array<String>;
	var _hash:Hash<T>;

	public function new()
	{
		_keys = new Array<String>();
		_hash = new Hash<T>();
	}

	public inline function set(key:String, value:T)
	{
		if (!_hash.exists(key)) _keys.push(key);
		_hash.set(key,value);
	}

	public inline function remove(key:String) : Bool
	{
		_keys.remove(key);
		return _hash.remove(key);
	}

	public inline function exists(key:String) { return _hash.exists(key); }
	public inline function get(key:String) { return _hash.get(key); }

	public function iterator():Iterator<T>
	{
		var _keys_itr = _keys.iterator();
		var __hash = _hash;
		return {
			next: function() { return __hash.get(_keys_itr.next()); },
			hasNext: _keys_itr.hasNext
		}
	}

	public function keys()
	{
		return _keys.iterator();
	}

	public function toString()
	{
		var __hash = _hash;
		var pairs = Lambda.map(_keys, function(x:String) { return x + ' => ' + __hash.get(x); });
		return  "{"+ pairs.join(', ') + "}";
	}
}
