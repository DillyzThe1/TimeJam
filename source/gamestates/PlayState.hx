package gamestates;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.util.FlxColor;
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
		add(player);
		#end
		add(player.playerSpr);

		player.maxVelocity.set(625, 1550);
		// 475 for ice physics
		player.drag.set(2150, 1125);
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
						player.acceleration.x -= player.maxVelocity.x * 3.75;
						player.facingLeft = true;
						player.evaluateOffset(player.getAnim());

						if (player.acceleration.x > 0)
							player.acceleration.x *= 0.15;
					case 1:
						player.acceleration.x += player.maxVelocity.x * 3.75;
						player.facingLeft = false;
						player.evaluateOffset(player.getAnim());

						if (player.acceleration.x < 0)
							player.acceleration.x *= 0.15;
					case 2 | 4:
						player.velocity.y = -player.maxVelocity.y * 0.55;
						// case 3:
						// player.y += 5;
				}
		super.update(elapsed);

		if (!controls[0] && !controls[1])
			player.acceleration.x = 0;

		zoomMAIN = FlxG.keys.pressed.SPACE ? 0.2 : 1;

		var lastBeat:Int = MusicManager.currentBeat;
		MusicManager.updatePosition();
		if (MusicManager.currentBeat != lastBeat && lastBeat % 4 == 0)
			player.idleDance();

		targetObject.setPosition(Std.int(player.x + player.width / 2 + (player.facingLeft ? -175 : 175)).clampInt(0, lvl.width * lvl.tileWidth),
			player.y + player.height / 2);

		lvl.checkCollision(player);

		if (player.y > 4800)
			player.y = 0;
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
