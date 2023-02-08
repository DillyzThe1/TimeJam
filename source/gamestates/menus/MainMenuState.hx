package gamestates.menus;

import flixel.FlxG;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;

class MainMenuState extends TJState
{
	public var bruh:FlxText;

	override public function create()
	{
		super.create();

		bruh = new FlxText(0, 0, 0, "press escape to go to the title screen,\npress 1 to start the game,\npress 2 to go to settings,\nand hit 3 to exit.");
		bruh.size = 32;
		add(bruh);
		bruh.screenCenter();
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.keys.justPressed.ESCAPE)
			FlxG.switchState(new TitleScreenState());
		if (FlxG.keys.justPressed.ONE)
		{
			if (FlxG.sound.music != null)
				FlxG.sound.music.fadeOut(0.75, 0);

			FlxTween.tween(bruh, {alpha: 0}, 0.75, {ease: FlxEase.cubeOut});

			new FlxTimer().start(1.5, function(bruh:FlxTimer)
			{
				FlxG.switchState(new PlayState());
			});
		}
		if (FlxG.keys.justPressed.THREE)
			Sys.exit(0);
	}
}
