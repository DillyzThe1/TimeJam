package gamestates;

import Paths;
import flixel.FlxG;
import flixel.FlxSprite;

class TitleScreenState extends TJState
{
	var bg:FlxSprite;
	var logoSpr:FlxSprite;

	override public function create()
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

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		totalElapsed += elapsed;

		if (FlxG.sound.music == null)
			FlxG.sound.playMusic(Paths.music("mainMenu"));

		bg.angle = totalElapsed * 1.15;
	}
}
