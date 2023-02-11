package;

import flixel.math.FlxPoint;

class TJUtil
{
	public static function clampInt(val:Int, min:Int, max:Int)
	{
		if (val > max)
			return max;
		if (val < min)
			return min;
		return val;
	}

	public static function clampFloat(val:Float, min:Float, max:Float)
	{
		if (val > max)
			return max;
		if (val < min)
			return min;
		return val;
	}

	public static function getDist(p1:FlxPoint, p2:FlxPoint)
	{
		return Math.sqrt((p1.x - p2.x) * (p1.x - p2.x) + (p1.y - p2.y) * (p1.y - p2.y));
	}
}
