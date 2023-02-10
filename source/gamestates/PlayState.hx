package gamestates;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.util.FlxColor;
import flixel.util.FlxDirection;
import gamesubstates.CutsceneSubState;
import managers.MusicManager;
import managers.PlayerDataManager;
import objects.Player;
import objects.TMXLevel;

using StringTools;
using TJUtil;

class PlayState extends TJState
{
	public var skyObject:FlxSprite;
	public var player:Player;
	public var lvl:TMXLevel;

	public var leftBound:FlxSprite;
	public var rightBound:FlxSprite;

	public static var levelName:String = "Tutorial";

	override public function create()
	{
		super.create();

		skyObject = new FlxSprite().loadGraphic(Paths.image("sky"));
		skyObject.screenCenter();
		skyObject.scale.set(1.15, 1.2);
		skyObject.scrollFactor.set(0, 0);
		skyObject.offset.y = 50;
		skyObject.alpha = 0.875;
		add(skyObject);

		lvl = new TMXLevel(Paths.tmx(levelName.toLowerCase().replace(" ", "-")));

		add(lvl.bgGroup);
		add(lvl.sprGroup);
		add(lvl.objGroup);
		add(lvl.fgGroup);

		trace(lvl.bgGroup.length);
		trace(lvl.sprGroup.length);
		trace(lvl.objGroup.length);
		trace(lvl.fgGroup.length);

		@:privateAccess
		trace(lvl.collisionTiles.length);

		player = new Player(lvl.playerStart.x, lvl.playerStart.y - 175);
		#if debug
		lvl.objGroup.add(player);
		#end
		add(player.playerSpr);

		leftBound = new FlxSprite(FlxG.worldBounds.x - 50, FlxG.worldBounds.y);
		leftBound.makeGraphic(50, Std.int(FlxG.worldBounds.height), 0xff00ff00);

		rightBound = new FlxSprite(FlxG.worldBounds.x + FlxG.worldBounds.width, FlxG.worldBounds.y);
		rightBound.makeGraphic(50, Std.int(FlxG.worldBounds.height), 0xff00ff00);

		player.maxVelocity.set(625, 2175);
		// 475 for ice physics
		player.drag.set(2150, 3250);

		#if discord_presence
		managers.DiscordManager.setStatus('Exploring ${PlayState.levelName}', 'In Game');
		#end
	}

	var lastSkid:Int = -1;
	var totalTime:Float = 0;
	var lastTimeOnGround:Float = 0;

