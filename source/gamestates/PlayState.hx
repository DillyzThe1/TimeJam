package gamestates;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.math.FlxPoint;
import flixel.system.FlxSound;
import flixel.util.FlxColor;
import flixel.util.FlxDirection;
import flixel.util.FlxTimer;
import gamesubstates.CutsceneSubState;
import managers.MusicManager;
import managers.PlayerDataManager;
import objects.ArcahicCrystal.ArchaicCrystal;
import objects.DialogueArea;
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

	var crystal_pickupSfx:Array<FlxSound>;
	var crystal_swooshSfx:FlxSound;

	public var nextCrystal:Int = -1;

	public static var seenOpeningCutscene:Bool = false;

	// a bunch of flags a level can use to determine what has and has not happened
	public static var flags:Array<String> = [];

	private var camDIALOGUE:FlxCamera;

	override public function create()
	{
		super.create();

		camDIALOGUE = new FlxCamera();
		camDIALOGUE.bgColor.alpha = 0;
		FlxG.cameras.add(camDIALOGUE, false);

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
		lvl.objGroup.add(player);
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

		crystal_pickupSfx = [
			new FlxSound().loadEmbedded(Paths.sound("crystal0")), new FlxSound().loadEmbedded(Paths.sound("crystal1")),
			new FlxSound().loadEmbedded(Paths.sound("crystal2")), new FlxSound().loadEmbedded(Paths.sound("crystal3"))
		];
		crystal_swooshSfx = new FlxSound().loadEmbedded(Paths.sound("swoosh low"));

		switch (levelName.toLowerCase())
		{
			case "tutorial":
				if (!seenOpeningCutscene)
				{
					player.inputDisabled = true;
					camMAIN.alpha = camHUD.alpha = 0;

					var timeeerr:FlxTimer = new FlxTimer();

					timeeerr.start(1.5, function(t:FlxTimer)
					{
						CutsceneSubState.nextCutscene = "cutscene 1";
						CutsceneSubState.nextOffset.put();
						CutsceneSubState.nextOffset = FlxPoint.get(-800, -500);
						openSubState(new CutsceneSubState());

						timeeerr.destroy();
					});
				}
				else if (ArchaicCrystal.lastCrystal() == 2)
				{
					player.inputDisabled = true;
					camMAIN.alpha = camHUD.alpha = 0;
					startDialogue("tutorial_end_demo", function()
					{
						FlxG.switchState(new TitleScreenState());
					});
				}
				else
				{
					player.inputDisabled = true;
					camMAIN.zoom = 7.5;
					camHUD.fade(FlxColor.BLACK, 1, true, function()
					{
						switch (ArchaicCrystal.lastCrystal())
						{
							case 0:
								startDialogue("doublejump_notice");
							default:
								player.inputDisabled = false;
						}
					});
				}
			default:
				camMAIN.zoom = 7.5;
				camHUD.fade(FlxColor.BLACK, 1, true);
		}
	}

	function startDialogue(dialogueName:String, ?onComplete:() -> Void)
	{
		player.inputDisabled = true;

		var onCompleteToUse:() -> Void;

		if (onComplete == null)
			onCompleteToUse = function()
			{
				player.inputDisabled = false;
			}
		else
			onCompleteToUse = onComplete;

		var dialogue:DialogueArea = new DialogueArea(dialogueName, onCompleteToUse);
		dialogue.cameras = [camDIALOGUE];
		add(dialogue);
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
			FlxG.keys.pressed.DOWN,
			FlxG.keys.justPressed.SPACE
		];

		if (player.inputDisabled)
			for (i in 0...controls.length)
				controls[i] = false;

		if (controls[1])
		{
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
		}
		else if (controls[0])
		{
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
		}
		if (controls[2] || controls[4])
		{
			var causedByTime:Bool = (totalTime - lastTimeOnGround) < 0.15;
			if (causedByTime || player.mayDoubleJump)
			{
				if (!causedByTime)
					player.mayDoubleJump = false;
				player.jump();
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

		var lastBeat:Int = MusicManager.currentBeat;
		MusicManager.updatePosition();
		if (MusicManager.currentBeat != lastBeat && lastBeat % 4 == 0)
			player.idleDance();

		targetObject.setPosition((player.x
			+ player.width / 2
			+ (player.facingLeft ? (controls[0] ? -250 : -175) : (controls[1] ? 375 : 300))).clampFloat(FlxG.worldBounds.x + FlxG.width / 2,
				FlxG.worldBounds.width - FlxG.width / 2),
			(player.y + player.height / 2).clampFloat(FlxG.worldBounds.y + FlxG.height / 2, FlxG.worldBounds.height - FlxG.height / 2));

		var oldSemi:Bool = lvl.lastWasSemi;
		lvl.checkCollisionAlt(player, controls[3]);
		FlxG.collide(leftBound, player);
		FlxG.collide(rightBound, player);

		if (oldSemi && controls[3])
			player.playAnim("jump", true, 7);

		player.onGround = player.isTouching(FlxDirection.DOWN);
		if (player.onGround)
		{
			lastTimeOnGround = totalTime;
			player.mayDoubleJump = PlayerDataManager.hasDoubleJump
				&& (levelName != "Tutorial" || ArchaicCrystal.crystalsCollected.contains(0));
		}

		if (nextCrystal == -1)
			for (crystal in ArchaicCrystal.allCrystals)
				if (FlxG.overlap(crystal, player))
				{
					nextCrystal = crystal.curIndex;

					var sfx:FlxSound = crystal_pickupSfx[FlxG.random.int(0, crystal_pickupSfx.length - 1)];
					sfx.volume = 0.5 * FlxG.sound.volume;
					sfx.play(true, 0.001);
					crystal_swooshSfx.volume = FlxG.sound.volume;
					crystal_swooshSfx.play();

					switch (levelName.toLowerCase())
					{
						case "tutorial":
							switch (crystal.curIndex)
							{
								case 0:
									PlayerDataManager.hasDoubleJump = true;
									PlayerDataManager.save();

									startDialogue("pngintro");
							}
					}

					crystal.destroy();
				}

		if (player.isTouching(FlxDirection.LEFT) || player.isTouching(FlxDirection.RIGHT))
			player.acceleration.x = 0;
		if (player.isTouching(FlxDirection.UP) && player.acceleration.y > 0)
		{
			player.acceleration.y = 0;
			player.velocity.y = player.maxVelocity.y * 0.15;
			player.playAnim("jump hit", true);
		}

		if (lvl.timelineReflector != null)
		{
			if (FlxG.overlap(lvl.timelineReflector, player) && !player.inputDisabled && nextCrystal != -1)
			{
				FlxG.sound.play(Paths.sound("crystal_insert")).persist = true;
				player.inputDisabled = true;
				ArchaicCrystal.addCrystal(nextCrystal);
				FlxG.switchState(new PlayState());
			}
		}

		if (lvl.wizard != null
			&& levelName.toLowerCase() == "tutorial"
			&& ArchaicCrystal.lastCrystal() == 1
			&& !flags.contains("crystal1_wizard_dialogue")
			&& player.getGraphicMidpoint().getDist(lvl.wizard.getGraphicMidpoint()) < 350)
		{
			flags.push("crystal1_wizard_dialogue");
			startDialogue("wizard_crystal1");
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
		{
			MusicManager.forceStop();
			FlxG.switchState(new TitleScreenState());
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
				seenOpeningCutscene = true;
				camHUD.flash(FlxColor.BLACK);
				camMAIN.alpha = camHUD.alpha = 1;
				player.inputDisabled = false;

				switch (levelName.toLowerCase())
				{
					case "tutorial":
						MusicManager.play("lvl_overworld", 140, 0.4);
				}
		}
		super.closeSubState();
	}
}
