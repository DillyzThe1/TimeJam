<p align="center">
  <img align="center" src="assets/images/glowy logo.png" width=500>
</p>
<p align="center">
  An indie game made by <a href="https://www.github.com/DillyzThe1">DillyzThe1</a> & <a href="https://www.github.com/Impostor5875">Impostor5875</a> in just 5 days.
</p>
<p align="center">
  Originally made for the February 2023's <a href="https://itch.io/jam/haxejam-2023-winter-jam">Winter Haxe Jam</a>.
</p>


# TimeJam
A game made for HaxeJam (Feb 2023) where you must correctly configure the forbidden machine to progress further.<br>
Jumping from place to place, you'll be fighting your way through enemies to collect a few archaic crystals, which may power the machine.<br>
If you get the machine wrong or fail to get sufficent power, you must restart in a slightly altered timeline, losing your progress while gaining a shortcut.<br>

# How To Play
Download the game [[here]](../../releases/latest/) for your platform and run it.<br>
<i>Note: Web builds are available [[here]](https://dillyzthe1.itch.io/)!</i><br>
<br>
After you've launched the game, you'll be greeted with this screen:<br>
![TimeJam Title Screen](art/title-screen.png)<br>
Hit enter and continue over the play button, in which the game will start.<br>
You must move all the way to the right to get some dialogue, and then you'll be greeted by someone to guide you.

# Dialogue Editing

# Level Editing
To edit the level's tiles and metadata, you'll need to download & install [[Tiled]](https://www.mapeditor.org/).<br>
After that, navigate to [`[assets/tm/]`](https://github.com/DillyzThe1/TimeJam/tree/main/assets/tm) in your installation of the game (or source code).<br>
Double click the TMX file to load it into the editor, and you should see everything pop up.<br>
![The folder with the TMX file.](art/folder.png)<br>
![The editor of said file.](art/tutorial%20editor.png)<br>
Here, you can explore all the properties and values I've left to work with eachother. Have fun!<br>
No documentation comes until high demand.

# Compiling
*Note: IF you publish a public modification to this game, you <b>MUST</b> open source it on github & add a link to the source code.*<br>
*Also Note: Pull requests of a full-on mod/engine will likely <u><b>not</b> be added</u>. Open an issue under the enhancement tag.*<br>
*Also ALSO Note: If you're just wanting to edit levels or dialogue, use the tutorials above. They do not require recompiling.*<br>
<br>
Download Haxe [4.2.5 64-bit](https://haxe.org/download/file/4.2.5/haxe-4.2.5-win64.exe/) or [4.2.5 32-bit](https://haxe.org/download/file/4.2.5/haxe-4.2.5-win.exe/).
<br>
Download the [source code of this repository](../..//archive/refs/heads/main.zip) or the [source code of the latest release](../../releases/latest).<br>
*Note: You can also fork the repository and clone with Github Desktop!*<br>
<br>
Extract the zip file and open the folder.<br>
You'll need the following libraries:
```batch
haxelib install lime
haxelib install openfl
haxelib install flixel
haxelib install flixel-addons
haxelib install flxanimate
haxelib git discord_rpc https://github.com/Aidan63/linc_discord-rpc
```
If discord presence is causing an error for you, make sure to remove [[this line]](https://github.com/DillyzThe1/TimeJam/blob/main/Project.xml#L53) before compiling.<br>
Anyway, after you've done that just run [`[build.bat]`](https://github.com/DillyzThe1/TimeJam/blob/main/build.bat) from the source folder and look at the instructions.<br>
<br>
*Note: Visual Studio Code is recommended for programming new features. Please install the appropiate plugins for haxeflixel in VSC.*<br>
