package ;

import openfl.display.Sprite;
import openfl.Assets;

class Story extends Sprite
{
	var storyText:String;
	var commands:Array<Command> = [];

	function new() {
		super();

		var reg:EReg = new EReg("\\(.*\\)", "ig");
		storyText = Assets.getText("assets/story/main.txt");

		commands.push({ type: "label", params: ["main"], startPos: 0, len: 0 });
		var cs:Array<String> = reg.split(storyText);

		for (i in 0...cs.length)
		{
			// if (
			// var c:Command
		}

		Sys.exit(0);
	}

	function update():Void
	{
		// Maybe I'll use regex. >_>
		var skipChars:Int = 0;
		for (i in 0...storyText.length) {
			var c:String = storyText.charAt(i);

			if (skipChars > 0) {
				skipChars--;
			} else if (c == "/") {
				skipChars = 1;
			} else if (c == "(") {
				// skipChars = exec(i);
			}
		}
	}
}

typedef Command = 
{
	var type:String;
	var params:Array<String>;
	var startPos:Int;
	var len:Int;
}
