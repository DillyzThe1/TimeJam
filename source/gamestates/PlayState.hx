package gamestates;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.util.FlxColor;
import flixel.util.FlxDirection;
import gamesubstates.CutsceneSubState;
import managers.MusicManager;
import objects.Player;
import objects.TMXLevel;

using TJUtil;

class PlayState extends TJState
{
	public var skyObject:FlxSprite;
	public var player:Player;
	public var lvl:TMXLevel;

	public var leftBound:FlxSprite;
	public var rightBound:FlxSprite;

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

		lvl = new TMXLevel(Paths.tmx("tutorial"));

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

		player.maxVelocity.set(625, 1550);
		// 475 for ice physics
		player.drag.set(2150, 2250);
	}

	override public function update(elapsed:Float)
	{
		if (FlxG.keys.justPressed.ESCAPE)
			FlxG.switchState(new TitleScreenState());

		if (FlxG.keys.justPressed.ONE)
			openSubState(new CutsceneSubState());

		player.acceleration.y = player.maxVelocity.y * 0.85;
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
						if (player.onGround)
							player.playAnim("walk");

						player.acceleration.x -= player.maxVelocity.x * (player.onGround ? 3.75 : 2.25);
						if (player.acceleration.x > 0)
							player.acceleration.x *= (player.onGround ? 0.15 : 0.35);
					case 1:
						player.facingLeft = false;
						if (player.onGround)
							player.playAnim("walk");

						player.acceleration.x += player.maxVelocity.x * (player.onGround ? 3.75 : 2.25);
						if (player.acceleration.x < 0)
							player.acceleration.x *= (player.onGround ? 0.15 : 0.35);
					case 2 | 4:
						if (player.onGround)
						{
							player.velocity.y = -player.maxVelocity.y * 0.55;
							player.onGround = false;
							player.playAnim("jump", true);
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

		zoomMAIN = FlxG.keys.pressed.SPACE ? 0.2 : 1;

		var lastBeat:Int = MusicManager.currentBeat;
		MusicManager.updatePosition();
		if (MusicManager.currentBeat != lastBeat && lastBeat % 4 == 0)
			player.idleDance();

		targetObject.setPosition((player.x + player.width / 2 + (player.facingLeft ? 0 : 300)).clampFloat(FlxG.worldBounds.x + FlxG.width / 2,
			FlxG.worldBounds.width - FlxG.width / 2),
			(player.y + player.height / 2).clampFloat(FlxG.worldBounds.y + FlxG.height / 2, FlxG.worldBounds.height - FlxG.height / 2));

		lvl.checkCollisionAlt(player);
		FlxG.collide(leftBound, player);
		FlxG.collide(rightBound, player);
		player.onGround = player.isTouching(FlxDirection.DOWN);
		if (player.isTouching(FlxDirection.LEFT) || player.isTouching(FlxDirection.RIGHT))
			player.acceleration.x = 0;
		if (player.isTouching(FlxDirection.UP) && player.acceleration.y > 0)
			player.acceleration.y = 0;

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
