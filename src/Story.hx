package ;

import openfl.display.Sprite;
import openfl.text.TextField;
import openfl.events.Event;
import openfl.Assets;

class Story extends Sprite
{
	var storyText:String;
	var commands:Array<Command>;
	var textField:TextField;

	function new() {
		super();
		addEventListener(Event.ADDED_TO_STAGE, init);
	}

	function init(e:Event):Void
	{
		removeEventListener(Event.ADDED_TO_STAGE, init);

		{ // Get story
			var reg:EReg = new EReg("\\(.*\\)", "ig");
			storyText = Assets.getText("assets/story/main.txt");

			commands = [{ type: "label", params: "main", startPos: 0, len: 0 }];

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

		{ // Setup UI
			var botPadding:Int = 30;
			var sidePadding:Int = 30;
			textField = new TextField();
			textField.width = stage.stageWidth - (sidePadding * 2);
			textField.height = stage.stageHeight * 0.25;
			textField.x = sidePadding;
			textField.y = stage.stageHeight - textField.height - botPadding;
			textField.text = "test";
			textField.border = true;
			addChild(textField);
		}
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
