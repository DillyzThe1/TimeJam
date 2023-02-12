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
	var enabled:Bool = true;

	public var hitbox:FlxSprite;

	public function new(x:Float, y:Float, buttonType:ButtonTypes)
	{
		super(x, y);

		type = buttonType;
		this.frames = Paths.sparrowv2("menu buttons");
		var smallButton:Bool = false;

		switch buttonType
		{
			case PLAY:
				this.animation.addByPrefix("static", "play static", 24);
				this.animation.addByPrefix("hover", "play hover animated", 24, false);
			case OPTIONS:
				this.animation.addByPrefix("static", "options static", 24);
				this.animation.addByPrefix("hover", "options hover animated", 24, false);
			case ISSUES:
				this.animation.addByPrefix("static", "issues static", 24);
				this.animation.addByPrefix("hover", "issues hover animated", 24, false);
				smallButton = true;
			case QUIT:
				this.animation.addByPrefix("static", "quit static", 24);
				this.animation.addByPrefix("hover", "quit hover animated", 24, false);
				smallButton = true;
		}

		this.animation.play("static");
		this.centerOffsets();

		hitbox = new FlxSprite(0, 0).makeGraphic(smallButton ? 200 : 400, smallButton ? 50 : 75, FlxColor.RED);
		hitbox.alpha = #if debug 0.25 #else 0 #end;
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		hitbox.x = x + this.width / 2 - hitbox.width / 2;
		hitbox.y = y + this.height / 2 - hitbox.height / 2;

		if (FlxG.mouse.overlaps(hitbox) && this.animation.curAnim.name == "static")
		{
			this.animation.play("hover");
			this.centerOffsets();
		}
		else if (!FlxG.mouse.overlaps(hitbox) && this.animation.curAnim.name == "hover")
		{
			this.animation.play("static");
			this.centerOffsets();
		}
	}
}
