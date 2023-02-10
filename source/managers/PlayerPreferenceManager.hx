package managers;

import flixel.FlxG;
import flixel.util.FlxSave;

class PlayerPreferenceManager
{
	private static var playerPrefs:FlxSave;

	public static var antialiasing:Bool = false;

	public static function save()
	{
		if (playerPrefs == null)
		{
			trace('Failed to save preferences to disk!');
			load();
			return false;
		}

		playerPrefs.data.antialiasing = antialiasing;
		playerPrefs.data.hasSaved = true;

		if (!playerPrefs.flush())
		{
			trace('Failed to save preferences to disk!');
			return false;
		}
		else
			trace('Saved preferences to disk!');
		return true;
	}

	public static function load()
	{
		if (playerPrefs != null)
			playerPrefs.destroy();
		playerPrefs = new FlxSave();
		playerPrefs.bind("TimeJam_playerPrefs");

		if (playerPrefs.data == null || playerPrefs.data.hasSaved == null || !playerPrefs.data.hasSaved)
		{
			trace('Failed to load preferences from disk!');
			save();
			return false;
		}

		antialiasing = playerPrefs.data.antialiasing;

		trace('Loaded preferences from disk!');
		return true;
	}
}
