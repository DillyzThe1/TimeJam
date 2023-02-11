package objects;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.system.FlxSound;
import flixel.util.FlxColor;
import managers.MusicManager;

using StringTools;

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
	public var mayDoubleJump:Bool = false;

	var lastGround:Bool = false;

	var walkFirst:Bool = true;
	var lastWalkDir:Bool = false;

	var grassSfx:Array<FlxSound>;
	var jumpSfx:FlxSound;

	public function new(x:Float, y:Float)
	{
		super(x, y);
		makeGraphic(75, 275, FlxColor.RED);
		alpha = #if debug 0.25 #else 0 #end;

		playerSpr = new FlxSprite();
		playerSpr.frames = Paths.sparrowv2("characters/jason");
		playerSpr.animation.addByPrefix("idle", "jason idle0", 24, false, false, false);
		playerSpr.animation.addByIndices("walk1", "jason walk0", [0, 1, 2, 3, 4, 5, 6, 7, 8], "", 24, false, false, false);
		playerSpr.animation.addByIndices("walk2", "jason walk0", [9, 10, 11, 12, 13, 14, 15, 16, 17], "", 24, false, false, false);
		playerSpr.animation.addByIndices("jump", "jason jump0", [1, 2, 3, 4, 5, 6, 7, 8], "", 24, false, false, false);
		playerSpr.animation.addByPrefix("jump hit", "jason jump hit0", 24, false, false, false);
		playerSpr.animation.addByPrefix("skid", "jason skid0", 24, false, false, false);

		offsetMap["idle"] = FlxPoint.get(5, 2);
		offsetMap["idle__flip"] = FlxPoint.get(-2, 2);
		offsetMap["walk1"] = FlxPoint.get(-35, -6);
		offsetMap["walk1__flip"] = FlxPoint.get(-50, -6);
		offsetMap["walk2"] = FlxPoint.get(-35, -6);
		offsetMap["walk2__flip"] = FlxPoint.get(-50, -6);
		offsetMap["jump"] = FlxPoint.get(-30, -12);
		offsetMap["jump__flip"] = FlxPoint.get(-30, -12);
		offsetMap["jump hit"] = FlxPoint.get(-25, -3);
		offsetMap["jump hit__flip"] = FlxPoint.get(-25, -3);
		offsetMap["skid"] = FlxPoint.get(0, 0);
		offsetMap["skid__flip"] = FlxPoint.get(0, 0);

		grassSfx = [
			new FlxSound().loadEmbedded(Paths.sound("grass0")), new FlxSound().loadEmbedded(Paths.sound("grass1")),
			new FlxSound().loadEmbedded(Paths.sound("grass2")), new FlxSound().loadEmbedded(Paths.sound("grass3"))
		];
		jumpSfx = new FlxSound().loadEmbedded(Paths.sound("jump"));

		playAnim("idle");
	}

	public override function update(e:Float)
	{
		super.update(e);
		updateSpr();

		if (lastGround != onGround && onGround)
		{
			var sfx:FlxSound = grassSfx[FlxG.random.int(0, grassSfx.length - 1)];
			sfx.volume = 0.45 * FlxG.sound.volume;
			sfx.play(true, 0.001);
		}
		lastGround = onGround;
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

	public function jump()
	{
		if (onGround)
		{
			var sfx:FlxSound = grassSfx[FlxG.random.int(0, grassSfx.length - 1)];
			sfx.volume = 0.45 * FlxG.sound.volume;
			sfx.play(true, 0.001);
		}

		velocity.y = -maxVelocity.y * 0.415;
		onGround = false;
		playAnim("jump", true);
		jumpSfx.volume = 0.325;
		jumpSfx.play(true, 0.01);
	}

	public function walkCycle()
	{
		if (!getAnim().startsWith("walk") || lastWalkDir != facingLeft)
		{
			walkFirst = true;
			lastWalkDir = facingLeft;
			playAnim("walk1", true);
			return;
		}

		if (animFinished())
		{
			walkFirst = !walkFirst;
			playAnim('walk${walkFirst ? 1 : 2}', true);

			var sfx:FlxSound = grassSfx[FlxG.random.int(0, grassSfx.length - 1)];
			sfx.volume = 0.45 * FlxG.sound.volume;
			sfx.play(true, 0.001);
		}
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

	public function playAnim(anim:String, ?fullForce:Bool = false, ?frame:Int = 0)
	{
		playerSpr.animation.play(anim, getAnim() != anim || fullForce, false, frame);
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
		if (playerSpr != null)
		{
			playerSpr.destroy();
			playerSpr = null;
		}
		if (offsetMap != null)
		{
			for (offset in offsetMap)
				offset.put();
			offsetMap.clear();
			offsetMap = null;
		}
		if (curOffset != null)
		{
			curOffset.put();
			curOffset = null;
		}
		super.destroy();
	}
}
