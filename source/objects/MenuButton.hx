package objects;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;

enum ButtonTypes
{
	PLAY;
	OPTIONS;
	ISSUES;
	QUIT;
}

class MenuButton extends FlxSprite
{
	var type:ButtonTypes;

	public var enabled:Bool = true;

	public var hitbox:FlxSprite;
	public var hovering:Bool = false;
	public var forcePosition:Bool = false;

	public function new(x:Float, y:Float, buttonType:ButtonTypes)
	{
		super(x, y);

		type = buttonType;
		this.frames = Paths.sparrowv2("menu buttons");
		var smallButton:Bool = false;
		var prefix:String = "";

		switch (buttonType)
		{
			case PLAY:
				prefix = "play";
			case OPTIONS:
				prefix = "options";
				enabled = false;
			case ISSUES:
				prefix = "issues";
				smallButton = true;
			case QUIT:
				prefix = "quit";
				smallButton = true;

				#if !sys
				enabled = false;
				#end
		}
		this.animation.addByPrefix("static", prefix + " static0", 24);
		this.animation.addByPrefix("hover", prefix + " hover animated0", 24, false);
		this.animation.addByPrefix("disabled", prefix + " disabled0", 24);

		this.animation.play("static");
		this.centerOffsets();

		hitbox = new FlxSprite(0, 0).makeGraphic(smallButton ? 200 : 400, smallButton ? 50 : 75, FlxColor.RED);
		// hitbox.alpha = #if debug 0.25 #else 0 #end;
		hitbox.visible = false;
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		hitbox.x = x + this.width / 2 - hitbox.width / 2;
		hitbox.y = y + this.height / 2 - hitbox.height / 2;

		if (!enabled)
		{
			if (this.animation.curAnim.name != "disabled")
			{
				this.animation.play("disabled");
				this.centerOffsets();
			}
			hovering = false;
			return;
		}

		if (FlxG.mouse.overlaps(hitbox) && this.animation.curAnim.name != "hover")
		{
			this.animation.play("hover");
			this.centerOffsets();
			hovering = true;
		}
		else if (!FlxG.mouse.overlaps(hitbox) && this.animation.curAnim.name != "static")
		{
			this.animation.play("static");
			this.centerOffsets();
			hovering = false;
		}
	}

	public function getOff_X()
	{
		switch (type)
		{
			case ISSUES:
				return -100;
			case QUIT:
				return 100;
			default:
				return 0;
		}
	}

	public function getOff_Y()
	{
		switch (type)
		{
			case OPTIONS:
				return 100;
			case ISSUES | QUIT:
				return 190;
			default:
				return 0;
		}
	}

	public function getType()
	{
		return type;
	}
}
