package managers;

#if discord_presence
import discord_rpc.DiscordRpc;
import gamestates.menus.MainMenuState;
import haxe.Exception;
import haxe.Timer;
import lime.app.Application;

class DiscordManager
{
	public static var startTimestamp:Int = 0;

	@:allow(Main)
	private static function initClient()
	{
		trace('Discord client setting up...');
		startTimestamp = Std.int(Date.now().getTime() / 1000);
		DiscordRpc.start({
			// https://discord.com/developers/applications/1073675707902853193/rich-presence/visualizer
			clientID: '1073675707902853193',
			onReady: function()
			{
				trace('Discord client ready to use!');
				setStatus(null, 'Title Screen');
			},
			onDisconnected: function(disCode:Int, disMessage:String)
			{
				trace('Discord disconnection code $disCode has occured under $disMessage');
			},
			onError: function(disCode:Int, disMessage:String)
			{
				trace('Discord error num $disCode has occured under $disMessage.');
			},
		});

		Application.current.onExit.add(function(exitCode:Int)
		{
			DiscordRpc.shutdown();
		});

		tryProcess();
	}

	private static function tryProcess()
	{
		Timer.delay(function()
		{
			DiscordRpc.process();
			tryProcess();
		}, 2000);
	}

	public static function setStatus(state:Null<String>, menuName:Null<String>)
	{
		DiscordRpc.presence({
			state: state,
			details: menuName,
			startTimestamp: startTimestamp,
			largeImageKey: 'logo',
			largeImageText: Main.getVersionName(),
			#if debug
			smallImageKey: 'flixel', smallImageText: 'Playing a dev build.',
			#else
			smallImageKey: '', smallImageText: '',
			#end
		});
	}
}
#end
