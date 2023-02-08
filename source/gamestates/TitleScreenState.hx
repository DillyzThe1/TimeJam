package gamestates;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxMath;
import managers.MusicManager;

class TitleScreenState extends TJState
{
	var bg:FlxSprite;
	var logoSpr:FlxSprite;

	public override function create()
	{
		super.create();

		bg = new FlxSprite().loadGraphic(Paths.image('bg'));
		bg.screenCenter();
		add(bg);

		logoSpr = new FlxSprite().loadGraphic(Paths.image('glowy logo'));
		logoSpr.screenCenter();
		add(logoSpr);

		logoSpr.scale.set(0.65, 0.65);
		bg.antialiasing = logoSpr.antialiasing = true;
	}

	var totalElapsed:Float = 0;

	// var lastStep:Int = -1;
	var fastStep:Int = -1;
	var lastBeat:Int = -1;

	var plusThis:Float = 0;

	public override function update(elapsed:Float)
	{
		super.update(elapsed);
		totalElapsed += elapsed;

		// lastStep = MusicManager.currentStep;
		lastBeat = MusicManager.currentBeat;
		MusicManager.updatePosition();

		if (lastBeat != MusicManager.currentBeat && lastBeat % 2 == 0)
			plusThis += 25;

		if (plusThis > 1.155)
			plusThis = FlxMath.lerp(plusThis, 1.15, clampFloat(elapsed * 10 * (120 / FlxG.drawFramerate), 0.01, 0.9));

		bg.angle += elapsed * (1.15 + plusThis);
	}

	function clampFloat(val:Float, min:Float, max:Float)
	{
		if (val > max)
			return max;
		if (val < min)
			return min;
		return val;
	}
}