	override public function update(elapsed:Float)
	{
		totalTime += elapsed;

		player.acceleration.y = player.maxVelocity.y * 0.875;
		var controls:Array<Bool> = [
			FlxG.keys.pressed.LEFT,
			FlxG.keys.pressed.RIGHT,
			FlxG.keys.justPressed.UP,
			FlxG.keys.justPressed.DOWN,
			FlxG.keys.justPressed.SPACE
		];
		for (i in 0...controls.length)
			if (controls[i])
				switch (i)
				{
					case 0:
						player.facingLeft = true;
						if (player.onGround || (player.getAnim() == "skid" && player.animFinished()))
							player.walkCycle();

						player.acceleration.x -= player.maxVelocity.x * (player.onGround ? 3.75 : 2.25);
						if (player.acceleration.x > 0)
						{
							player.acceleration.x *= (player.onGround ? 0.15 : 0.35);

							if (lastSkid != 2 && player.onGround && player.getAnim().startsWith("walk"))
							{
								player.playAnim("skid", true);
								lastSkid = 2;
							}
						}
					case 1:
						player.facingLeft = false;
						if (player.onGround || (player.getAnim() == "skid" && player.animFinished()))
							player.walkCycle();

						player.acceleration.x += player.maxVelocity.x * (player.onGround ? 3.75 : 2.25);
						if (player.acceleration.x < 0)
						{
							player.acceleration.x *= (player.onGround ? 0.15 : 0.35);

							if (lastSkid != 1 && player.onGround && player.getAnim().startsWith("walk"))
							{
								player.playAnim("skid", true);
								lastSkid = 1;
							}
						}
					case 2 | 4:
						var causedByTime:Bool = (totalTime - lastTimeOnGround) < 0.15;
						if (causedByTime || player.mayDoubleJump)
						{
							if (causedByTime)
								trace('You had ${0.15 - (totalTime - lastTimeOnGround)} seconds left to jump.');
							else
								player.mayDoubleJump = false;

							player.velocity.y = -player.maxVelocity.y * 0.415;
							player.onGround = false;
							player.playAnim("jump", true);
							lastTimeOnGround = 0;
						}
						// case 3:
						// player.y += 5;
				}
		super.update(elapsed);

		player.maxVelocity.x = player.onGround ? 550 : 635;

		if (!controls[0] && !controls[1] && player.onGround)
		{
			player.acceleration.x = 0;
			player.playAnim("idle");
		}

		#if debug
		zoomMAIN = FlxG.keys.pressed.SPACE ? 0.2 : 1;
		#end

		var lastBeat:Int = MusicManager.currentBeat;
		MusicManager.updatePosition();
		if (MusicManager.currentBeat != lastBeat && lastBeat % 4 == 0)
			player.idleDance();

		targetObject.setPosition((player.x + player.width / 2 + (player.facingLeft ? -175 : 300)).clampFloat(FlxG.worldBounds.x + FlxG.width / 2,
			FlxG.worldBounds.width - FlxG.width / 2),
			(player.y + player.height / 2).clampFloat(FlxG.worldBounds.y + FlxG.height / 2, FlxG.worldBounds.height - FlxG.height / 2));

		lvl.checkCollisionAlt(player);
		FlxG.collide(leftBound, player);
		FlxG.collide(rightBound, player);

		player.onGround = player.isTouching(FlxDirection.DOWN);
		if (player.onGround)
		{
			lastTimeOnGround = totalTime;
			player.mayDoubleJump = PlayerDataManager.hasDoubleJump;
		}

		#if debug
		if (FlxG.keys.justPressed.I)
		{
			PlayerDataManager.hasDoubleJump = true;
			PlayerDataManager.save();
		}
		if (FlxG.keys.justPressed.O)
		{
			PlayerDataManager.hasDoubleJump = false;
			PlayerDataManager.save();
		}
		#end

		if (player.isTouching(FlxDirection.LEFT) || player.isTouching(FlxDirection.RIGHT))
			player.acceleration.x = 0;
		if (player.isTouching(FlxDirection.UP) && player.acceleration.y > 0)
		{
			player.acceleration.y = 0;
			player.velocity.y = player.maxVelocity.y * 0.15;
			player.playAnim("jump hit", true);
		}

		if (player.y + player.height > FlxG.worldBounds.y + FlxG.worldBounds.height)
		{
			player.y = FlxG.worldBounds.y;
			player.velocity.y = 0;
		}
		if (player.x < FlxG.worldBounds.x)
		{
			player.x = FlxG.worldBounds.x;
			player.velocity.x = 0;
		}
		else if (player.x + player.width > FlxG.worldBounds.x + FlxG.worldBounds.width)
		{
			player.x = FlxG.worldBounds.x + FlxG.worldBounds.width - player.width;
			player.velocity.x = 0;
		}

		if (FlxG.keys.justPressed.ESCAPE)
			FlxG.switchState(new TitleScreenState());

		if (FlxG.keys.justPressed.ONE)
			openSubState(new CutsceneSubState());
	}

	override function destroy()
	{
		skyObject.destroy();
		skyObject = null;
		lvl.bgGroup.destroy();
		lvl.bgGroup = null;
		lvl.sprGroup.destroy();
		lvl.sprGroup = null;
		lvl.objGroup.destroy();
		lvl.objGroup = null;
		lvl.fgGroup.destroy();
		lvl.fgGroup = null;
		lvl = null;
		player.destroy();
		player = null;
		super.destroy();
	}

	override function closeSubState()
	{
		@:privateAccess
		var subname:String = Type.getClassName(Type.getClass(subState));
		trace("closing sub " + subname);

		switch (subname)
		{
			case "gamesubstates.CutsceneSubState":
				camHUD.flash(FlxColor.BLACK);
		}

		super.closeSubState();
	}
}
