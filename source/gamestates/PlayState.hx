package gamestates;

import flixel.FlxG;
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

		player = new Player(lvl.playerStart.x, lvl.playerStart.y - 175);
		#if debug
		add(player);
		#end
		add(player.playerSpr);

		player.maxVelocity.set(450, 550);
		player.drag.set(250, 385);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.keys.justPressed.ESCAPE)
			FlxG.switchState(new TitleScreenState());

		if (FlxG.keys.justPressed.ONE)
			openSubState(new CutsceneSubState());

		var controls:Array<Bool> = [
			FlxG.keys.pressed.LEFT,
			FlxG.keys.pressed.RIGHT,
			FlxG.keys.pressed.UP,
			FlxG.keys.pressed.DOWN
		];
		for (i in 0...controls.length)
			if (controls[i])
				switch (i)
				{
					case 0:
						player.acceleration.x -= 25;
						player.facingLeft = true;
						player.evaluateOffset(player.getAnim());
					case 1:
						player.acceleration.x += 25;
						player.facingLeft = false;
						player.evaluateOffset(player.getAnim());
					case 2:
						player.y -= 5;
					case 3:
						player.y += 5;
				}

		if (!controls[0] && !controls[1])
			player.acceleration.x = 0;

		zoomMAIN = FlxG.keys.pressed.SPACE ? 0.2 : 1;

		var lastBeat:Int = MusicManager.currentBeat;
		MusicManager.updatePosition();
		if (MusicManager.currentBeat != lastBeat && lastBeat % 4 == 0)
			player.idleDance();

		targetObject.setPosition(Std.int(player.x + player.width / 2 + (player.facingLeft ? -175 : 175)).clampInt(0, lvl.width * lvl.tileWidth),
			player.y + player.height / 2);
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
