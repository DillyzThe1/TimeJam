package objects;

import flixel.FlxSprite;

class ArchaicCrystal extends FlxSprite
{
	public static var allCrystals:Array<ArchaicCrystal> = [];
	public static var crystalsCollected:Array<Int> = [];

	public static function getHighestIndex()
	{
		var highestIndex:Int = -1;
		for (crystal in allCrystals)
			if (crystal.curIndex > highestIndex)
				highestIndex = crystal.curIndex;
		return highestIndex;
	}

	public var curIndex:Int;

	public function new(midX:Float, midY:Float, index:Int)
	{
		super(midX, midY);
		loadGraphic(Paths.image("archaic crystal"));

		x -= width / 2;
		y -= height / 2;

		scale.set(0.725, 0.725);

		curIndex = index;

		allCrystals.push(this);
	}

	var fullElapsed:Float = 0;

	public override function update(e:Float)
	{
		super.update(e);

		fullElapsed += e;

		var sine:Float = Math.sin(fullElapsed);
		var cosine:Float = Math.cos(fullElapsed);

		offset.x = cosine * 5.65;
		offset.y = sine * 5.65;
		angle = cosine * 2.65 + sine * 3.65;

		var scaleeeeee:Float = 0.725 + sine / 25;
		scale.set(scaleeeeee, scaleeeeee);

		alpha = 0.75 + sine / 10;

		color.saturation = Math.abs(sine / 5);
	}

	public override function destroy()
	{
		allCrystals.remove(this);
		super.destroy();
	}

	public static function lastCrystal()
	{
		return crystalsCollected[crystalsCollected.length];
	}
}
