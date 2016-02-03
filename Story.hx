package ;

import openfl.display.Sprite;
import openfl.text.TextField;
import openfl.Assets;

class Story extends Sprite
{
	var storyText:String;
	var commands:Array<Command> = [];
	var textField:TextField = new TextField();

	function new() {
		super();

		{ // Get story
			var reg:EReg = new EReg("\\(.*\\)", "ig");
			storyText = Assets.getText("assets/story/main.txt");

			commands.push({ type: "label", params: "main", startPos: 0, len: 0 });

			reg.map(
					storyText, function(r) {
						var commandString:String = reg.matched(0);
						commandString = commandString.substring(1, commandString.length - 1);
						if (commandString.charAt(1) == "(") return commandString;
						if (commandString.charAt(1) == "/" && commandString.charAt(2) == "/")
							return commandString;

						var commandSubStrings:Array<String> = commandString.split(" ");

						var c:Command = {};
						c.type = commandSubStrings.shift();
						c.params = commandSubStrings.join(" ");
						c.startPos = reg.matchedPos().pos;
						c.len = reg.matchedPos().len;
						commands.push(c);

						return commandString;
					});

			// for (c in commands) trace(c);
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
	?type:String,
	?params:String,
	?startPos:Int,
	?len:Int
}
