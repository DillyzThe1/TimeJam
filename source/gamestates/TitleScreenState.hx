package gamestates;

import flixel.FlxSprite;

class TitleScreenState extends TJState
{
	public var logoSpr:FlxSprite;

	override public function create()
	{
		super.create();

		logoSpr = new FlxSprite().loadGraphic(Paths.image('logo'));
		logoSpr.screenCenter();
		add(logoSpr);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}
