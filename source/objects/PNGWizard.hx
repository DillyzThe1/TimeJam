package objects;

import flixel.FlxSprite;
import flixel.math.FlxPoint;

class PNGWizard extends FlxSprite
{
	public var sprSize:FlxPoint = FlxPoint.get(293, 280);

	public function new(midX:Float, groundY:Float)
	{
		super(midX - sprSize.x / 2, groundY - sprSize.y);
		loadGraphic(Paths.image("characters/pngwizard"));
	}
}
