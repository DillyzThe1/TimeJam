package objects;

import flixel.FlxSprite;

class TimelineReflector extends FlxSprite
{
	public function new(midX:Float, floorY:Float)
	{
		super(midX, floorY);
		loadGraphic(Paths.image("timeline-reflector"));
		x -= width / 2;
		y -= height;
	}
}
