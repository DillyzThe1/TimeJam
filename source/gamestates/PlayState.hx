package gamestates;

import objects.TMXLevel;

class PlayState extends TJState
{
	public var lvl:TMXLevel;

	override public function create()
	{
		super.create();

		lvl = new TMXLevel(Paths.tmx("you know who else"));

		add(lvl.bgGroup);
		add(lvl.sprGroup);
		add(lvl.objGroup);
		add(lvl.fgGroup);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}
