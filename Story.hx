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

		reg.map(
			storyText, function(r) {
				var commandString:String = reg.matched(0);
				if (commandString.charAt(1) == "(") return commandString;
				if (commandString.charAt(1) == "/" && commandString.charAt(2) == "/")
					return commandString;

				var commandSubStrings:Array<String> = commandString.split(" ");
				commandSubStrings.shift();

				var c:Command = {};
				c.type = commandSubStrings[0];
				commandSubStrings.shift();
				c.params = commandSubStrings;
				// c.startPos = reg.matchedPos();

				return commandString;
			});
		// for (i in 0...cs.length)
		// {
		// 	if (cs[i].charAt(i+1) == "(") continue;
		// 	if (cs[i].charAt(i+1) == "/" && cs[i].charAt(i+2) == "/") continue;

		// 	trace(cs[i]);
		// 	var clets:Array<String> = [];
		// 	var c:Command = {};
		// }

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
	?type:String,
	?params:Array<String>,
	?startPos:Int,
	?len:Int
}
