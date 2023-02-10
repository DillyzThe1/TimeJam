package objects;

import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import managers.MusicManager;

// the player extends it's hitbox, playing the animations above it on a character
class Player extends FlxSprite
{
	public var playerSpr:FlxSprite;

	public var inputEnabled:Bool;

	var offsetMap:Map<String, FlxPoint> = new Map<String, FlxPoint>();
	var curOffset:FlxPoint = FlxPoint.get();
	var freeNextOffset:Bool = true;

	public function new(x:Float, y:Float)
	{
		super(x, y);
		makeGraphic(75, 275, FlxColor.RED);
		alpha = #if debug 0.25 #else 0 #end;

		playerSpr = new FlxSprite();
		playerSpr.frames = Paths.sparrowv2("characters/jason");
		playerSpr.animation.addByPrefix("idle", "jason idle0", 24, false, false, false);

		offsetMap["idle"] = FlxPoint.get(5, 5);

		playAnim("idle");
	}

	public override function update(e:Float)
	{
		super.update(e);

		playerSpr.setPosition(x + curOffset.x, y + curOffset.y);
	}

	public function idleDance()
	{
		if (playerSpr.animation.curAnim == null || getAnim() == "idle")
			playAnim("idle");
	}

	public function playAnim(anim:String)
	{
		if (freeNextOffset)
			curOffset.put();

		if (offsetMap.exists(anim))
			curOffset = offsetMap[anim];
		else
		{
			curOffset = FlxPoint.get();
			freeNextOffset = true;
		}
		playerSpr.animation.play(anim, true);
	}

	public function getAnim()
	{
		return playerSpr.animation.curAnim == null ? "" : playerSpr.animation.curAnim.name;
	}
}
