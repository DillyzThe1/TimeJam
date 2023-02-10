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

	public var facingLeft:Bool = false;

	public var onGround:Bool = false;

	public function new(x:Float, y:Float)
	{
		super(x, y);
		makeGraphic(75, 275, FlxColor.RED);
		alpha = #if debug 0.25 #else 0 #end;

		playerSpr = new FlxSprite();
		playerSpr.frames = Paths.sparrowv2("characters/jason");
		playerSpr.animation.addByPrefix("idle", "jason idle0", 24, false, false, false);
		playerSpr.animation.addByPrefix("walk", "jason walk0", 24, false, false, false);
		playerSpr.animation.addByIndices("jump", "jason jump0", [1, 2, 3, 4, 5, 6, 7, 8], "", 24, false, false, false);
		playerSpr.animation.addByPrefix("jump hit", "jason jump hit0", 24, false, false, false);
		playerSpr.animation.addByPrefix("skid", "jason skid0", 24, false, false, false);

		offsetMap["idle"] = FlxPoint.get(5, 2);
		offsetMap["idle__flip"] = FlxPoint.get(-2, 2);
		offsetMap["walk"] = FlxPoint.get(-35, -6);
		offsetMap["walk__flip"] = FlxPoint.get(-50, -6);
		offsetMap["jump"] = FlxPoint.get(-30, -12);
		offsetMap["jump__flip"] = FlxPoint.get(-30, -12);
		offsetMap["jump hit"] = FlxPoint.get(-25, -3);
		offsetMap["jump hit__flip"] = FlxPoint.get(-25, -3);
		offsetMap["skid"] = FlxPoint.get(0, 0);
		offsetMap["skid__flip"] = FlxPoint.get(0, 0);

		playAnim("idle");
	}

	public override function update(e:Float)
	{
		super.update(e);
		updateSpr();
	}

	public function updateSpr()
	{
		playerSpr.setPosition(x + curOffset.x, y + curOffset.y);
		playerSpr.flipX = facingLeft;
	}

	public function idleDance()
	{
		if (playerSpr.animation.curAnim == null || getAnim() == "idle")
			playAnim("idle", true);
	}

	public function evaluateOffset(anim:String)
	{
		var _anim:String = anim;
		if (facingLeft)
			_anim += "__flip";

		if (freeNextOffset)
		{
			curOffset.put();
			freeNextOffset = false;
		}

		if (offsetMap.exists(_anim))
			curOffset = offsetMap[_anim];
		else
		{
			curOffset = FlxPoint.get();
			freeNextOffset = true;
		}
		updateSpr();
	}

	public function playAnim(anim:String, ?fullForce:Bool = false)
	{
		playerSpr.animation.play(anim, getAnim() != anim || fullForce);
		evaluateOffset(getAnim());
	}

	public function getAnim()
	{
		return playerSpr.animation.curAnim == null ? "" : playerSpr.animation.curAnim.name;
	}

	public function animFinished()
	{
		return playerSpr.animation.curAnim == null || playerSpr.animation.curAnim.finished;
	}

	public override function destroy()
	{
		playerSpr.destroy();
		playerSpr = null;
		for (offset in offsetMap)
			offset.put();
		offsetMap.clear();
		offsetMap = null;
		curOffset.put();
		curOffset = null;
		super.destroy();
	}
}
