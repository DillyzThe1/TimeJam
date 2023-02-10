package managers;

import flixel.util.FlxSave;

class PlayerDataManager
{
	private static var saveIndex:Int = 0;
	private static var playerData:FlxSave;

	public static var hasDoubleJump:Bool = false;

	public static function save()
	{
		if (playerData == null)
		{
			trace('Failed to save data to disk!');
			load(saveIndex);
			return false;
		}

		playerData.data.hasDoubleJump = hasDoubleJump;

		if (!playerData.flush())
		{
			trace('Failed to save data to disk!');
			return false;
		}
		else
			trace('Saved data to disk!');
		return true;
	}

	public static function load(index:Int)
	{
		saveIndex = index;
		if (playerData != null)
			playerData.destroy();
		playerData = new FlxSave();
		playerData.bind('TimeJam_saveData_INSTANCE_$saveIndex');

		if (playerData.data == null || playerData.data.hasSaved == null || !playerData.data.hasSaved)
		{
			trace('Failed to load data from disk!');
			save();
			return false;
		}

		hasDoubleJump = playerData.data.hasDoubleJump;

		trace('Loaded data from disk!');
		return true;
	}
}
