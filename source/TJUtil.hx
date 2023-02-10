package;

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
}
