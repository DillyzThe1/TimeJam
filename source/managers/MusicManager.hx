package managers;

import flixel.FlxG;

class MusicManager
{
	public static var songTitle:String = "";
	public static var songBpm:Int = 100;
	public static var songLength:Float = 0;

	public static var beatLength:Float = (60 / songBpm) * 1000;
	public static var stepLength:Float = beatLength / 4;

	public static function play(song:String, bpm:Int, volume:Float)
	{
		// why is vsc formatting this wrongly
		if (FlxG.sound.music != null && songTitle == song && FlxG.sound.music.playing)
			return;
		FlxG.sound.playMusic(Paths.music(song), volume);
		songTitle = song;
		songBpm = bpm;
		songLength = FlxG.sound.music.length;

		beatLength = (60 / songBpm) * 1000;
		stepLength = beatLength / 4;

		trace("Playing " + songTitle + "!");
	}

	public static function forceStop()
	{
		if (FlxG.sound.music == null)
			return;
		FlxG.sound.music.stop();
	}

	public static var currentStep:Int = -1;
	public static var currentBeat:Int = -1;

	public static function updatePosition()
	{
		if (FlxG.sound.music == null)
		{
			currentStep = currentBeat = -1;
			return;
		}

		currentStep = Math.floor(FlxG.sound.music.time / stepLength);
		currentBeat = Math.floor(currentStep / 4);
	}

	public static function exists()
	{
		return FlxG.sound.music != null && FlxG.sound.music.playing;
	}
}
